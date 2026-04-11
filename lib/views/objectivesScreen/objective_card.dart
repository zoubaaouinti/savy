import 'package:flutter/material.dart';
import '../../models/objective.dart';
import '../../viewmodels/objectives_view_model.dart';

// ══════════════════════════════════════════════════════════════
//  WIDGET – ObjectiveCard
//  lib/views/objectivesScreen/objective_card.dart
// ══════════════════════════════════════════════════════════════

class ObjectiveCard extends StatelessWidget {
  final Objective objective;
  final ObjectivesViewModel viewModel;

  const ObjectiveCard({
    super.key,
    required this.objective,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final obj = objective;
    final color = Objective.colorFromHex(obj.color);
    final icon = Objective.iconFromName(obj.icon);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF0B1535),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(context, obj, color, icon),
          _buildProgressBar(obj, color),
          const SizedBox(height: 12),
          _buildSuggestionStrip(color),  // UI visible, bouton désactivé
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, Objective obj,
      Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 22, height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.15),
              border: Border.all(color: color.withOpacity(0.4)),
            ),
            child: Center(
              child: Text('${obj.priority}',
                  style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: color.withOpacity(0.12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(obj.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        color: Color(0xFF4A6080), size: 11),
                    const SizedBox(width: 4),
                    Text(obj.deadline,
                        style: const TextStyle(
                            color: Color(0xFF4A6080), fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${obj.currentAmount.toStringAsFixed(0)} TND',
                  style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.w800)),
              Text('/ ${obj.targetAmount.toStringAsFixed(0)} TND',
                  style: const TextStyle(
                      color: Color(0xFF4A6080), fontSize: 11)),
            ],
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _confirmDelete(context, obj),
            child: const Icon(Icons.delete_outline_rounded,
                color: Color(0xFF4A6080), size: 18),
          ),
        ],
      ),
    );
  }

  // ── Barre de progression ───────────────────────────────────
  Widget _buildProgressBar(Objective obj, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: obj.progress,
              minHeight: 8,
              backgroundColor: const Color(0xFF1A2E52),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${(obj.progress * 100).toStringAsFixed(0)}% atteint',
                  style: TextStyle(color: color, fontSize: 11)),
              Text('Manque: ${obj.remaining.toStringAsFixed(0)} TND',
                  style: const TextStyle(
                      color: Color(0xFF4A6080), fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Suggestion strip — UI présente, bouton "Bientôt" ───────
  Widget _buildSuggestionStrip(Color color) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF0D1B38),
        border: Border.all(color: const Color(0xFF1A2E52)),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome,
              color: Color(0xFF3A5068), size: 14),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Suggestion IA — bientôt disponible',
              style: TextStyle(color: Color(0xFF3A5068), fontSize: 12),
            ),
          ),
          // Bouton désactivé visuellement
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFF1A2E52),
            ),
            child: const Text('Bientôt',
                style: TextStyle(
                    color: Color(0xFF3A5068),
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ── Supprimer ──────────────────────────────────────────────
  Future<void> _confirmDelete(BuildContext context, Objective obj) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0B1535),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Supprimer l\'objectif',
            style: TextStyle(color: Colors.white)),
        content: Text('Voulez-vous supprimer "${obj.name}" ?',
            style: const TextStyle(color: Color(0xFF8BA8D4))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler',
                style: TextStyle(color: Color(0xFF4A6080))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer',
                style: TextStyle(color: Color(0xFFFF6B8A))),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      final error = await viewModel.deleteObjective(obj.id);
      if (error != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error),
          backgroundColor: const Color(0xFFFF6B8A),
        ));
      }
    }
  }
}