import 'dart:async';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/budget_models.dart';
import '../models/objective.dart';

// ══════════════════════════════════════════════════════════════
//  VIEWMODEL – DashboardViewModel
//  lib/viewmodels/dashboard_view_model.dart
//
//  Gère tous les KPI du tableau de bord via 5 streams Firestore.
//  Chaque mise à jour de n'importe quel stream déclenche un
//  recalcul complet de tous les indicateurs → notifyListeners().
//  Utilisé avec ChangeNotifierProvider dans HomeScreen.
// ══════════════════════════════════════════════════════════════

// ── DTOs ──────────────────────────────────────────────────────

/// Transaction simplifiée pour l'affichage "Récentes"
class HomeTx {
  final String label;
  final String category;
  final String iconName;
  final double amount;
  final bool isIncome;
  final int colorValue;

  const HomeTx({
    required this.label,
    required this.category,
    required this.iconName,
    required this.amount,
    required this.isIncome,
    required this.colorValue,
  });
}

/// Un point de données pour le graphique d'évolution hebdomadaire
class WeeklyExpense {
  final String weekLabel; // ex: "13/1"
  final double amount;

  const WeeklyExpense({required this.weekLabel, required this.amount});
}

// ── ViewModel ─────────────────────────────────────────────────

class DashboardViewModel extends ChangeNotifier {
  final _db   = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // ── Abonnements aux streams ─────────────────────────────────
  StreamSubscription<DocumentSnapshot>? _userSub;
  StreamSubscription<QuerySnapshot>?    _revSub;
  StreamSubscription<QuerySnapshot>?    _budSub;
  StreamSubscription<QuerySnapshot>?    _txSub;
  StreamSubscription<QuerySnapshot>?    _objSub;

  // ── Cache des docs bruts (pour recalcul croisé) ────────────
  double _cachedInitialBalance = 0;
  String _cachedName           = '';
  List<QueryDocumentSnapshot> _revDocs = [];
  List<QueryDocumentSnapshot> _budDocs = [];
  List<QueryDocumentSnapshot> _txDocs  = [];
  List<QueryDocumentSnapshot> _objDocs = [];

  // Streams chargés (évite de passer isLoading=false trop tôt)
  final Set<String> _ready = {};

  // ── État exposé ────────────────────────────────────────────
  bool   isLoading           = true;
  String userName            = '';

  double totalBalance        = 0;
  double totalIncome         = 0;
  double totalExpenses       = 0;
  double totalObjectivesSaved= 0;

  int    healthScore         = 0;
  double avgObjectivesProgress = 0;  // 0.0 – 1.0

  List<BudgetCategory> budgetCategories = [];
  List<WeeklyExpense>  weeklyExpenses   = [];
  List<Objective>      topObjectives    = [];
  List<HomeTx>         recentTransactions = [];

  // ── Getters calculés ──────────────────────────────────────
  double get budgetUsedPct => totalIncome > 0
      ? ((totalExpenses + totalObjectivesSaved) / totalIncome).clamp(0.0, 1.0)
      : 0.0;

  double get remainingBudget =>
      (totalIncome - totalExpenses).clamp(0.0, double.infinity);

  String? get _uid => _auth.currentUser?.uid;

  // ── Références Firestore ──────────────────────────────────
  DocumentReference  get _userRef => _db.collection('users').doc(_uid);
  CollectionReference get _revRef => _userRef.collection('revenues');
  CollectionReference get _budRef => _userRef.collection('budget');
  CollectionReference get _txRef  => _userRef.collection('transactions');
  CollectionReference get _objRef => _userRef.collection('objectives');

  // ── Initialisation (appelée par le widget) ─────────────────
  void init() {
    if (_uid == null) {
      isLoading = false;
      notifyListeners();
      return;
    }
    _subscribeAll();
  }

  void _subscribeAll() {
    // Profil utilisateur
    _userSub = _userRef.snapshots().listen((snap) {
      final d = snap.data() as Map<String, dynamic>? ?? {};
      _cachedName           = d['name']           as String? ?? 'Utilisateur';
      _cachedInitialBalance = (d['initialBalance'] ?? 0).toDouble();
      _ready.add('user');
      _recompute();
    });

    // Revenus
    _revSub = _revRef.snapshots().listen((snap) {
      _revDocs = snap.docs;
      _ready.add('revenues');
      _recompute();
    });

    // Catégories de budget
    _budSub = _budRef.snapshots().listen((snap) {
      _budDocs = snap.docs;
      _ready.add('budget');
      _recompute();
    });

    // Transactions (max 200 pour couvrir 6 semaines)
    _txSub = _txRef
        .orderBy('date', descending: true)
        .limit(200)
        .snapshots()
        .listen((snap) {
      _txDocs = snap.docs;
      _ready.add('transactions');
      _recompute();
    });

    // Objectifs
    _objSub = _objRef
        .orderBy('priority', descending: true)
        .snapshots()
        .listen((snap) {
      _objDocs = snap.docs;
      _ready.add('objectives');
      _recompute();
    });
  }

