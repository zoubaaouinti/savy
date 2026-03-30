import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/budget_models.dart';
import '../models/export_models.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  // Ajouter une dépense
  Future<void> addExpense({
    required String category,
    required double amount,
    required String note,
    required DateTime date,
  }) async {
    try {
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

  // Ajouter un revenu
  Future<void> addRevenue({
    required String source,
    required double amount,
    required String type,
    required DateTime date,
  }) async {
    try {
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

  // Mettre à jour le budget dépensé
  Future<void> _updateBudgetSpent(String categoryName, double amount) async {
    try {
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

        await budgetDoc.reference.update({
          'spent': currentSpent + amount,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

    } catch (e) {
      print('Erreur mise à jour budget: $e');
    }
  }


  Stream<List<RevenueSource>> getRevenues() {
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

// Ajoutez ces méthodes helper dans TransactionService
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
  // Récupérer les budgets
  Future<List<BudgetCategory>> getBudgets() async {
    try {
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
      print('Erreur récupération budgets: $e');
      return [];
    }
  }

  // Ajoutez cette méthode dans TransactionService
  Stream<List<TransactionSnapshot>> getTransactionsStream() {
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

// Méthode pour récupérer les transactions une fois
  Future<List<TransactionSnapshot>> getTransactions() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('transactions')
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => TransactionSnapshot.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('Erreur récupération transactions: $e');
      return [];
    }
  }

  // Initialiser les budgets par défaut
  Future<void> initializeDefaultBudgets() async {
    try {
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

    } catch (e) {
      print('Erreur initialisation budgets: $e');
    }
  }
}