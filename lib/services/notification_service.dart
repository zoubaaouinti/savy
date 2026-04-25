// ══════════════════════════════════════════════════════════════
//  SAVY – NOTIFICATION SERVICE
//  lib/services/notification_service.dart
//
//  Architecture:
//  • FCM receives push from Cloud Function (triggered by Firestore)
//  • Foreground → flutter_local_notifications shows a heads-up banner
//  • Background/Terminated → FCM system tray; tap opens app via navigatorKey
//  • Token stored under users/{uid}.fcmToken in Firestore
// ══════════════════════════════════════════════════════════════

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────
//  TOP-LEVEL background handler (REQUIRED by FCM — must NOT be
//  inside a class or it will silently fail on Android).
// ─────────────────────────────────────────────────────────────
@pragma('vm:entry-point')
Future<void> firebaseBackgroundMessageHandler(RemoteMessage message) async {
  // Firebase is already initialised by the isolate before this runs.
  // Do lightweight work only — no UI, no Provider access.
  debugPrint('[FCM-BG] ${message.messageId} | type=${message.data['type']}');
}

// ─────────────────────────────────────────────────────────────
//  Android notification channel (must match AndroidManifest.xml
//  meta-data "com.google.firebase.messaging.default_notification_channel_id")
// ─────────────────────────────────────────────────────────────
const AndroidNotificationChannel _savyChannel = AndroidNotificationChannel(
  'savy_channel',
  'Savy Notifications',
  description: 'Budget alerts, goal reminders and saving suggestions',
  importance: Importance.max,
  playSound: true,
  enableVibration: true,
);

class NotificationService {
  NotificationService._();

  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  /// Wire this key into MaterialApp.navigatorKey so notification taps
  /// can push routes even when launched from terminated state.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // ── Dedup: avoid re-sending the same alert within one session ─
  static final Set<String> _sentKeys = {};

  // ────────────────────────────────────────────────────────────
  //  INIT — call once from main() AFTER Firebase.initializeApp()
  // ────────────────────────────────────────────────────────────
  static Future<void> init() async {
    // 1. Create the Android channel (no-op on iOS)
    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_savyChannel);