  // ── Recalcul de tous les KPI ──────────────────────────────
  void _recompute() {
    // ── Catégories de budget ──────────────────────────────────
    final categories = _budDocs
        .map((d) => BudgetCategory.fromMap(d.id, d.data() as Map<String, dynamic>))
        .toList();
    final catMap = {for (final c in categories) c.id: c};

    // ── Revenus totaux ────────────────────────────────────────
    final income = _revDocs.fold<double>(0, (s, d) {
      return s + ((d.data() as Map<String, dynamic>)['amount'] ?? 0).toDouble();
    });

    // ── Dépenses (somme des "spent" par catégorie) ────────────
    final expenses = categories.fold<double>(0, (s, c) => s + c.spent);

    // ── Objectifs ─────────────────────────────────────────────
    final objectives = _objDocs
        .map((d) => Objective.fromFirestore(d))
        .toList();
    final objSaved = objectives.fold<double>(0, (s, o) => s + o.currentAmount);

    // ── 5 transactions récentes ───────────────────────────────
    final recentTxs = _txDocs.take(5).map((doc) {
      final d = doc.data() as Map<String, dynamic>;
      final isIncome = d['isIncome'] as bool? ?? false;
      final catId    = d['categoryId'] as String? ?? '';
      final cat      = catMap[catId];
      return HomeTx(
        label:      d['label'] as String? ?? '',
        category:   isIncome ? 'Revenu' : (cat?.name    ?? 'Autres'),
        iconName:   isIncome ? 'trending_up' : (cat?.iconName ?? 'category'),
        amount:     (d['amount'] ?? 0).toDouble(),
        isIncome:   isIncome,
        colorValue: isIncome ? 0xFF3EFFA8 : (cat?.colorValue ?? 0xFF8BA8D4),
      );
    }).toList();

    // ── Évolution hebdomadaire (6 semaines) ───────────────────
    final weekly = _computeWeekly(_txDocs);

    // ── Progression moyenne des objectifs ─────────────────────
    final avgProgress = objectives.isEmpty
        ? 0.0
        : objectives.fold<double>(0, (s, o) => s + o.progress) /
              objectives.length;

    // ── Score de santé financière ─────────────────────────────
    final score = _computeHealthScore(income, expenses + objSaved);

    // ── Mise à jour de l'état ─────────────────────────────────
    totalIncome           = income;
    totalExpenses         = expenses;
    totalObjectivesSaved  = objSaved;
    totalBalance          = _cachedInitialBalance + income - expenses;
    userName              = _cachedName;
    healthScore           = score;
    budgetCategories      = categories;
    topObjectives         = objectives.where((o) => !o.isCompleted).take(3).toList();
    recentTransactions    = recentTxs;
    weeklyExpenses        = weekly;
    avgObjectivesProgress = avgProgress;

    // isLoading = false seulement quand tous les 5 streams ont répondu
    isLoading = !_ready.containsAll(
        {'user', 'revenues', 'budget', 'transactions', 'objectives'});

    notifyListeners();
  }

  // ── Graphique d'évolution : 6 semaines glissantes ─────────
  List<WeeklyExpense> _computeWeekly(List<QueryDocumentSnapshot> docs) {
    final now = DateTime.now();

    // Début de la semaine courante (lundi)
    final todayMidnight = DateTime(now.year, now.month, now.day);
    final startThisWeek =
        todayMidnight.subtract(Duration(days: now.weekday - 1));

    // Génère les 6 débuts de semaine (du plus vieux au plus récent)
    final weekStarts = List.generate(
      6,
      (i) => startThisWeek.subtract(Duration(days: (5 - i) * 7)),
    );

    final buckets = List.filled(6, 0.0);

    for (final doc in docs) {
      final d = doc.data() as Map<String, dynamic>;
      if (d['isIncome'] == true) continue;
      final ms   = (d['date'] ?? 0) as num;
      final date = DateTime.fromMillisecondsSinceEpoch(ms.toInt());

      for (int i = 0; i < 6; i++) {
        final wEnd = i < 5
            ? weekStarts[i + 1]
            : startThisWeek.add(const Duration(days: 7));
        if (!date.isBefore(weekStarts[i]) && date.isBefore(wEnd)) {
          buckets[i] += (d['amount'] ?? 0).toDouble();
          break;
        }
      }
    }

    return List.generate(6, (i) {
      final ws = weekStarts[i];
      return WeeklyExpense(
        weekLabel: '${ws.day}/${ws.month}',
        amount:    buckets[i],
      );
    });
  }

  // ── Score de santé financière (0–100) ─────────────────────
  int _computeHealthScore(double income, double expenses) {
    if (income <= 0) return 50;
    final ratio = expenses / income;
    // Pondéré pour récompenser les bons comportements
    if (ratio <= 0.30) return 98;
    if (ratio <= 0.40) return 90;
    if (ratio <= 0.55) return 78;
    if (ratio <= 0.70) return 62;
    if (ratio <= 0.85) return 45;
    if (ratio <= 1.00) return 28;
    return math.max(0, (15 - ((ratio - 1.0) * 30).round()));
  }

  @override
  void dispose() {
    _userSub?.cancel();
    _revSub?.cancel();
    _budSub?.cancel();
    _txSub?.cancel();
    _objSub?.cancel();
    super.dispose();
  }
}
