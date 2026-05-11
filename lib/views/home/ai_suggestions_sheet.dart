import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/objective.dart';
import '../../models/smart_engine_models.dart';
import '../../providers/currency_provider.dart';
import '../../viewmodels/smart_engine_view_model.dart';

// ══════════════════════════════════════════════════════════════
//  AI SUGGESTIONS SHEET
//  lib/views/home/ai_suggestions_sheet.dart
//
//  DraggableScrollableSheet displayed via showModalBottomSheet.
//  Must be wrapped with ChangeNotifierProvider.value for both
//  SmartEngineViewModel and CurrencyProvider before showing.
// ══════════════════════════════════════════════════════════════

class AiSuggestionsSheet extends StatefulWidget {
  const AiSuggestionsSheet({super.key});

  @override
  State<AiSuggestionsSheet> createState() => _AiSuggestionsSheetState();
}

class _AiSuggestionsSheetState extends State<AiSuggestionsSheet> {
  /// Tracks which suggestion cards are currently awaiting a Firestore response.
  final Set<String> _loadingIds = {};

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SmartEngineViewModel>();
    final cur = context.watch<CurrencyProvider>();

    return DraggableScrollableSheet(
      initialChildSize: 0.80,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      snap: true,
      snapSizes: const [0.45, 0.80, 0.95],
      builder: (_, scrollController) =>
          _buildSheetContent(context, scrollController, vm, cur),
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  Shell
  // ─────────────────────────────────────────────────────────────

  Widget _buildSheetContent(
    BuildContext context,
    ScrollController sc,
    SmartEngineViewModel vm,
    CurrencyProvider cur,
  ) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF080F20),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top:   BorderSide(color: Color(0xFF1A2E52)),
          left:  BorderSide(color: Color(0xFF1A2E52)),
          right: BorderSide(color: Color(0xFF1A2E52)),
        ),
      ),
      child: Column(
        children: [
          _buildDragHandle(),
          _buildHeader(context, vm),
          const Divider(color: Color(0xFF1A2E52), height: 1),
          Expanded(
            child: ListView(
              controller: sc,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 48),
              children: [
                if (vm.healthScore != null) ...[
                  _buildHealthBanner(vm),
                  const SizedBox(height: 16),
                ],
                if (vm.hasBudgetAlert) ...[
                  _buildAlertBanner(vm, cur),
                  const SizedBox(height: 16),
                ],
                if (vm.isLoading)
                  _buildLoadingState()
                else if (vm.pendingSuggestions.isEmpty)
                  _buildEmptyState()
                else
                  for (final s in vm.pendingSuggestions) ...[
                    _buildSuggestionCard(context, s, vm, cur),
                    const SizedBox(height: 12),
                  ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  Header
  // ─────────────────────────────────────────────────────────────

  Widget _buildDragHandle() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 8),
        child: Container(
          width: 40, height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFF1A2E52),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, SmartEngineViewModel vm) {
    final count = vm.pendingSuggestions.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 16, 12),
      child: Row(
        children: [
          // Gradient AI icon
          Container(
            width: 40, height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF3EFFA8), Color(0xFF00D4FF)],
              ),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.black,
              size: 19,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Suggestions IA',
                style: TextStyle(
                  color:      Colors.white,
                  fontSize:   17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                count == 0
                    ? 'Aucune suggestion en attente'
                    : '$count suggestion${count > 1 ? 's' : ''} '
                      'disponible${count > 1 ? 's' : ''}',
                style: const TextStyle(
                  color:    Color(0xFF6B8CAE),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color:  const Color(0xFF0D1B38),
                border: Border.all(color: const Color(0xFF1A2E52)),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Color(0xFF8BA8D4),
                size:  16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  Health Score Banner
  // ─────────────────────────────────────────────────────────────

  Widget _buildHealthBanner(SmartEngineViewModel vm) {
    final score = vm.healthScore!;
    final color = score.total >= 75
        ? const Color(0xFF3EFFA8)
        : score.total >= 50
            ? const Color(0xFFFFB340)
            : const Color(0xFFFF5C7A);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color:  color.withOpacity(0.07),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // Circular progress score
          SizedBox(
            width: 52, height: 52,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value:           score.total / 100,
                  strokeWidth:     4.5,
                  backgroundColor: color.withOpacity(0.15),
                  valueColor:      AlwaysStoppedAnimation(color),
                  strokeCap:       StrokeCap.round,
                ),
                Text(
                  '${score.total}',
                  style: TextStyle(
                    color:      color,
                    fontSize:   14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          // Component scores
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Score santé financière',
                  style: TextStyle(
                    color:      color,
                    fontSize:   13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 5,
                  runSpacing: 4,
                  children: [
                    _scoreChip('Épargne',   score.savingsRateScore,   40),
                    _scoreChip('Budget',    score.budgetControlScore, 35),
                    _scoreChip('Objectifs', score.goalProgressScore,  25),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Level badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color:  color.withOpacity(0.12),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(
              score.level.label,
              style: TextStyle(
                color:      color,
                fontSize:   11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scoreChip(String label, int score, int max) {
    final ratio = score / max;
    final color = ratio >= 0.8
        ? const Color(0xFF3EFFA8)
        : ratio >= 0.5
            ? const Color(0xFFFFB340)
            : const Color(0xFFFF5C7A);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: color.withOpacity(0.1),
      ),
      child: Text(
        '$label $score/$max',
        style: TextStyle(
          color:      color,
          fontSize:   9,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  Budget Alert Banner
  // ─────────────────────────────────────────────────────────────

  Widget _buildAlertBanner(SmartEngineViewModel vm, CurrencyProvider cur) {
    final pred     = vm.prediction!;
    final daysLeft = pred.daysUntilBalanceExhausted;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color:  const Color(0xFFFFB340).withOpacity(0.07),
        border: Border.all(color: const Color(0xFFFFB340).withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFFFB340),
              size:  18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Alerte budget',
                  style: TextStyle(
                    color:      Color(0xFFFFB340),
                    fontSize:   13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  pred.willExceedIncome
                      ? 'Dépenses projetées (${cur.format(pred.projectedMonthlyTotal)}) '
                        'dépasseront vos revenus ce mois-ci.'
                      : 'Vos dépenses risquent de dépasser votre budget alloué.',
                  style: const TextStyle(
                    color:    Color(0xFFD4900A),
                    fontSize: 11,
                    height:   1.4,
                  ),
                ),
                if (daysLeft >= 0 && daysLeft <= 10) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        color: Color(0xFFFFB340),
                        size:  11,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Solde épuisé dans ~$daysLeft jour${daysLeft != 1 ? 's' : ''}',
                        style: const TextStyle(
                          color:      Color(0xFFFFB340),
                          fontSize:   11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  Suggestion Card
  // ─────────────────────────────────────────────────────────────

  Widget _buildSuggestionCard(
    BuildContext       context,
    SavingSuggestion   s,
    SmartEngineViewModel vm,
    CurrencyProvider   cur,
  ) {
    final objective = vm.objectiveById(s.objectiveId);
    final objColor  = objective != null
        ? Objective.colorFromHex(objective.color)
        : const Color(0xFF3EFFA8);
    final objIcon   = objective != null
        ? Objective.iconFromName(objective.icon)
        : Icons.savings_rounded;
    final isCardLoading = _loadingIds.contains(s.objectiveId);

    final forecast = vm.goalForecasts
        .where((f) => f.objectiveId == s.objectiveId)
        .firstOrNull;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF0D1B38),
        border: Border.all(
          color: s.isOnTrack
              ? objColor.withOpacity(0.30)
              : const Color(0xFFFFB340).withOpacity(0.30),
        ),
        boxShadow: [
          BoxShadow(
            color:      objColor.withOpacity(0.05),
            blurRadius: 12,
            offset:     const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Goal info row ────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: objColor.withOpacity(0.12),
                ),
                child: Icon(objIcon, color: objColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.objectiveName,
                      maxLines:  1,
                      overflow:  TextOverflow.ellipsis,
                      style: const TextStyle(
                        color:      Colors.white,
                        fontSize:   14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        _chip('P${s.priority}', const Color(0xFF7B61FF)),
                        const SizedBox(width: 6),
                        _chip(
                          '${s.monthsLeft} mois',
                          const Color(0xFF6B8CAE),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _onTrackBadge(s.isOnTrack),
            ],
          ),
          const SizedBox(height: 14),

          // ── Progress bar ─────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value:           (s.progressPercent / 100).clamp(0.0, 1.0),
                    minHeight:       6,
                    backgroundColor: const Color(0xFF1A2E52),
                    valueColor:      AlwaysStoppedAnimation(objColor),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${s.progressPercent.toStringAsFixed(0)}%',
                style: TextStyle(
                  color:      objColor,
                  fontSize:   11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Amount tiles ─────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _amountTile(
                  label: 'Suggéré / mois',
                  value: cur.format(s.suggestedAmount),
                  valueColor: const Color(0xFF3EFFA8),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _amountTile(
                  label: 'Requis / mois',
                  value: cur.format(s.monthlyRequired),
                  valueColor: const Color(0xFF6B8CAE),
                ),
              ),
            ],
          ),

          // ── Success probability ───────────────────────────────
          if (forecast != null) ...[
            const SizedBox(height: 12),
            _buildProbabilityRow(forecast),
          ],

          const SizedBox(height: 16),
          const Divider(color: Color(0xFF1A2E52), height: 1),
          const SizedBox(height: 14),

          // ── Action buttons ────────────────────────────────────
          if (isCardLoading)
            const Center(
              child: SizedBox(
                width: 24, height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(Color(0xFF3EFFA8)),
                ),
              ),
            )
          else
            _buildActionButtons(context, s, vm, cur),
        ],
      ),
    );
  }

  Widget _amountTile({
    required String label,
    required String value,
    required Color  valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color:  const Color(0xFF060D1F),
        border: Border.all(
          color: const Color(0xFF1A2E52).withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color:    Color(0xFF4A6080),
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color:      valueColor,
              fontSize:   13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProbabilityRow(GoalSuccessForecast forecast) {
    final pct   = (forecast.successProbability * 100).round();
    final color = pct >= 70
        ? const Color(0xFF3EFFA8)
        : pct >= 40
            ? const Color(0xFFFFB340)
            : const Color(0xFFFF5C7A);

    return Row(
      children: [
        Icon(
          pct >= 70
              ? Icons.trending_up_rounded
              : pct >= 40
                  ? Icons.trending_flat_rounded
                  : Icons.trending_down_rounded,
          color: color,
          size:  14,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 11),
              children: [
                const TextSpan(
                  text:  'Probabilité de succès : ',
                  style: TextStyle(color: Color(0xFF6B8CAE)),
                ),
                TextSpan(
                  text:  '$pct%',
                  style: TextStyle(
                    color:      color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Five-dot indicator
        Row(
          children: List.generate(5, (i) {
            final filled = i < (pct / 20).round();
            return Padding(
              padding: const EdgeInsets.only(left: 3),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 7, height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: filled ? color : const Color(0xFF1A2E52),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  Action Buttons (Accept / Modify / Reject)
  // ─────────────────────────────────────────────────────────────

  Widget _buildActionButtons(
    BuildContext       context,
    SavingSuggestion   s,
    SmartEngineViewModel vm,
    CurrencyProvider   cur,
  ) {
    return Row(
      children: [
        // ── Accept ────────────────────────────────────────────
        Expanded(
          flex: 5,
          child: GestureDetector(
            onTap: () => _onAccept(context, s, vm, cur),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [Color(0xFF3EFFA8), Color(0xFF00D4FF)],
                ),
                boxShadow: [
                  BoxShadow(
                    color:      const Color(0xFF3EFFA8).withOpacity(0.25),
                    blurRadius: 8,
                    offset:     const Offset(0, 3),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_rounded, color: Colors.black, size: 16),
                  SizedBox(width: 5),
                  Text(
                    'Accepter',
                    style: TextStyle(
                      color:      Colors.black,
                      fontSize:   12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // ── Modify ────────────────────────────────────────────
        Expanded(
          flex: 4,
          child: GestureDetector(
            onTap: () => _onModify(context, s, vm, cur),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF00D4FF).withOpacity(0.5),
                ),
                color: const Color(0xFF00D4FF).withOpacity(0.07),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_rounded, color: Color(0xFF00D4FF), size: 14),
                  SizedBox(width: 5),
                  Text(
                    'Modifier',
                    style: TextStyle(
                      color:      Color(0xFF00D4FF),
                      fontSize:   12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // ── Reject ────────────────────────────────────────────
        GestureDetector(
          onTap: () => _onReject(s, vm),
          child: Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFF5C7A).withOpacity(0.35),
              ),
              color: const Color(0xFFFF5C7A).withOpacity(0.07),
            ),
            child: const Icon(
              Icons.close_rounded,
              color: Color(0xFFFF5C7A),
              size:  17,
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  Empty / Loading states
  // ─────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              shape:  BoxShape.circle,
              color:  const Color(0xFF0D1B38),
              border: Border.all(color: const Color(0xFF1A2E52)),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Color(0xFF4A6080),
              size:  32,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Aucune suggestion disponible',
            style: TextStyle(
              color:      Colors.white,
              fontSize:   16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ajoutez des objectifs d\'épargne pour\nrecevoir des suggestions personnalisées.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color:    Color(0xFF4A6080),
              fontSize: 13,
              height:   1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation(Color(0xFF3EFFA8)),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  Action handlers
  // ─────────────────────────────────────────────────────────────

  Future<void> _onAccept(
    BuildContext       context,
    SavingSuggestion   s,
    SmartEngineViewModel vm,
    CurrencyProvider   cur,
  ) async {
    HapticFeedback.mediumImpact();
    setState(() => _loadingIds.add(s.objectiveId));

    final error = await vm.acceptSuggestion(s.objectiveId, s.suggestedAmount);

    if (!mounted) return;
    setState(() => _loadingIds.remove(s.objectiveId));

    if (error != null) {
      _showError(context, error);
    } else {
      _showSuccess(
        context,
        '${cur.format(s.suggestedAmount)} ajouté à « ${s.objectiveName} »',
      );
    }
  }

  void _onModify(
    BuildContext       context,
    SavingSuggestion   s,
    SmartEngineViewModel vm,
    CurrencyProvider   cur,
  ) {
    HapticFeedback.selectionClick();
    _showModifyDialog(context, s, vm, cur);
  }

  void _onReject(SavingSuggestion s, SmartEngineViewModel vm) {
    HapticFeedback.selectionClick();
    vm.rejectSuggestion(s.objectiveId);
  }

  // ─────────────────────────────────────────────────────────────
  //  Modify dialog
  // ─────────────────────────────────────────────────────────────

  void _showModifyDialog(
    BuildContext       context,
    SavingSuggestion   s,
    SmartEngineViewModel vm,
    CurrencyProvider   cur,
  ) {
    showDialog<void>(
      context: context,
      builder: (_) => _ModifyDialog(
        suggestion: s,
        vm:         vm,
        cur:        cur,
        onConfirm:  (amount) => _applyModify(context, s, vm, cur, amount),
      ),
    );
  }

  Future<void> _applyModify(
    BuildContext         context,
    SavingSuggestion     s,
    SmartEngineViewModel vm,
    CurrencyProvider     cur,
    double               amount,
  ) async {
    setState(() => _loadingIds.add(s.objectiveId));

    final error = await vm.modifySuggestion(s.objectiveId, amount);

    if (!mounted) return;
    setState(() => _loadingIds.remove(s.objectiveId));

    if (error != null) {
      _showError(context, error);
    } else {
      _showSuccess(
        context,
        '${cur.format(amount)} ajouté à « ${s.objectiveName} »',
      );
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  Feedback helpers
  // ─────────────────────────────────────────────────────────────

  void _showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF3EFFA8),
              size:  18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0D1B38),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF3EFFA8), width: 0.5),
        ),
        behavior:        SnackBarBehavior.floating,
        margin:          const EdgeInsets.fromLTRB(20, 0, 20, 16),
        duration:        const Duration(seconds: 3),
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFFF5C7A),
              size:  18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0D1B38),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFFF5C7A), width: 0.5),
        ),
        behavior: SnackBarBehavior.floating,
        margin:   const EdgeInsets.fromLTRB(20, 0, 20, 16),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  Small helpers
  // ─────────────────────────────────────────────────────────────

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: color.withOpacity(0.1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color:      color,
          fontSize:   10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _onTrackBadge(bool isOnTrack) {
    final color = isOnTrack
        ? const Color(0xFF3EFFA8)
        : const Color(0xFFFFB340);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color.withOpacity(0.1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOnTrack
                ? Icons.check_circle_outline_rounded
                : Icons.schedule_rounded,
            color: color,
            size:  12,
          ),
          const SizedBox(height: 2),
          Text(
            isOnTrack ? 'En voie' : 'À risque',
            style: TextStyle(
              color:      color,
              fontSize:   9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  Modify Dialog  (extracted to keep _AiSuggestionsSheetState lean)
// ══════════════════════════════════════════════════════════════

class _ModifyDialog extends StatefulWidget {
  final SavingSuggestion     suggestion;
  final SmartEngineViewModel vm;
  final CurrencyProvider     cur;
  final Future<void>         Function(double amount) onConfirm;

  const _ModifyDialog({
    required this.suggestion,
    required this.vm,
    required this.cur,
    required this.onConfirm,
  });

  @override
  State<_ModifyDialog> createState() => _ModifyDialogState();
}

class _ModifyDialogState extends State<_ModifyDialog> {
  // Controller is owned here so it is always disposed with the widget.
  late final TextEditingController _controller;
  String? _validationError;
  bool    _confirming = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.suggestion.suggestedAmount.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF0D1B38),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFF1A2E52)),
      ),
      title: const Row(
        children: [
          Icon(Icons.edit_rounded, color: Color(0xFF00D4FF), size: 18),
          SizedBox(width: 8),
          Text(
            'Modifier la suggestion',
            style: TextStyle(
              color:      Colors.white,
              fontSize:   15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      // SingleChildScrollView prevents overflow when the keyboard appears.
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Objective name
            Text(
              widget.suggestion.objectiveName,
              style: const TextStyle(
                color:    Color(0xFF6B8CAE),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),

            // Amount input
            TextField(
              controller:  _controller,
            autofocus:   true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Colors.white, fontSize: 15),
            decoration: InputDecoration(
              labelText:  'Montant à épargner',
              labelStyle: const TextStyle(color: Color(0xFF6B8CAE)),
              suffixText: 'TND',
              suffixStyle: const TextStyle(
                color:      Color(0xFF6B8CAE),
                fontSize:   13,
              ),
              filled:    true,
              fillColor: const Color(0xFF060D1F),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF1A2E52)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF00D4FF),
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFFF5C7A)),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFFF5C7A),
                  width: 1.5,
                ),
              ),
              errorText: _validationError,
            ),
            onChanged: (_) {
              if (_validationError != null) {
                setState(() => _validationError = null);
              }
            },
          ),
          const SizedBox(height: 10),

          // Budget hint
          Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: Color(0xFF4A6080),
                size:  12,
              ),
              const SizedBox(width: 5),
              Text(
                'Budget restant : ${widget.cur.format(widget.vm.remainingBudget)}',
                style: const TextStyle(
                  color:    Color(0xFF4A6080),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
        ),   // Column
      ),     // SingleChildScrollView (content)
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Annuler',
            style: TextStyle(color: Color(0xFF6B8CAE)),
          ),
        ),
        TextButton(
          onPressed: _confirming ? null : _handleConfirm,
          child: _confirming
              ? const SizedBox(
                  width: 16, height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Color(0xFF3EFFA8)),
                  ),
                )
              : const Text(
                  'Confirmer',
                  style: TextStyle(
                    color:      Color(0xFF3EFFA8),
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ],
    );
  }

  Future<void> _handleConfirm() async {
    final raw    = _controller.text.trim().replaceAll(',', '.');
    final amount = double.tryParse(raw);

    if (amount == null || amount <= 0) {
      setState(() => _validationError = 'Entrez un montant valide');
      return;
    }

    final objective    = widget.vm.objectiveById(widget.suggestion.objectiveId);
    final maxAllowed   = objective?.remaining ?? double.infinity;
    if (amount > maxAllowed) {
      setState(() =>
          _validationError = 'Dépasse le montant restant de l\'objectif');
      return;
    }

    setState(() => _confirming = true);
    Navigator.of(context).pop();
    await widget.onConfirm(amount);
  }
}
