import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../providers/currency_provider.dart';
import 'package:savy/l10n/app_localizations.dart';

import '../../models/objective.dart';
import '../../models/budget_models.dart';
import '../../utils/category_translator.dart';
import '../mainLayout/main_layout.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final AnimationController _bgController;
  late final AnimationController _entranceController;
  late final Animation<double> _bgAnim;
  late final Animation<double> _fadeIn;

  // ── State ──────────────────────────────────────────────────
  bool _isLoading = true;
  String _userName = '';
  double _totalBalance = 0;
  double _totalIncome = 0;
  double _totalExpenses = 0;
  double _totalObjectivesSaved = 0;
  int _healthScore = 0;
  List<Objective> _objectives = [];
  List<_HomeTx> _transactions = [];
  StreamSubscription<QuerySnapshot>? _objSub;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    _bgAnim = CurvedAnimation(parent: _bgController, curve: Curves.easeInOut);

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );
    Future.delayed(
        const Duration(milliseconds: 100), _entranceController.forward);

    _loadData();
    _subscribeToObjectives();
  }

  void _subscribeToObjectives() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    bool isFirst = true;
    _objSub = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('objectives')
        .snapshots()
        .listen((_) {
      if (isFirst) {
        isFirst = false;
        return;
      }
      if (mounted) _loadData();
    });
  }

  @override
  void dispose() {
    _objSub?.cancel();
    _bgController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  // ── Chargement Firestore ────────────────────────────────────
  Future<void> _loadData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _isLoading = false);
      return;
    }

    final db = FirebaseFirestore.instance;

    try {
      final results = await Future.wait([
        db.collection('users').doc(uid).get(),
        db.collection('users').doc(uid).collection('revenues').get(),
        db.collection('users').doc(uid).collection('budget').get(),
        db
            .collection('users')
            .doc(uid)
            .collection('objectives')
            .orderBy('priority', descending: true)
            .get(),
        db
            .collection('users')
            .doc(uid)
            .collection('transactions')
            .orderBy('date', descending: true)
            .limit(5)
            .get(),
      ]);

      final userDoc = results[0] as DocumentSnapshot;
      final revenueSnap = results[1] as QuerySnapshot;
      final budgetSnap = results[2] as QuerySnapshot;
      final objectivesSnap = results[3] as QuerySnapshot;
      final txSnap = results[4] as QuerySnapshot;

      // ── User ──────────────────────────────────────────────
      final userData = userDoc.data() as Map<String, dynamic>? ?? {};
      final name = userData['name'] as String? ?? 'Utilisateur';
      final initialBalance =
          (userData['initialBalance'] ?? 0).toDouble();

      // ── Revenus ───────────────────────────────────────────
      double totalIncome = 0;
      for (final doc in revenueSnap.docs) {
        totalIncome +=
            ((doc.data() as Map<String, dynamic>)['amount'] ?? 0).toDouble();
      }

      // ── Budget → dépenses + map catégories ───────────────
      double totalExpenses = 0;
      final Map<String, BudgetCategory> categoryMap = {};
      for (final doc in budgetSnap.docs) {
        final cat =
            BudgetCategory.fromMap(doc.id, doc.data() as Map<String, dynamic>);
        totalExpenses += cat.spent;
        categoryMap[doc.id] = cat;
      }

      // ── Objectifs — somme totale + top 3 pour affichage ──
      double totalObjectivesSaved = 0;
      for (final doc in objectivesSnap.docs) {
        totalObjectivesSaved +=
            ((doc.data() as Map<String, dynamic>)['currentAmount'] ?? 0)
                .toDouble();
      }
      final objectives = objectivesSnap.docs
          .map((d) => Objective.fromFirestore(d))
          .where((o) => !o.isCompleted)
          .take(3)
          .toList();

      // ── Transactions (5 dernières) ─────────────────────────
      final transactions = <_HomeTx>[];
      for (final doc in txSnap.docs) {
        final d = doc.data() as Map<String, dynamic>;
        final isIncome = d['isIncome'] as bool? ?? false;
        final categoryId = d['categoryId'] as String? ?? '';
        final cat = categoryMap[categoryId];

        IconData icon;
        Color color;
        String categoryName;

        if (isIncome) {
          icon = Icons.trending_up_rounded;
          color = const Color(0xFF3EFFA8);
          categoryName = 'Revenu';
        } else if (cat != null) {
          icon = _iconFromName(cat.iconName);
          color = Color(cat.colorValue);
          categoryName = cat.name;
        } else {
          icon = Icons.receipt_outlined;
          color = const Color(0xFF8BA8D4);
          categoryName = 'Autres';
        }

        transactions.add(_HomeTx(
          label: d['label'] as String? ?? categoryName,
          category: categoryName,
          amount: (d['amount'] ?? 0).toDouble(),
          isIncome: isIncome,
          icon: icon,
          color: color,
        ));
      }

      // ── Balance & score ────────────────────────────────────
      final balance = initialBalance + totalIncome - totalExpenses;
      final score = _computeHealthScore(totalIncome, totalExpenses + totalObjectivesSaved);

      if (!mounted) return;
      setState(() {
        _userName = name;
        _totalBalance = balance;
        _totalIncome = totalIncome;
        _totalExpenses = totalExpenses;
        _totalObjectivesSaved = totalObjectivesSaved;
        _objectives = objectives;
        _transactions = transactions;
        _healthScore = score;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  int _computeHealthScore(double income, double expenses) {
    if (income <= 0) return 50;
    final ratio = expenses / income;
    if (ratio <= 0.40) return 95;
    if (ratio <= 0.60) return 80;
    if (ratio <= 0.80) return 60;
    if (ratio <= 1.00) return 35;
    return 15;
  }

  void _changeTab(int index) {
    HapticFeedback.selectionClick();
    context.findAncestorStateOfType<MainLayoutState>()?.setCurrentIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _bgAnim,
            builder: (_, __) => CustomPaint(
              size: size,
              painter: _HomeBgPainter(_bgAnim.value),
            ),
          ),
          _GridPainter.widget(size),
          SafeArea(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation(Color(0xFF3EFFA8)),
                      strokeWidth: 2.5,
                    ),
                  )
                : FadeTransition(
                    opacity: _fadeIn,
                    child: RefreshIndicator(
                      color: const Color(0xFF3EFFA8),
                      backgroundColor: const Color(0xFF0B1535),
                      onRefresh: _loadData,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics()),
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            _buildTopBar(l10n),
                            const SizedBox(height: 24),
                            _buildBalanceCard(size, l10n),
                            const SizedBox(height: 20),
                            _buildIncomeExpenseRow(l10n),
                            const SizedBox(height: 20),
                            _buildHealthScore(l10n),
                            const SizedBox(height: 20),
                            _buildSectionTitle(
                              l10n.homeMyObjectives,
                              onSeeAll: () => _changeTab(2),
                              l10n: l10n,
                            ),
                            const SizedBox(height: 12),
                            _buildObjectivesList(l10n),
                            const SizedBox(height: 20),
                            _buildSectionTitle(
                              l10n.homeRecentTransactions,
                              onSeeAll: () => _changeTab(3),
                              l10n: l10n,
                            ),
                            const SizedBox(height: 12),
                            _buildTransactionsList(l10n),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ── Top Bar ───────────────────────────────────────────────
  Widget _buildTopBar(AppLocalizations l10n) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n.homeHello} $_userName 👋',
              style: const TextStyle(
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
  Widget _buildBalanceCard(Size size, AppLocalizations l10n) {
    final cur = context.watch<CurrencyProvider>();
    final budgetPct = _totalIncome > 0
        ? ((_totalExpenses + _totalObjectivesSaved) / _totalIncome).clamp(0.0, 1.0)
        : 0.0;
    final now = DateTime.now();
    final months = [
      'jan', 'fév', 'mar', 'avr', 'mai', 'jun',
      'jul', 'aoû', 'sep', 'oct', 'nov', 'déc'
    ];
    final monthLabel = '${months[now.month - 1]} ${now.year}';

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
              Text(
                l10n.homeTotalBalance,
                style: const TextStyle(color: Color(0xFF6B8CAE), fontSize: 13),
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
                child: Row(
                  children: [
                    const Icon(Icons.circle,
                        color: Color(0xFF3EFFA8), size: 6),
                    const SizedBox(width: 5),
                    Text(
                      monthLabel,
                      style:
                          const TextStyle(color: Color(0xFF3EFFA8), fontSize: 11),
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
              cur.format(_totalBalance),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.homeBudgetUsed,
                    style:
                        const TextStyle(color: Color(0xFF4A6080), fontSize: 11),
                  ),
                  Text(
                    '${(budgetPct * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                        color: Color(0xFF8BA8D4), fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: budgetPct,
                  minHeight: 6,
                  backgroundColor: const Color(0xFF1A2E52),
                  valueColor:
                      const AlwaysStoppedAnimation(Color(0xFF3EFFA8)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Income / Expense Row ──────────────────────────────────
  Widget _buildIncomeExpenseRow(AppLocalizations l10n) {
    final cur = context.watch<CurrencyProvider>();
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            label: l10n.homeIncome,
            value: '+ ${cur.format(_totalIncome)}',
            icon: Icons.arrow_downward_rounded,
            color: const Color(0xFF3EFFA8),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            label: l10n.homeExpenses,
            value: '- ${cur.format(_totalExpenses)}',
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
        border: Border.all(color: color.withOpacity(0.2), width: 1),
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
  Widget _buildHealthScore(AppLocalizations l10n) {
    final color = _healthScore >= 75
        ? const Color(0xFF3EFFA8)
        : _healthScore >= 50
            ? const Color(0xFFFFB340)
            : const Color(0xFFFF5C7A);
    final label = _healthScore >= 75
        ? l10n.homeScoreExcellent
        : _healthScore >= 50
            ? l10n.homeScoreGood
            : _healthScore >= 35
                ? l10n.homeScoreAverage
                : l10n.homeScorePoor;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF0B1535),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
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
                Text(
                  l10n.homeHealthScore,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
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

  // ── Section title ─────────────────────────────────────────
  Widget _buildSectionTitle(String title, {required VoidCallback onSeeAll, required AppLocalizations l10n}) {
    return Row(
      children: [
        Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700)),
        const Spacer(),
        GestureDetector(
          onTap: onSeeAll,
          child: Text(l10n.homeViewAll,
              style: const TextStyle(color: Color(0xFF3EFFA8), fontSize: 12)),
        ),
      ],
    );
  }

  // ── Objectives List ───────────────────────────────────────
  Widget _buildObjectivesList(AppLocalizations l10n) {
    if (_objectives.isEmpty) {
      return Container(
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: const Color(0xFF0B1535),
          border: Border.all(
              color: const Color(0xFF1A2E52).withOpacity(0.5)),
        ),
        child: Center(
          child: Text(
            l10n.homeNoObjectives,
            style: const TextStyle(color: Color(0xFF4A6080), fontSize: 13),
          ),
        ),
      );
    }

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _objectives.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => _buildObjectiveCard(_objectives[i], l10n),
      ),
    );
  }

  Widget _buildObjectiveCard(Objective obj, AppLocalizations l10n) {
    final cur = context.watch<CurrencyProvider>();
    final color = Objective.colorFromHex(obj.color);
    final icon = Objective.iconFromName(obj.icon);
    final progress = obj.progress;

    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color(0xFF0B1535),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  obj.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '${cur.format(obj.currentAmount)} / ${cur.format(obj.targetAmount)}',
            style: const TextStyle(color: Color(0xFF4A6080), fontSize: 11),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: const Color(0xFF1A2E52),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.homeObjectiveProgress('${(progress * 100).toStringAsFixed(0)}'),
            style: TextStyle(color: color, fontSize: 10),
          ),
        ],
      ),
    );
  }

  // ── Transactions List ─────────────────────────────────────
  Widget _buildTransactionsList(AppLocalizations l10n) {
    if (_transactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: const Color(0xFF0B1535),
          border: Border.all(
              color: const Color(0xFF1A2E52).withOpacity(0.5)),
        ),
        child: Center(
          child: Text(
            l10n.homeNoTransactions,
            style: const TextStyle(color: Color(0xFF4A6080), fontSize: 13),
          ),
        ),
      );
    }

    return Column(
      children: _transactions
          .map((tx) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildTxItem(tx),
              ))
          .toList(),
    );
  }

  Widget _buildTxItem(_HomeTx tx) {
    final l10n = AppLocalizations.of(context);
    final cur = context.watch<CurrencyProvider>();
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
                Text(
                  CategoryTranslator.resolveLabel(tx.label, tx.category, l10n),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
                Text(CategoryTranslator.byStoredName(tx.category, l10n),
                    style: const TextStyle(
                        color: Color(0xFF4A6080), fontSize: 11)),
              ],
            ),
          ),
          Text(
            '${tx.isIncome ? '+' : '-'}${cur.format(tx.amount)}',
            style: TextStyle(
              color: tx.isIncome
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

  // ── Helpers ───────────────────────────────────────────────
  String _getDateString() {
    final now = DateTime.now();
    const months = [
      'jan', 'fév', 'mar', 'avr', 'mai', 'jun',
      'jul', 'aoû', 'sep', 'oct', 'nov', 'déc'
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  static IconData _iconFromName(String name) {
    const map = {
      'restaurant': Icons.restaurant_rounded,
      'directions_bus': Icons.directions_bus_rounded,
      'movie': Icons.movie_rounded,
      'menu_book': Icons.menu_book_rounded,
      'favorite': Icons.favorite_rounded,
      'category': Icons.category_rounded,
      'shopping_cart': Icons.shopping_cart_rounded,
      'local_cafe': Icons.local_cafe_rounded,
      'fitness_center': Icons.fitness_center_rounded,
      'home': Icons.home_rounded,
      'phone': Icons.smartphone_rounded,
      'school': Icons.school_rounded,
    };
    return map[name] ?? Icons.receipt_outlined;
  }
}

// ── Data model (home-specific) ─────────────────────────────────
class _HomeTx {
  final String label;
  final String category;
  final double amount;
  final bool isIncome;
  final IconData icon;
  final Color color;

  const _HomeTx({
    required this.label,
    required this.category,
    required this.amount,
    required this.isIncome,
    required this.icon,
    required this.color,
  });
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
          ..shader = RadialGradient(colors: [c, Colors.transparent])
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
