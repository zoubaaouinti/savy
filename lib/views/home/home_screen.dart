import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:savy/l10n/app_localizations.dart';

import '../../models/objective.dart';
import '../../providers/currency_provider.dart';
import '../../utils/category_translator.dart';
import '../../viewmodels/dashboard_view_model.dart';
import '../../viewmodels/smart_engine_view_model.dart';
import '../../widgets/charts/donut_chart.dart';
import '../../widgets/charts/half_gauge_chart.dart';
import '../../widgets/charts/weekly_bar_chart.dart';
import '../../widgets/kpi_dashboard.dart';
import '../mainLayout/main_layout.dart';
import '../notifications/notifications_screen.dart';
import 'ai_suggestions_sheet.dart';

// ══════════════════════════════════════════════════════════════
//  HOME SCREEN – Tableau de bord dynamique
//  Architecture MVVM : HomeScreen fournit le DashboardViewModel
//  via ChangeNotifierProvider. _HomeView consomme ce ViewModel
//  et affiche tous les KPI en temps réel via Firestore streams.
// ══════════════════════════════════════════════════════════════

/// Wrapper Provider : crée le ViewModel et le fournit à l'arbre
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardViewModel()..init()),
        ChangeNotifierProvider(create: (_) => SmartEngineViewModel()..init()),
      ],
      child: const _HomeView(),
    );
  }
}

