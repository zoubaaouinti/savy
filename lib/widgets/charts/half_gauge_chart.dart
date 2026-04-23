import 'dart:math' as math;
import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════════════
//  WIDGET – HalfGaugeChart
//  lib/widgets/charts/half_gauge_chart.dart
//
//  Jauge demi-cercle (style speedomètre) affichant le
//  pourcentage de budget utilisé.  Dessiné avec CustomPainter
//  (sans dépendance fl_chart) pour un contrôle total.
//
//  Usage :
//    HalfGaugeChart(
//      percentage: vm.budgetUsedPct,   // 0.0 → 1.0
//      remaining:  vm.remainingBudget, // montant absolu
//      currency:   cur.format,         // formatter
//    )
// ══════════════════════════════════════════════════════════════

class HalfGaugeChart extends StatelessWidget {
  final double percentage;              // 0.0 – 1.0
  final double remaining;              // montant restant
  final String Function(double) currency; // CurrencyProvider.format

  const HalfGaugeChart({
    super.key,
    required this.percentage,
    required this.remaining,
    required this.currency,
  });

  // Couleur selon le taux d'utilisation
  static Color gaugeColor(double pct) {
    if (pct <= 0.45) return const Color(0xFF3EFFA8); // vert
    if (pct <= 0.75) return const Color(0xFFFFB340); // orange
    return const Color(0xFFFF5C7A);                  // rouge
  }

  @override
  Widget build(BuildContext context) {
    final color = gaugeColor(percentage);
    final pct   = percentage.clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Arc ───────────────────────────────────────────────
        SizedBox(
          height: 110,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Arc peint
              CustomPaint(
                size: const Size(double.infinity, 110),
                painter: _HalfGaugePainter(
                  percentage: pct,
                  color:      color,
                ),
              ),

              // Texte centré dans l'arc
              Positioned(
                bottom: 4,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(pct * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        color:      color,
                        fontSize:   26,
                        fontWeight: FontWeight.w800,
                        height:     1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'utilisé',
                      style: TextStyle(
                        color:    Color(0xFF4A6080),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Montant restant ───────────────────────────────────
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width:  8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Restant : ${currency(remaining)}',
              style: const TextStyle(
                color:      Color(0xFF8BA8D4),
                fontSize:   12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── CustomPainter ─────────────────────────────────────────────

class _HalfGaugePainter extends CustomPainter {
  final double percentage; // 0.0 – 1.0
  final Color  color;

  const _HalfGaugePainter({required this.percentage, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 16.0;
    final center = Offset(size.width / 2, size.height);
    final radius = (size.width / 2) - strokeWidth;

    // Angles : π (gauche) → 2π (droite) par le bas = demi-cercle ∪
    const startAngle = math.pi;
    const totalSweep = math.pi;

    final bgPaint = Paint()
      ..style       = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap   = StrokeCap.round
      ..color       = const Color(0xFF1A2E52);

    // Arc de fond (gris foncé)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      totalSweep,
      false,
      bgPaint,
    );

    if (percentage <= 0) return;

    // Arc de progression avec dégradé couleur
    final fgPaint = Paint()
      ..style       = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap   = StrokeCap.round
      ..shader      = _buildShader(center, radius);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      totalSweep * percentage,
      false,
      fgPaint,
    );

    // Petits repères 0 % et 100 %
    _drawLabel(canvas, size, '0%',   const Offset(0, 0));
    _drawLabel(canvas, size, '100%', Offset(size.width, 0));
  }

  // Dégradé vert → orange → rouge sur toute la longueur de l'arc
  Shader _buildShader(Offset center, double radius) {
    return const LinearGradient(
      colors: [
        Color(0xFF3EFFA8), // vert
        Color(0xFFFFB340), // orange
        Color(0xFFFF5C7A), // rouge
      ],
      stops: [0.0, 0.55, 1.0],
    ).createShader(
      Rect.fromCircle(center: center, radius: radius),
    );
  }

  void _drawLabel(Canvas canvas, Size size, String text, Offset topLeft) {
    final tp = TextPainter(
      text: TextSpan(
        text:  text,
        style: const TextStyle(
          color:    Color(0xFF4A6080),
          fontSize: 9,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // Ajuste la position selon le côté
    final dx = topLeft.dx == 0 ? 4.0 : size.width - tp.width - 4;
    tp.paint(canvas, Offset(dx, size.height - tp.height - 2));
  }

  @override
  bool shouldRepaint(_HalfGaugePainter old) =>
      old.percentage != percentage || old.color != color;
}
