import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ══════════════════════════════════════════════════════════════
//  PROVIDER – LanguageProvider
//  lib/providers/language_provider.dart
//  Gère la langue active + persistance via SharedPreferences
// ══════════════════════════════════════════════════════════════

class LanguageProvider extends ChangeNotifier {
  static const _prefKey = 'app_locale';

  Locale _locale = const Locale('fr');

  Locale get locale => _locale;

  String get languageCode => _locale.languageCode;

  bool get isArabic => _locale.languageCode == 'ar';

  // ── Langues supportées ─────────────────────────────────────
  static const List<_LangOption> supportedLanguages = [
    _LangOption(code: 'fr', label: 'Français', nativeLabel: 'Français', flag: '🇫🇷'),
    _LangOption(code: 'en', label: 'English',  nativeLabel: 'English',  flag: '🇬🇧'),
    _LangOption(code: 'ar', label: 'العربية',   nativeLabel: 'العربية',  flag: '🇸🇦'),
  ];

  // ── Initialisation depuis SharedPreferences ────────────────
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey);
    if (saved != null && _isSupported(saved)) {
      _locale = Locale(saved);
    }
    notifyListeners();
  }

  // ── Changer la langue ──────────────────────────────────────
  Future<void> setLocale(String languageCode) async {
    if (!_isSupported(languageCode)) return;
    if (_locale.languageCode == languageCode) return;
    _locale = Locale(languageCode);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, languageCode);
    // Persist to Firestore so Cloud Function sends FCM in the right language
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({'languageCode': languageCode}, SetOptions(merge: true))
          .catchError((_) {});
    }
  }

  bool _isSupported(String code) =>
      supportedLanguages.any((l) => l.code == code);
}

// ── Modèle option langue ────────────────────────────────────
class _LangOption {
  final String code;
  final String label;
  final String nativeLabel;
  final String flag;
  const _LangOption({
    required this.code,
    required this.label,
    required this.nativeLabel,
    required this.flag,
  });
}

// Expose public pour les pickers
typedef LangOption = _LangOption;
