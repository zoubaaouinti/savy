import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:savy/firebase_options.dart';
import 'package:savy/providers/currency_provider.dart';
import 'package:savy/providers/language_provider.dart';
import 'package:savy/views/auth/login_screen.dart';
import 'package:savy/views/splashScreen/splash_screen.dart' hide LoginScreen;
import 'package:savy/views/mainLayout/main_layout.dart';
import 'package:savy/views/legalScreen/legal_screens.dart';
import 'package:savy/views/onboarding/onboarding_screens.dart';
import 'package:savy/l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:savy/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Formatage de dates pour toutes les locales ─────────────
  await initializeDateFormatting('fr', null);
  await initializeDateFormatting('en', null);
  await initializeDateFormatting('ar', null);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ Initialize notifications (FCM + local notifications)
  await NotificationService.init();

  // ✅ Re-save FCM token whenever auth state changes (covers all sign-in paths)
  FirebaseAuth.instance.authStateChanges().listen((user) {
    if (user != null) NotificationService.saveTokenAfterLogin();
  });

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  final currencyProvider = CurrencyProvider();
  await currencyProvider.init();

  final languageProvider = LanguageProvider();
  await languageProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: currencyProvider),
        ChangeNotifierProvider.value(value: languageProvider),
      ],
      child: const SavyApp(),
    ),
  );
}

class SavyApp extends StatelessWidget {
  const SavyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final langProvider = context.watch<LanguageProvider>();
    final locale = langProvider.locale;

    return MaterialApp(
      title: 'Savy',
      navigatorKey: NotificationService.navigatorKey, // ✅ ADDED - connects notification taps to navigation
      debugShowCheckedModeBanner: false,

      // ── Localisation dynamique ─────────────────────────────
      locale: locale,
      supportedLocales: const [
        Locale('fr'),
        Locale('en'),
        Locale('ar'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // ── RTL automatique pour l'arabe ───────────────────────
      builder: (context, child) {
        return Directionality(
          textDirection: locale.languageCode == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: child!,
        );
      },

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3EFFA8),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF060D1F),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),

      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash:     (_) => const SplashScreen(),
        AppRoutes.login:      (_) => const LoginScreen(),
        AppRoutes.signUp:     (_) => const SignUpScreen(),
        AppRoutes.home:       (_) => const MainLayout(),
        AppRoutes.terms:      (_) => const TermsScreen(),
        AppRoutes.privacy:    (_) => const PrivacyScreen(),
        AppRoutes.onboarding: (_) => const OnboardingNameScreen(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.splash:
            return _fadeRoute(const SplashScreen());
          case AppRoutes.login:
            return _fadeRoute(const LoginScreen());
          case AppRoutes.signUp:
            return _slideRoute(const SignUpScreen(), fromRight: true);
          case AppRoutes.home:
            return _slideRoute(const MainLayout(), fromRight: false);
          case AppRoutes.terms:
            return _slideRoute(const TermsScreen(), fromRight: true);
          case AppRoutes.privacy:
            return _slideRoute(const PrivacyScreen(), fromRight: true);
          case AppRoutes.onboarding:
            return _slideRoute(const OnboardingNameScreen(), fromRight: false);
          default:
            return _fadeRoute(const LoginScreen());
        }
      },
    );
  }

  static PageRouteBuilder _fadeRoute(Widget page) => PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) =>
        FadeTransition(opacity: animation, child: child),
    transitionDuration: const Duration(milliseconds: 400),
  );

  static PageRouteBuilder _slideRoute(Widget page,
      {bool fromRight = true}) =>
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: Offset(fromRight ? 1.0 : 0.0, fromRight ? 0.0 : 0.06),
            end: Offset.zero,
          ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: FadeTransition(opacity: animation, child: child),
        ),
        transitionDuration: const Duration(milliseconds: 350),
      );
}

class AppRoutes {
  AppRoutes._();
  static const String splash     = '/';
  static const String login      = '/login';
  static const String signUp     = '/signup';
  static const String home       = '/home';
  static const String terms      = '/terms';
  static const String privacy    = '/privacy';
  static const String onboarding = '/onboarding';
}