import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../models/budget_models.dart';

// ══════════════════════════════════════════════════════════════
//  WIDGET – DonutChart
//  lib/widgets/charts/donut_chart.dart
//
//  Graphique circulaire (donut) affichant la répartition des
//  dépenses par catégorie de budget.
//  Utilise PieChart de fl_chart.
//
//  Usage :
//    DonutChart(
//      categories: vm.budgetCategories,
//      currency:   cur.format,
//    )
// ══════════════════════════════════════════════════════════════

class DonutChart extends StatefulWidget {
  final List<BudgetCategory> categories;
  final String Function(double) currency;

  const DonutChart({
    super.key,
    required this.categories,
    required this.currency,
  });

  @override
  State<DonutChart> createState() => _DonutChartState();
}

class _DonutChartState extends State<DonutChart> {
  int _touchedIndex = -1;

  // Catégories avec dépenses > 0 seulement
  List<BudgetCategory> get _active =>
      widget.categories.where((c) => c.spent > 0).toList();

  @override
  Widget build(BuildContext context) {
    final active = _active;

    if (active.isEmpty) {
      return _emptyState();
    }

    final total = active.fold<double>(0, (s, c) => s + c.spent);

    return Column(
      children: [
        // ── Donut ──────────────────────────────────────────────
        SizedBox(
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sections: _buildSections(active, total),
                  centerSpaceRadius: 58,
                  sectionsSpace:     3,
                  startDegreeOffset: -90,
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            response == null ||
                            response.touchedSection == null) {
                          _touchedIndex = -1;
                          return;
                        }
                        _touchedIndex =
                            response.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                ),
              ),

              // Texte au centre du donut
              _touchedIndex >= 0 && _touchedIndex < active.length
                  ? _centerTouched(active[_touchedIndex], total)
                  : _centerDefault(total),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Légende ─────────────────────────────────────────────
        _buildLegend(active, total),
      ],
    );
  }

  // ── Sections du PieChart ─────────────────────────────────────
  List<PieChartSectionData> _buildSections(
    List<BudgetCategory> cats,
    double total,
  ) {
    return cats.asMap().entries.map((e) {
      final i      = e.key;
      final cat    = e.value;
      final isTouched = i == _touchedIndex;
      final pct    = total > 0 ? (cat.spent / total * 100) : 0;

      return PieChartSectionData(
        value:      cat.spent,
        color:      Color(cat.colorValue),
        radius:     isTouched ? 58 : 48,
        showTitle:  isTouched,
        title:      '${pct.toStringAsFixed(0)}%',
        titleStyle: const TextStyle(
          color:      Colors.white,
          fontSize:   12,
          fontWeight: FontWeight.w700,
        ),
        badgePositionPercentageOffset: 1.0,
      );
    }).toList();
  }

  // ── Centre par défaut (total dépenses) ───────────────────────
  Widget _centerDefault(double total) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Dépenses',
          style: TextStyle(color: Color(0xFF4A6080), fontSize: 10),
        ),
        const SizedBox(height: 2),
        Text(
          widget.currency(total),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color:      Colors.white,
            fontSize:   14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  // ── Centre quand une section est sélectionnée ────────────────
  Widget _centerTouched(BudgetCategory cat, double total) {
    final pct = total > 0 ? (cat.spent / total * 100) : 0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          cat.name,
          style: TextStyle(
            color:      Color(cat.colorValue),
            fontSize:   11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          widget.currency(cat.spent),
          style: const TextStyle(
            color:      Colors.white,
            fontSize:   13,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          '${pct.toStringAsFixed(1)}%',
          style: const TextStyle(color: Color(0xFF6B8CAE), fontSize: 10),
        ),
      ],
    );
  }

  // ── Légende en grille 2 colonnes ─────────────────────────────
  Widget _buildLegend(List<BudgetCategory> cats, double total) {
    return Wrap(
      spacing:     12,
      runSpacing:   8,
      children: cats.map((cat) {
        final pct = total > 0 ? (cat.spent / total * 100) : 0;
        return SizedBox(
          width: 140,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width:  10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(cat.colorValue),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  cat.name,
                  maxLines:  1,
                  overflow:  TextOverflow.ellipsis,
                  style: const TextStyle(
                    color:    Color(0xFF8BA8D4),
                    fontSize: 11,
                  ),
                ),
              ),
              Text(
                '${pct.toStringAsFixed(0)}%',
                style: const TextStyle(
                  color:      Color(0xFF4A6080),
                  fontSize:   10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── État vide ────────────────────────────────────────────────
  Widget _emptyState() {
    return SizedBox(
      height: 100,
      child: Center(
        child: Text(
          'Aucune dépense à afficher',
          style: const TextStyle(color: Color(0xFF4A6080), fontSize: 13),
        ),
      ),
    );
  }
}
