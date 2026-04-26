import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

// ══════════════════════════════════════════════════════════════
//  WIDGET – HalfGaugeChart
//  Jauge demi-cercle responsive :
//  • LayoutBuilder → hauteur = largeur / 2 pour éviter le
//    clipping de l'arc quelle que soit la largeur du parent.
//  • AppLocalizations pour "utilisé" / "Restant" multilingue.
// ══════════════════════════════════════════════════════════════

class HalfGaugeChart extends StatelessWidget {
  final double percentage;               // 0.0 – 1.0
  final double remaining;               // montant restant
  final String Function(double) currency; // CurrencyProvider.format

  const HalfGaugeChart({
    super.key,
    required this.percentage,
    required this.remaining,
    required this.currency,
  });

  static Color gaugeColor(double pct) {
    if (pct <= 0.45) return const Color(0xFF3EFFA8);
    if (pct <= 0.75) return const Color(0xFFFFB340);
    return const Color(0xFFFF5C7A);
  }

  @override
  Widget build(BuildContext context) {
    final l10n  = AppLocalizations.of(context);
    final color = gaugeColor(percentage);
    final pct   = percentage.clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Arc responsive ────────────────────────────────────
        // LayoutBuilder donne la largeur réelle du parent.
        // height = width/2 garantit que le demi-cercle tient
        // toujours dans les limites du widget sans clipping.
        LayoutBuilder(
          builder: (_, constraints) {
            final w      = constraints.maxWidth;
            final h      = w / 2;
            return SizedBox(
              height: h,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // Arc peint en taille exacte
                  CustomPaint(
                    size:    Size(w, h),
                    painter: _HalfGaugePainter(
                      percentage: pct,
                      color:      color,
                    ),
                  ),

                  // Pourcentage + libellé au centre de l'arc
                  Positioned(
                    bottom: 8,
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
                        Text(
                          l10n.homeGaugeUsed,
                          style: const TextStyle(
                            color:    Color(0xFF4A6080),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        // ── Montant restant ───────────────────────────────────
        const SizedBox(height: 10),
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
              l10n.homeGaugeRemaining(currency(remaining)),
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

  static const _strokeWidth = 14.0;

  @override
  void paint(Canvas canvas, Size size) {
    // Le centre est au bas du widget (centre du demi-cercle)
    final center = Offset(size.width / 2, size.height);
    // Le rayon laisse strokeWidth/2 de marge de chaque côté
    final radius = (size.width / 2) - _strokeWidth;

    // Arc de fond
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,       // départ : côté gauche
      math.pi,       // balayage : demi-cercle complet
      false,
      Paint()
        ..style       = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth
        ..strokeCap   = StrokeCap.round
        ..color       = const Color(0xFF1A2E52),
    );

    if (percentage <= 0) return;

    // Arc de progression avec dégradé
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi * percentage,
      false,
      Paint()
        ..style       = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth
        ..strokeCap   = StrokeCap.round
        ..shader      = _buildShader(center, radius),
    );

    // Repères 0 % et 100 %
    _drawLabel(canvas, size, '0%',    left: true);
    _drawLabel(canvas, size, '100%',  left: false);
  }

  Shader _buildShader(Offset center, double radius) {
    return const LinearGradient(
      colors: [Color(0xFF3EFFA8), Color(0xFFFFB340), Color(0xFFFF5C7A)],
      stops:  [0.0, 0.55, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: radius));
  }

  void _drawLabel(
    Canvas canvas,
    Size   size,
    String text, {
    required bool left,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text:  text,
        style: const TextStyle(color: Color(0xFF4A6080), fontSize: 9),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final dx = left ? 4.0 : size.width - tp.width - 4;
    tp.paint(canvas, Offset(dx, size.height - tp.height - 4));
  }

  @override
  bool shouldRepaint(_HalfGaugePainter old) =>
      old.percentage != percentage || old.color != color;
}
