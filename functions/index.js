// ══════════════════════════════════════════════════════════════
//  SAVY – CLOUD FUNCTION: sendNotificationOnCreate
//  functions/index.js
//
//  Trigger: Firestore onCreate  →  notifications/{notificationId}
//  Action : reads the user's FCM token and sends an FCM push.
//
//  Deploy:
//    cd functions && npm install
//    firebase deploy --only functions
// ══════════════════════════════════════════════════════════════

const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const { initializeApp }     = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const { getMessaging }      = require('firebase-admin/messaging');
const { logger }            = require('firebase-functions');

initializeApp();

// ─────────────────────────────────────────────────────────────
//  sendNotificationOnCreate
//  Triggered every time a document is written to /notifications
// ─────────────────────────────────────────────────────────────
exports.sendNotificationOnCreate = onDocumentCreated(
  {
    document: 'notifications/{notificationId}',
    region: 'us-central1', // change to match your Firebase project region
  },
  async (event) => {
    const snap = event.data;
    if (!snap) {
      logger.warn('No data in event snapshot — skipping');
      return null;
    }

    const notifData  = snap.data();
    const notifRef   = snap.ref;
    const { userId, title, body, type, data: extra = {} } = notifData;

    // Skip FCM push when the Flutter app set sent=true (history-only mode,
    // e.g. user disabled security alert push notifications).
    if (notifData.sent === true) {
      logger.info(`Notification ${snap.id} has sent=true — skipping FCM push (history-only)`);
      return null;
    }

    if (!userId || !title || !body) {
      logger.warn('Missing required fields (userId/title/body) — skipping', notifData);
      await notifRef.update({ error: 'missing_fields', processedAt: FieldValue.serverTimestamp() });
      return null;
    }

    // 1. Fetch the target user's FCM token + language preference
    const db = getFirestore();
    const userSnap = await db.collection('users').doc(userId).get();

    if (!userSnap.exists) {
      logger.warn(`User document not found: ${userId}`);
      await notifRef.update({ error: 'user_not_found', processedAt: FieldValue.serverTimestamp() });
      return null;
    }

    const fcmToken = userSnap.data()?.fcmToken;
    if (!fcmToken) {
      logger.warn(`No FCM token for user ${userId} — user may not have granted permission yet`);
      await notifRef.update({ error: 'no_fcm_token', processedAt: FieldValue.serverTimestamp() });
      return null;
    }

    // 2. Pick the right language for the push notification title/body.
    //    The Flutter app saves languageCode to Firestore when the user
    //    changes their language (LanguageProvider.setLocale).
    const langCode = userSnap.data()?.languageCode ?? 'en';
    let pushTitle, pushBody;
    if (langCode === 'fr') {
      pushTitle = notifData.titleFr || notifData.title || title;
      pushBody  = notifData.bodyFr  || notifData.body  || body;
    } else if (langCode === 'ar') {
      pushTitle = notifData.titleAr || notifData.title || title;
      pushBody  = notifData.bodyAr  || notifData.body  || body;
    } else {
      pushTitle = notifData.titleEn || notifData.title || title;
      pushBody  = notifData.bodyEn  || notifData.body  || body;
    }
    logger.info(`Sending FCM in lang=${langCode} to user ${userId}`);

    // 3. Build the FCM message
    const dataPayload = {
      type: type ?? 'general',
      ...Object.fromEntries(
        Object.entries(extra).map(([k, v]) => [k, String(v)])
      ),
    };

    const message = {
      token: fcmToken,

      notification: {
        title: pushTitle,
        body:  pushBody,
      },

      // Android-specific overrides
      android: {
        priority: 'high',
        notification: {
          channelId: 'savy_channel', // must match the channel created in Flutter
          priority: 'max',
          defaultSound: true,
          defaultVibrateTimings: true,
          color: '#3EFFA8', // Savy brand green
          // Notification icon — put a white monochrome ic_notification.png
          // in android/app/src/main/res/drawable/ and reference it here:
          // icon: 'ic_notification',
        },
      },

      // iOS (APNs) overrides
      apns: {
        headers: {
          'apns-priority': '10', // 10 = immediate delivery
        },
        payload: {
          aps: {
            alert: { title, body },
            badge: 1,
            sound: 'default',
            'content-available': 1,
          },
        },
      },

      data: dataPayload,
    };

    // 4. Send via FCM
    try {
      const response = await getMessaging().send(message);
      logger.info(`FCM sent successfully: ${response} | notifId=${snap.id}`);

      // Mark as sent so you can audit from the Firebase Console
      await notifRef.update({
        sent: true,
        fcmMessageId: response,
        processedAt: FieldValue.serverTimestamp(),
      });
    } catch (err) {
      logger.error('FCM send failed:', err.message, err.code);

      // Handle stale / invalid tokens gracefully
      if (
        err.code === 'messaging/registration-token-not-registered' ||
        err.code === 'messaging/invalid-registration-token'
      ) {
        // Delete the stale token so the app re-registers on next launch
        await db.collection('users').doc(userId).update({ fcmToken: FieldValue.delete() });
        logger.info(`Stale FCM token removed for user ${userId}`);
      }

      await notifRef.update({
        sent: false,
        error: err.message,
        errorCode: err.code ?? 'unknown',
        processedAt: FieldValue.serverTimestamp(),
      });
    }

    return null;
  }
);

