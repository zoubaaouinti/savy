import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/budget_models.dart';
import '../models/export_models.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  // ============================================================
  //  TRANSACTIONS
  // ============================================================

  Future<void> _addTransaction({
    required String label,
    required double amount,
    required String categoryId,
    required bool isIncome,
    required DateTime date,
    String? note,
    String iconName = 'category',
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
        'label': label,
        'amount': amount,
        'categoryId': categoryId,
        'category': iconName,   // clé canonique (iconName) pour la traduction i18n
        'isIncome': isIncome,
        'date': date.millisecondsSinceEpoch,
        'note': note ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('✅ Transaction ajoutée: $label');
    } catch (e) {
      print('❌ Erreur ajout transaction: $e');
      rethrow;
    }
  }

  Future<void> addExpense({
    required String categoryId,
    required double amount,
    required String note,
    required DateTime date,
  }) async {
    try {
      if (_userId.isEmpty) throw Exception('Utilisateur non connecté');

      // Récupérer l'iconName (clé canonique i18n) depuis le doc budget
      final categoryDoc = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('budget')
          .doc(categoryId)
          .get();
      final iconName = categoryDoc.exists
          ? (categoryDoc.data()?['iconName'] ?? 'category')
          : 'category';

      await _addTransaction(
        label: note,          // label vide si pas de note → affiché traduit côté UI
        amount: amount,
        categoryId: categoryId,
        isIncome: false,
        date: date,
        note: note,
        iconName: iconName,
      );

      await _updateBudgetSpent(categoryId, amount);
      print('✅ Dépense ajoutée: $iconName - $amount TND');
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout de la dépense: $e');
    }
  }

  Future<void> addRevenue({
    required String source,
    required double amount,
    required String type,
    required DateTime date,
    String? note,
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
        'note': note ?? '',
      });

      print('✅ Revenu ajouté: $source - $amount TND');
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout du revenu: $e');
    }
  }

  // ============================================================
  //  GESTION DES BUDGETS (CRUD)
  // ============================================================

  /// Ajouter une nouvelle catégorie de budget
  Future<void> addBudgetCategory({
    required String name,
    required double budget,
    required String iconName,
    required int colorValue,
  }) async {
    try {
      if (_userId.isEmpty) throw Exception('Utilisateur non connecté');

      final docRef = _firestore
          .collection('users')
          .doc(_userId)
          .collection('budget')
          .doc(); // ID automatique

      await docRef.set({
        'name': name,
        'spent': 0.0,
        'budget': budget,
        'iconName': iconName,
        'colorValue': colorValue,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('✅ Catégorie budget ajoutée: $name');
    } catch (e) {
      throw Exception('Erreur ajout catégorie: $e');
    }
  }

  /// Modifier une catégorie de budget
  Future<void> updateBudgetCategory({
    required String id,
    required String name,
    required double budget,
    required String iconName,
    required int colorValue,
  }) async {
    try {
      if (_userId.isEmpty) return;

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('budget')
          .doc(id)
          .update({
        'name': name,
        'budget': budget,
        'iconName': iconName,
        'colorValue': colorValue,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Catégorie budget modifiée: $name');
    } catch (e) {
      throw Exception('Erreur modification catégorie: $e');
    }
  }

  /// Supprimer une catégorie de budget (seulement si aucune transaction associée)
  Future<void> deleteBudgetCategory(String id) async {
    try {
      if (_userId.isEmpty) return;

      // Vérifier s'il existe des transactions liées à cette catégorie
      final transactionsQuery = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('transactions')
          .where('categoryId', isEqualTo: id)
          .limit(1)
          .get();

      if (transactionsQuery.docs.isNotEmpty) {
        throw Exception('Impossible de supprimer : des transactions existent pour cette catégorie');
      }

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('budget')
          .doc(id)
          .delete();

      print('✅ Catégorie budget supprimée: $id');
    } catch (e) {
      throw Exception('Erreur suppression catégorie: $e');
    }
  }

  /// Mettre à jour le budget (montant) d'une catégorie (méthode existante, mais avec id)
  Future<void> updateBudget(String categoryId, double newBudget) async {
    try {
      if (_userId.isEmpty) return;

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('budget')
          .doc(categoryId)
          .update({
        'budget': newBudget,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Budget mis à jour: $categoryId -> $newBudget');
    } catch (e) {
      print('❌ Erreur mise à jour budget: $e');
      throw Exception('Erreur mise à jour budget: $e');
    }
  }

  // ============================================================
  //  MISE À JOUR DES DÉPENSES (interne)
  // ============================================================

  Future<void> _updateBudgetSpent(String categoryId, double amount) async {
    try {
      if (_userId.isEmpty) return;

      final budgetDoc = _firestore
          .collection('users')
          .doc(_userId)
          .collection('budget')
          .doc(categoryId);

      final doc = await budgetDoc.get();
      if (doc.exists) {
        final currentSpent = (doc.data()?['spent'] ?? 0).toDouble();
        final newSpent = currentSpent + amount;
        await budgetDoc.update({
          'spent': newSpent,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        print('✅ Budget mis à jour: $categoryId - Dépensé: $newSpent TND');
      } else {
        print('⚠️ Catégorie non trouvée: $categoryId');
      }
    } catch (e) {
      print('❌ Erreur mise à jour budget: $e');
    }
  }

  Future<void> _decrementBudgetSpent(String categoryId, double amount) async {
    try {
      if (_userId.isEmpty) return;

      final budgetDoc = _firestore
          .collection('users')
          .doc(_userId)
          .collection('budget')
          .doc(categoryId);

      final doc = await budgetDoc.get();
      if (doc.exists) {
        final currentSpent = (doc.data()?['spent'] ?? 0).toDouble();
        final newSpent = (currentSpent - amount).clamp(0.0, double.infinity);
        await budgetDoc.update({
          'spent': newSpent,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        print('✅ Budget mis à jour (suppression): $categoryId - Dépensé: $newSpent TND');
      }
    } catch (e) {
      print('❌ Erreur mise à jour budget (suppression): $e');
    }
  }

  // ============================================================
  //  SUPPRESSION / MODIFICATION DE TRANSACTIONS
  // ============================================================

  Future<void> deleteTransaction(String transactionId) async {
    try {
      if (_userId.isEmpty) return;

      final doc = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('transactions')
          .doc(transactionId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        final categoryId = data['categoryId'] as String?;
        final amount = (data['amount'] as num?)?.toDouble() ?? 0;
        final isIncome = data['isIncome'] as bool? ?? false;

        if (!isIncome && categoryId != null && amount > 0) {
          await _decrementBudgetSpent(categoryId, amount);
        }
      }

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

  Future<void> updateTransaction(
      String transactionId, {
        required String label,
        required double amount,
        required String categoryId,
        required String note,
      }) async {
    try {
      if (_userId.isEmpty) return;

      final oldDoc = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('transactions')
          .doc(transactionId)
          .get();

      if (!oldDoc.exists) return;

      final oldData = oldDoc.data()!;
      final oldCategoryId = oldData['categoryId'] as String?;
      final oldAmount = (oldData['amount'] as num?)?.toDouble() ?? 0;
      final oldIsIncome = oldData['isIncome'] as bool? ?? false;

      if (!oldIsIncome && oldCategoryId != null) {
        await _decrementBudgetSpent(oldCategoryId, oldAmount);
      }

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('transactions')
          .doc(transactionId)
          .update({
        'label': label,
        'amount': amount,
        'categoryId': categoryId,
        'note': note,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!oldIsIncome) {
        await _updateBudgetSpent(categoryId, amount);
      }

      print('✅ Transaction modifiée: $transactionId');
    } catch (e) {
      print('❌ Erreur modification transaction: $e');
      throw Exception('Erreur lors de la modification: $e');
    }
  }

  // ============================================================
  //  GESTION DES REVENUS (CRUD)
  // ============================================================

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

  // ============================================================
  //  STREAMS (temps réel)
  // ============================================================

  Stream<List<BudgetCategory>> getBudgetsStream() {
    if (_userId.isEmpty) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('budget')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      return BudgetCategory.fromMap(doc.id, doc.data());
    }).toList());
  }

  Stream<List<TransactionSnapshot>> getTransactionsStream() {
    if (_userId.isEmpty) return Stream.value([]);

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

  Stream<List<RevenueSource>> getRevenues() {
    if (_userId.isEmpty) return Stream.value([]);

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
        date: data['date'] != null ? DateTime.fromMillisecondsSinceEpoch(data['date']) : null,
      );
    }).toList());
  }

  Stream<List<RevenueSnapshot>> getRevenuesStream() {
    if (_userId.isEmpty) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('revenues')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => RevenueSnapshot.fromMap(doc.id, doc.data()))
        .toList());
  }

  // ============================================================
  //  INITIALISATION DES BUDGETS PAR DÉFAUT
  // ============================================================

  Future<void> initializeDefaultBudgets() async {
    try {
      if (_userId.isEmpty) return;

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
        {'name': 'Alimentation', 'budget': 200.0, 'iconName': 'restaurant', 'colorValue': 0xFFFFB340},
        {'name': 'Transport', 'budget': 60.0, 'iconName': 'directions_bus', 'colorValue': 0xFF00D4FF},
        {'name': 'Loisirs', 'budget': 70.0, 'iconName': 'movie', 'colorValue': 0xFFFF5C7A},
        {'name': 'Académique', 'budget': 100.0, 'iconName': 'menu_book', 'colorValue': 0xFF7B61FF},
        {'name': 'Santé', 'budget': 50.0, 'iconName': 'favorite', 'colorValue': 0xFF3EFFA8},
        {'name': 'Autres', 'budget': 40.0, 'iconName': 'category', 'colorValue': 0xFF8BA8D4},
      ];

      final batch = _firestore.batch();

      for (final budget in defaultBudgets) {
        final docRef = _firestore
            .collection('users')
            .doc(_userId)
            .collection('budget')
            .doc(); // ID automatique
        batch.set(docRef, {
          'name': budget['name'],
          'spent': 0.0,
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

  // ============================================================
  //  MÉTHODES HELPER (icônes, couleurs)
  // ============================================================

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