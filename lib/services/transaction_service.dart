import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/budget_models.dart';
import '../models/export_models.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  // ─────────────────────────────────────────────────────────────
  //  AJOUTER UNE DÉPENSE
  // ─────────────────────────────────────────────────────────────
  Future<void> addExpense({
    required String category,
    required double amount,
    required String note,
    required DateTime date,
  }) async {
    try {
      if (_userId.isEmpty) throw Exception('Utilisateur non connecté');

      final transactionRef = _firestore
          .collection('users')
          .doc(_userId)
          .collection('transactions')
          .doc();

      await transactionRef.set({
        'id': transactionRef.id,
        'label': note.isNotEmpty ? note : 'Dépense $category',
        'amount': amount,
        'category': category,
        'isIncome': false,
        'date': date.millisecondsSinceEpoch,
        'note': note,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Mettre à jour le budget de la catégorie
      await _updateBudgetSpent(category, amount);

    } catch (e) {
      throw Exception('Erreur lors de l\'ajout de la dépense: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  AJOUTER UN REVENU
  // ─────────────────────────────────────────────────────────────
  Future<void> addRevenue({
    required String source,
    required double amount,
    required String type,
    required DateTime date,
  }) async {
    try {
      if (_userId.isEmpty) throw Exception('Utilisateur non connecté');

      final revenueRef = _firestore
          .collection('users')
          .doc(_userId)
          .collection('revenues')
          .doc();

      await revenueRef.set({
        'id': revenueRef.id,
        'source': source,
        'amount': amount,
        'type': type,
        'date': date.millisecondsSinceEpoch,
        'createdAt': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      throw Exception('Erreur lors de l\'ajout du revenu: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  METTRE À JOUR LE BUDGET DÉPENSÉ
  // ─────────────────────────────────────────────────────────────
  Future<void> _updateBudgetSpent(String categoryName, double amount) async {
    try {
      if (_userId.isEmpty) return;

      final budgetQuery = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('budget')
          .where('name', isEqualTo: categoryName)
          .limit(1)
          .get();

      if (budgetQuery.docs.isNotEmpty) {
        final budgetDoc = budgetQuery.docs.first;
        final currentSpent = (budgetDoc.data()['spent'] ?? 0).toDouble();
        final newSpent = currentSpent + amount;

        await budgetDoc.reference.update({
          'spent': newSpent,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        print('✅ Budget mis à jour: $categoryName - Dépensé: $newSpent TND');
      } else {
        print('⚠️ Catégorie non trouvée: $categoryName');
      }

    } catch (e) {
      print('❌ Erreur mise à jour budget: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  DÉCRÉMENTER LE BUDGET DÉPENSÉ (suppression de dépense)
  // ─────────────────────────────────────────────────────────────
  Future<void> _decrementBudgetSpent(String categoryName, double amount) async {
    try {
      if (_userId.isEmpty) return;

      final budgetQuery = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('budget')
          .where('name', isEqualTo: categoryName)
          .limit(1)
          .get();

      if (budgetQuery.docs.isNotEmpty) {
        final budgetDoc = budgetQuery.docs.first;
        final currentSpent = (budgetDoc.data()['spent'] ?? 0).toDouble();
        final newSpent = (currentSpent - amount).clamp(0.0, double.infinity);

        await budgetDoc.reference.update({
          'spent': newSpent,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        print('✅ Budget mis à jour (suppression): $categoryName - Dépensé: $newSpent TND');
      }
    } catch (e) {
      print('❌ Erreur mise à jour budget (suppression): $e');
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  SUPPRIMER UNE TRANSACTION
  // ─────────────────────────────────────────────────────────────
  Future<void> deleteTransaction(String transactionId) async {
    try {
      if (_userId.isEmpty) return;

      // Récupérer la transaction avant suppression pour connaître la catégorie et le montant
      final doc = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('transactions')
          .doc(transactionId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        final category = data['category'] as String?;
        final amount = (data['amount'] as num?)?.toDouble() ?? 0;
        final isIncome = data['isIncome'] as bool? ?? false;

        // Si c'est une dépense, décrémenter le budget
        if (!isIncome && category != null && amount > 0) {
          await _decrementBudgetSpent(category, amount);
        }
      }

      // Supprimer la transaction
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('transactions')
          .doc(transactionId)
          .delete();

      print('✅ Transaction supprimée: $transactionId');
    } catch (e) {
      print('❌ Erreur suppression transaction: $e');
      throw Exception('Erreur lors de la suppression: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  MODIFIER UNE TRANSACTION
  // ─────────────────────────────────────────────────────────────
  Future<void> updateTransaction(
      String transactionId, {
        required String label,
        required double amount,
        required String category,
        required String note,
      }) async {
    try {
      if (_userId.isEmpty) return;

      // Récupérer l'ancienne transaction pour ajuster les budgets
      final oldDoc = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('transactions')
          .doc(transactionId)
          .get();

      if (!oldDoc.exists) return;

      final oldData = oldDoc.data()!;
      final oldCategory = oldData['category'] as String?;
      final oldAmount = (oldData['amount'] as num?)?.toDouble() ?? 0;
      final oldIsIncome = oldData['isIncome'] as bool? ?? false;

      // Si c'est une dépense, ajuster les budgets
      if (!oldIsIncome && oldCategory != null) {
        // Retirer l'ancien montant
        await _decrementBudgetSpent(oldCategory, oldAmount);
      }

      // Mettre à jour la transaction
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('transactions')
          .doc(transactionId)
          .update({
        'label': label,
        'amount': amount,
        'category': category,
        'note': note,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Si c'est une dépense, ajouter le nouveau montant
      if (!oldIsIncome) {
        await _updateBudgetSpent(category, amount);
      }

      print('✅ Transaction modifiée: $transactionId');
    } catch (e) {
      print('❌ Erreur modification transaction: $e');
      throw Exception('Erreur lors de la modification: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  SUPPRIMER UN REVENU
  // ─────────────────────────────────────────────────────────────
  Future<void> deleteRevenue(String revenueId) async {
    try {
      if (_userId.isEmpty) return;

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('revenues')
          .doc(revenueId)
          .delete();

      print('✅ Revenu supprimé: $revenueId');
    } catch (e) {
      print('❌ Erreur suppression revenu: $e');
      throw Exception('Erreur lors de la suppression du revenu: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  MODIFIER UN REVENU
  // ─────────────────────────────────────────────────────────────
  Future<void> updateRevenue(
      String revenueId, {
        required String source,
        required double amount,
        required String type,
      }) async {
    try {
      if (_userId.isEmpty) return;

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('revenues')
          .doc(revenueId)
          .update({
        'source': source,
        'amount': amount,
        'type': type,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Revenu modifié: $revenueId');
    } catch (e) {
      print('❌ Erreur modification revenu: $e');
      throw Exception('Erreur lors de la modification du revenu: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  METTRE À JOUR LE BUDGET D'UNE CATÉGORIE
  // ─────────────────────────────────────────────────────────────
  Future<void> updateBudget(String categoryName, double newBudget) async {
    try {
      if (_userId.isEmpty) return;

      final budgetQuery = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('budget')
          .where('name', isEqualTo: categoryName)
          .limit(1)
          .get();

      if (budgetQuery.docs.isNotEmpty) {
        final budgetDoc = budgetQuery.docs.first;
        await budgetDoc.reference.update({
          'budget': newBudget,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        print('✅ Budget mis à jour: $categoryName -> $newBudget');
      } else {
        print('⚠️ Catégorie non trouvée: $categoryName');
      }
    } catch (e) {
      print('❌ Erreur mise à jour budget: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  STREAM DES BUDGETS (temps réel)
  // ─────────────────────────────────────────────────────────────
  Stream<List<BudgetCategory>> getBudgetsStream() {
    if (_userId.isEmpty) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('budget')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      final data = doc.data();
      return BudgetCategory(
        name: data['name'] ?? '',
        spent: (data['spent'] ?? 0).toDouble(),
        budget: (data['budget'] ?? 0).toDouble(),
        iconName: data['iconName'] ?? 'category',
        colorValue: data['colorValue'] ?? 0xFF8BA8D4,
      );
    }).toList());
  }

  // ─────────────────────────────────────────────────────────────
  //  RÉCUPÉRER LES BUDGETS (une fois)
  // ─────────────────────────────────────────────────────────────
  Future<List<BudgetCategory>> getBudgets() async {
    try {
      if (_userId.isEmpty) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('budget')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return BudgetCategory(
          name: data['name'] ?? '',
          spent: (data['spent'] ?? 0).toDouble(),
          budget: (data['budget'] ?? 0).toDouble(),
          iconName: data['iconName'] ?? 'category',
          colorValue: data['colorValue'] ?? 0xFF8BA8D4,
        );
      }).toList();

    } catch (e) {
      print('❌ Erreur récupération budgets: $e');
      return [];
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  STREAM DES TRANSACTIONS (temps réel)
  // ─────────────────────────────────────────────────────────────
  Stream<List<TransactionSnapshot>> getTransactionsStream() {
    if (_userId.isEmpty) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => TransactionSnapshot.fromMap(doc.id, doc.data()))
        .toList());
  }

  // ─────────────────────────────────────────────────────────────
  //  STREAM DES REVENUS (temps réel)
  // ─────────────────────────────────────────────────────────────
  Stream<List<RevenueSource>> getRevenues() {
    if (_userId.isEmpty) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('revenues')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      final data = doc.data();
      return RevenueSource(
        id: doc.id,
        source: data['source'] ?? '',
        amount: (data['amount'] ?? 0).toDouble(),
        type: data['type'] ?? 'Mensuel',
        iconName: _getIconNameForSource(data['source'] ?? ''),
        colorValue: _getColorForSource(data['source'] ?? ''),
      );
    }).toList());
  }

  // ─────────────────────────────────────────────────────────────
  //  INITIALISER LES BUDGETS PAR DÉFAUT
  // ─────────────────────────────────────────────────────────────
  Future<void> initializeDefaultBudgets() async {
    try {
      if (_userId.isEmpty) return;

      // Vérifier si les budgets existent déjà
      final existingBudgets = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('budget')
          .limit(1)
          .get();

      if (existingBudgets.docs.isNotEmpty) {
        print('✅ Budgets déjà initialisés');
        return;
      }

      final defaultBudgets = [
        {'name': 'Alimentation', 'spent': 0.0, 'budget': 200.0, 'iconName': 'restaurant', 'colorValue': 0xFFFFB340},
        {'name': 'Transport', 'spent': 0.0, 'budget': 60.0, 'iconName': 'directions_bus', 'colorValue': 0xFF00D4FF},
        {'name': 'Loisirs', 'spent': 0.0, 'budget': 70.0, 'iconName': 'movie', 'colorValue': 0xFFFF5C7A},
        {'name': 'Académique', 'spent': 0.0, 'budget': 100.0, 'iconName': 'menu_book', 'colorValue': 0xFF7B61FF},
        {'name': 'Santé', 'spent': 0.0, 'budget': 50.0, 'iconName': 'favorite', 'colorValue': 0xFF3EFFA8},
        {'name': 'Autres', 'spent': 0.0, 'budget': 40.0, 'iconName': 'category', 'colorValue': 0xFF8BA8D4},
      ];

      final batch = _firestore.batch();

      for (final budget in defaultBudgets) {
        final docRef = _firestore
            .collection('users')
            .doc(_userId)
            .collection('budget')
            .doc(budget['name'] as String?);

        batch.set(docRef, {
          'name': budget['name'],
          'spent': budget['spent'],
          'budget': budget['budget'],
          'iconName': budget['iconName'],
          'colorValue': budget['colorValue'],
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      print('✅ Budgets par défaut initialisés');

    } catch (e) {
      print('❌ Erreur initialisation budgets: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  MÉTHODES HELPER POUR LES ICONES ET COULEURS
  // ─────────────────────────────────────────────────────────────
  String _getIconNameForSource(String source) {
    if (source.contains('Bourse') || source.contains('bourse')) return 'school';
    if (source.contains('Job') || source.contains('travail')) return 'work';
    if (source.contains('Aide') || source.contains('familiale')) return 'family_restroom';
    return 'attach_money';
  }

  int _getColorForSource(String source) {
    if (source.contains('Bourse') || source.contains('bourse')) return 0xFF3EFFA8;
    if (source.contains('Job') || source.contains('travail')) return 0xFF00D4FF;
    if (source.contains('Aide') || source.contains('familiale')) return 0xFFFFB340;
    return 0xFF8BA8D4;
  }
}