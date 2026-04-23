// ══════════════════════════════════════════════════════════════
//  SAVY – BUDGET NOTIFICATION HELPERS
//  lib/viewmodels/budget_notifications.dart
//
//  Usage — paste one of the two snippets below into whichever
//  class / screen currently calls Firestore to update spending.
//
//  ① If you have a BudgetViewModel (ChangeNotifier):
//      class BudgetViewModel extends ChangeNotifier
//          with BudgetNotificationMixin { ... }
//
//  ② If spending is updated directly from a screen, call the
//      static helper BudgetNotificationMixin.checkAndAlert()
//      right after you write the new 'spent' value to Firestore.
// ══════════════════════════════════════════════════════════════

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/budget_models.dart';
import '../services/notification_service.dart';

// ─────────────────────────────────────────────────────────────
//  Mixin — add to your BudgetViewModel
// ─────────────────────────────────────────────────────────────
mixin BudgetNotificationMixin on ChangeNotifier {

  /// Call this after any expense is recorded / updated.
  /// Pass the full updated [BudgetCategory] so we can check progress.
  Future<void> checkBudgetAlert(BudgetCategory category) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    if (category.budget <= 0) return;

    final progress = category.progress; // spent / budget, clamped 0-1

    if (progress >= 0.90) {
      await NotificationService.sendBudgetAlert(
        userId: uid,
        categoryName: category.name,
        spent: category.spent,
        budget: category.budget,
      );
    }
  }

  /// Convenience: check every category in a list at once.
  Future<void> checkAllBudgetAlerts(List<BudgetCategory> categories) async {
    for (final cat in categories) {
      await checkBudgetAlert(cat);
    }
  }
}

// ─────────────────────────────────────────────────────────────
//  Example: BudgetViewModel skeleton
//  (fill in your existing Firestore read/write logic)
// ─────────────────────────────────────────────────────────────
/*

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/budget_models.dart';
import 'budget_notifications.dart';

class BudgetViewModel extends ChangeNotifier with BudgetNotificationMixin {
  final _db   = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference get _categoriesRef =>
      _db.collection('users').doc(_uid).collection('budgetCategories');

  List<BudgetCategory> _categories = [];
  List<BudgetCategory> get categories => _categories;

  // ── Add an expense to a category ──────────────────────────
  Future<String?> addExpense({
    required String categoryId,
    required double amount,
  }) async {
    if (amount <= 0) return 'Amount must be greater than 0';
    try {
      final ref  = _categoriesRef.doc(categoryId);
      final snap = await ref.get();
      if (!snap.exists) return 'Category not found';

      final data    = snap.data() as Map<String, dynamic>;
      final current = (data['spent'] ?? 0).toDouble();
      final newSpent = current + amount;

      await ref.update({'spent': newSpent});

      // Rebuild local model and check alert threshold
      final updated = BudgetCategory.fromMap(categoryId, {
        ...data,
        'spent': newSpent,
      });

      final idx = _categories.indexWhere((c) => c.id == categoryId);
      if (idx != -1) _categories[idx] = updated;
      notifyListeners();

      // 🔔 Fire alert if ≥ 90 % of budget used
      await checkBudgetAlert(updated);

      return null;
    } catch (e) {
      return 'Error recording expense: $e';
    }
  }
}

*/
