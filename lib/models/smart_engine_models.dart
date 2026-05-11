import 'package:flutter/foundation.dart';

// ─────────────────────────────────────────────
//  Saving Suggestion  (one entry per objective)
// ─────────────────────────────────────────────

@immutable
class SavingSuggestion {
  final String objectiveId;
  final String objectiveName;

  /// Amount recommended to allocate toward this goal this month.
  final double suggestedAmount;

  /// Minimum monthly contribution needed to reach the goal on time.
  final double monthlyRequired;

  /// Current progress as a percentage (0–100).
  final double progressPercent;

  /// Full months remaining until the deadline (≥ 1).
  final int monthsLeft;

  final int priority;

  /// True when the suggested pace will reach the goal before the deadline.
  final bool isOnTrack;

  const SavingSuggestion({
    required this.objectiveId,
    required this.objectiveName,
    required this.suggestedAmount,
    required this.monthlyRequired,
    required this.progressPercent,
    required this.monthsLeft,
    required this.priority,
    required this.isOnTrack,
  });

  @override
  String toString() =>
      'SavingSuggestion($objectiveName: suggest=$suggestedAmount, '
      'required=$monthlyRequired, onTrack=$isOnTrack)';
}

// ─────────────────────────────────────────────
//  Financial Health Score
// ─────────────────────────────────────────────

/// Qualitative tier derived from the numeric score.
enum HealthLevel {
  critical, // 0–19
  poor, //  20–39
  fair, //  40–59
  good, //  60–74
  veryGood, //  75–89
  excellent, //  90–100
}

extension HealthLevelLabel on HealthLevel {
  String get label {
    switch (this) {
      case HealthLevel.critical:
        return 'Critical';
      case HealthLevel.poor:
        return 'Poor';
      case HealthLevel.fair:
        return 'Fair';
      case HealthLevel.good:
        return 'Good';
      case HealthLevel.veryGood:
        return 'Very Good';
      case HealthLevel.excellent:
        return 'Excellent';
    }
  }
}

@immutable
class HealthScore {
  /// Composite score 0–100.
  final int total;

  // ── Component raw ratios (0–1) ──
  /// (income − expenses) / income  →  fraction of income not spent.
  final double savingsRate;

  /// 1 − totalExpenses / totalBudget  →  how far under budget.
  final double budgetControl;

  /// Arithmetic mean of all objective progress values (0–1).
  final double avgGoalProgress;

  // ── Component weighted scores ──
  /// Weighted 40 pts.
  final int savingsRateScore;

  /// Weighted 35 pts.
  final int budgetControlScore;

  /// Weighted 25 pts.
  final int goalProgressScore;

  final HealthLevel level;

  const HealthScore({
    required this.total,
    required this.savingsRate,
    required this.budgetControl,
    required this.avgGoalProgress,
    required this.savingsRateScore,
    required this.budgetControlScore,
    required this.goalProgressScore,
    required this.level,
  });

  static HealthLevel _levelFrom(int score) {
    if (score >= 90) return HealthLevel.excellent;
    if (score >= 75) return HealthLevel.veryGood;
    if (score >= 60) return HealthLevel.good;
    if (score >= 40) return HealthLevel.fair;
    if (score >= 20) return HealthLevel.poor;
    return HealthLevel.critical;
  }

  factory HealthScore.fromComponents({
    required double savingsRate,
    required double budgetControl,
    required double avgGoalProgress,
  }) {
    // Savings rate: full marks at 20 % savings or above.
    final srScore = ((savingsRate.clamp(0.0, 1.0) / 0.20).clamp(0.0, 1.0) * 40)
        .round();

    // Budget control: full marks when expenses ≤ budget.
    final bcScore = (budgetControl.clamp(0.0, 1.0) * 35).round();

    // Goal progress: linear 0–25.
    final gpScore = (avgGoalProgress.clamp(0.0, 1.0) * 25).round();

    final total = (srScore + bcScore + gpScore).clamp(0, 100);

    return HealthScore(
      total: total,
      savingsRate: savingsRate,
      budgetControl: budgetControl,
      avgGoalProgress: avgGoalProgress,
      savingsRateScore: srScore,
      budgetControlScore: bcScore,
      goalProgressScore: gpScore,
      level: _levelFrom(total),
    );
  }

