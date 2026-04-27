import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savy/l10n/app_localizations.dart';
import '../../models/objective.dart';
import '../../providers/currency_provider.dart';
import '../../viewmodels/objectives_view_model.dart';
import 'objective_card.dart';
import 'add_objective_sheet.dart';

// ══════════════════════════════════════════════════════════════
//  VIEW – ObjectivesScreen
//  lib/views/objectivesScreen/objectives_screen.dart
// ══════════════════════════════════════════════════════════════

enum SortOption {
  dateDesc,      // Date : plus récent → plus ancien
  dateAsc,       // Date : plus ancien → plus récent
  priorityAsc,   // Priorité : haute → basse
  priorityDesc,  // Priorité : basse → haute
  progressDesc,  // Progression : plus atteint → moins atteint
  progressAsc,   // Progression : moins atteint → plus atteint
}

extension SortOptionIcon on SortOption {
  IconData get icon {
    switch (this) {
      case SortOption.dateDesc:     return Icons.arrow_downward_rounded;
      case SortOption.dateAsc:      return Icons.arrow_upward_rounded;
      case SortOption.priorityAsc:  return Icons.keyboard_double_arrow_up_rounded;
      case SortOption.priorityDesc: return Icons.keyboard_double_arrow_down_rounded;
      case SortOption.progressDesc: return Icons.signal_cellular_alt_rounded;
      case SortOption.progressAsc:  return Icons.signal_cellular_alt_1_bar_rounded;
    }
  }
}

class ObjectivesScreen extends StatelessWidget {
  const ObjectivesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ObjectivesViewModel(),
      child: const _ObjectivesView(),
    );
  }
}

class _ObjectivesView extends StatefulWidget {
  const _ObjectivesView();

  @override
  State<_ObjectivesView> createState() => _ObjectivesViewState();
}