    // 2. Initialise flutter_local_notifications
    const androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false, // we ask via FCM below
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _local.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    // 3. Request permissions (iOS prompt; Android 13+ prompt)
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('[FCM] Permission denied — notifications disabled');
      return;
    }

    // 4. Show FCM notifications in foreground on iOS too
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 5. Register the background handler (top-level function above)
    FirebaseMessaging.onBackgroundMessage(firebaseBackgroundMessageHandler);

    // 6. Foreground messages → show local heads-up banner
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // 7. App opened from BACKGROUND via notification tap
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageNavigation);

    // 8. App opened from TERMINATED state via notification tap
    final initial = await _fcm.getInitialMessage();
    if (initial != null) _handleMessageNavigation(initial);

    // 9. Get & store FCM token for the current user (if already logged in)
    await _refreshAndSaveToken();

    // 10. Keep token fresh on rotation
    _fcm.onTokenRefresh.listen(_saveToken);
  }

  // ────────────────────────────────────────────────────────────
  //  Call this right after a successful login / sign-up so the
  //  token is stored even if the user was not logged in during init().
  // ────────────────────────────────────────────────────────────
  static Future<void> saveTokenAfterLogin() => _refreshAndSaveToken();

  // ────────────────────────────────────────────────────────────
  //  INTERNAL TOKEN HELPERS
  // ────────────────────────────────────────────────────────────
  static Future<void> _refreshAndSaveToken() async {
    final token = await _fcm.getToken();
    if (token != null) await _saveToken(token);
  }

  static Future<void> _saveToken(String token) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set(
        {
          'fcmToken': token,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
          'platform': _platform(),
        },
        SetOptions(merge: true),
      );
      debugPrint('[FCM] Token saved for $uid');
    } catch (e) {
      debugPrint('[FCM] Token save error: $e');
    }
  }

  static String _platform() {
    // Used by Cloud Function to set correct APNs/Android priority
    try {
      return const bool.fromEnvironment('dart.vm.product') ? 'prod' : 'debug';
    } catch (_) {
      return 'unknown';
    }
  }

  // ────────────────────────────────────────────────────────────
  //  FOREGROUND: show a local heads-up notification
  // ────────────────────────────────────────────────────────────
  static void _onForegroundMessage(RemoteMessage message) {
    final n = message.notification;
    if (n == null) return;

    _local.show(
      message.hashCode,
      n.title ?? 'Savy',
      n.body ?? '',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _savyChannel.id,
          _savyChannel.name,
          channelDescription: _savyChannel.description,
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          // Colour matches Savy brand green
          color: const Color(0xFF3EFFA8),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      // Payload carries the notification type for tap navigation
      payload: message.data['type'],
    );
  }

  // ────────────────────────────────────────────────────────────
  //  TAP HANDLERS
  // ────────────────────────────────────────────────────────────

  // Tapped while app is open (flutter_local_notifications callback)
  static void _onLocalNotificationTap(NotificationResponse response) {
    _navigateForType(response.payload, null);
  }

  // Tapped from system tray (background / terminated)
  static void _handleMessageNavigation(RemoteMessage message) {
    _navigateForType(message.data['type'], message.data);
  }

  /// Route the user to the right screen based on notification type.
  /// Extend this switch as you add more screens.
  static void _navigateForType(
      String? type, Map<String, dynamic>? data) {
    final nav = navigatorKey.currentState;
    if (nav == null) return;

    switch (type) {
      case 'budget_alert':
        // Push home; the user can then tap the Budget tab
        nav.pushNamedAndRemoveUntil('/home', (r) => false);
        break;
      case 'goal_reminder':
      case 'goal_completion':
        // You can pass goalId via data and open the detail sheet
        nav.pushNamedAndRemoveUntil('/home', (r) => false);
        break;
      case 'saving_suggestion':
        nav.pushNamedAndRemoveUntil('/home', (r) => false);
        break;
      case 'password_changed':
        nav.pushNamedAndRemoveUntil('/home', (r) => false);
        break;
      default:
        nav.pushNamedAndRemoveUntil('/home', (r) => false);
    }
  }

  // ════════════════════════════════════════════════════════════
  //  PUBLIC API — call from ViewModels
  // ════════════════════════════════════════════════════════════

  /// Low-level: write a multilingual notification to Firestore.
  /// titleEn/bodyEn are the defaults used by FCM if no specific language
  /// field exists. The Cloud Function reads the user's languageCode from
  /// Firestore and picks the right field for the push title/body.
  static Future<void> _dispatch({
    required String userId,
    required String title,   // EN — also the FCM fallback
    required String body,
    required String type,
    String? titleFr,
    String? titleAr,
    String? bodyFr,
    String? bodyAr,
    Map<String, String> extra = const {},
    String? dedupKey,
    // true → stored for history only, Cloud Function skips FCM push
    bool skipPush = false,
  }) async {
    if (dedupKey != null && _sentKeys.contains(dedupKey)) return;
    if (dedupKey != null) _sentKeys.add(dedupKey);

    try {
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': userId,
        // EN (default / FCM fallback)
        'title':   title,
        'body':    body,
        // Per-language fields — Cloud Function + Flutter app both use these
        'titleEn': title,
        'titleFr': titleFr ?? title,
        'titleAr': titleAr ?? title,
        'bodyEn':  body,
        'bodyFr':  bodyFr ?? body,
        'bodyAr':  bodyAr ?? body,
        'type':    type,
        'data':    extra,
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
        'sent': skipPush,
      });
    } catch (e) {
      debugPrint('[FCM] dispatch error: $e');
    }
  }

  // ── Typed helpers ──────────────────────────────────────────

  static Future<void> sendBudgetAlert({
    required String userId,
    required String categoryName,
    required double spent,
    required double budget,
  }) {
    final pct       = (spent / budget * 100).round();
    final remaining = (budget - spent).toStringAsFixed(2);
    return _dispatch(
      userId: userId,
      title:   '⚠️ Budget Alert — $categoryName',
      body:    "You've used $pct% of your $categoryName budget. Only $remaining TND left!",
      titleFr: '⚠️ Alerte budget — $categoryName',
      bodyFr:  'Vous avez utilisé $pct% de votre budget $categoryName. Il reste $remaining TND !',
      titleAr: '⚠️ تنبيه الميزانية — $categoryName',
      bodyAr:  'استخدمت $pct% من ميزانية $categoryName. تبقّى $remaining دينار فقط!',
      type:    'budget_alert',
      extra:   {'categoryName': categoryName, 'pct': pct.toString()},
      dedupKey: 'budget_alert_${userId}_$categoryName',
    );
  }

  static Future<void> sendGoalReminder({
    required String userId,
    required String goalId,
    required String goalName,
    required int daysLeft,
    required double remaining,
  }) {
    final rem = remaining.toStringAsFixed(2);
    return _dispatch(
      userId: userId,
      title: '⏰ Goal Reminder — $goalName',
      body: daysLeft == 0
          ? 'Today is the deadline for "$goalName"! $rem TND still needed.'
          : '$daysLeft day${daysLeft > 1 ? 's' : ''} left for "$goalName". $rem TND still needed.',
      titleFr: '⏰ Rappel d\'objectif — $goalName',
      bodyFr: daysLeft == 0
          ? 'Aujourd\'hui est la date limite pour "$goalName" ! Il manque encore $rem TND.'
          : '$daysLeft jour${daysLeft > 1 ? 's' : ''} restant${daysLeft > 1 ? 's' : ''} pour "$goalName". Il manque encore $rem TND.',
      titleAr: '⏰ تذكير بالهدف — $goalName',
      bodyAr: daysLeft == 0
          ? 'اليوم هو الموعد النهائي لـ "$goalName"! لا يزال ينقصك $rem دينار.'
          : 'متبقّي $daysLeft يوم لـ "$goalName". لا يزال ينقصك $rem دينار.',
      type:    'goal_reminder',
      extra:   {'goalId': goalId, 'daysLeft': daysLeft.toString()},
      dedupKey: 'goal_reminder_${userId}_$goalId',
    );
  }

  static Future<void> sendGoalCompletion({
    required String userId,
    required String goalId,
    required String goalName,
  }) {
    return _dispatch(
      userId: userId,
      title:   '🎉 Goal Achieved!',
      body:    'Congratulations! You reached your "$goalName" goal. Keep up the great work!',
      titleFr: '🎉 Objectif atteint !',
      bodyFr:  'Félicitations ! Vous avez atteint votre objectif "$goalName". Continuez comme ça !',
      titleAr: '🎉 تم تحقيق الهدف!',
      bodyAr:  'تهانينا! لقد حققت هدفك "$goalName". أحسنت!',
      type:    'goal_completion',
      extra:   {'goalId': goalId},
      dedupKey: 'goal_done_${userId}_$goalId',
    );
  }

  static Future<void> sendSavingSuggestion({
    required String userId,
    required String goalName,
    required double suggestedAmount,
  }) {
    final amt = suggestedAmount.toStringAsFixed(2);
    return _dispatch(
      userId: userId,
      title:   '💡 Saving Suggestion',
      body:    'Set aside $amt TND this week to stay on track for "$goalName".',
      titleFr: '💡 Suggestion d\'épargne',
      bodyFr:  'Mettez de côté $amt TND cette semaine pour rester sur la bonne voie pour "$goalName".',
      titleAr: '💡 اقتراح ادخار',
      bodyAr:  'خصّص $amt دينار هذا الأسبوع للبقاء على المسار الصحيح لـ "$goalName".',
      type:    'saving_suggestion',
      extra:   {'goalName': goalName, 'amount': amt},
      dedupKey: 'suggestion_${userId}_$goalName',
    );
  }

  /// Sent after a successful password change.
  /// push enabled → sent=false → Cloud Function sends FCM even when app is closed.
  /// push disabled → sent=true → history-only, no FCM push.
  static Future<void> sendPasswordChangedAlert({
    required String userId,
    required String email,
  }) async {
    final prefs       = await SharedPreferences.getInstance();
    final pushEnabled = prefs.getBool('notif_security_alert') ?? true;

    return _dispatch(
      userId: userId,
      title:   '🔐 Password changed',
      body:    'Your password for $email was just updated. If this wasn\'t you, secure your account immediately.',
      titleFr: '🔐 Mot de passe modifié',
      bodyFr:  'Le mot de passe de votre compte $email vient d\'être mis à jour. Si ce n\'était pas vous, sécurisez votre compte immédiatement.',
      titleAr: '🔐 تم تغيير كلمة المرور',
      bodyAr:  'تم تحديث كلمة مرور حسابك $email للتو. إذا لم تكن أنت، فقم بتأمين حسابك فوراً.',
      type:    'password_changed',
      skipPush: !pushEnabled,
    );
  }

  // ── Legacy helper ───────────────────────────────────────────
  static Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    required String type,
    Map<String, String>? customData,
  }) =>
      _dispatch(userId: userId, title: title, body: body, type: type,
          extra: customData ?? {});
}