// ── Vue principale ────────────────────────────────────────────

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> with TickerProviderStateMixin {
  late final AnimationController _bgController;
  late final AnimationController _entranceController;
  late final Animation<double>   _bgAnim;
  late final Animation<double>   _fadeIn;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync:    this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    _bgAnim = CurvedAnimation(parent: _bgController, curve: Curves.easeInOut);

    _entranceController = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );
    Future.delayed(const Duration(milliseconds: 120), _entranceController.forward);
  }

  @override
  void dispose() {
    _bgController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  void _changeTab(int index) {
    HapticFeedback.selectionClick();
    context.findAncestorStateOfType<MainLayoutState>()?.setCurrentIndex(index);
  }

  // ── AI suggestions bottom sheet ───────────────────────────
  void _showAiSuggestionsSheet() {
    HapticFeedback.mediumImpact();
    final smVm = context.read<SmartEngineViewModel>();
    final cur  = context.read<CurrencyProvider>();
    showModalBottomSheet<void>(
      context:            context,
      isScrollControlled: true,
      backgroundColor:    Colors.transparent,
      useSafeArea:        true,
      builder: (_) => MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: smVm),
          ChangeNotifierProvider.value(value: cur),
        ],
        child: const AiSuggestionsSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm   = context.watch<DashboardViewModel>();
    final smVm = context.watch<SmartEngineViewModel>();
    final cur  = context.watch<CurrencyProvider>();
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ── Fond animé ─────────────────────────────────────
          AnimatedBuilder(
            animation: _bgAnim,
            builder: (_, __) => CustomPaint(
              size: size,
              painter: _HomeBgPainter(_bgAnim.value),
            ),
          ),
          _GridPainter.widget(size),

          // ── Contenu ────────────────────────────────────────
          SafeArea(
            child: vm.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Color(0xFF3EFFA8)),
                      strokeWidth: 2.5,
                    ),
                  )
                : FadeTransition(
                    opacity: _fadeIn,
                    child: RefreshIndicator(
                      color:           const Color(0xFF3EFFA8),
                      backgroundColor: const Color(0xFF0B1535),
                      // Forcer un rechargement = re-créer le ViewModel via setState du parent
                      // Le Provider se met à jour automatiquement via les streams
                      onRefresh: () async =>
                          context.read<DashboardViewModel>().init(),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),

                            // 1. En-tête : bonjour + notifications
                            _buildTopBar(vm, smVm, l10n),
                            const SizedBox(height: 24),

                            // 2. Carte solde + jauge demi-cercle
                            _buildBalanceCard(vm, cur, l10n, size),
                            const SizedBox(height: 20),

                            // 3. Revenus | Dépenses
                            _buildIncomeExpenseRow(vm, cur, l10n),
                            const SizedBox(height: 20),

                            // 4. Score de santé financière
                            _buildHealthScore(vm, l10n),
                            const SizedBox(height: 20),

                            // 4b. Suggestions IA
                            _buildAiSuggestionsCard(smVm),
                            const SizedBox(height: 20),

                            // 5. Répartition des dépenses (donut)
                            _buildSectionTitle(
                              'Répartition des dépenses',
                              onSeeAll: () => _changeTab(1),
                              l10n: l10n,
                            ),
                            const SizedBox(height: 12),
                            _buildCard(
                              child: DonutChart(
                                categories: vm.budgetCategories,
                                currency:   cur.format,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // 6. Évolution des dépenses (barres)
                            _buildSectionTitle(
                              'Évolution hebdomadaire',
                              onSeeAll: () => _changeTab(3),
                              l10n: l10n,
                            ),
                            const SizedBox(height: 12),
                            _buildCard(
                              child: WeeklyBarChart(
                                data:     vm.weeklyExpenses,
                                currency: cur.format,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // 7. Objectifs : progression moyenne + liste
                            _buildSectionTitle(
                              l10n.homeMyObjectives,
                              onSeeAll: () => _changeTab(2),
                              l10n: l10n,
                            ),
                            const SizedBox(height: 10),
                            _buildObjectivesAvgProgress(vm),
                            const SizedBox(height: 12),
                            _buildObjectivesList(vm, cur, l10n),
                            const SizedBox(height: 20),

                            // 8. Transactions récentes
                            _buildSectionTitle(
                              l10n.homeRecentTransactions,
                              onSeeAll: () => _changeTab(3),
                              l10n: l10n,
                            ),
                            const SizedBox(height: 12),
                            _buildTransactionsList(vm, cur, l10n),
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

  // ══════════════════════════════════════════════════════════
  //  SECTIONS
  // ══════════════════════════════════════════════════════════

  // ── 1. Top bar ────────────────────────────────────────────
  Widget _buildTopBar(
    DashboardViewModel   vm,
    SmartEngineViewModel smVm,
    AppLocalizations     l10n,
  ) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n.homeHello} ${vm.userName} 👋',
              style: const TextStyle(
                color:      Colors.white,
                fontSize:   20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _getDateString(),
              style: const TextStyle(
                color:    Color(0xFF4A6080),
                fontSize: 12,
              ),
            ),
          ],
        ),
        const Spacer(),

        // ── AI suggestions icon button ─────────────────────
        GestureDetector(
          onTap: _showAiSuggestionsSheet,
          child: Stack(
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color:  const Color(0xFF3EFFA8).withOpacity(0.1),
                  border: Border.all(
                    color: const Color(0xFF3EFFA8).withOpacity(0.35),
                  ),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFF3EFFA8),
                  size:  19,
                ),
              ),
              // Badge: shows count when suggestions are pending
              if (smVm.pendingCount > 0)
                Positioned(
                  top: 6, right: 6,
                  child: Container(
                    width: 8, height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF00D4FF),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const NotificationsScreen(),
              ),
            );
          },
          child: StreamBuilder<QuerySnapshot>(
            stream: uid == null
                ? null
                : FirebaseFirestore.instance
                    .collection('notifications')
                    .where('userId', isEqualTo: uid)
                    .where('read', isEqualTo: false)
                    .limit(1)
                    .snapshots(),
            builder: (context, snap) {
              final hasUnread = (snap.data?.docs.isNotEmpty) ?? false;
              return Stack(
                children: [
                  Container(
                    width:  42,
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF1A2E52)),
                      color:  const Color(0xFF0D1B38),
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: Color(0xFF8BA8D4),
                      size:  20,
                    ),
                  ),
                  if (hasUnread)
                    Positioned(
                      top: 8, right: 8,
                      child: Container(
                        width:  8, height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF3EFFA8),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // ── 2. Carte solde + jauge ────────────────────────────────
  Widget _buildBalanceCard(
    DashboardViewModel vm,
    CurrencyProvider   cur,
    AppLocalizations   l10n,
    Size               size,
  ) {
    final now      = DateTime.now();
    const months   = ['jan','fév','mar','avr','mai','jun',
                       'jul','aoû','sep','oct','nov','déc'];
    final monthLbl = '${months[now.month - 1]} ${now.year}';

    return Container(
      width:   double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin:  Alignment.topLeft,
          end:    Alignment.bottomRight,
          colors: [Color(0xFF0F2347), Color(0xFF0B1535)],
        ),
        border: Border.all(
          color: const Color(0xFF3EFFA8).withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color:      const Color(0xFF3EFFA8).withOpacity(0.08),
            blurRadius: 30,
            offset:     const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête : label + badge mois
          Row(
            children: [
              Text(
                l10n.homeTotalBalance,
                style: const TextStyle(color: Color(0xFF6B8CAE), fontSize: 13),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color:  const Color(0xFF3EFFA8).withOpacity(0.1),
                  border: Border.all(color: const Color(0xFF3EFFA8).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.circle, color: Color(0xFF3EFFA8), size: 6),
                    const SizedBox(width: 5),
                    Text(
                      monthLbl,
                      style: const TextStyle(color: Color(0xFF3EFFA8), fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Montant du solde
          ShaderMask(
            shaderCallback: (b) => const LinearGradient(
              colors: [Color(0xFF3EFFA8), Color(0xFF00D4FF)],
            ).createShader(b),
            child: Text(
              cur.format(vm.totalBalance),
              style: const TextStyle(
                color:      Colors.white,
                fontSize:   36,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Jauge demi-cercle (remplace la barre linéaire)
          HalfGaugeChart(
            percentage: vm.budgetUsedPct,
            remaining:  vm.remainingBudget,
            currency:   cur.format,
          ),
        ],
      ),
    );
  }

  // ── 3. Revenus | Dépenses ─────────────────────────────────
  Widget _buildIncomeExpenseRow(
    DashboardViewModel vm,
    CurrencyProvider   cur,
    AppLocalizations   l10n,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            label: l10n.homeIncome,
            value: '+ ${cur.format(vm.totalIncome)}',
            icon:  Icons.arrow_downward_rounded,
            color: const Color(0xFF3EFFA8),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            label: l10n.homeExpenses,
            value: '- ${cur.format(vm.totalExpenses)}',
            icon:  Icons.arrow_upward_rounded,
            color: const Color(0xFFFF5C7A),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String   label,
    required String   value,
    required IconData icon,
    required Color    color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color:  const Color(0xFF0B1535),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
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
                        color:      color,
                        fontSize:   13,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 4. Score de santé financière ─────────────────────────
  Widget _buildHealthScore(DashboardViewModel vm, AppLocalizations l10n) {
    final score = vm.healthScore;
    final color = score >= 75
        ? const Color(0xFF3EFFA8)
        : score >= 50
            ? const Color(0xFFFFB340)
            : const Color(0xFFFF5C7A);
    final label = score >= 75
        ? l10n.homeScoreExcellent
        : score >= 50
            ? l10n.homeScoreGood
            : score >= 35
                ? l10n.homeScoreAverage
                : l10n.homeScorePoor;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color:  const Color(0xFF0B1535),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // Indicateur circulaire
          SizedBox(
            width: 64, height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value:           score / 100,
                  strokeWidth:     5,
                  backgroundColor: const Color(0xFF1A2E52),
                  valueColor:      AlwaysStoppedAnimation(color),
                  strokeCap:       StrokeCap.round,
                ),
                Text(
                  '$score',
                  style: TextStyle(
                    color:      color,
                    fontSize:   18,
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
                    color:      Colors.white,
                    fontSize:   14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    color:    Color(0xFF6B8CAE),
                    fontSize: 12,
                    height:   1.4,
                  ),
                ),
              ],
            ),
          ),

          // Mini-jauge linéaire score
          Column(
            children: [
              Container(
                width: 4, height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: const Color(0xFF1A2E52),
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: FractionallySizedBox(
                    heightFactor: score / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        gradient: LinearGradient(
                          begin:  Alignment.bottomCenter,
                          end:    Alignment.topCenter,
                          colors: [color, color.withOpacity(0.4)],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 4b. AI Suggestions card ───────────────────────────────
  Widget _buildAiSuggestionsCard(SmartEngineViewModel smVm) {
    final count      = smVm.pendingCount;
    final hasPending = count > 0;

    return GestureDetector(
      onTap: smVm.isLoading ? null : _showAiSuggestionsSheet,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve:    Curves.easeOut,
        padding:  const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin:  Alignment.topLeft,
            end:    Alignment.bottomRight,
            colors: hasPending
                ? [const Color(0xFF0A2018), const Color(0xFF091625)]
                : [const Color(0xFF0B1535), const Color(0xFF0B1535)],
          ),
          border: Border.all(
            color: hasPending
                ? const Color(0xFF3EFFA8).withOpacity(0.35)
                : const Color(0xFF1A2E52).withOpacity(0.7),
          ),
          boxShadow: hasPending
              ? [
                  BoxShadow(
                    color:      const Color(0xFF3EFFA8).withOpacity(0.1),
                    blurRadius: 20,
                    offset:     const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // AI icon — gradient when active, muted when no suggestions
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              width: 48, height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: hasPending
                    ? const LinearGradient(
                        colors: [Color(0xFF3EFFA8), Color(0xFF00D4FF)],
                      )
                    : null,
                color: hasPending ? null : const Color(0xFF0D1B38),
                border: hasPending
                    ? null
                    : Border.all(color: const Color(0xFF1A2E52)),
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                color: hasPending ? Colors.black : const Color(0xFF4A6080),
                size:  22,
              ),
            ),
            const SizedBox(width: 16),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Suggestions IA',
                    style: TextStyle(
                      color:      Colors.white,
                      fontSize:   15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      key: ValueKey('$hasPending-$count'),
                      smVm.isLoading
                          ? 'Analyse en cours...'
                          : hasPending
                              ? '$count suggestion${count > 1 ? 's' : ''} '
                                'personnalisée${count > 1 ? 's' : ''}'
                              : 'Aucune suggestion disponible',
                      style: TextStyle(
                        color: hasPending
                            ? const Color(0xFF3EFFA8)
                            : const Color(0xFF4A6080),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Arrow / spinner
            if (smVm.isLoading)
              const SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Color(0xFF4A6080)),
                ),
              )
            else
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                width: 36, height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: hasPending
                      ? const Color(0xFF3EFFA8).withOpacity(0.15)
                      : const Color(0xFF0D1B38),
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: hasPending
                      ? const Color(0xFF3EFFA8)
                      : const Color(0xFF4A6080),
                  size: 14,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── 7a. Progression moyenne des objectifs ─────────────────
  Widget _buildObjectivesAvgProgress(DashboardViewModel vm) {
    final pct   = vm.avgObjectivesProgress;
    final color = pct >= 0.75
        ? const Color(0xFF3EFFA8)
        : pct >= 0.40
            ? const Color(0xFFFFB340)
            : const Color(0xFF00D4FF);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color:  const Color(0xFF0B1535),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.flag_rounded, color: color, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Progression moyenne',
                      style: TextStyle(
                        color:    Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${(pct * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        color:      color,
                        fontSize:   13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value:           pct.clamp(0.0, 1.0),
                    minHeight:       6,
                    backgroundColor: const Color(0xFF1A2E52),
                    valueColor:      AlwaysStoppedAnimation(color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 7b. Liste des 3 premiers objectifs ────────────────────
  Widget _buildObjectivesList(
    DashboardViewModel vm,
    CurrencyProvider   cur,
    AppLocalizations   l10n,
  ) {
    if (vm.topObjectives.isEmpty) {
      return Container(
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color:  const Color(0xFF0B1535),
          border: Border.all(color: const Color(0xFF1A2E52).withOpacity(0.5)),
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
        itemCount:       vm.topObjectives.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) =>
            _buildObjectiveCard(vm.topObjectives[i], cur, l10n),
      ),
    );
  }

  Widget _buildObjectiveCard(
    Objective        obj,
    CurrencyProvider cur,
    AppLocalizations l10n,
  ) {
    final color    = Objective.colorFromHex(obj.color);
    final icon     = Objective.iconFromName(obj.icon);
    final progress = obj.progress;

    return Container(
      width:   180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color:  const Color(0xFF0B1535),
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
                    color:      Colors.white,
                    fontSize:   13,
                    fontWeight: FontWeight.w600,
                  ),
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
              value:           progress,
              minHeight:       5,
              backgroundColor: const Color(0xFF1A2E52),
              valueColor:      AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.homeObjectiveProgress(
                '${(progress * 100).toStringAsFixed(0)}'),
            style: TextStyle(color: color, fontSize: 10),
          ),
        ],
      ),
    );
  }

  // ── 8. Transactions récentes ──────────────────────────────
  Widget _buildTransactionsList(
    DashboardViewModel vm,
    CurrencyProvider   cur,
    AppLocalizations   l10n,
  ) {
    if (vm.recentTransactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color:  const Color(0xFF0B1535),
          border: Border.all(color: const Color(0xFF1A2E52).withOpacity(0.5)),
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
      children: vm.recentTransactions
          .map((tx) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child:   _buildTxItem(tx, cur, l10n),
              ))
          .toList(),
    );
  }

  Widget _buildTxItem(
    HomeTx           tx,
    CurrencyProvider cur,
    AppLocalizations l10n,
  ) {
    final color = Color(tx.colorValue);
    final icon  = _iconFromName(tx.iconName);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color:  const Color(0xFF0B1535),
        border: Border.all(color: const Color(0xFF1A2E52).withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: color.withOpacity(0.12),
            ),
            child: Icon(icon, color: color, size: 18),
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
                    color:      Colors.white,
                    fontSize:   13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  CategoryTranslator.byStoredName(tx.category, l10n),
                  style: const TextStyle(
                    color:    Color(0xFF4A6080),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${tx.isIncome ? '+' : '-'}${cur.format(tx.amount)}',
            style: TextStyle(
              color:      tx.isIncome
                  ? const Color(0xFF3EFFA8)
                  : const Color(0xFFFF5C7A),
              fontWeight: FontWeight.w700,
              fontSize:   13,
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  //  HELPERS
  // ══════════════════════════════════════════════════════════

  Widget _buildSectionTitle(
    String           title, {
    required VoidCallback     onSeeAll,
    required AppLocalizations l10n,
  }) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color:      Colors.white,
            fontSize:   16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onSeeAll,
          child: Text(
            l10n.homeViewAll,
            style: const TextStyle(color: Color(0xFF3EFFA8), fontSize: 12),
          ),
        ),
      ],
    );
  }

  /// Carte générique avec style cohérent
  Widget _buildCard({required Widget child}) {
    return Container(
      width:   double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color:  const Color(0xFF0B1535),
        border: Border.all(
          color: const Color(0xFF1A2E52).withOpacity(0.7),
        ),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset:     const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  String _getDateString() {
    final now = DateTime.now();
    const months = ['jan','fév','mar','avr','mai','jun',
                    'jul','aoû','sep','oct','nov','déc'];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  static IconData _iconFromName(String name) {
    const map = {
      'restaurant':     Icons.restaurant_rounded,
      'directions_bus': Icons.directions_bus_rounded,
      'movie':          Icons.movie_rounded,
      'menu_book':      Icons.menu_book_rounded,
      'favorite':       Icons.favorite_rounded,
      'category':       Icons.category_rounded,
      'shopping_cart':  Icons.shopping_cart_rounded,
      'local_cafe':     Icons.local_cafe_rounded,
      'fitness_center': Icons.fitness_center_rounded,
      'home':           Icons.home_rounded,
      'phone':          Icons.smartphone_rounded,
      'school':         Icons.school_rounded,
      'trending_up':    Icons.trending_up_rounded,
    };
    return map[name] ?? Icons.receipt_outlined;
  }
}

// ══════════════════════════════════════════════════════════════
//  PAINTERS  (identiques à la version précédente)
// ══════════════════════════════════════════════════════════════

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
        size:    size,
        painter: _GridCustomPainter(),
      );
}

class _GridCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color       = const Color(0xFF1A2E52).withOpacity(0.15)
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