  @override
  String toString() =>
      'HealthScore(total=$total, level=${level.label}, '
      'sr=$savingsRateScore, bc=$budgetControlScore, gp=$goalProgressScore)';
}

// ─────────────────────────────────────────────
//  Spending Prediction
// ─────────────────────────────────────────────

@immutable
class SpendingPrediction {
  /// Average daily spend derived from the analysis window.
  final double dailyAverage;

  /// totalExpenses + (dailyAverage × daysRemainingInMonth).
  final double projectedMonthlyTotal;

  /// Expenses logged so far this period.
  final double currentPeriodSpent;

  /// Income − currentPeriodSpent (positive = still within budget).
  final double availableBalance;

  /// Whether projectedMonthlyTotal will exceed total income.
  final bool willExceedIncome;

  /// Whether projectedMonthlyTotal will exceed the declared spending budget.
  final bool willExceedBudget;

  /// Estimated calendar days until the available balance hits zero.
  /// -1 means the balance will not be exhausted within the month.
  final int daysUntilBalanceExhausted;

  /// availableBalance − projected additional spend (positive = safe margin).
  final double safetyMargin;

  /// How many days of transaction data were used to compute dailyAverage.
  final int analysisDays;

  const SpendingPrediction({
    required this.dailyAverage,
    required this.projectedMonthlyTotal,
    required this.currentPeriodSpent,
    required this.availableBalance,
    required this.willExceedIncome,
    required this.willExceedBudget,
    required this.daysUntilBalanceExhausted,
    required this.safetyMargin,
    required this.analysisDays,
  });

  @override
  String toString() =>
      'SpendingPrediction(dailyAvg=$dailyAverage, projected=$projectedMonthlyTotal, '
      'exceedsIncome=$willExceedIncome, exceedsBudget=$willExceedBudget)';
}

// ─────────────────────────────────────────────
//  Goal Success Forecast  (one entry per objective)
// ─────────────────────────────────────────────

@immutable
class GoalSuccessForecast {
  final String objectiveId;
  final String objectiveName;

  /// Probability 0–1 that the goal will be met on time at current capacity.
  final double successProbability;

  /// Minimum monthly saving needed to reach the goal before the deadline.
  final double monthlyRequired;

  /// Net monthly surplus available to allocate toward goals
  /// (income − expenses, divided among active goals or just this one).
  final double monthlySurplus;

  /// Calendar days remaining until the deadline.
  final int daysRemaining;

  /// Goal is already fully funded.
  final bool isCompleted;

  /// Deadline has passed and the goal is NOT yet completed.
  final bool isExpired;

  const GoalSuccessForecast({
    required this.objectiveId,
    required this.objectiveName,
    required this.successProbability,
    required this.monthlyRequired,
    required this.monthlySurplus,
    required this.daysRemaining,
    required this.isCompleted,
    required this.isExpired,
  });

  @override
  String toString() =>
      'GoalSuccessForecast($objectiveName: prob=${(successProbability * 100).round()}%, '
      'required=$monthlyRequired, surplus=$monthlySurplus)';
}

// ─────────────────────────────────────────────
//  Aggregate result returned by SmartEngine
// ─────────────────────────────────────────────

@immutable
class SmartEngineResult {
  final List<SavingSuggestion> suggestions;
  final HealthScore healthScore;
  final SpendingPrediction prediction;
  final List<GoalSuccessForecast> goalForecasts;
  final DateTime computedAt;

  const SmartEngineResult({
    required this.suggestions,
    required this.healthScore,
    required this.prediction,
    required this.goalForecasts,
    required this.computedAt,
  });

  /// True when the engine could not derive meaningful results (e.g. no income).
  bool get hasInsufficientData =>
      healthScore.total == 0 &&
      suggestions.isEmpty &&
      goalForecasts.isEmpty;
}