// ─────────────────────────────────────────────────────────────
//  (Optional) Daily cron: check goal deadlines and fire reminders
//  Requires firebase-functions v2 scheduler + Cloud Scheduler API
// ─────────────────────────────────────────────────────────────
const { onSchedule } = require('firebase-functions/v2/scheduler');

exports.dailyGoalDeadlineCheck = onSchedule(
  {
    schedule: 'every day 09:00',   // fires at 09:00 UTC daily
    timeZone: 'Africa/Tunis',      // ← adjust to your users' timezone
    region: 'us-central1',
  },
  async (_event) => {
    const db = getFirestore();
    const now = new Date();
    const in3Days = new Date(now.getTime() + 3 * 24 * 60 * 60 * 1000);

    // Find all objectives with deadline within the next 3 days
    // that are not yet complete (currentAmount < targetAmount)
    // across ALL users (collection group query)
    const snapshot = await db
      .collectionGroup('objectives')
      .where('deadlineTimestamp', '>=', now)
      .where('deadlineTimestamp', '<=', in3Days)
      .get();

    if (snapshot.empty) {
      logger.info('No upcoming deadlines found');
      return;
    }

    const batch = [];

    for (const doc of snapshot.docs) {
      const obj      = doc.data();
      const uid      = doc.ref.parent.parent?.id; // users/{uid}/objectives/{id}
      if (!uid) continue;

      const current  = obj.currentAmount ?? 0;
      const target   = obj.targetAmount ?? 0;
      if (current >= target) continue; // already completed

      const deadlineMs = obj.deadlineTimestamp?.toMillis?.() ?? 0;
      const daysLeft   = Math.ceil((deadlineMs - now.getTime()) / (1000 * 60 * 60 * 24));

      const rem      = (target - current).toFixed(2);
      const daysStr  = String(daysLeft);
      const titleEn  = `⏰ Goal Reminder — ${obj.name}`;
      const bodyEn   = `${daysLeft} day${daysLeft !== 1 ? 's' : ''} left for "${obj.name}". ${rem} TND still needed.`;
      const titleFr  = `⏰ Rappel d'objectif — ${obj.name}`;
      const bodyFr   = `${daysLeft} jour${daysLeft !== 1 ? 's' : ''} restant${daysLeft !== 1 ? 's' : ''} pour "${obj.name}". Il manque encore ${rem} TND.`;
      const titleAr  = `⏰ تذكير بالهدف — ${obj.name}`;
      const bodyAr   = `متبقّي ${daysLeft} يوم لـ "${obj.name}". لا يزال ينقصك ${rem} دينار.`;
      batch.push(
        db.collection('notifications').add({
          userId: uid,
          title: titleEn, titleEn, titleFr, titleAr,
          body:  bodyEn,  bodyEn,  bodyFr,  bodyAr,
          type: 'goal_reminder',
          data: { goalId: doc.id, daysLeft: daysStr },
          createdAt: FieldValue.serverTimestamp(),
          read: false,
          sent: false,
        })
      );
    }

    await Promise.all(batch);
    logger.info(`Queued ${batch.length} goal reminder notification(s)`);
  }
);
