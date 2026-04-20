import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:savy/l10n/app_localizations.dart';
import '../../models/objective.dart';
import '../../providers/currency_provider.dart';
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

    final cur = context.watch<CurrencyProvider>();

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
          _buildHeader(context, obj, color, icon, cur),
          _buildProgressBar(context, obj, color, cur),
          const SizedBox(height: 12),
          _buildSuggestionStrip(color),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, Objective obj,
      Color color, IconData icon, CurrencyProvider cur) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Badge priorité
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
          // Icône
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: color.withOpacity(0.12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          // Nom + deadline
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
          // Montants
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(cur.format(obj.currentAmount),
                  style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.w800)),
              Text('/ ${cur.format(obj.targetAmount)}',
                  style: const TextStyle(
                      color: Color(0xFF4A6080), fontSize: 11)),
            ],
          ),
          const SizedBox(width: 8),
          // Bouton + (ajouter un versement)
          if (!obj.isCompleted)
            GestureDetector(
              onTap: () => _showAddAmountSheet(context, obj, color),
              child: Container(
                width: 30, height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: color.withOpacity(0.15),
                  border: Border.all(color: color.withOpacity(0.4)),
                ),
                child: Icon(Icons.add_rounded, color: color, size: 16),
              ),
            ),
          if (obj.isCompleted)
            const Icon(Icons.check_circle_rounded,
                color: Color(0xFF3EFFA8), size: 22),
          const SizedBox(width: 6),
          // Bouton supprimer
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
  Widget _buildProgressBar(BuildContext context, Objective obj, Color color, CurrencyProvider cur) {
    final l10n = AppLocalizations.of(context);
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
              Text('${(obj.progress * 100).toStringAsFixed(0)}% ${l10n.objectivesReached}',
                  style: TextStyle(color: color, fontSize: 11)),
              Text('${l10n.objectivesMissing} ${cur.format(obj.remaining)}',
                  style: const TextStyle(
                      color: Color(0xFF4A6080), fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Suggestion strip ────────────────────────────────────────
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

  // ── Bottom sheet : ajouter un versement ────────────────────
  void _showAddAmountSheet(BuildContext context, Objective obj, Color color) {
    final ctrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) {
          final l10n = AppLocalizations.of(ctx);
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0B1535),
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Form(
                key: formKey,
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

                    // Titre
                    Row(
                      children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: color.withOpacity(0.15),
                          ),
                          child: Icon(Icons.savings_rounded,
                              color: color, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${l10n.objectivesFeedTitle} "${obj.name}"',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800)),
                              Text(
                                '${l10n.objectivesMissing} ${context.read<CurrencyProvider>().format(obj.remaining)}',
                                style: TextStyle(
                                    color: color, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Champ montant
                    Text(l10n.objectivesAmountToAdd,
                        style: const TextStyle(
                            color: Color(0xFF8BA8D4),
                            fontSize: 13,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: ctrl,
                      autofocus: true,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      inputFormatters: [_DecimalFormatter()],
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return l10n.objectivesAmountError;
                        final val =
                            double.tryParse(v.replaceAll(',', '.'));
                        if (val == null || val <= 0)
                          return l10n.objectivesAmountInvalid;
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: '0.00',
                        hintStyle: const TextStyle(
                            color: Color(0xFF3A5068), fontSize: 15),
                        prefixIcon: Icon(Icons.add_rounded,
                            color: color, size: 20),
                        suffixText: context.read<CurrencyProvider>().selected.symbol,
                        suffixStyle: const TextStyle(
                            color: Color(0xFF8BA8D4),
                            fontSize: 15,
                            fontWeight: FontWeight.w500),
                        filled: true,
                        fillColor: const Color(0xFF0D1B38),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              const BorderSide(color: Color(0xFF1A2E52)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: Color(0xFF1A2E52), width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              BorderSide(color: color, width: 1.5),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: Color(0xFFFF5C7A), width: 1),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: Color(0xFFFF5C7A), width: 1.5),
                        ),
                        errorStyle: const TextStyle(
                            color: Color(0xFFFF5C7A), fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Bouton confirmer
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: isLoading
                          ? Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: color.withOpacity(0.2),
                              ),
                              child: Center(
                                child: SizedBox(
                                  width: 22, height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor:
                                        AlwaysStoppedAnimation(color),
                                  ),
                                ),
                              ),
                            )
                          : DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                gradient: LinearGradient(colors: [
                                  color,
                                  color.withOpacity(0.7),
                                ]),
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withOpacity(0.3),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (!formKey.currentState!
                                      .validate()) return;
                                  setSheet(() => isLoading = true);

                                  final amount = double.parse(
                                      ctrl.text.replaceAll(',', '.'));
                                  final error = await viewModel
                                      .addAmountToObjective(
                                    id: obj.id,
                                    amount: amount,
                                  );

                                  if (!ctx.mounted) return;
                                  Navigator.pop(ctx);

                                  if (error != null) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text(error,
                                          style: const TextStyle(
                                              color: Colors.white)),
                                      backgroundColor:
                                          const Color(0xFF0D1B38),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        side: const BorderSide(
                                            color: Color(0xFFFF5C7A)),
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                    ));
                                  } else {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text(
                                        '+ ${context.read<CurrencyProvider>().format(amount)} ajoutés à "${obj.name}"',
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      backgroundColor:
                                          const Color(0xFF0D1B38),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        side: const BorderSide(
                                            color: Color(0xFF3EFFA8)),
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                    ));
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(14)),
                                ),
                                child: Text(l10n.objectivesConfirmPayment,
                                    style: const TextStyle(
                                        color: Color(0xFF060D1F),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700)),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Supprimer ──────────────────────────────────────────────
  Future<void> _confirmDelete(BuildContext context, Objective obj) async {
    final l10n = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0B1535),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.objectivesDeleteTitle,
            style: const TextStyle(color: Colors.white)),
        content: Text(l10n.objectivesDeleteConfirm(obj.name),
            style: const TextStyle(color: Color(0xFF8BA8D4))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel,
                style: const TextStyle(color: Color(0xFF4A6080))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete,
                style: const TextStyle(color: Color(0xFFFF6B8A))),
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

// ── Formateur décimal (chiffres, virgule, point) ───────────────
class _DecimalFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue next) {
    final text = next.text.replaceAll(RegExp(r'[^0-9,.]'), '');
    final seps =
        text.split('').where((c) => c == '.' || c == ',').length;
    if (seps > 1) return old;
    final dot = text.indexOf(RegExp(r'[.,]'));
    if (dot != -1 && text.substring(dot + 1).length > 2) return old;
    if (text == next.text) return next;
    return next.copyWith(
        text: text,
        selection: TextSelection.collapsed(offset: text.length));
  }
}
