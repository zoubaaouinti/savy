import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../viewmodels/dashboard_view_model.dart';

// ══════════════════════════════════════════════════════════════
//  WIDGET – WeeklyBarChart
//  lib/widgets/charts/weekly_bar_chart.dart
//
//  Graphique en barres affichant l'évolution des dépenses sur
//  les 6 dernières semaines.  Utilise BarChart de fl_chart.
//
//  Usage :
//    WeeklyBarChart(
//      data:     vm.weeklyExpenses,
//      currency: cur.format,
//    )
// ══════════════════════════════════════════════════════════════

class WeeklyBarChart extends StatefulWidget {
  final List<WeeklyExpense> data;
  final String Function(double) currency;

  const WeeklyBarChart({
    super.key,
    required this.data,
    required this.currency,
  });

  @override
  State<WeeklyBarChart> createState() => _WeeklyBarChartState();
}

class _WeeklyBarChartState extends State<WeeklyBarChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    if (data.isEmpty || data.every((d) => d.amount == 0)) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: Text(
            'Aucune dépense sur les 6 dernières semaines',
            style: TextStyle(color: Color(0xFF4A6080), fontSize: 13),
          ),
        ),
      );
    }

    final maxAmount = data.fold<double>(0, (m, d) => m > d.amount ? m : d.amount);
    // Ajoute 20 % de marge en haut pour que la barre ne touche pas le bord
    final yMax = maxAmount * 1.25;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Montant touché ──────────────────────────────────────
        if (_touchedIndex >= 0 && _touchedIndex < data.length)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF3EFFA8),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Sem. ${data[_touchedIndex].weekLabel} : '
                  '${widget.currency(data[_touchedIndex].amount)}',
                  style: const TextStyle(
                    color:      Color(0xFF8BA8D4),
                    fontSize:   12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

        // ── BarChart ────────────────────────────────────────────
        SizedBox(
          height: 160,
          child: BarChart(
            BarChartData(
              maxY:        yMax == 0 ? 100 : yMax,
              barGroups:   _buildGroups(data, yMax),
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => const Color(0xFF0B1535),
                  tooltipRoundedRadius: 8,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                      BarTooltipItem(
                    widget.currency(rod.toY),
                    const TextStyle(
                      color:      Color(0xFF3EFFA8),
                      fontSize:   11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                touchCallback: (event, response) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        response == null ||
                        response.spot == null) {
                      _touchedIndex = -1;
                      return;
                    }
                    _touchedIndex = response.spot!.touchedBarGroupIndex;
                  });
                },
              ),
              titlesData: FlTitlesData(
                // Masque les axes gauche, droite, haut
                leftTitles:   const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles:  const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles:    const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                // Axe bas : étiquettes de semaine
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles:   true,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= data.length) {
                        return const SizedBox.shrink();
                      }
                      final isCurrent = idx == data.length - 1;
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          isCurrent ? '●' : data[idx].weekLabel,
                          style: TextStyle(
                            color: isCurrent
                                ? const Color(0xFF3EFFA8)
                                : const Color(0xFF4A6080),
                            fontSize:   isCurrent ? 14 : 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              gridData: FlGridData(
                show:                true,
                drawVerticalLine:    false,
                horizontalInterval:  yMax == 0 ? 25 : yMax / 4,
                getDrawingHorizontalLine: (_) => const FlLine(
                  color:       Color(0xFF1A2E52),
                  strokeWidth: 0.5,
                ),
              ),
              borderData: FlBorderData(show: false),
            ),
            swapAnimationDuration: const Duration(milliseconds: 400),
            swapAnimationCurve:    Curves.easeOutCubic,
          ),
        ),
      ],
    );
  }

  // ── Construction des groupes de barres ────────────────────────
  List<BarChartGroupData> _buildGroups(
    List<WeeklyExpense> data,
    double yMax,
  ) {
    return data.asMap().entries.map((e) {
      final i         = e.key;
      final isTouched = i == _touchedIndex;
      final isCurrent = i == data.length - 1; // semaine en cours

      final barColor = isCurrent
          ? const Color(0xFF3EFFA8)
          : const Color(0xFF1A5C4A);

      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY:         e.value.amount,
            color:       isTouched ? Colors.white : barColor,
            width:       isTouched ? 20 : 16,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(6),
            ),
            // Barre fantôme (fond) pour montrer le potentiel max
            backDrawRodData: BackgroundBarChartRodData(
              show:  true,
              toY:   yMax == 0 ? 100 : yMax,
              color: const Color(0xFF0D1B38),
            ),
          ),
        ],
      );
    }).toList();
  }
}
