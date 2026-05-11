import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/budget_models.dart';
import '../models/export_models.dart';
import '../models/objective.dart';
import '../models/smart_engine_models.dart';
import '../services/smart_engine.dart';

/// ViewModel that owns all Firestore subscriptions needed by [SmartEngine]
/// and exposes the computed [SmartEngineResult] plus accept/modify/reject
/// actions for each saving suggestion.
///
/// Usage:
/// ```dart
/// ChangeNotifierProvider(
///   create: (_) => SmartEngineViewModel()..init(),
///   child: ...,
/// )
/// ```
class SmartEngineViewModel extends ChangeNotifier {
  SmartEngineViewModel({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  // ── Computation state ──────────────────────────────────────────────────
  bool _isLoading = true;
  String? _error;
  SmartEngineResult? _result;

  bool get isLoading => _isLoading;
  String? get error => _error;
  SmartEngineResult? get result => _result;

  // ── Per-session action tracking ────────────────────────────────────────
  // Once accepted or rejected in this session, the suggestion is hidden
  // until the user explicitly resets (e.g. on pull-to-refresh).
  final Set<String> _acceptedIds = {};
  final Set<String> _rejectedIds = {};

  // ── Derived accessors ──────────────────────────────────────────────────

  HealthScore? get healthScore => _result?.healthScore;
  SpendingPrediction? get prediction => _result?.prediction;
  List<GoalSuccessForecast> get goalForecasts =>
      _result?.goalForecasts ?? const [];

  /// Suggestions that have not yet been acted on this session.
  List<SavingSuggestion> get pendingSuggestions =>
      _result?.suggestions
          .where((s) =>
              !_acceptedIds.contains(s.objectiveId) &&
              !_rejectedIds.contains(s.objectiveId))
          .toList() ??
      const [];

  int get pendingCount => pendingSuggestions.length;

  bool get hasBudgetAlert =>
      _result?.prediction.willExceedBudget == true ||
      _result?.prediction.willExceedIncome == true;

  bool willExhaustBalanceWithin(int days) {
    final d = _result?.prediction.daysUntilBalanceExhausted ?? -1;
    return d >= 0 && d <= days;
  }

  // ── Raw data (read-only exposure for the UI) ───────────────────────────
  double _totalIncome = 0;
  double _totalExpenses = 0;
  List<Objective> _objectives = [];
  List<TransactionSnapshot> _transactions = [];

  double get totalIncome => _totalIncome;
  double get totalExpenses => _totalExpenses;
  double get remainingBudget =>
      (_totalIncome - _totalExpenses).clamp(0.0, double.infinity);

  /// Finds a cached [Objective] by id.  Returns null if not yet loaded.
  Objective? objectiveById(String id) {
    try {
      return _objectives.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── Stream subscriptions ───────────────────────────────────────────────
  StreamSubscription<QuerySnapshot>? _revSub;
  StreamSubscription<QuerySnapshot>? _budSub;
  StreamSubscription<QuerySnapshot>? _txSub;
  StreamSubscription<QuerySnapshot>? _objSub;

  final Set<String> _loaded = {};

  String get _uid => _auth.currentUser?.uid ?? '';

  DocumentReference get _userRef =>
      _firestore.collection('users').doc(_uid);

  // ── Lifecycle ──────────────────────────────────────────────────────────

  void init() {
    if (_uid.isEmpty) {
      _error = 'Utilisateur non authentifié';
      _isLoading = false;
      notifyListeners();
      return;
    }
    _subscribeRevenues();
    _subscribeBudgets();
    _subscribeTransactions();
    _subscribeObjectives();
  }

  @override
  void dispose() {
    _revSub?.cancel();
    _budSub?.cancel();
    _txSub?.cancel();
    _objSub?.cancel();
    super.dispose();
  }

  // ── User-facing actions ────────────────────────────────────────────────

  /// Adds [amount] to the objective's `currentAmount` in Firestore and marks
  /// the suggestion as accepted for this session.
  /// Returns an error message string on failure, or null on success.
  Future<String?> acceptSuggestion(String objectiveId, double amount) =>
      _applyAmount(objectiveId, amount);

  /// Same as [acceptSuggestion] but with a user-supplied custom amount.
  Future<String?> modifySuggestion(String objectiveId, double customAmount) =>
      _applyAmount(objectiveId, customAmount);

  /// Removes the suggestion from the pending list for this session only.
  /// No Firestore write is performed.
  void rejectSuggestion(String objectiveId) {
    _rejectedIds.add(objectiveId);
    notifyListeners();
  }

  /// Clears all session-level accept/reject tracking so that all current
  /// suggestions become visible again.  Call this when the user refreshes.
  void resetActedSuggestions() {
    _acceptedIds.clear();
    _rejectedIds.clear();
    notifyListeners();
  }

  // ── Private helpers ────────────────────────────────────────────────────

  Future<String?> _applyAmount(String objectiveId, double amount) async {
    if (amount <= 0) return 'Le montant doit être supérieur à zéro';
    try {
      await _userRef.collection('objectives').doc(objectiveId).update({
        'currentAmount': FieldValue.increment(amount),
      });
      _acceptedIds.add(objectiveId);
      notifyListeners();
      return null;
    } catch (e) {
      debugPrint('SmartEngineViewModel._applyAmount error: $e');
      return 'Erreur lors de la mise à jour : $e';
    }
  }

  // ── Firestore subscriptions ────────────────────────────────────────────

  void _subscribeRevenues() {
    _revSub = _userRef.collection('revenues').snapshots().listen((snap) {
      _totalIncome = snap.docs.fold(0.0, (sum, doc) {
        final data = doc.data() as Map<String, dynamic>;
        return sum + ((data['amount'] as num?)?.toDouble() ?? 0.0);
      });
      _markLoaded('revenues');
    }, onError: _onStreamError);
  }

  void _subscribeBudgets() {
    _budSub = _userRef.collection('budget').snapshots().listen((snap) {
      final cats = snap.docs
          .map((d) =>
              BudgetCategory.fromMap(d.id, d.data() as Map<String, dynamic>))
          .toList();
      _totalExpenses = cats.fold(0.0, (s, c) => s + c.spent);
      _markLoaded('budget');
    }, onError: _onStreamError);
  }

  void _subscribeTransactions() {
    _txSub = _userRef
        .collection('transactions')
        .orderBy('date', descending: true)
        .limit(200)
        .snapshots()
        .listen((snap) {
      _transactions = snap.docs
          .map((d) => TransactionSnapshot.fromMap(
              d.id, d.data() as Map<String, dynamic>))
          .toList();
      _markLoaded('transactions');
    }, onError: _onStreamError);
  }

  void _subscribeObjectives() {
    _objSub = _userRef.collection('objectives').snapshots().listen((snap) {
      _objectives = snap.docs.map((d) => Objective.fromFirestore(d)).toList();
      _markLoaded('objectives');
    }, onError: _onStreamError);
  }

  void _markLoaded(String key) {
    _loaded.add(key);
    if (_loaded.length >= 4) _recompute();
  }

  void _recompute() {
    try {
      _result = SmartEngine.compute(
        totalIncome: _totalIncome,
        totalExpenses: _totalExpenses,
        totalBudget: _totalExpenses, // uses current spending as budget ceiling
        objectives: _objectives,
        transactions: _transactions,
      );
      _error = null;
    } catch (e) {
      _error = 'Erreur de calcul : $e';
      debugPrint('SmartEngineViewModel._recompute error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  void _onStreamError(Object err) {
    _error = err.toString();
    _isLoading = false;
    debugPrint('SmartEngineViewModel stream error: $err');
    notifyListeners();
  }
}
