import 'dart:math' as math;
import 'package:flutter/material.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _bgController;
  late final AnimationController _entranceController;
  late final Animation<double> _bgAnim;
  late final Animation<double> _fadeIn;

  // Données fictives (à remplacer par Firebase)
  final double _totalBalance = 1240.50;
  final double _totalIncome = 1800.00;
  final double _totalExpenses = 559.50;
  final int _healthScore = 74;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    _bgAnim =
        CurvedAnimation(parent: _bgController, curve: Curves.easeInOut);

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );
    Future.delayed(
        const Duration(milliseconds: 100), _entranceController.forward);
  }

  @override
  void dispose() {
    _bgController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF060D1F),
      body: Stack(
        children: [
          // Background
          AnimatedBuilder(
            animation: _bgAnim,
            builder: (_, __) => CustomPaint(
              size: size,
              painter: _HomeBgPainter(_bgAnim.value),
            ),
          ),
          _GridPainter.widget(size),

          // Content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeIn,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildTopBar(),
                    const SizedBox(height: 24),
                    _buildBalanceCard(size),
                    const SizedBox(height: 20),
                    _buildIncomeExpenseRow(),
                    const SizedBox(height: 20),
                    _buildHealthScore(),
                    const SizedBox(height: 20),
                    _buildSuggestionCard(),
                    const SizedBox(height: 20),
                    _buildSectionTitle('Objectifs en cours'),
                    const SizedBox(height: 12),
                    _buildObjectivesList(),
                    const SizedBox(height: 20),
                    _buildSectionTitle('Dernières transactions'),
                    const SizedBox(height: 12),
                    _buildTransactionsList(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Top Bar ───────────────────────────────────────────────
  Widget _buildTopBar() {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bonjour, Zeineb 👋',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _getDateString(),
              style: const TextStyle(
                color: Color(0xFF4A6080),
                fontSize: 12,
              ),
            ),
          ],
        ),
        const Spacer(),
        // Notification bell
        Stack(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1A2E52)),
                color: const Color(0xFF0D1B38),
              ),
              child: const Icon(
                Icons.notifications_outlined,
                color: Color(0xFF8BA8D4),
                size: 20,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF3EFFA8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Balance Card ──────────────────────────────────────────
  Widget _buildBalanceCard(Size size) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F2347), Color(0xFF0B1535)],
        ),
        border: Border.all(
          color: const Color(0xFF3EFFA8).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3EFFA8).withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Solde disponible',
                style: TextStyle(color: Color(0xFF6B8CAE), fontSize: 13),
              ),
              const Spacer(),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color(0xFF3EFFA8).withOpacity(0.1),
                  border: Border.all(
                      color: const Color(0xFF3EFFA8).withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.circle, color: Color(0xFF3EFFA8), size: 6),
                    SizedBox(width: 5),
                    Text(
                      'Mars 2025',
                      style: TextStyle(
                          color: Color(0xFF3EFFA8), fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ShaderMask(
            shaderCallback: (b) => const LinearGradient(
              colors: [Color(0xFF3EFFA8), Color(0xFF00D4FF)],
            ).createShader(b),
            child: Text(
              '${_totalBalance.toStringAsFixed(2)} TND',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Budget progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Budget utilisé',
                    style: TextStyle(color: Color(0xFF4A6080), fontSize: 11),
                  ),
                  Text(
                    '${((_totalExpenses / _totalIncome) * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                        color: Color(0xFF8BA8D4), fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _totalExpenses / _totalIncome,
                  minHeight: 6,
                  backgroundColor: const Color(0xFF1A2E52),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF3EFFA8)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Income / Expense Row ──────────────────────────────────
  Widget _buildIncomeExpenseRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            label: 'Revenus',
            value: '+ ${_totalIncome.toStringAsFixed(0)} TND',
            icon: Icons.arrow_downward_rounded,
            color: const Color(0xFF3EFFA8),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            label: 'Dépenses',
            value: '- ${_totalExpenses.toStringAsFixed(0)} TND',
            icon: Icons.arrow_upward_rounded,
            color: const Color(0xFFFF5C7A),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color(0xFF0B1535),
        border: Border.all(
            color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.12),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: Color(0xFF4A6080), fontSize: 11)),
                const SizedBox(height: 2),
                Text(value,
                    style: TextStyle(
                        color: color,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Health Score ──────────────────────────────────────────
  Widget _buildHealthScore() {
    final color = _healthScore >= 75
        ? const Color(0xFF3EFFA8)
        : _healthScore >= 50
        ? const Color(0xFFFFB340)
        : const Color(0xFFFF5C7A);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF0B1535),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // Circular score
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: _healthScore / 100,
                  strokeWidth: 5,
                  backgroundColor: const Color(0xFF1A2E52),
                  valueColor: AlwaysStoppedAnimation(color),
                  strokeCap: StrokeCap.round,
                ),
                Text(
                  '$_healthScore',
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Score de santé financière',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  _healthScore >= 75
                      ? 'Excellente gestion ! Continuez ainsi 🎉'
                      : _healthScore >= 50
                      ? 'Bonne gestion, quelques améliorations possibles'
                      : 'Attention, réduisez vos dépenses',
                  style: const TextStyle(
                      color: Color(0xFF6B8CAE), fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Suggestion Card ───────────────────────────────────────
  Widget _buildSuggestionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF3EFFA8).withOpacity(0.08),
            const Color(0xFF00D4FF).withOpacity(0.06),
          ],
        ),
        border: Border.all(
            color: const Color(0xFF3EFFA8).withOpacity(0.25), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF3EFFA8).withOpacity(0.15),
                ),
                child: const Icon(Icons.auto_awesome,
                    color: Color(0xFF3EFFA8), size: 16),
              ),
              const SizedBox(width: 10),
              const Text(
                'Suggestion intelligente',
                style: TextStyle(
                    color: Color(0xFF3EFFA8),
                    fontSize: 13,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Épargner 180 TND ce mois pour atteindre votre objectif "Ordinateur" en 3 mois.',
            style: TextStyle(
                color: Colors.white, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSuggestionBtn(
                  label: 'Accepter',
                  color: const Color(0xFF3EFFA8),
                  icon: Icons.check_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSuggestionBtn(
                  label: 'Modifier',
                  color: const Color(0xFF00D4FF),
                  icon: Icons.edit_rounded,
                  outlined: true,
                ),
              ),
              const SizedBox(width: 10),
              _buildSuggestionBtn(
                label: '',
                color: const Color(0xFFFF5C7A),
                icon: Icons.close_rounded,
                outlined: true,
                compact: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionBtn({
    required String label,
    required Color color,
    required IconData icon,
    bool outlined = false,
    bool compact = false,
  }) {
    return Container(
      height: 36,
      width: compact ? 36 : null,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: outlined ? Colors.transparent : color.withOpacity(0.15),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {},
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 14),
                if (!compact) ...[
                  const SizedBox(width: 4),
                  Text(label,
                      style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Section title ─────────────────────────────────────────
  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700)),
        const Spacer(),
        const Text('Voir tout',
            style: TextStyle(color: Color(0xFF3EFFA8), fontSize: 12)),
      ],
    );
  }

  // ── Objectives List ───────────────────────────────────────
  Widget _buildObjectivesList() {
    final objectives = [
      _ObjectiveData(
          name: 'Ordinateur',
          icon: Icons.laptop_rounded,
          current: 360,
          target: 900,
          color: const Color(0xFF3EFFA8)),
      _ObjectiveData(
          name: 'Voyage',
          icon: Icons.flight_rounded,
          current: 150,
          target: 600,
          color: const Color(0xFF00D4FF)),
    ];

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: objectives.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => _buildObjectiveCard(objectives[i]),
      ),
    );
  }

  Widget _buildObjectiveCard(_ObjectiveData obj) {
    final progress = obj.current / obj.target;
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color(0xFF0B1535),
        border: Border.all(color: obj.color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(obj.icon, color: obj.color, size: 18),
              const SizedBox(width: 8),
              Text(obj.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const Spacer(),
          Text(
            '${obj.current.toStringAsFixed(0)} / ${obj.target.toStringAsFixed(0)} TND',
            style:
            const TextStyle(color: Color(0xFF4A6080), fontSize: 11),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: const Color(0xFF1A2E52),
              valueColor: AlwaysStoppedAnimation(obj.color),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(progress * 100).toStringAsFixed(0)}% atteint',
            style: TextStyle(color: obj.color, fontSize: 10),
          ),
        ],
      ),
    );
  }

  // ── Transactions List ─────────────────────────────────────
  Widget _buildTransactionsList() {
    final txs = [
      _TxData(
          label: 'Courses alimentaires',
          category: 'Alimentation',
          amount: -45.0,
          icon: Icons.shopping_cart_outlined,
          color: const Color(0xFFFFB340)),
      _TxData(
          label: 'Bourse universitaire',
          category: 'Revenu',
          amount: - 600.0,
          icon: Icons.school_outlined,
          color: const Color(0xFF3EFFA8)),
      _TxData(
          label: 'Transport (métro)',
          category: 'Transport',
          amount: -12.0,
          icon: Icons.directions_bus_outlined,
          color: const Color(0xFF00D4FF)),
    ];

    return Column(
      children: txs
          .map((tx) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _buildTxItem(tx),
      ))
          .toList(),
    );
  }

  Widget _buildTxItem(_TxData tx) {
    final isIncome = tx.amount > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0xFF0B1535),
        border:
        Border.all(color: const Color(0xFF1A2E52).withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: tx.color.withOpacity(0.12),
            ),
            child: Icon(tx.icon, color: tx.color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                Text(tx.category,
                    style: const TextStyle(
                        color: Color(0xFF4A6080), fontSize: 11)),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : ''}${tx.amount.toStringAsFixed(2)} TND',
            style: TextStyle(
              color: isIncome
                  ? const Color(0xFF3EFFA8)
                  : const Color(0xFFFF5C7A),
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  String _getDateString() {
    final now = DateTime.now();
    final months = [
      'jan', 'fév', 'mar', 'avr', 'mai', 'jun',
      'jul', 'aoû', 'sep', 'oct', 'nov', 'déc'
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }
}

// ── Data models ───────────────────────────────────────────────
class _ObjectiveData {
  final String name;
  final IconData icon;
  final double current, target;
  final Color color;
  const _ObjectiveData(
      {required this.name,
        required this.icon,
        required this.current,
        required this.target,
        required this.color});
}

class _TxData {
  final String label, category;
  final double amount;
  final IconData icon;
  final Color color;
  const _TxData(
      {required this.label,
        required this.category,
        required this.amount,
        required this.icon,
        required this.color});
}

// ── Painters ──────────────────────────────────────────────────
class _HomeBgPainter extends CustomPainter {
  final double t;
  _HomeBgPainter(this.t);
  @override
  void paint(Canvas canvas, Size size) {
    void drawOrb(Offset center, double r, Color c) {
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..shader = RadialGradient(
              colors: [c, Colors.transparent])
              .createShader(Rect.fromCircle(center: center, radius: r)),
      );
    }

    drawOrb(
      Offset(size.width * (0.1 + 0.06 * math.sin(t * math.pi)),
          size.height * 0.1),
      size.width * 0.4,
      const Color(0xFF3EFFA8).withOpacity(0.05),
    );
    drawOrb(
      Offset(size.width * 0.9,
          size.height * (0.7 + 0.05 * math.cos(t * math.pi))),
      size.width * 0.35,
      const Color(0xFF00D4FF).withOpacity(0.04),
    );
  }

  @override
  bool shouldRepaint(_HomeBgPainter old) => old.t != t;
}

class _GridPainter {
  static Widget widget(Size size) => CustomPaint(
    size: size,
    painter: _GridCustomPainter(),
  );
}

class _GridCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A2E52).withOpacity(0.15)
      ..strokeWidth = 0.5;
    const step = 44.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridCustomPainter old) => false;
}