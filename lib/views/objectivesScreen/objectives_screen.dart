import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/objective.dart';
import '../../viewmodels/objectives_view_model.dart';
import 'objective_card.dart';
import 'add_objective_sheet.dart';

// ══════════════════════════════════════════════════════════════
//  VIEW – ObjectivesScreen
//  lib/views/objectivesScreen/objectives_screen.dart
// ══════════════════════════════════════════════════════════════

// Options de tri
enum SortOption {
  priorityAsc,    // Priorité : haute → basse
  priorityDesc,   // Priorité : basse → haute
  progressAsc,    // Progression : moins → plus atteint
  progressDesc,   // Progression : plus → moins atteint
}

extension SortOptionLabel on SortOption {
  String get label {
    switch (this) {
      case SortOption.priorityAsc:  return 'Priorité : haute → basse';
      case SortOption.priorityDesc: return 'Priorité : basse → haute';
      case SortOption.progressAsc:  return 'Progression : moins atteint';
      case SortOption.progressDesc: return 'Progression : plus atteint';
    }
  }

  IconData get icon {
    switch (this) {
      case SortOption.priorityAsc:  return Icons.arrow_upward_rounded;
      case SortOption.priorityDesc: return Icons.arrow_downward_rounded;
      case SortOption.progressAsc:  return Icons.signal_cellular_alt_1_bar_rounded;
      case SortOption.progressDesc: return Icons.signal_cellular_alt_rounded;
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
  SortOption _currentSort = SortOption.priorityAsc;

  // ── Applique le tri choisi sur la liste ────────────────────
  List<Objective> _sorted(List<Objective> list) {
    final sorted = List<Objective>.from(list);
    switch (_currentSort) {
      case SortOption.priorityAsc:
        sorted.sort((a, b) => a.priority.compareTo(b.priority));
        break;
      case SortOption.priorityDesc:
        sorted.sort((a, b) => b.priority.compareTo(a.priority));
        break;
      case SortOption.progressAsc:
        sorted.sort((a, b) => a.progress.compareTo(b.progress));
        break;
      case SortOption.progressDesc:
        sorted.sort((a, b) => b.progress.compareTo(a.progress));
        break;
    }
    return sorted;
  }

  // ── Menu de tri (bottom sheet) ─────────────────────────────
  void _showSortSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0B1535),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
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
              const Text('Trier par',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              const Text('Choisissez l\'ordre d\'affichage',
                  style: TextStyle(
                      color: Color(0xFF4A6080), fontSize: 12)),
              const SizedBox(height: 20),

              // ── Séparateur : Priorité
              _sheetSectionLabel('Par priorité'),
              const SizedBox(height: 10),
              _sortOption(
                ctx, setSheet,
                option: SortOption.priorityAsc,
                subtitle: 'Les plus importants en premier',
              ),
              const SizedBox(height: 8),
              _sortOption(
                ctx, setSheet,
                option: SortOption.priorityDesc,
                subtitle: 'Les moins importants en premier',
              ),
              const SizedBox(height: 16),

              // ── Séparateur : Progression
              _sheetSectionLabel('Par progression'),
              const SizedBox(height: 10),
              _sortOption(
                ctx, setSheet,
                option: SortOption.progressDesc,
                subtitle: 'Les plus proches du but en premier',
              ),
              const SizedBox(height: 8),
              _sortOption(
                ctx, setSheet,
                option: SortOption.progressAsc,
                subtitle: 'Les moins avancés en premier',
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetSectionLabel(String text) => Text(
    text,
    style: const TextStyle(
        color: Color(0xFF8BA8D4),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5),
  );

  Widget _sortOption(
      BuildContext ctx,
      StateSetter setSheet, {
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
              child: Icon(
                option.icon,
                color: isSelected
                    ? const Color(0xFF3EFFA8)
                    : const Color(0xFF4A6080),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(option.label,
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

    return Scaffold(
      backgroundColor: const Color(0xFF060D1F),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildGlobalProgress(vm),
            Expanded(child: _buildList(context, vm)),
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
        label: const Text('Nouvel objectif',
            style: TextStyle(
                color: Color(0xFF060D1F),
                fontWeight: FontWeight.w700)),
      ),
    );
  }

  // ── Header avec bouton tri actif ───────────────────────────
  Widget _buildHeader(BuildContext context) {
    // Affiche le label court du tri actif
    final shortLabel = _currentSort == SortOption.priorityAsc
        ? 'Priorité'
        : _currentSort == SortOption.priorityDesc
        ? 'Priorité ↑'
        : _currentSort == SortOption.progressDesc
        ? 'Plus atteint'
        : 'Moins atteint';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Objectifs',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800)),
              Text('Vos objectifs d\'épargne',
                  style: TextStyle(
                      color: Color(0xFF4A6080), fontSize: 13)),
            ],
          ),
          const Spacer(),
          // Bouton tri — s'allume si tri non-défaut
          GestureDetector(
            onTap: () => _showSortSheet(context),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: _currentSort != SortOption.priorityAsc
                    ? const Color(0xFF3EFFA8).withOpacity(0.12)
                    : const Color(0xFF0B1535),
                border: Border.all(
                  color: _currentSort != SortOption.priorityAsc
                      ? const Color(0xFF3EFFA8).withOpacity(0.5)
                      : const Color(0xFF1A2E52),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.sort_rounded,
                    color: _currentSort != SortOption.priorityAsc
                        ? const Color(0xFF3EFFA8)
                        : const Color(0xFF8BA8D4),
                    size: 16,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    shortLabel,
                    style: TextStyle(
                      color: _currentSort != SortOption.priorityAsc
                          ? const Color(0xFF3EFFA8)
                          : const Color(0xFF8BA8D4),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Barre de progression globale ───────────────────────────
  Widget _buildGlobalProgress(ObjectivesViewModel vm) {
    return StreamBuilder<List<Objective>>(
      stream: vm.objectivesStream,
      builder: (context, snapshot) {
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
                    const Text('Épargne totale',
                        style: TextStyle(
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
                    Text('${saved.toStringAsFixed(0)} TND épargnés',
                        style: const TextStyle(
                            color: Color(0xFF3EFFA8), fontSize: 12)),
                    Text('Objectif: ${target.toStringAsFixed(0)} TND',
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
  Widget _buildList(BuildContext context, ObjectivesViewModel vm) {
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
                const Text('Aucun objectif pour l\'instant',
                    style: TextStyle(
                        color: Color(0xFF4A6080), fontSize: 15)),
                const SizedBox(height: 6),
                const Text('Appuyez sur + pour en créer un',
                    style: TextStyle(
                        color: Color(0xFF2A4060), fontSize: 12)),
              ],
            ),
          );
        }

        return Column(
          children: [
            // ── Indicateur du tri actif
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Row(
                children: [
                  Icon(_currentSort.icon,
                      color: const Color(0xFF4A6080), size: 12),
                  const SizedBox(width: 6),
                  Text(
                    _currentSort.label,
                    style: const TextStyle(
                        color: Color(0xFF4A6080), fontSize: 11),
                  ),
                  const Spacer(),
                  Text(
                    '${objectives.length} objectif${objectives.length > 1 ? 's' : ''}',
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