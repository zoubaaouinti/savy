import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../viewmodels/dashboard_view_model.dart';

// ══════════════════════════════════════════════════════════════
//  KPI DASHBOARD – Tableau de bord créatif (HomeScreen)
//  Deux rangées de cartes arrondies + bande de statut.
//  Chaque carte est cliquable → infobulle explicative.
// ══════════════════════════════════════════════════════════════

class KpiDashboard extends StatelessWidget {
  final DashboardViewModel vm;

  const KpiDashboard({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.homeKeyIndicators,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),

        // ── Rangée 1 : Score santé + Taux suggestions ─────────
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _HealthScoreCard(score: vm.healthScore)),
              const SizedBox(width: 12),
              Expanded(
                child: _SuggestionRateCard(
                  rate: vm.suggestionAcceptanceRate,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // ── Rangée 2 : Objectifs + Dépassements + Sessions ────
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 5,
                child: _ObjectivesProgressCard(
                  progress: vm.avgObjectivesProgress,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 4,
                child: _BudgetOverrunsCard(
                  count: vm.budgetOverrunsAvoided,
                  total: vm.budgetCategories.length,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 4,
                child: _ActiveSessionsCard(
                  sessions: vm.activeSessionsThisWeek,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // ── Bande de statut : Saisie + Synchronisation ────────
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _EntryIndicatorCard(
                hasRecent: vm.hasRecentEntry,
                daysAgo:   vm.lastEntryDaysAgo,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: _OfflineSyncCard(isSynced: vm.isOfflineSynced),
            ),
          ],
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  CARTE GÉNÉRIQUE avec infobulle
// ══════════════════════════════════════════════════════════════

class _KpiCard extends StatelessWidget {
  final Widget child;
  final Color  accentColor;
  final Color  bgColor;
  final String tooltipTitle;
  final String tooltipBody;

  const _KpiCard({
    required this.child,
    required this.accentColor,
    required this.bgColor,
    required this.tooltipTitle,
    required this.tooltipBody,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showInfo(context),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color:  bgColor,
          border: Border.all(color: accentColor.withOpacity(0.25)),
          boxShadow: [
            BoxShadow(
              color:      accentColor.withOpacity(0.07),
              blurRadius: 10,
              offset:     const Offset(0, 3),
            ),
          ],
        ),
        child: child,
      ),
    );
  }

  void _showInfo(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context:      context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF0D1B38),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: accentColor.withOpacity(0.35)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width:  36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: accentColor.withOpacity(0.4),
                ),
              ),
              Text(
                tooltipTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color:      accentColor,
                  fontSize:   15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                tooltipBody,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color:    Color(0xFF8BA8D4),
                  fontSize: 13,
                  height:   1.6,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: TextButton.styleFrom(
                    backgroundColor: accentColor.withOpacity(0.12),
                    foregroundColor: accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: Text(
                    l10n.kpiDismiss,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  CARTE 1 – Score de santé financière (jauge circulaire animée)
// ══════════════════════════════════════════════════════════════

class _HealthScoreCard extends StatelessWidget {
  final int score;
  const _HealthScoreCard({required this.score});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = score >= 75
        ? const Color(0xFF3EFFA8)
        : score >= 50
            ? const Color(0xFFFFB340)
            : const Color(0xFFFF5C7A);
    final label = score >= 75
        ? l10n.homeScoreExcellent
        : score >= 50
            ? l10n.homeScoreGood
            : l10n.homeScorePoor;

    return _KpiCard(
      accentColor:  color,
      bgColor:      const Color(0xFF0A1E15),
      tooltipTitle: l10n.kpiHealthTooltipTitle,
      tooltipBody:  l10n.kpiHealthTooltipBody,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Jauge circulaire animée via fl_chart PieChart
            TweenAnimationBuilder<double>(
              tween:    Tween(begin: 0, end: score.toDouble()),
              duration: const Duration(milliseconds: 1400),
              curve:    Curves.easeOutCubic,
              builder: (_, val, __) {
                final filled = val.clamp(0.001, 99.999);
                return SizedBox(
                  width:  80,
                  height: 80,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          startDegreeOffset: 270,
                          sections: [
                            PieChartSectionData(
                              value:     filled,
                              color:     color,
                              radius:    11,
                              showTitle: false,
                            ),
                            PieChartSectionData(
                              value:     100 - filled,
                              color:     const Color(0xFF1A2E52),
                              radius:    11,
                              showTitle: false,
                            ),
                          ],
                          centerSpaceRadius: 28,
                          sectionsSpace:     0,
                          borderData: FlBorderData(show: false),
                        ),
                        duration: Duration.zero,
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${val.round()}',
                            style: TextStyle(
                              color:      color,
                              fontSize:   20,
                              fontWeight: FontWeight.w800,
                              height:     1.0,
                            ),
                          ),
                          Text(
                            '/100',
                            style: TextStyle(
                              color:    color.withOpacity(0.55),
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            Text(
              l10n.kpiHealthTitle,
              style: const TextStyle(
                color:      Colors.white,
                fontSize:   11,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: color.withOpacity(0.13),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color:      color,
                  fontSize:   10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  CARTE 2 – Taux d'acceptation des suggestions (anneau)
// ══════════════════════════════════════════════════════════════

class _SuggestionRateCard extends StatelessWidget {
  final double rate; // 0.0 – 1.0
  const _SuggestionRateCard({required this.rate});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const color = Color(0xFF00D4FF);

    return _KpiCard(
      accentColor:  color,
      bgColor:      const Color(0xFF091A24),
      tooltipTitle: l10n.kpiSuggestionsTooltipTitle,
      tooltipBody:  l10n.kpiSuggestionsTooltipBody,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween:    Tween(begin: 0, end: rate * 100),
              duration: const Duration(milliseconds: 1200),
              curve:    Curves.easeOutCubic,
              builder: (_, val, __) {
                final filled = val.clamp(0.001, 99.999);
                return SizedBox(
                  width:  80,
                  height: 80,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          startDegreeOffset: 270,
                          sections: [
                            PieChartSectionData(
                              value:     filled,
                              color:     color,
                              radius:    11,
                              showTitle: false,
                            ),
                            PieChartSectionData(
                              value:     100 - filled,
                              color:     const Color(0xFF1A2E52),
                              radius:    11,
                              showTitle: false,
                            ),
                          ],
                          centerSpaceRadius: 28,
                          sectionsSpace:     0,
                          borderData: FlBorderData(show: false),
                        ),
                        duration: Duration.zero,
                      ),
                      Text(
                        '${val.round()}%',
                        style: const TextStyle(
                          color:      color,
                          fontSize:   15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            Text(
              l10n.kpiSuggestionsTitle,
              style: const TextStyle(
                color:      Colors.white,
                fontSize:   11,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              l10n.kpiSuggestionsSubtitle,
              style: const TextStyle(color: color, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  CARTE 3 – Progression moyenne des objectifs (barre)
// ══════════════════════════════════════════════════════════════

class _ObjectivesProgressCard extends StatelessWidget {
  final double progress; // 0.0 – 1.0
  const _ObjectivesProgressCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    final l10n  = AppLocalizations.of(context);
    final pct   = (progress * 100).round();
    final color = progress >= 0.75
        ? const Color(0xFF3EFFA8)
        : progress >= 0.40
            ? const Color(0xFFFFB340)
            : const Color(0xFF00D4FF);

    return _KpiCard(
      accentColor:  color,
      bgColor:      const Color(0xFF0A1525),
      tooltipTitle: l10n.kpiObjectivesTooltipTitle,
      tooltipBody:  l10n.kpiObjectivesTooltipBody,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment:  CrossAxisAlignment.start,
          mainAxisAlignment:   MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(Icons.flag_rounded, color: color, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n.kpiObjectivesTitle,
                    style: const TextStyle(
                      color:      Colors.white,
                      fontSize:   11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '$pct%',
                  style: TextStyle(
                    color:      color,
                    fontSize:   12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TweenAnimationBuilder<double>(
              tween:    Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 1200),
              curve:    Curves.easeOut,
              builder: (_, val, __) => ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value:           val.clamp(0.0, 1.0),
                  minHeight:       8,
                  backgroundColor: const Color(0xFF1A2E52),
                  valueColor:      AlwaysStoppedAnimation(color),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.kpiObjectivesSubtitle,
              style: const TextStyle(color: Color(0xFF4A6080), fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  CARTE 4 – Dépassements de budget évités (flèche variation)
// ══════════════════════════════════════════════════════════════

class _BudgetOverrunsCard extends StatelessWidget {
  final int count; // catégories sous budget
  final int total;
  const _BudgetOverrunsCard({required this.count, required this.total});

  @override
  Widget build(BuildContext context) {
    final l10n  = AppLocalizations.of(context);
    final ratio = total > 0 ? count / total : 0.0;
    final color = ratio >= 0.8
        ? const Color(0xFF3EFFA8)
        : ratio >= 0.5
            ? const Color(0xFFFFB340)
            : const Color(0xFFFF5C7A);
    final arrowIcon = ratio >= 0.8
        ? Icons.trending_up_rounded
        : ratio >= 0.5
            ? Icons.trending_flat_rounded
            : Icons.trending_down_rounded;

    return _KpiCard(
      accentColor:  const Color(0xFFFFB340),
      bgColor:      const Color(0xFF1E1408),
      tooltipTitle: l10n.kpiBudgetTooltipTitle,
      tooltipBody:  l10n.kpiBudgetTooltipBody,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(arrowIcon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(
              '$count',
              style: TextStyle(
                color:      color,
                fontSize:   24,
                fontWeight: FontWeight.w800,
                height:     1.0,
              ),
            ),
            Text(
              l10n.kpiBudgetOutOf(total),
              style: const TextStyle(
                color:    Color(0xFF4A6080),
                fontSize: 9,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.kpiBudgetNotExceeded,
              style: const TextStyle(
                color:      Colors.white,
                fontSize:   10,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  CARTE 5 – Sessions actives cette semaine (icône calendrier)
// ══════════════════════════════════════════════════════════════

class _ActiveSessionsCard extends StatelessWidget {
  final int sessions; // jours distincts avec transactions
  const _ActiveSessionsCard({required this.sessions});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const color = Color(0xFF7B61FF);

    return _KpiCard(
      accentColor:  color,
      bgColor:      const Color(0xFF100D20),
      tooltipTitle: l10n.kpiSessionsTooltipTitle,
      tooltipBody:  l10n.kpiSessionsTooltipBody,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              color: color,
              size:  18,
            ),
            const SizedBox(height: 4),
            Text(
              '$sessions',
              style: const TextStyle(
                color:      color,
                fontSize:   24,
                fontWeight: FontWeight.w800,
                height:     1.0,
              ),
            ),
            Text(
              l10n.kpiSessionsOf7,
              style: const TextStyle(
                color:    Color(0xFF4A6080),
                fontSize: 9,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.kpiSessionsThisWeek,
              style: const TextStyle(
                color:      Colors.white,
                fontSize:   10,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  CARTE 6 – Indicateur de saisie régulière (vert / orange)
// ══════════════════════════════════════════════════════════════

class _EntryIndicatorCard extends StatelessWidget {
  final bool hasRecent;
  final int  daysAgo; // -1 si aucune saisie
  const _EntryIndicatorCard({
    required this.hasRecent,
    required this.daysAgo,
  });

  @override
  Widget build(BuildContext context) {
    final l10n  = AppLocalizations.of(context);
    final color = hasRecent
        ? const Color(0xFF3EFFA8)
        : const Color(0xFFFFB340);
    final label = hasRecent
        ? daysAgo == 0
            ? l10n.kpiToday
            : daysAgo == 1
                ? l10n.kpiYesterday
                : l10n.kpiDaysAgo(daysAgo)
        : daysAgo < 0
            ? l10n.kpiNoEntry
            : l10n.kpiOver7Days;

    return _KpiCard(
      accentColor:  color,
      bgColor:      hasRecent
          ? const Color(0xFF0A1E12)
          : const Color(0xFF1E1408),
      tooltipTitle: l10n.kpiEntryTooltipTitle,
      tooltipBody:  l10n.kpiEntryTooltipBody,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Container(
              width:  10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                boxShadow: [
                  BoxShadow(
                    color:       color.withOpacity(0.45),
                    blurRadius:  6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment:  MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.kpiLastEntry,
                    style: const TextStyle(
                      color:    Color(0xFF6B8CAE),
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      color:      color,
                      fontSize:   12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  CARTE 7 – Badge de synchronisation hors ligne
// ══════════════════════════════════════════════════════════════

class _OfflineSyncCard extends StatelessWidget {
  final bool isSynced;
  const _OfflineSyncCard({required this.isSynced});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const syncColor    = Color(0xFF60A5FA);
    const offlineColor = Color(0xFF4A6080);
    final color = isSynced ? syncColor : offlineColor;

    return _KpiCard(
      accentColor:  syncColor,
      bgColor:      const Color(0xFF0A1220),
      tooltipTitle: l10n.kpiSyncTooltipTitle,
      tooltipBody:  l10n.kpiSyncTooltipBody,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Icon(
              isSynced
                  ? Icons.cloud_done_rounded
                  : Icons.cloud_off_rounded,
              color: color,
              size:  20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isSynced ? l10n.kpiSynced : l10n.kpiOffline,
                style: TextStyle(
                  color:      color,
                  fontSize:   11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
