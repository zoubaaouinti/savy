import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../models/objective.dart';
import '../../viewmodels/objectives_view_model.dart';

// ══════════════════════════════════════════════════════════════
//  WIDGET – AddObjectiveSheet
//  lib/views/objectivesScreen/add_objective_sheet.dart
// ══════════════════════════════════════════════════════════════

class AddObjectiveSheet extends StatefulWidget {
  final ObjectivesViewModel viewModel;

  const AddObjectiveSheet({super.key, required this.viewModel});

  @override
  State<AddObjectiveSheet> createState() => _AddObjectiveSheetState();
}

class _AddObjectiveSheetState extends State<AddObjectiveSheet> {
  // ── Controllers ────────────────────────────────────────────
  final _nameCtrl    = TextEditingController();
  final _targetCtrl  = TextEditingController();
  final _currentCtrl = TextEditingController();

  // ── State local ────────────────────────────────────────────
  DateTime? _selectedDate;
  String    _selectedIcon  = 'savings';
  String    _selectedColor = '#3EFFA8';
  int       _selectedPriority = 1;          // liste 1-5

  @override
  void dispose() {
    _nameCtrl.dispose();
    _targetCtrl.dispose();
    _currentCtrl.dispose();
    super.dispose();
  }

  // ── Calendrier thème sombre ────────────────────────────────
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
      locale: const Locale('fr'),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF3EFFA8),
            onPrimary: Color(0xFF060D1F),
            surface: Color(0xFF0F2347),
            onSurface: Colors.white,
          ),
          dialogBackgroundColor: const Color(0xFF0B1535),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF3EFFA8)),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  // ── Submit → ViewModel ─────────────────────────────────────
  Future<void> _submit() async {
    final error = await widget.viewModel.createObjective(
      name:          _nameCtrl.text,
      targetAmount:  double.tryParse(_targetCtrl.text)  ?? 0,
      currentAmount: double.tryParse(_currentCtrl.text) ?? 0,
      priority:      _selectedPriority,
      deadline:      _selectedDate,
      icon:          _selectedIcon,
      color:         _selectedColor,
    );

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error),
        backgroundColor: const Color(0xFFFF6B8A),
        behavior: SnackBarBehavior.floating,
      ));
    } else {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('✅ Objectif créé avec succès !'),
        backgroundColor: Color(0xFF3EFFA8),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  // ── Build ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0B1535),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Handle
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
            const Text('Nouvel objectif',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 20),

            // ── Nom (texte libre)
            _label('Nom de l\'objectif'),
            const SizedBox(height: 8),
            _textField(
              ctrl: _nameCtrl,
              hint: 'Ex: Ordinateur portable',
              icon: Icons.flag_rounded,
            ),
            const SizedBox(height: 14),

            // ── Montants (chiffres uniquement)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Montant cible (TND)'),
                      const SizedBox(height: 8),
                      _amountField(
                        ctrl: _targetCtrl,
                        hint: '0.00',
                        icon: Icons.savings_rounded,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Déjà épargné (TND)'),
                      const SizedBox(height: 8),
                      _amountField(
                        ctrl: _currentCtrl,
                        hint: '0.00',
                        icon: Icons.account_balance_wallet_rounded,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Priorité — liste 1 à 5
            _label('Priorité'),
            const SizedBox(height: 10),
            _buildPrioritySelector(),
            const SizedBox(height: 14),

            // ── Date limite
            _label('Date limite'),
            const SizedBox(height: 8),
            _buildDatePicker(),
            const SizedBox(height: 20),

            // ── Icône
            _label('Icône'),
            const SizedBox(height: 10),
            _buildIconSelector(),
            const SizedBox(height: 20),

            // ── Couleur
            _label('Couleur'),
            const SizedBox(height: 10),
            _buildColorSelector(),
            const SizedBox(height: 28),

            // ── Bouton créer
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: widget.viewModel.isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3EFFA8),
                  disabledBackgroundColor:
                  const Color(0xFF3EFFA8).withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: widget.viewModel.isLoading
                    ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(
                        color: Color(0xFF060D1F), strokeWidth: 2))
                    : const Text('Créer l\'objectif',
                    style: TextStyle(
                        color: Color(0xFF060D1F),
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  //  COMPOSANTS UI
  // ══════════════════════════════════════════════════════════

  // ── Priorité 1-5 (chips sélectionnables) ──────────────────
  Widget _buildPrioritySelector() {
    const labels = {
      1: '1 — Haute',
      2: '2 — Élevée',
      3: '3 — Moyenne',
      4: '4 — Faible',
      5: '5 — Basse',
    };

    return Row(
      children: List.generate(5, (i) {
        final val = i + 1;
        final isSelected = _selectedPriority == val;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedPriority = val),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: EdgeInsets.only(right: i < 4 ? 6 : 0),
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: isSelected
                    ? const Color(0xFF3EFFA8).withOpacity(0.15)
                    : const Color(0xFF0D1B38),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF3EFFA8)
                      : const Color(0xFF1A2E52),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$val',
                    style: TextStyle(
                      color: isSelected
                          ? const Color(0xFF3EFFA8)
                          : const Color(0xFF4A6080),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // ── Label de priorité en dessous ──────────────────────────
  Widget _buildPriorityLabel() {
    const labels = {
      1: 'Haute',
      2: 'Élevée',
      3: 'Moyenne',
      4: 'Faible',
      5: 'Basse',
    };
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        'Priorité sélectionnée : ${labels[_selectedPriority]}',
        style: const TextStyle(
            color: Color(0xFF3EFFA8), fontSize: 11),
      ),
    );
  }

  // ── Date picker ───────────────────────────────────────────
  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF0D1B38),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _selectedDate != null
                ? const Color(0xFF3EFFA8).withOpacity(0.6)
                : const Color(0xFF1A2E52),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_rounded,
                color: Color(0xFF3EFFA8), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedDate != null
                    ? DateFormat('dd MMMM yyyy', 'fr')
                    .format(_selectedDate!)
                    : 'Choisir une date',
                style: TextStyle(
                  color: _selectedDate != null
                      ? Colors.white
                      : const Color(0xFF3A5068),
                  fontSize: 14,
                ),
              ),
            ),
            if (_selectedDate != null)
              GestureDetector(
                onTap: () => setState(() => _selectedDate = null),
                child: const Icon(Icons.close_rounded,
                    color: Color(0xFF4A6080), size: 16),
              )
            else
              const Icon(Icons.chevron_right_rounded,
                  color: Color(0xFF3A5068), size: 18),
          ],
        ),
      ),
    );
  }

  // ── Icône selector ────────────────────────────────────────
  Widget _buildIconSelector() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: Objective.availableIcons.entries.map((e) {
        final isSelected = _selectedIcon == e.key;
        return GestureDetector(
          onTap: () => setState(() => _selectedIcon = e.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 46, height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isSelected
                  ? const Color(0xFF3EFFA8).withOpacity(0.15)
                  : const Color(0xFF0D1B38),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF3EFFA8)
                    : const Color(0xFF1A2E52),
              ),
            ),
            child: Icon(e.value,
                color: isSelected
                    ? const Color(0xFF3EFFA8)
                    : const Color(0xFF4A6080),
                size: 22),
          ),
        );
      }).toList(),
    );
  }

  // ── Couleur selector ──────────────────────────────────────
  Widget _buildColorSelector() {
    return Row(
      children: Objective.availableColors.map((hex) {
        final c = Objective.colorFromHex(hex);
        final isSelected = _selectedColor == hex;
        return GestureDetector(
          onTap: () => setState(() => _selectedColor = hex),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.only(right: 10),
            width: 36, height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: c,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 2.5,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: c.withOpacity(0.5), blurRadius: 8)]
                  : [],
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : null,
          ),
        );
      }).toList(),
    );
  }

  // ══════════════════════════════════════════════════════════
  //  CHAMPS TEXTE
  // ══════════════════════════════════════════════════════════

  // ── Champ texte libre (nom) ───────────────────────────────
  Widget _textField({
    required TextEditingController ctrl,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.text,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: _inputDecoration(hint, icon),
    );
  }

  // ── Champ montant — chiffres + point décimal uniquement ───
  Widget _amountField({
    required TextEditingController ctrl,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      // Bloque tout ce qui n'est pas chiffre ou point
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: _inputDecoration(hint, icon),
    );
  }

  // ── Decoration partagée ───────────────────────────────────
  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
      const TextStyle(color: Color(0xFF3A5068), fontSize: 13),
      filled: true,
      fillColor: const Color(0xFF0D1B38),
      contentPadding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 14),
      prefixIcon:
      Icon(icon, color: const Color(0xFF3EFFA8), size: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF1A2E52)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF1A2E52)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide:
        const BorderSide(color: Color(0xFF3EFFA8), width: 1.5),
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          color: Color(0xFF8BA8D4),
          fontSize: 12,
          fontWeight: FontWeight.w600));
}