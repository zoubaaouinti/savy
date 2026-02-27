import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../main.dart';

// ══════════════════════════════════════════════════════════════
//  SAVVY – SPLASH SCREEN
//  Responsive · Animated · Professional
// ══════════════════════════════════════════════════════════════

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Controllers ──────────────────────────────────────────────
  late final AnimationController _bgController;
  late final AnimationController _logoController;
  late final AnimationController _textController;
  late final AnimationController _taglineController;
  late final AnimationController _dotsController;
  late final AnimationController _exitController;
  late final AnimationController _particleController;
  late final AnimationController _ringController;

  // ── Animations ───────────────────────────────────────────────
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _taglineOpacity;
  late final Animation<Offset> _taglineSlide;
  late final Animation<double> _bgAnim;
  late final Animation<double> _exitOpacity;
  late final Animation<double> _exitScale;
  late final Animation<double> _ringAnim;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    _setupAnimations();
    _startSequence();
  }

  void _setupAnimations() {
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _bgAnim = CurvedAnimation(parent: _bgController, curve: Curves.easeInOut);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _ringAnim = CurvedAnimation(parent: _ringController, curve: Curves.linear);

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _logoScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.2)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 65,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 35,
      ),
    ]).animate(_logoController);

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeIn),
      ),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );

    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeOut),
    );

    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.6),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeOutCubic),
    );

    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _exitOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInCubic),
    );

    _exitScale = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeIn),
    );
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();

    await Future.delayed(const Duration(milliseconds: 450));
    _taglineController.forward();

    // ── Replace with real Firebase init ──
    await Future.delayed(const Duration(milliseconds: 2200));

    await _exitController.forward();

    if (mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _bgController.dispose();
    _logoController.dispose();
    _textController.dispose();
    _taglineController.dispose();
    _dotsController.dispose();
    _exitController.dispose();
    _particleController.dispose();
    _ringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide > 600;
    final logoSize = (isTablet ? size.width * 0.16 : size.width * 0.26)
        .clamp(90.0, 200.0);

    return Scaffold(
      backgroundColor: const Color(0xFF060D1F),
      body: AnimatedBuilder(
        animation: Listenable.merge([_exitController]),
        builder: (context, child) => FadeTransition(
          opacity: _exitOpacity,
          child: ScaleTransition(
            scale: _exitScale,
            child: _buildContent(size, logoSize),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(Size size, double logoSize) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF060D1F),
            Color(0xFF0B1535),
            Color(0xFF060D1F),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Background orbs
          AnimatedBuilder(
            animation: _bgAnim,
            builder: (_, __) => CustomPaint(
              size: size,
              painter: _OrbPainter(_bgAnim.value),
            ),
          ),

          // Particles
          AnimatedBuilder(
            animation: _particleController,
            builder: (_, __) => CustomPaint(
              size: size,
              painter: _ParticlePainter(_particleController.value),
            ),
          ),

          // Grid
          CustomPaint(
            size: size,
            painter: _GridPainter(),
          ),

          // Top accent line
          AnimatedBuilder(
            animation: _textController,
            builder: (_, __) => Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: _textOpacity.value,
                child: Container(
                  height: 2,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Color(0xFF3EFFA8),
                        Color(0xFF00D4FF),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Main center content
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),
                _buildLogo(logoSize),
                SizedBox(height: size.height * 0.045),
                _buildAppName(size),
                SizedBox(height: size.height * 0.014),
                _buildTagline(size),
                const Spacer(flex: 3),
                _buildLoadingDots(size),
                SizedBox(height: size.height * 0.055),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(double size) {
    return AnimatedBuilder(
      animation: Listenable.merge([_logoController, _ringController]),
      builder: (_, __) => FadeTransition(
        opacity: _logoOpacity,
        child: Transform.scale(
          scale: _logoScale.value,
          child: SizedBox(
            width: size * 1.6,
            height: size * 1.6,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer rotating ring
                Transform.rotate(
                  angle: _ringAnim.value * 2 * math.pi,
                  child: CustomPaint(
                    size: Size(size * 1.5, size * 1.5),
                    painter: _RingPainter(
                      color: const Color(0xFF3EFFA8),
                      strokeWidth: 1.5,
                      dashCount: 20,
                    ),
                  ),
                ),
                // Inner counter-rotating ring
                Transform.rotate(
                  angle: -_ringAnim.value * 2 * math.pi * 0.6,
                  child: CustomPaint(
                    size: Size(size * 1.25, size * 1.25),
                    painter: _RingPainter(
                      color: const Color(0xFF00D4FF).withOpacity(0.5),
                      strokeWidth: 1.0,
                      dashCount: 12,
                    ),
                  ),
                ),
                // Glow
                Container(
                  width: size * 1.1,
                  height: size * 1.1,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3EFFA8).withOpacity(0.25),
                        blurRadius: size * 0.6,
                        spreadRadius: size * 0.05,
                      ),
                    ],
                  ),
                ),
                // Logo circle
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1A2E52),
                        Color(0xFF0D1B38),
                      ],
                    ),
                    border: Border.all(
                      color: const Color(0xFF3EFFA8).withOpacity(0.6),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3EFFA8).withOpacity(0.3),
                        blurRadius: size * 0.4,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Center(
                    child: _SavyMark(size: size * 0.52),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppName(Size size) {
    final fontSize = (size.width * 0.115).clamp(36.0, 72.0);
    return AnimatedBuilder(
      animation: _textController,
      builder: (_, __) => FadeTransition(
        opacity: _textOpacity,
        child: SlideTransition(
          position: _textSlide,
          child: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF3EFFA8), Color(0xFF00D4FF), Color(0xFFB8FFEA)],
              stops: [0.0, 0.5, 1.0],
            ).createShader(bounds),
            child: Text(
              'Savy',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w800,
                letterSpacing: fontSize * 0.06,
                color: Colors.white,
                height: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTagline(Size size) {
    final fontSize = (size.width * 0.038).clamp(13.0, 20.0);
    return AnimatedBuilder(
      animation: _taglineController,
      builder: (_, __) => FadeTransition(
        opacity: _taglineOpacity,
        child: SlideTransition(
          position: _taglineSlide,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 28,
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      const Color(0xFF3EFFA8).withOpacity(0.6),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Gérez vos finances, atteignez vos objectifs',
                style: TextStyle(
                  fontSize: fontSize,
                  color: const Color(0xFF8BA8D4),
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 28,
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF3EFFA8).withOpacity(0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingDots(Size size) {
    final dotSize = (size.width * 0.02).clamp(6.0, 12.0);
    return AnimatedBuilder(
      animation: _dotsController,
      builder: (_, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final delay = i / 3.0;
            final t = (_dotsController.value - delay).clamp(0.0, 1.0);
            final scale = 0.6 + 0.4 * math.sin(t * math.pi);
            final opacity = 0.3 + 0.7 * math.sin(t * math.pi);
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: dotSize * 0.5),
              child: Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: dotSize,
                    height: dotSize,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF3EFFA8), Color(0xFF00D4FF)],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  CUSTOM PAINTERS
// ══════════════════════════════════════════════════════════════

class _OrbPainter extends CustomPainter {
  final double t;
  _OrbPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final orbs = [
      _OrbData(
        center: Offset(
          size.width * (0.1 + 0.08 * math.sin(t * math.pi)),
          size.height * (0.15 + 0.06 * math.cos(t * math.pi)),
        ),
        radius: size.width * 0.35,
        color: const Color(0xFF3EFFA8).withOpacity(0.045),
      ),
      _OrbData(
        center: Offset(
          size.width * (0.85 + 0.05 * math.cos(t * math.pi)),
          size.height * (0.75 + 0.07 * math.sin(t * math.pi)),
        ),
        radius: size.width * 0.4,
        color: const Color(0xFF00D4FF).withOpacity(0.035),
      ),
      _OrbData(
        center: Offset(
          size.width * 0.5,
          size.height * (0.5 + 0.04 * math.sin(t * math.pi * 2)),
        ),
        radius: size.width * 0.28,
        color: const Color(0xFF7B61FF).withOpacity(0.025),
      ),
    ];

    for (final orb in orbs) {
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [orb.color, Colors.transparent],
        ).createShader(Rect.fromCircle(center: orb.center, radius: orb.radius))
        ..blendMode = BlendMode.screen;
      canvas.drawCircle(orb.center, orb.radius, paint);
    }
  }

  @override
  bool shouldRepaint(_OrbPainter old) => old.t != t;
}

class _OrbData {
  final Offset center;
  final double radius;
  final Color color;
  const _OrbData({required this.center, required this.radius, required this.color});
}

class _ParticlePainter extends CustomPainter {
  final double t;
  static final _rng = math.Random(42);
  static late final List<_Particle> _particles;
  static bool _initialized = false;

  _ParticlePainter(this.t) {
    if (!_initialized) {
      _particles = List.generate(
        35,
            (_) => _Particle(
          x: _rng.nextDouble(),
          y: _rng.nextDouble(),
          size: _rng.nextDouble() * 2.5 + 0.5,
          speed: _rng.nextDouble() * 0.12 + 0.04,
          phase: _rng.nextDouble(),
          drift: (_rng.nextDouble() - 0.5) * 0.02,
        ),
      );
      _initialized = true;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final yNorm = (p.y - p.speed * t + p.phase) % 1.0;
      final xPos = size.width * (p.x + math.sin(t * math.pi * 2 + p.phase) * p.drift);
      final yPos = size.height * yNorm;
      final opacity = (math.sin(yNorm * math.pi) * 0.6).clamp(0.0, 0.6);

      final paint = Paint()
        ..color = (p.size > 2.0
            ? const Color(0xFF3EFFA8)
            : const Color(0xFF00D4FF))
            .withOpacity(opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(xPos, yPos), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.t != t;
}

class _Particle {
  final double x, y, size, speed, phase, drift;
  const _Particle({
    required this.x, required this.y, required this.size,
    required this.speed, required this.phase, required this.drift,
  });
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A2E52).withOpacity(0.25)
      ..strokeWidth = 0.5;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => false;
}

class _RingPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final int dashCount;

  _RingPainter({required this.color, required this.strokeWidth, required this.dashCount});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final dashAngle = (2 * math.pi) / dashCount;
    final gapAngle = dashAngle * 0.4;
    final drawAngle = dashAngle - gapAngle;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * dashAngle;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        drawAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => false;
}

// ══════════════════════════════════════════════════════════════
//  SAVVY LOGO MARK
// ══════════════════════════════════════════════════════════════
class _SavyMark extends StatelessWidget {
  final double size;
  const _SavyMark({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SavyMarkPainter(),
      ),
    );
  }
}

class _SavyMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── "S" stylisé avec courbe ascendante (symbolise croissance) ──
    final greenPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF3EFFA8), Color(0xFF00D4FF)],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.1
      ..strokeCap = StrokeCap.round;

    // Chart upward line
    final chartPath = Path();
    chartPath.moveTo(w * 0.12, h * 0.75);
    chartPath.lineTo(w * 0.35, h * 0.52);
    chartPath.lineTo(w * 0.55, h * 0.62);
    chartPath.lineTo(w * 0.88, h * 0.25);
    canvas.drawPath(chartPath, greenPaint);

    // Arrow tip
    final arrowPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF3EFFA8), Color(0xFF00D4FF)],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.09
      ..strokeCap = StrokeCap.round;

    final arrowPath = Path();
    arrowPath.moveTo(w * 0.68, h * 0.22);
    arrowPath.lineTo(w * 0.88, h * 0.25);
    arrowPath.lineTo(w * 0.84, h * 0.44);
    canvas.drawPath(arrowPath, arrowPaint);

    // Coin dot
    final coinPaint = Paint()
      ..color = const Color(0xFF3EFFA8).withOpacity(0.7)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(w * 0.35, h * 0.52), w * 0.07, coinPaint);
    canvas.drawCircle(Offset(w * 0.55, h * 0.62), w * 0.05, coinPaint);
  }

  @override
  bool shouldRepaint(_SavyMarkPainter old) => false;
}

// ══════════════════════════════════════════════════════════════
//  PLACEHOLDER – remplace par les vrais écrans
// ══════════════════════════════════════════════════════════════
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Login Screen')),
  );
}