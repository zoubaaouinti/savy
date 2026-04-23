import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/objective.dart';
import '../services/notification_service.dart';

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

    String? goalName;
    double? newCurrent;
    double? target;

    try {
      final userRef = _firestore.collection('users').doc(_uid);
      final objRef = _goalsRef.doc(id);

      final error = await _firestore.runTransaction((tx) async {
        final userSnap = await tx.get(userRef);
        final objSnap = await tx.get(objRef);

        if (!objSnap.exists) return 'Objectif introuvable.';

        final data    = objSnap.data() as Map<String, dynamic>;
        final current = (data['currentAmount'] ?? 0).toDouble();
        target        = (data['targetAmount']  ?? 0).toDouble();
        goalName      = data['name'] as String?;

        final balance = (userSnap.data()?['initialBalance'] ?? 0).toDouble();
        if (balance < amount) {
          return 'Solde insuffisant (${balance.toStringAsFixed(2)} TND disponibles).';
        }

        newCurrent = (current + amount).clamp(0.0, target!);
        tx.update(objRef,  {'currentAmount': newCurrent});
        tx.update(userRef, {'initialBalance': balance - amount});
        return null;
      });

      // Fire notification AFTER the transaction commits (no UI in tx)
      if (error == null &&
          goalName != null &&
          newCurrent != null &&
          target != null) {
        final name = goalName!;
        final uid  = _uid;

        if (newCurrent! >= target!) {
          // 🎉 Goal completed
          await NotificationService.sendGoalCompletion(
            userId: uid,
            goalId: id,
            goalName: name,
          );
        } else {
          // 💡 Compute a simple weekly saving suggestion
          final remaining = target! - newCurrent!;
          final weeklyTarget = remaining / 4; // rough 4-week estimate
          await NotificationService.sendSavingSuggestion(
            userId: uid,
            goalName: name,
            suggestedAmount: weeklyTarget,
          );
        }
      }

      return error;
    } catch (e) {
      return 'Erreur lors de la mise à jour : $e';
    }
  }

  // ── Vérifier les objectifs proches de leur deadline ───────
  /// Call once on app start (e.g. from initState of ObjectivesScreen)
  /// to queue reminders for goals due within 3 days.
  Future<void> checkDeadlineReminders() async {
    final uid = _uid;
    final now = DateTime.now();

    try {
      final snap = await _goalsRef.get();
      for (final doc in snap.docs) {
        final obj = Objective.fromFirestore(doc);
        if (obj.isCompleted) continue;
        if (obj.deadlineTimestamp == null) continue;

        final deadline  = obj.deadlineTimestamp!.toDate();
        final daysLeft  = deadline.difference(now).inDays;

        if (daysLeft >= 0 && daysLeft <= 3) {
          await NotificationService.sendGoalReminder(
            userId: uid,
            goalId: obj.id,
            goalName: obj.name,
            daysLeft: daysLeft,
            remaining: obj.remaining,
          );
        }
      }
    } catch (e) {
      debugPrint('[ObjectivesVM] deadline check error: $e');
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