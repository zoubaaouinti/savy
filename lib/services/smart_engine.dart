import 'dart:math' as math;

import '../models/export_models.dart';
import '../models/objective.dart';
import '../models/smart_engine_models.dart';

/// Pure rule-based computation engine.
///
/// All methods are static and side-effect free — they take plain Dart values
/// and return immutable result objects.  No Firestore, no Flutter dependencies.
class SmartEngine {
  SmartEngine._();

  // ─────────────────────────────────────────────────────────────────────────
  //  Public entry-point: compute everything in one call
  // ─────────────────────────────────────────────────────────────────────────

  /// Runs the full engine and returns a [SmartEngineResult].
  ///
  /// Parameters
  /// - [totalIncome]    Sum of all revenue sources for the current period.
  /// - [totalExpenses]  Sum of all expense transactions for the current period.
  /// - [totalBudget]    Declared spending budget ceiling (sum of BudgetCategory.budget).
  /// - [objectives]     All active savings goals from Firestore.
  /// - [transactions]   Recent transactions (used to compute daily average).
  ///                    Pass expense-only entries or the full list — the engine
  ///                    filters internally.
  /// - [now]            Override the current time (useful for testing).
  static SmartEngineResult compute({
    required double totalIncome,
    required double totalExpenses,
    required double totalBudget,
    required List<Objective> objectives,
    required List<TransactionSnapshot> transactions,
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();

    final prediction = computePrediction(
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      totalBudget: totalBudget,
      transactions: transactions,
      now: today,
    );

    final healthScore = computeHealthScore(
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      totalBudget: totalBudget,
      objectives: objectives,
    );

    final suggestions = computeSuggestions(
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      objectives: objectives,
      now: today,
    );

    final goalForecasts = computeGoalForecasts(
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      objectives: objectives,
      now: today,
    );

    return SmartEngineResult(
      suggestions: suggestions,
      healthScore: healthScore,
      prediction: prediction,
      goalForecasts: goalForecasts,
      computedAt: today,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  1. Saving Suggestions
  // ─────────────────────────────────────────────────────────────────────────

  /// Distributes the available budget surplus among incomplete objectives.
  ///
  /// Algorithm
  /// 1. Compute the monthly surplus available for goal savings.
  /// 2. For each eligible (non-completed, non-expired) objective compute:
  ///    - [monthlyRequired] = remaining / monthsLeft
  ///    - a priority weight = baseWeight × urgencyMultiplier
  /// 3. Allocate proportionally, then cap each allocation at [monthlyRequired]
  ///    so we never over-allocate to a single goal.
  /// 4. Redistribute freed capacity from capped goals to under-served ones
  ///    (single redistribution pass).
  static List<SavingSuggestion> computeSuggestions({
    required double totalIncome,
    required double totalExpenses,
    required List<Objective> objectives,
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();

    final surplus = math.max(0.0, totalIncome - totalExpenses);
    if (surplus == 0 || objectives.isEmpty) return [];

    // Eligible: not completed, has a future deadline, has remaining amount.
    final eligible = objectives.where((o) {
      if (o.isCompleted) return false;
      if (o.deadlineTimestamp == null) return false;
      final deadline = o.deadlineTimestamp!.toDate();
      return deadline.isAfter(today) && o.remaining > 0;
    }).toList();

    if (eligible.isEmpty) return [];

    // ── Step 1: compute months left and monthly required ──────────────────
    final List<_GoalCalc> calcs = eligible.map((o) {
      final deadline = o.deadlineTimestamp!.toDate();
      final daysLeft = deadline.difference(today).inDays;
      final monthsLeft = math.max(1, (daysLeft / 30.0).ceil());
      final monthlyRequired = o.remaining / monthsLeft;
      return _GoalCalc(objective: o, monthsLeft: monthsLeft, monthlyRequired: monthlyRequired);
    }).toList();

    // ── Step 2: compute weights ───────────────────────────────────────────
    // Priority is 1-based (1 = highest).  Convert to a positive weight.
    final weights = calcs.map((c) {
      final priorityWeight = 1.0 / math.max(1, c.objective.priority);
      return priorityWeight * _urgencyMultiplier(c.monthsLeft);
    }).toList();

    final totalWeight = weights.fold(0.0, (a, b) => a + b);

    // ── Step 3: first-pass proportional allocation ────────────────────────
    final allocations = List<double>.generate(calcs.length, (i) {
      return (weights[i] / totalWeight) * surplus;
    });

    // ── Step 4: cap at monthlyRequired, collect freed budget ──────────────
    double freed = 0.0;
    for (int i = 0; i < calcs.length; i++) {
      if (allocations[i] > calcs[i].monthlyRequired) {
        freed += allocations[i] - calcs[i].monthlyRequired;
        allocations[i] = calcs[i].monthlyRequired;
      }
    }

    // ── Step 5: single redistribution pass for freed amount ───────────────
    if (freed > 0.01) {
      final underserved = <int>[];
      for (int i = 0; i < calcs.length; i++) {
        if (allocations[i] < calcs[i].monthlyRequired) underserved.add(i);
      }
      if (underserved.isNotEmpty) {
        final shareEach = freed / underserved.length;
        for (final idx in underserved) {
          final space = calcs[idx].monthlyRequired - allocations[idx];
          allocations[idx] += math.min(shareEach, space);
        }
      }
    }

    // ── Step 6: build results ─────────────────────────────────────────────
    final results = <SavingSuggestion>[];
    for (int i = 0; i < calcs.length; i++) {
      final c = calcs[i];
      final o = c.objective;
      final suggested = _round(allocations[i]);

      // On-track: if user saves [suggested] each month, will they meet goal?
      final projectedFinal = o.currentAmount + suggested * c.monthsLeft;
      final isOnTrack = projectedFinal >= o.targetAmount * 0.95;

      results.add(SavingSuggestion(
        objectiveId: o.id,
        objectiveName: o.name,
        suggestedAmount: suggested,
        monthlyRequired: _round(c.monthlyRequired),
        progressPercent: _round(o.progress * 100),
        monthsLeft: c.monthsLeft,
        priority: o.priority,
        isOnTrack: isOnTrack,
      ));
    }

    // Return sorted by priority then urgency (fewest months first).
    results.sort((a, b) {
      final pCmp = a.priority.compareTo(b.priority);
      if (pCmp != 0) return pCmp;
      return a.monthsLeft.compareTo(b.monthsLeft);
    });

    return results;
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  2. Financial Health Score
  // ─────────────────────────────────────────────────────────────────────────

  /// Computes a 0–100 composite health score from three components:
  ///
  /// | Component       | Weight | Metric                                   |
  /// |-----------------|--------|------------------------------------------|
  /// | Savings rate    |   40   | (income − expenses) / income             |
  /// | Budget control  |   35   | 1 − expenses / totalBudget               |
  /// | Goal progress   |   25   | mean of objective.progress values        |
  ///
  /// The savings-rate component awards full marks at ≥ 20 % savings.
  static HealthScore computeHealthScore({
    required double totalIncome,
    required double totalExpenses,
    required double totalBudget,
    required List<Objective> objectives,
  }) {
    // Guard: no income data yet.
    if (totalIncome <= 0) {
      return HealthScore.fromComponents(
        savingsRate: 0,
        budgetControl: 0,
        avgGoalProgress: _avgProgress(objectives),
      );
    }

    final savingsRate = math.max(0.0, (totalIncome - totalExpenses) / totalIncome);

    final budgetControl = totalBudget > 0
        ? math.max(0.0, 1.0 - totalExpenses / totalBudget)
        : (totalExpenses <= totalIncome ? 1.0 : 0.0);

    return HealthScore.fromComponents(
      savingsRate: savingsRate,
      budgetControl: budgetControl,
      avgGoalProgress: _avgProgress(objectives),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  3. Spending Prediction
  // ─────────────────────────────────────────────────────────────────────────

  /// Estimates end-of-month spending based on the average daily expense rate.
  ///
  /// The analysis window is the span of days covered by the provided
  /// [transactions].  If fewer than 3 days of history are available the engine
  /// uses a conservative 30-day window (i.e. treats current spending as if it
  /// were spread over a full month).
  static SpendingPrediction computePrediction({
    required double totalIncome,
    required double totalExpenses,
    required double totalBudget,
    required List<TransactionSnapshot> transactions,
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();

    // ── Determine analysis window ─────────────────────────────────────────
    final expenseTxs = transactions.where((t) => !t.isIncome).toList();

    int analysisDays = 30;
    if (expenseTxs.isNotEmpty) {
      final dates = expenseTxs.map((t) => t.date).toList();
      final earliest = dates.reduce((a, b) => a.isBefore(b) ? a : b);
      final span = today.difference(earliest).inDays;
      if (span >= 3) analysisDays = span;
    }

    final dailyAverage = analysisDays > 0 ? totalExpenses / analysisDays : 0.0;

    // ── Days remaining in the current calendar month ──────────────────────
    final lastDayOfMonth = DateTime(today.year, today.month + 1, 0).day;
    final daysRemaining = lastDayOfMonth - today.day;

    final projectedAdditional = dailyAverage * daysRemaining;
    final projectedTotal = totalExpenses + projectedAdditional;

    final availableBalance = totalIncome - totalExpenses;
    final safetyMargin = availableBalance - projectedAdditional;

    // Days until balance is exhausted at current daily rate.
    int daysUntilExhausted = -1;
    if (dailyAverage > 0 && availableBalance > 0) {
      final days = (availableBalance / dailyAverage).floor();
      if (days <= daysRemaining) daysUntilExhausted = days;
    } else if (availableBalance <= 0) {
      daysUntilExhausted = 0;
    }

    final effectiveCeiling = totalBudget > 0 ? totalBudget : totalIncome;

    return SpendingPrediction(
      dailyAverage: _round(dailyAverage),
      projectedMonthlyTotal: _round(projectedTotal),
      currentPeriodSpent: _round(totalExpenses),
      availableBalance: _round(availableBalance),
      willExceedIncome: projectedTotal > totalIncome,
      willExceedBudget: totalBudget > 0 && projectedTotal > effectiveCeiling,
      daysUntilBalanceExhausted: daysUntilExhausted,
      safetyMargin: _round(safetyMargin),
      analysisDays: analysisDays,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  4. Goal Success Forecasts
  // ─────────────────────────────────────────────────────────────────────────

  /// Estimates the probability (0–1) that each goal will be fully funded
  /// before its deadline given the user's current monthly surplus.
  ///
  /// Probability formula:
  ///   p = clamp(monthlySurplus / monthlyRequired, 0, 1)
  ///
  /// The monthly surplus is the net amount available for saving after
  /// expenses, split equally among active goals when there are multiple.
  static List<GoalSuccessForecast> computeGoalForecasts({
    required double totalIncome,
    required double totalExpenses,
    required List<Objective> objectives,
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();
    if (objectives.isEmpty) return [];

    final totalSurplus = math.max(0.0, totalIncome - totalExpenses);

    // Active goals = not completed, not expired.
    final activeGoals = objectives.where((o) {
      if (o.isCompleted) return false;
      if (o.deadlineTimestamp == null) return false;
      return o.deadlineTimestamp!.toDate().isAfter(today);
    }).length;

    // Each active goal gets an equal share of the surplus as its baseline
    // available monthly saving.
    final monthlySurplusPerGoal =
        activeGoals > 0 ? totalSurplus / activeGoals : 0.0;

    return objectives.map((o) {
      if (o.isCompleted) {
        return GoalSuccessForecast(
          objectiveId: o.id,
          objectiveName: o.name,
          successProbability: 1.0,
          monthlyRequired: 0,
          monthlySurplus: monthlySurplusPerGoal,
          daysRemaining: 0,
          isCompleted: true,
          isExpired: false,
        );
      }

      if (o.deadlineTimestamp == null) {
        // No deadline set — treat as a long-horizon goal with neutral probability.
        return GoalSuccessForecast(
          objectiveId: o.id,
          objectiveName: o.name,
          successProbability: totalSurplus > 0 ? 0.5 : 0.0,
          monthlyRequired: 0,
          monthlySurplus: monthlySurplusPerGoal,
          daysRemaining: -1,
          isCompleted: false,
          isExpired: false,
        );
      }

      final deadline = o.deadlineTimestamp!.toDate();
      final daysLeft = deadline.difference(today).inDays;

      if (daysLeft <= 0) {
        return GoalSuccessForecast(
          objectiveId: o.id,
          objectiveName: o.name,
          successProbability: 0.0,
          monthlyRequired: 0,
          monthlySurplus: 0,
          daysRemaining: 0,
          isCompleted: false,
          isExpired: true,
        );
      }

      final monthsLeft = math.max(1.0, daysLeft / 30.0);
      final monthlyRequired = o.remaining / monthsLeft;

      final probability = monthlyRequired > 0
          ? (monthlySurplusPerGoal / monthlyRequired).clamp(0.0, 1.0)
          : 1.0; // Already fully funded or no remaining needed.

      return GoalSuccessForecast(
        objectiveId: o.id,
        objectiveName: o.name,
        successProbability: probability,
        monthlyRequired: _round(monthlyRequired),
        monthlySurplus: _round(monthlySurplusPerGoal),
        daysRemaining: daysLeft,
        isCompleted: false,
        isExpired: false,
      );
    }).toList();
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Helpers
  // ─────────────────────────────────────────────────────────────────────────

  static double _urgencyMultiplier(int monthsLeft) {
    if (monthsLeft <= 1) return 3.0;
    if (monthsLeft <= 3) return 2.0;
    if (monthsLeft <= 6) return 1.5;
    return 1.0;
  }

  static double _round(double v, {int decimals = 2}) {
    final factor = math.pow(10, decimals).toDouble();
    return (v * factor).roundToDouble() / factor;
  }

  static double _avgProgress(List<Objective> objectives) {
    if (objectives.isEmpty) return 0.0;
    final sum = objectives.fold(0.0, (acc, o) => acc + o.progress);
    return sum / objectives.length;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Internal calculation holder (not exported)
// ─────────────────────────────────────────────────────────────────────────────

class _GoalCalc {
  final Objective objective;
  final int monthsLeft;
  final double monthlyRequired;

  const _GoalCalc({
    required this.objective,
    required this.monthsLeft,
    required this.monthlyRequired,
  });
}
