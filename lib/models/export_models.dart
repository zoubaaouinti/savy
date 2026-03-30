// ══════════════════════════════════════════════════════════════
//  SAVVY – EXPORT MODELS
//  lib/models/export_models.dart
// ══════════════════════════════════════════════════════════════

enum ExportFormat { pdf, csv }

enum ExportSection { profile, budget, transactions, objectives, revenues }

extension ExportSectionExtension on ExportSection {
  String get label {
    switch (this) {
      case ExportSection.profile:      return 'Profil';
      case ExportSection.budget:       return 'Budget';
      case ExportSection.transactions: return 'Transactions';
      case ExportSection.objectives:   return 'Objectifs';
      case ExportSection.revenues:     return 'Revenus';
    }
  }

  String get iconName {
    switch (this) {
      case ExportSection.profile:      return 'person';
      case ExportSection.budget:       return 'wallet';
      case ExportSection.transactions: return 'receipt';
      case ExportSection.objectives:   return 'flag';
      case ExportSection.revenues:     return 'trending_up';
    }
  }

  int get colorValue {
    switch (this) {
      case ExportSection.profile:      return 0xFF3EFFA8;
      case ExportSection.budget:       return 0xFF00D4FF;
      case ExportSection.transactions: return 0xFFFFB340;
      case ExportSection.objectives:   return 0xFF7B61FF;
      case ExportSection.revenues:     return 0xFF3EFFA8;
    }
  }
}

// ── Snapshot des données utilisateur ─────────────────────────
class UserDataSnapshot {
  final String userName;
  final String userEmail;
  final DateTime exportDate;

  // Budget
  final List<BudgetCategorySnapshot> budgetCategories;

  // Transactions
  final List<TransactionSnapshot> transactions;

  // Objectifs
  final List<ObjectiveSnapshot> objectives;

  // Revenus
  final List<RevenueSnapshot> revenues;

  const UserDataSnapshot({
    required this.userName,
    required this.userEmail,
    required this.exportDate,
    required this.budgetCategories,
    required this.transactions,
    required this.objectives,
    required this.revenues,
  });

  // ── Totaux calculés ───────────────────────────────────────
  double get totalBudget =>
      budgetCategories.fold(0, (s, c) => s + c.budget);
  double get totalSpent =>
      budgetCategories.fold(0, (s, c) => s + c.spent);
  double get totalRevenue =>
      revenues.fold(0, (s, r) => s + r.amount);
  double get totalSaved =>
      objectives.fold(0, (s, o) => s + o.current);
  double get totalTarget =>
      objectives.fold(0, (s, o) => s + o.target);
  double get balance => totalRevenue - totalSpent;
}

class BudgetCategorySnapshot {
  final String name;
  final double spent;
  final double budget;
  final String color;

  const BudgetCategorySnapshot({
    required this.name,
    required this.spent,
    required this.budget,
    required this.color,
  });

  double get progress => budget == 0 ? 0 : (spent / budget).clamp(0, 1);
  bool get isOver => spent > budget;

  // Firestore
  factory BudgetCategorySnapshot.fromMap(Map<String, dynamic> map) =>
      BudgetCategorySnapshot(
        name: map['name'] ?? '',
        spent: (map['spent'] ?? 0).toDouble(),
        budget: (map['budget'] ?? 0).toDouble(),
        color: map['color'] ?? '#3EFFA8',
      );
}

class TransactionSnapshot {
  final String id;
  final String label;
  final double amount;
  final String category;
  final bool isIncome;
  final DateTime date;
  final String? note;

  const TransactionSnapshot({
    required this.id,
    required this.label,
    required this.amount,
    required this.category,
    required this.isIncome,
    required this.date,
    this.note,
  });

  String get formattedDate =>
      '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';

  String get formattedAmount =>
      '${isIncome ? '+' : '-'}${amount.toStringAsFixed(2)} TND';

  factory TransactionSnapshot.fromMap(String id, Map<String, dynamic> map) =>
      TransactionSnapshot(
        id: id,
        label: map['label'] ?? '',
        amount: (map['amount'] ?? 0).toDouble().abs(),
        category: map['category'] ?? 'Autres',
        isIncome: map['isIncome'] ?? false,
        date: map['date'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['date'])
            : DateTime.now(),
        note: map['note'],
      );
}

class ObjectiveSnapshot {
  final String id;
  final String name;
  final double current;
  final double target;
  final String deadline;
  final int priority;

  const ObjectiveSnapshot({
    required this.id,
    required this.name,
    required this.current,
    required this.target,
    required this.deadline,
    required this.priority,
  });

  double get progress => target == 0 ? 0 : (current / target).clamp(0, 1);
  double get remaining => target - current;
  String get progressPercent => '${(progress * 100).toStringAsFixed(0)}%';

  factory ObjectiveSnapshot.fromMap(String id, Map<String, dynamic> map) =>
      ObjectiveSnapshot(
        id: id,
        name: map['name'] ?? '',
        current: (map['current'] ?? 0).toDouble(),
        target: (map['target'] ?? 0).toDouble(),
        deadline: map['deadline'] ?? '',
        priority: map['priority'] ?? 1,
      );
}

class RevenueSnapshot {
  final String id;
  final String source;
  final double amount;
  final String type;

  const RevenueSnapshot({
    required this.id,
    required this.source,
    required this.amount,
    required this.type,
  });

  factory RevenueSnapshot.fromMap(String id, Map<String, dynamic> map) =>
      RevenueSnapshot(
        id: id,
        source: map['source'] ?? '',
        amount: (map['amount'] ?? 0).toDouble(),
        type: map['type'] ?? 'Mensuel',
      );
}

// ── Résultat export ───────────────────────────────────────────
class ExportResult {
  final bool isSuccess;
  final String? filePath;
  final String? errorMessage;

  const ExportResult._({
    required this.isSuccess,
    this.filePath,
    this.errorMessage,
  });

  factory ExportResult.success(String path) =>
      ExportResult._(isSuccess: true, filePath: path);
  factory ExportResult.error(String msg) =>
      ExportResult._(isSuccess: false, errorMessage: msg);
}