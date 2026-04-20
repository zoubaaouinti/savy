// ══════════════════════════════════════════════════════════════
//  SAVVY – BUDGET MODELS
//  lib/models/budget_models.dart
// ══════════════════════════════════════════════════════════════

class BudgetCategory {
  final String id;          // ← AJOUTÉ : identifiant unique Firestore
  final String name;
  final double spent;
  final double budget;
  final String iconName;    // nom de l'icône pour Firestore
  final int colorValue;     // valeur hexadécimale pour Firestore

  const BudgetCategory({
    required this.id,
    required this.name,
    required this.spent,
    required this.budget,
    required this.iconName,
    required this.colorValue,
  });

  double get progress => (spent / budget).clamp(0.0, 1.0);
  double get remaining => budget - spent;
  bool get isOver => spent > budget;

  // ── Firestore ─────────────────────────────────────────────
  // La méthode fromMap reçoit maintenant l'id du document en premier paramètre
  factory BudgetCategory.fromMap(String id, Map<String, dynamic> map) {
    return BudgetCategory(
      id: id,
      name: map['name'] ?? '',
      spent: (map['spent'] ?? 0).toDouble(),
      budget: (map['budget'] ?? 0).toDouble(),
      iconName: map['iconName'] ?? 'category',
      colorValue: map['colorValue'] ?? 0xFF8BA8D4,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'spent': spent,
      'budget': budget,
      'iconName': iconName,
      'colorValue': colorValue,
    };
  }

  BudgetCategory copyWith({
    String? id,
    String? name,
    double? spent,
    double? budget,
    String? iconName,
    int? colorValue,
  }) {
    return BudgetCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      spent: spent ?? this.spent,
      budget: budget ?? this.budget,
      iconName: iconName ?? this.iconName,
      colorValue: colorValue ?? this.colorValue,
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  REVENUES – inchangé
// ─────────────────────────────────────────────────────────────

class RevenueSource {
  final String id;
  final String source;
  final double amount;
  final String type; // Mensuel, Hebdomadaire, Irrégulier
  final String iconName;
  final int colorValue;
  final DateTime? date;

  const RevenueSource({
    required this.id,
    required this.source,
    required this.amount,
    required this.type,
    required this.iconName,
    required this.colorValue,
    this.date,
  });

  factory RevenueSource.fromMap(String id, Map<String, dynamic> map) {
    return RevenueSource(
      id: id,
      source: map['source'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      type: map['type'] ?? 'Mensuel',
      iconName: map['iconName'] ?? 'work',
      colorValue: map['colorValue'] ?? 0xFF3EFFA8,
      date: map['date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['date'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'source': source,
      'amount': amount,
      'type': type,
      'iconName': iconName,
      'colorValue': colorValue,
      if (date != null) 'date': date!.millisecondsSinceEpoch,
    };
  }
}

// ─────────────────────────────────────────────────────────────
//  BUDGET SUMMARY – inchangé
// ─────────────────────────────────────────────────────────────

class BudgetSummary {
  final double totalBudget;
  final double totalSpent;

  const BudgetSummary({
    required this.totalBudget,
    required this.totalSpent,
  });

  double get remaining => totalBudget - totalSpent;
  double get usagePercent =>
      totalBudget == 0 ? 0 : (totalSpent / totalBudget * 100).clamp(0, 100);
}