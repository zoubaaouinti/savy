import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/objective.dart';

// ══════════════════════════════════════════════════════════════
//  VIEWMODEL – ObjectivesViewModel
//  lib/viewmodels/objectives_view_model.dart
// ══════════════════════════════════════════════════════════════

class ObjectivesViewModel extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference get _goalsRef =>
      _firestore.collection('users').doc(_uid).collection('objectives');

  // ── Stream temps réel ──────────────────────────────────────
  Stream<List<Objective>> get objectivesStream => _goalsRef
      .orderBy('priority')
      .snapshots()
      .map((snap) =>
      snap.docs.map((d) => Objective.fromFirestore(d)).toList());

  // ── Suggestion IA — DÉSACTIVÉE (TODO: Sprint IA) ──────────
  double computeSuggestion(
      double target, double current, DateTime? deadline) {
    return 0; // sera calculé par l'IA dans un sprint futur
  }

  // ── Totaux pour la progress bar globale ───────────────────
  Map<String, double> computeTotals(List<Objective> objectives) {
    final saved = objectives.fold<double>(0, (s, o) => s + o.currentAmount);
    final target = objectives.fold<double>(0, (s, o) => s + o.targetAmount);
    return {'saved': saved, 'target': target};
  }

  // ── Créer un objectif ─────────────────────────────────────
  Future<String?> createObjective({
    required String name,
    required double targetAmount,
    required double currentAmount,
    required int priority,
    required DateTime? deadline,
    required String icon,
    required String color,
  }) async {
    if (name.trim().isEmpty) return 'Veuillez entrer un nom.';
    if (targetAmount <= 0) return 'Le montant cible doit être supérieur à 0.';
    if (currentAmount < 0) return 'Le montant épargné ne peut pas être négatif.';
    if (currentAmount > targetAmount) return 'Le montant épargné dépasse le montant cible.';

    _setLoading(true);
    try {
      final deadlineStr = deadline != null
          ? DateFormat('MMM yyyy', 'fr').format(deadline)
          : 'Sans limite';

      final objective = Objective(
        id: '',
        name: name.trim(),
        targetAmount: targetAmount,
        currentAmount: currentAmount,
        priority: priority,
        deadline: deadlineStr,
        deadlineTimestamp: deadline != null ? Timestamp.fromDate(deadline) : null,
        icon: icon,
        color: color,
        suggestion: 0, // sera généré par l'IA plus tard
      );

      await _goalsRef.add(objective.toMap());
      return null;
    } catch (e) {
      return 'Erreur lors de la création : $e';
    } finally {
      _setLoading(false);
    }
  }

  // ── Accepter suggestion — DÉSACTIVÉE (TODO: Sprint IA) ────
  Future<String?> acceptSuggestion(Objective obj) async {
    return null; // no-op pour le moment
  }

  // ── Ajouter un montant à un objectif ─────────────────────
  Future<String?> addAmountToObjective({
    required String id,
    required double amount,
  }) async {
    if (amount <= 0) return 'Le montant doit être supérieur à 0.';

    try {
      final userRef = _firestore.collection('users').doc(_uid);
      final objRef = _goalsRef.doc(id);

      return await _firestore.runTransaction((tx) async {
        final userSnap = await tx.get(userRef);
        final objSnap = await tx.get(objRef);

        if (!objSnap.exists) return 'Objectif introuvable.';

        final data = objSnap.data() as Map<String, dynamic>;
        final current = (data['currentAmount'] ?? 0).toDouble();
        final target  = (data['targetAmount']  ?? 0).toDouble();

        final balance = (userSnap.data()?['initialBalance'] ?? 0).toDouble();
        if (balance < amount) return 'Solde insuffisant (${balance.toStringAsFixed(2)} TND disponibles).';

        final newCurrent = (current + amount).clamp(0.0, target);
        tx.update(objRef,  {'currentAmount': newCurrent});
        tx.update(userRef, {'initialBalance': balance - amount});
        return null;
      });
    } catch (e) {
      return 'Erreur lors de la mise à jour : $e';
    }
  }

  // ── Supprimer un objectif ──────────────────────────────────
  Future<String?> deleteObjective(String docId) async {
    try {
      await _goalsRef.doc(docId).delete();
      return null;
    } catch (e) {
      return 'Erreur lors de la suppression : $e';
    }
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}