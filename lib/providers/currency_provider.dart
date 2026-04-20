import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/currency_model.dart';
import '../services/currency_service.dart';

// ══════════════════════════════════════════════════════════════
//  PROVIDER – CurrencyProvider
// ══════════════════════════════════════════════════════════════

class CurrencyProvider extends ChangeNotifier {
  CurrencyInfo _selected = CurrencyInfo.defaultCurrency;
  double _rate = 1.0;
  bool _isLoadingRate = false;

  CurrencyInfo get selected => _selected;
  double get rate => _rate;
  bool get isLoadingRate => _isLoadingRate;
  String get symbol => _selected.symbol;
  String get code => _selected.code;

  // ── Conversion & formatage ─────────────────────────────────
  double convert(double tndAmount) => tndAmount * _rate;

  String format(double tndAmount) => _selected.format(convert(tndAmount));

  // ── Initialisation (appelée au démarrage de l'app) ─────────
  Future<void> init() async {
    await _loadFromPrefs();
    _syncFromFirestore();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('currency_code') ?? 'TND';
    final rate = prefs.getDouble('currency_rate') ?? 1.0;
    _selected = CurrencyInfo.findByCode(code) ?? CurrencyInfo.defaultCurrency;
    _rate = rate;
    notifyListeners();
  }

  Future<void> _syncFromFirestore() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final code = doc.data()?['currency'] as String? ?? 'TND';
      final firestoreCurrency =
          CurrencyInfo.findByCode(code) ?? CurrencyInfo.defaultCurrency;

      if (firestoreCurrency.code != _selected.code) {
        await _applyAndFetch(firestoreCurrency, saveToFirestore: false);
      } else if (_rate == 1.0 && code != 'TND') {
        await _fetchRate();
      }
    } catch (_) {}
  }

  // ── Changer la devise (appelé depuis l'UI) ─────────────────
  Future<void> setCurrency(CurrencyInfo currency) async {
    await _applyAndFetch(currency, saveToFirestore: true);
  }

  Future<void> _applyAndFetch(
    CurrencyInfo currency, {
    required bool saveToFirestore,
  }) async {
    _selected = currency;
    notifyListeners();

    if (currency.code == 'TND') {
      _rate = 1.0;
    } else {
      await _fetchRate();
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency_code', currency.code);
    await prefs.setDouble('currency_rate', _rate);

    if (saveToFirestore) {
      try {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .update({'currency': currency.code});
        }
      } catch (_) {}
    }

    notifyListeners();
  }

  Future<void> _fetchRate() async {
    _isLoadingRate = true;
    notifyListeners();
    try {
      final rates = await CurrencyService().fetchRatesFromTND();
      _rate = rates[_selected.code] ?? 1.0;
    } catch (_) {
      _rate = 1.0;
    }
    _isLoadingRate = false;
    notifyListeners();
  }

  // ── Rechargement manuel du taux (pull-to-refresh) ──────────
  Future<void> refreshRate() async {
    if (_selected.code == 'TND') return;
    await _fetchRate();
  }
}
