import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Android notification channel — must match AndroidManifest meta-data
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

  // ── OneSignal credentials ────────────────────────────────────
  static const _kAppId   = 'cbccff71-a011-4b08-8266-0335a9084da3';
  static const _kRestKey = 'os_v2_app_zpgp64nacffqratgam22sccnun4fzr3dhtcevl4lkizkjmmqks2hbxiv2qudglb32ssmare7dfvwchswkc2gdzjbntbzbwljtfhz57i'; // OneSignal → Settings → Keys & IDs

  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  /// Plug into MaterialApp.navigatorKey to enable tap-navigation from
  /// terminated state.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final Set<String> _sentKeys = {};

  // ────────────────────────────────────────────────────────────
  //  INIT — call once from main() AFTER Firebase.initializeApp()
  // ────────────────────────────────────────────────────────────
  static Future<void> init() async {
    // 1. Create Android notification channel
    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_savyChannel);

    // 2. Init flutter_local_notifications
    await _local.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@drawable/ic_notification'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        ),
      ),
      onDidReceiveNotificationResponse: _onLocalTap,
    );

    // Request Android 13+ notification permission via flutter_local_notifications
    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // 3. Init OneSignal — handles FCM registration + push in background/terminated
    OneSignal.initialize(_kAppId);
    await OneSignal.Notifications.requestPermission(true);

    // 4. Tap on notification (background OR terminated) → navigate
    OneSignal.Notifications.addClickListener((event) {
      final data = Map<String, dynamic>.from(event.notification.additionalData ?? {});
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _navigateForType(data['type'] as String?, data),
      );
    });
  }

  // ────────────────────────────────────────────────────────────
  //  AUTH HELPERS — call after login / logout
  // ────────────────────────────────────────────────────────────

  /// Links the OneSignal subscription to the Firebase UID so we can target
  /// this user by ID when sending pushes.
  static Future<void> loginUser(String uid) async {
    await OneSignal.login(uid);
    debugPrint('[OneSignal] External ID set: $uid');
  }

  /// Unlinks the subscription on sign-out so the user stops receiving pushes.
  static Future<void> logoutUser() async {
    await OneSignal.logout();
    debugPrint('[OneSignal] Logged out');
  }

  // ────────────────────────────────────────────────────────────
  //  FOREGROUND BANNER
  // ────────────────────────────────────────────────────────────
  static void _showBanner({
    required int    id,
    required String title,
    required String body,
    String?         type,
  }) {
    _local.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _savyChannel.id,
          _savyChannel.name,
          channelDescription: _savyChannel.description,
          importance: Importance.max,
          priority:   Priority.high,
          icon:  '@drawable/ic_notification',
          color: const Color(0xFF3EFFA8),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: type,
    );
  }

  // ────────────────────────────────────────────────────────────
  //  NAVIGATION ON TAP
  // ────────────────────────────────────────────────────────────
  static void _onLocalTap(NotificationResponse response) {
    _navigateForType(response.payload, null);
  }

  static void _navigateForType(String? type, Map<String, dynamic>? data) {
    final nav = navigatorKey.currentState;
    if (nav == null) return;
    nav.pushNamedAndRemoveUntil('/home', (r) => false);
  }

  // ────────────────────────────────────────────────────────────
  //  ONESIGNAL REST API — send push to a user by Firebase UID
  // ────────────────────────────────────────────────────────────
  static Future<void> _sendPush({
    required String userId,
    required String titleEn,
    required String titleFr,
    required String titleAr,
    required String bodyEn,
    required String bodyFr,
    required String bodyAr,
    required String type,
    Map<String, String> extra = const {},
  }) async {
    try {
      // Use the app's chosen language, not the device system language
      final prefs = await SharedPreferences.getInstance();
      final lang  = prefs.getString('app_locale') ?? 'fr';
      final title = lang == 'ar' ? titleAr : lang == 'en' ? titleEn : titleFr;
      final body  = lang == 'ar' ? bodyAr  : lang == 'en' ? bodyEn  : bodyFr;

      final res = await http.post(
        Uri.parse('https://api.onesignal.com/notifications'),
        headers: {
          'Authorization': 'Key $_kRestKey',
          'Content-Type':  'application/json',
        },
        body: jsonEncode({
          'app_id': _kAppId,
          'include_aliases': {'external_id': [userId]},
          'target_channel': 'push',
          'headings': {'en': title},
          'contents': {'en': body},
          'data': {'type': type, ...extra},
        }),
      );
      debugPrint('[OneSignal] ${res.statusCode} — ${res.body}');
    } catch (e) {
      debugPrint('[OneSignal] send error: $e');
    }
  }

  // ────────────────────────────────────────────────────────────
  //  DISPATCH — write to Firestore + send OneSignal push
  // ────────────────────────────────────────────────────────────
  static Future<void> _dispatch({
    required String userId,
    required String title,
    required String body,
    required String type,
    String? titleFr,
    String? titleAr,
    String? bodyFr,
    String? bodyAr,
    Map<String, String> extra = const {},
    String? dedupKey,
    bool skipPush = false,
  }) async {
    if (dedupKey != null && _sentKeys.contains(dedupKey)) return;
    if (dedupKey != null) _sentKeys.add(dedupKey);

    try {
      // Resolve localized text for the local banner
      final prefs = await SharedPreferences.getInstance();
      final lang  = prefs.getString('app_locale') ?? 'fr';
      final localTitle = lang == 'ar' ? (titleAr ?? title) : lang == 'en' ? title : (titleFr ?? title);
      final localBody  = lang == 'ar' ? (bodyAr  ?? body)  : lang == 'en' ? body  : (bodyFr  ?? body);

      // Write to Firestore for the in-app notification inbox
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId':  userId,
        'title':   title,   'body':    body,
        'titleEn': title,   'titleFr': titleFr ?? title, 'titleAr': titleAr ?? title,
        'bodyEn':  body,    'bodyFr':  bodyFr  ?? body,  'bodyAr':  bodyAr  ?? body,
        'type':    type,
        'data':    extra,
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
        'sent': true,
      });

      // Always show a local system notification (visible in the status bar)
      if (!skipPush) {
        _showBanner(
          id:    DateTime.now().millisecondsSinceEpoch.remainder(100000),
          title: localTitle,
          body:  localBody,
          type:  type,
        );
      }

      // Also send via OneSignal for background / terminated state
      if (!skipPush) {
        await _sendPush(
          userId:   userId,
          titleEn:  title,          titleFr: titleFr ?? title, titleAr: titleAr ?? title,
          bodyEn:   body,           bodyFr:  bodyFr  ?? body,  bodyAr:  bodyAr  ?? body,
          type:     type,
          extra:    extra,
        );
      }
    } catch (e) {
      debugPrint('[NotificationService] dispatch error: $e');
    }
  }

  // ════════════════════════════════════════════════════════════
  //  PUBLIC API
  // ════════════════════════════════════════════════════════════

  static Future<void> sendBudgetAlert({
    required String userId,
    required String categoryName,
    required double spent,
    required double budget,
  }) {
    final pct       = (spent / budget * 100).round();
    final remaining = (budget - spent).toStringAsFixed(2);
    return _dispatch(
      userId:  userId,
      title:   '⚠️ Budget Alert — $categoryName',
      body:    "You've used $pct% of your $categoryName budget. Only $remaining TND left!",
      titleFr: '⚠️ Alerte budget — $categoryName',
      bodyFr:  'Vous avez utilisé $pct% de votre budget $categoryName. Il reste $remaining TND !',
      titleAr: '⚠️ تنبيه الميزانية — $categoryName',
      bodyAr:  'استخدمت $pct% من ميزانية $categoryName. تبقّى $remaining دينار فقط!',
      type:     'budget_alert',
      extra:    {'categoryName': categoryName, 'pct': pct.toString()},
      dedupKey: 'budget_alert_${userId}_$categoryName',
    );
  }

  static Future<void> sendGoalReminder({
    required String userId,
    required String goalId,
    required String goalName,
    required int    daysLeft,
    required double remaining,
  }) {
    final rem = remaining.toStringAsFixed(2);
    return _dispatch(
      userId:  userId,
      title:   '⏰ Goal Reminder — $goalName',
      body:    daysLeft == 0
          ? 'Today is the deadline for "$goalName"! $rem TND still needed.'
          : '$daysLeft day${daysLeft > 1 ? 's' : ''} left for "$goalName". $rem TND still needed.',
      titleFr: '⏰ Rappel d\'objectif — $goalName',
      bodyFr:  daysLeft == 0
          ? 'Aujourd\'hui est la date limite pour "$goalName" ! Il manque encore $rem TND.'
          : '$daysLeft jour${daysLeft > 1 ? 's' : ''} restant${daysLeft > 1 ? 's' : ''} pour "$goalName". Il manque encore $rem TND.',
      titleAr: '⏰ تذكير بالهدف — $goalName',
      bodyAr:  daysLeft == 0
          ? 'اليوم هو الموعد النهائي لـ "$goalName"! لا يزال ينقصك $rem دينار.'
          : 'متبقّي $daysLeft يوم لـ "$goalName". لا يزال ينقصك $rem دينار.',
      type:     'goal_reminder',
      extra:    {'goalId': goalId, 'daysLeft': daysLeft.toString()},
      dedupKey: 'goal_reminder_${userId}_$goalId',
    );
  }

  static Future<void> sendGoalCompletion({
    required String userId,
    required String goalId,
    required String goalName,
  }) {
    return _dispatch(
      userId:  userId,
      title:   '🎉 Goal Achieved!',
      body:    'Congratulations! You reached your "$goalName" goal. Keep up the great work!',
      titleFr: '🎉 Objectif atteint !',
      bodyFr:  'Félicitations ! Vous avez atteint votre objectif "$goalName". Continuez comme ça !',
      titleAr: '🎉 تم تحقيق الهدف!',
      bodyAr:  'تهانينا! لقد حققت هدفك "$goalName". أحسنت!',
      type:     'goal_completion',
      extra:    {'goalId': goalId},
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
      userId:  userId,
      title:   '💡 Saving Suggestion',
      body:    'Set aside $amt TND this week to stay on track for "$goalName".',
      titleFr: '💡 Suggestion d\'épargne',
      bodyFr:  'Mettez de côté $amt TND cette semaine pour rester sur la bonne voie pour "$goalName".',
      titleAr: '💡 اقتراح ادخار',
      bodyAr:  'خصّص $amt دينار هذا الأسبوع للبقاء على المسار الصحيح لـ "$goalName".',
      type:     'saving_suggestion',
      extra:    {'goalName': goalName, 'amount': amt},
      dedupKey: 'suggestion_${userId}_$goalName',
    );
  }

  static Future<void> sendPasswordChangedAlert({
    required String userId,
    required String email,
  }) async {
    final prefs       = await SharedPreferences.getInstance();
    final pushEnabled = prefs.getBool('notif_security_alert') ?? true;
    return _dispatch(
      userId:  userId,
      title:   '🔐 Password changed',
      body:    'Your password for $email was just updated. If this wasn\'t you, secure your account immediately.',
      titleFr: '🔐 Mot de passe modifié',
      bodyFr:  'Le mot de passe de votre compte $email vient d\'être mis à jour. Si ce n\'était pas vous, sécurisez votre compte immédiatement.',
      titleAr: '🔐 تم تغيير كلمة المرور',
      bodyAr:  'تم تحديث كلمة مرور حسابك $email للتو. إذا لم تكن أنت، فقم بتأمين حسابك فوراً.',
      type:     'password_changed',
      skipPush: !pushEnabled,
    );
  }

  static Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    required String type,
    Map<String, String>? customData,
  }) =>
      _dispatch(
        userId: userId,
        title:  title,
        body:   body,
        type:   type,
        extra:  customData ?? {},
      );

  static Future<void> sendHealthScoreAlert({
    required String userId,
    required int score,
  }) {
    return _dispatch(
      userId:   userId,
      title:    '🚨 Critical Financial Health Alert',
      body:     'Your financial health score has dropped to $score/100. Immediate action is needed to get back on track.',
      titleFr:  '🚨 Alerte santé financière critique',
      bodyFr:   'Votre score de santé financière est tombé à $score/100. Une action immédiate est nécessaire pour vous redresser.',
      titleAr:  '🚨 تنبيه حرج: الصحة المالية',
      bodyAr:   'انخفض مؤشر صحتك المالية إلى $score/100. يلزم اتخاذ إجراء فوري للتعافي.',
      type:     'health_score_alert',
      extra:    {'score': score.toString()},
      dedupKey: 'health_score_alert_${userId}_$score',
    );
  }
}