class _ObjectivesViewState extends State<_ObjectivesView> {
  SortOption _currentSort = SortOption.dateDesc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ObjectivesViewModel>().checkDeadlineReminders();
    });
  }

  // ── Helper: get localized label for a SortOption ──────────
  String _sortLabel(SortOption option, AppLocalizations l10n) {
    switch (option) {
      case SortOption.dateDesc:     return l10n.objectivesSortDateDesc;
      case SortOption.dateAsc:      return l10n.objectivesSortDateAsc;
      case SortOption.priorityAsc:  return l10n.objectivesSortPriorityHighFirst;
      case SortOption.priorityDesc: return l10n.objectivesSortPriorityLowFirst;
      case SortOption.progressDesc: return l10n.objectivesSortProgressDesc;
      case SortOption.progressAsc:  return l10n.objectivesSortProgressAsc;
    }
  }

  // ── Tri ────────────────────────────────────────────────────
  List<Objective> _sorted(List<Objective> list) {
    final sorted = List<Objective>.from(list);
    switch (_currentSort) {
      case SortOption.dateDesc:
        sorted.sort((a, b) =>
            (b.createdAt ?? DateTime(2000)).compareTo(a.createdAt ?? DateTime(2000)));
        break;
      case SortOption.dateAsc:
        sorted.sort((a, b) =>
            (a.createdAt ?? DateTime(2000)).compareTo(b.createdAt ?? DateTime(2000)));
        break;
      case SortOption.priorityAsc:
        sorted.sort((a, b) => a.priority.compareTo(b.priority));
        break;
      case SortOption.priorityDesc:
        sorted.sort((a, b) => b.priority.compareTo(a.priority));
        break;
      case SortOption.progressDesc:
        sorted.sort((a, b) => b.progress.compareTo(a.progress));
        break;
      case SortOption.progressAsc:
        sorted.sort((a, b) => a.progress.compareTo(b.progress));
        break;
    }
    return sorted;
  }

  // ── Bottom sheet filtre unique ─────────────────────────────
  void _showFilterSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0B1535),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2E52),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(l10n.objectivesSortTitle,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(l10n.objectivesSortSubtitle,
                    style: const TextStyle(color: Color(0xFF4A6080), fontSize: 12)),
                const SizedBox(height: 20),

                _sectionLabel(l10n.objectivesSortByDate),
                const SizedBox(height: 10),
                _sortOption(ctx, setSheet, l10n,
                    option: SortOption.dateDesc,
                    subtitle: l10n.objectivesSortDateDescSub),
                const SizedBox(height: 8),
                _sortOption(ctx, setSheet, l10n,
                    option: SortOption.dateAsc,
                    subtitle: l10n.objectivesSortDateAscSub),
                const SizedBox(height: 16),

                _sectionLabel(l10n.objectivesSortByPriority),
                const SizedBox(height: 10),
                _sortOption(ctx, setSheet, l10n,
                    option: SortOption.priorityAsc,
                    subtitle: l10n.objectivesSortPriorityHighFirstSub),
                const SizedBox(height: 8),
                _sortOption(ctx, setSheet, l10n,
                    option: SortOption.priorityDesc,
                    subtitle: l10n.objectivesSortPriorityLowFirstSub),
                const SizedBox(height: 16),

                _sectionLabel(l10n.objectivesSortByProgress),
                const SizedBox(height: 10),
                _sortOption(ctx, setSheet, l10n,
                    option: SortOption.progressDesc,
                    subtitle: l10n.objectivesSortProgressDescSub),
                const SizedBox(height: 8),
                _sortOption(ctx, setSheet, l10n,
                    option: SortOption.progressAsc,
                    subtitle: l10n.objectivesSortProgressAscSub),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: const TextStyle(
        color: Color(0xFF8BA8D4),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5),
  );

  Widget _sortOption(
      BuildContext ctx,
      StateSetter setSheet,
      AppLocalizations l10n, {
        required SortOption option,
        required String subtitle,
      }) {
    final isSelected = _currentSort == option;
    return GestureDetector(
      onTap: () {
        setState(() => _currentSort = option);
        setSheet(() {});
        Navigator.pop(ctx);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isSelected
              ? const Color(0xFF3EFFA8).withOpacity(0.08)
              : const Color(0xFF0D1B38),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF3EFFA8).withOpacity(0.5)
                : const Color(0xFF1A2E52),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: isSelected
                    ? const Color(0xFF3EFFA8).withOpacity(0.15)
                    : const Color(0xFF1A2E52),
              ),
              child: Icon(option.icon,
                  color: isSelected
                      ? const Color(0xFF3EFFA8)
                      : const Color(0xFF4A6080),
                  size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_sortLabel(option, l10n),
                      style: TextStyle(
                          color: isSelected
                              ? const Color(0xFF3EFFA8)
                              : Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          color: Color(0xFF4A6080), fontSize: 11)),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: Color(0xFF3EFFA8), size: 18),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ObjectivesViewModel>();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF060D1F),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, l10n),
            _buildGlobalProgress(vm, l10n),
            Expanded(child: _buildList(context, vm, l10n)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_objectives',
        onPressed: () => showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (_) => AddObjectiveSheet(viewModel: vm),
        ),
        backgroundColor: const Color(0xFF3EFFA8),
        icon: const Icon(Icons.add, color: Color(0xFF060D1F)),
        label: Text(l10n.objectivesAdd,
            style: const TextStyle(
                color: Color(0xFF060D1F),
                fontWeight: FontWeight.w700)),
      ),
    );
  }

  // ── Header avec bouton filtre unique ──────────────────────
  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.objectivesTitle,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800)),
              Text(l10n.objectivesSubtitle,
                  style: const TextStyle(
                      color: Color(0xFF4A6080), fontSize: 13)),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _showFilterSheet(context),
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xFF0B1535),
                border: Border.all(color: const Color(0xFF1A2E52)),
              ),
              child: const Icon(Icons.filter_list_rounded,
                  color: Color(0xFF8BA8D4), size: 18),
            ),
          ),
        ],
      ),
    );
  }

  // ── Barre de progression globale ───────────────────────────
  Widget _buildGlobalProgress(ObjectivesViewModel vm, AppLocalizations l10n) {
    return StreamBuilder<List<Objective>>(
      stream: vm.objectivesStream,
      builder: (context, snapshot) {
        final cur = context.watch<CurrencyProvider>();
        final objectives = snapshot.data ?? [];
        final totals = vm.computeTotals(objectives);
        final saved = totals['saved']!;
        final target = totals['target']!;
        final progress =
        target > 0 ? (saved / target).clamp(0.0, 1.0) : 0.0;

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F2347), Color(0xFF0B1535)],
              ),
              border: Border.all(
                  color: const Color(0xFF3EFFA8).withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.savings_rounded,
                        color: Color(0xFF3EFFA8), size: 20),
                    const SizedBox(width: 10),
                    Text(l10n.objectivesTotalSavings,
                        style: const TextStyle(
                            color: Color(0xFF8BA8D4),
                            fontSize: 13,
                            fontWeight: FontWeight.w500)),
                    const Spacer(),
                    Text('${(progress * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                            color: Color(0xFF3EFFA8),
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: const Color(0xFF1A2E52),
                    valueColor: const AlwaysStoppedAnimation(
                        Color(0xFF3EFFA8)),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${cur.format(saved)} ${l10n.objectivesSaved}',
                        style: const TextStyle(
                            color: Color(0xFF3EFFA8), fontSize: 12)),
                    Text('Objectif: ${cur.format(target)}',
                        style: const TextStyle(
                            color: Color(0xFF4A6080), fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Liste triée ────────────────────────────────────────────
  Widget _buildList(BuildContext context, ObjectivesViewModel vm, AppLocalizations l10n) {
    return StreamBuilder<List<Objective>>(
      stream: vm.objectivesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(
                  color: Color(0xFF3EFFA8)));
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Erreur: ${snapshot.error}',
                style: const TextStyle(color: Color(0xFFFF6B8A))),
          );
        }

        final objectives = _sorted(snapshot.data ?? []);

        if (objectives.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.savings_outlined,
                    color: const Color(0xFF1A2E52), size: 64),
                const SizedBox(height: 16),
                Text(l10n.objectivesEmpty,
                    style: const TextStyle(
                        color: Color(0xFF4A6080), fontSize: 15)),
                const SizedBox(height: 6),
                Text(l10n.objectivesEmptyHint,
                    style: const TextStyle(
                        color: Color(0xFF2A4060), fontSize: 12)),
              ],
            ),
          );
        }

        final countText = objectives.length == 1
            ? l10n.objectivesCount(1)
            : l10n.objectivesCountPlural(objectives.length);

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Row(
                children: [
                  Icon(_currentSort.icon,
                      color: const Color(0xFF4A6080), size: 12),
                  const SizedBox(width: 6),
                  Text(
                    _sortLabel(_currentSort, l10n),
                    style: const TextStyle(
                        color: Color(0xFF4A6080), fontSize: 11),
                  ),
                  const Spacer(),
                  Text(
                    countText,
                    style: const TextStyle(
                        color: Color(0xFF4A6080), fontSize: 11),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                physics: const BouncingScrollPhysics(),
                itemCount: objectives.length,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ObjectiveCard(
                    objective: objectives[i],
                    viewModel: vm,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
