import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:savy/views/auth/login_screen.dart';
import 'package:savy/views/splashScreen/splash_screen.dart' hide LoginScreen;
import 'package:savy/views/mainLayout/main_layout.dart';
import 'package:savy/views/legalScreen/legal_screens.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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

  runApp(const SavyApp());
}

class SavyApp extends StatelessWidget {
  const SavyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Savy',
      debugShowCheckedModeBanner: false,
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
        AppRoutes.splash:   (_) => const SplashScreen(),
        AppRoutes.login:    (_) => const LoginScreen(),
        AppRoutes.signUp:   (_) => const SignUpScreen(),
        AppRoutes.home:     (_) => const MainLayout(),
        AppRoutes.terms:    (_) => const TermsScreen(),
        AppRoutes.privacy:  (_) => const PrivacyScreen(),
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

  static PageRouteBuilder _slideRoute(Widget page, {bool fromRight = true}) =>
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: Offset(fromRight ? 1.0 : 0.0, fromRight ? 0.0 : 0.06),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: FadeTransition(opacity: animation, child: child),
        ),
        transitionDuration: const Duration(milliseconds: 350),
      );
}

class AppRoutes {
  AppRoutes._();
  static const String splash  = '/';
  static const String login   = '/login';
  static const String signUp  = '/signup';
  static const String home    = '/home';
  static const String terms   = '/terms';
  static const String privacy = '/privacy';
}