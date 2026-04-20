import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../models/currency_model.dart';
import '../../providers/currency_provider.dart';
import 'package:savy/l10n/app_localizations.dart';

class _DecimalInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;

    // Autorise uniquement chiffres, virgule et point
    final filtered = text.replaceAll(RegExp(r'[^0-9,.]'), '');

    // Normalise : remplace la virgule par un point pour le traitement
    // mais garde le séparateur saisi par l'utilisateur
    final separatorCount =
        filtered.split('').where((c) => c == '.' || c == ',').length;

    // Interdit plus d'un séparateur décimal
    if (separatorCount > 1) return oldValue;

    // Interdit plus de 2 chiffres après le séparateur
    final dotIndex = filtered.indexOf(RegExp(r'[.,]'));
    if (dotIndex != -1) {
      final decimals = filtered.substring(dotIndex + 1);
      if (decimals.length > 2) return oldValue;
    }

    if (filtered == text) return newValue;
    return newValue.copyWith(
      text: filtered,
      selection: TextSelection.collapsed(offset: filtered.length),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  ONBOARDING – STEP 1: Nom de l'utilisateur
// ══════════════════════════════════════════════════════════════

class OnboardingNameScreen extends StatefulWidget {
  const OnboardingNameScreen({super.key});

  @override
  State<OnboardingNameScreen> createState() => _OnboardingNameScreenState();
}

class _OnboardingNameScreenState extends State<OnboardingNameScreen>
    with TickerProviderStateMixin {
  final _nameCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _nameEmpty = true;

  late final AnimationController _bgController;
  late final AnimationController _entranceController;
  late final Animation<double> _bgAnim;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideIn;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
    _bgAnim = CurvedAnimation(parent: _bgController, curve: Curves.easeInOut);

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );
    _slideIn = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
    );
    Future.delayed(
        const Duration(milliseconds: 100), _entranceController.forward);

    _nameCtrl.addListener(() {
      final empty = _nameCtrl.text.trim().isEmpty;
      if (empty != _nameEmpty) setState(() => _nameEmpty = empty);
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _entranceController.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            OnboardingBalanceScreen(userName: _nameCtrl.text.trim()),
        transitionsBuilder: (_, animation, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: FadeTransition(opacity: animation, child: child),
        ),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;
    final hPad = size.shortestSide > 600 ? size.width * 0.2 : 24.0;

    return Scaffold(
      backgroundColor: const Color(0xFF060D1F),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _bgAnim,
            builder: (_, __) => CustomPaint(
              size: size,
              painter: _OnbBgPainter(_bgAnim.value),
            ),
          ),
          CustomPaint(size: size, painter: _OnbGridPainter()),
          SafeArea(
            child: AnimatedBuilder(
              animation: _entranceController,
              builder: (_, child) => FadeTransition(
                opacity: _fadeIn,
                child: SlideTransition(position: _slideIn, child: child),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: hPad),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: size.height * 0.10),
                      _buildIcon(),
                      SizedBox(height: size.height * 0.04),
                      _buildTitle(size, l10n),
                      SizedBox(height: size.height * 0.06),
                      _buildCard(l10n),
                      SizedBox(height: size.height * 0.04),
                      _buildStepIndicator(step: 1),
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

  Widget _buildIcon() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF3EFFA8), Color(0xFF00D4FF)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3EFFA8).withOpacity(0.35),
            blurRadius: 20,
          ),
        ],
      ),
      child: const Center(
        child: Icon(Icons.waving_hand_rounded,
            color: Color(0xFF060D1F), size: 26),
      ),
    );
  }

  Widget _buildTitle(Size size, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (b) => const LinearGradient(
            colors: [Color(0xFF3EFFA8), Color(0xFF00D4FF)],
          ).createShader(b),
          child: Text(
            l10n.onboardingNameTitle,
            style: TextStyle(
              fontSize: (size.width * 0.09).clamp(30.0, 50.0),
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
              height: 1.1,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.onboardingNameSubtitle,
          style: TextStyle(
            fontSize: (size.width * 0.038).clamp(13.0, 18.0),
            color: const Color(0xFF6B8CAE),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0xFF0B1535).withOpacity(0.85),
        border: Border.all(
            color: const Color(0xFF1A2E52).withOpacity(0.8), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3EFFA8).withOpacity(0.05),
            blurRadius: 40,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.onboardingNameHint,
            style: const TextStyle(
              color: Color(0xFF8BA8D4),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameCtrl,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            style: const TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.w400),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return l10n.onboardingNameError;
              return null;
            },
            decoration: InputDecoration(
              hintText: 'Ex: Alex',
              hintStyle:
                  const TextStyle(color: Color(0xFF3A5068), fontSize: 15),
              prefixIcon: const Icon(Icons.person_outline_rounded,
                  color: Color(0xFF3EFFA8), size: 20),
              filled: true,
              fillColor: const Color(0xFF0D1B38),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF1A2E52)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: Color(0xFF1A2E52), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: Color(0xFF3EFFA8), width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: Color(0xFFFF5C7A), width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: Color(0xFFFF5C7A), width: 1.5),
              ),
              errorStyle:
                  const TextStyle(color: Color(0xFFFF5C7A), fontSize: 12),
            ),
          ),
          const SizedBox(height: 28),
          _buildNextButton(l10n),
        ],
      ),
    );
  }

  Widget _buildNextButton(AppLocalizations l10n) {
    final enabled = !_nameEmpty;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: AnimatedOpacity(
        opacity: enabled ? 1.0 : 0.4,
        duration: const Duration(milliseconds: 200),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
              colors: [Color(0xFF3EFFA8), Color(0xFF00D4FF)],
            ),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: const Color(0xFF3EFFA8).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [],
          ),
          child: ElevatedButton(
            onPressed: enabled ? _handleNext : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.onboardingNameNext,
                  style: const TextStyle(
                    color: Color(0xFF060D1F),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded,
                    color: Color(0xFF060D1F), size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator({required int step}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(2, (i) {
        final active = i + 1 == step;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: active
                ? const LinearGradient(
                    colors: [Color(0xFF3EFFA8), Color(0xFF00D4FF)])
                : null,
            color: active ? null : const Color(0xFF1A2E52),
          ),
        );
      }),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  ONBOARDING – STEP 2: Solde disponible
// ══════════════════════════════════════════════════════════════

class OnboardingBalanceScreen extends StatefulWidget {
  final String userName;
  const OnboardingBalanceScreen({super.key, required this.userName});

  @override
  State<OnboardingBalanceScreen> createState() =>
      _OnboardingBalanceScreenState();
}

class _OnboardingBalanceScreenState extends State<OnboardingBalanceScreen>
    with TickerProviderStateMixin {
  final _balanceCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;
  CurrencyInfo _selectedCurrency = CurrencyInfo.defaultCurrency;

  late final AnimationController _bgController;
  late final AnimationController _entranceController;
  late final Animation<double> _bgAnim;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideIn;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
    _bgAnim = CurvedAnimation(parent: _bgController, curve: Curves.easeInOut);

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );
    _slideIn = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
    );
    Future.delayed(
        const Duration(milliseconds: 100), _entranceController.forward);
  }

  @override
  void dispose() {
    _bgController.dispose();
    _entranceController.dispose();
    _balanceCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleFinish() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('Utilisateur non connecté');

      final balance =
          double.tryParse(_balanceCtrl.text.replaceAll(',', '.')) ?? 0.0;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': widget.userName,
        'initialBalance': balance,
        'currency': _selectedCurrency.code,
        'onboardingDone': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      await context
          .read<CurrencyProvider>()
          .setCurrency(_selectedCurrency);
      if (!mounted) return;
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/home', (route) => false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = AppLocalizations.of(context).onboardingBalanceError;
      });
    }
  }

  void _showCurrencyPicker(BuildContext ctx) {
    final searchCtrl = TextEditingController();
    List<CurrencyInfo> filtered = CurrencyInfo.allCurrencies;

    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (sheetCtx, setSheet) => DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scrollCtrl) => Container(
            decoration: const BoxDecoration(
              color: Color(0xFF0B1535),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(children: [
              const SizedBox(height: 12),
              Center(child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: const Color(0xFF1A2E52), borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(AppLocalizations.of(ctx).onboardingBalanceCurrency, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: searchCtrl,
                    onChanged: (q) {
                      final lower = q.toLowerCase();
                      setSheet(() {
                        filtered = q.isEmpty
                            ? CurrencyInfo.allCurrencies
                            : CurrencyInfo.allCurrencies.where((c) =>
                                c.code.toLowerCase().contains(lower) ||
                                c.name.toLowerCase().contains(lower)).toList();
                      });
                    },
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Rechercher...', hintStyle: const TextStyle(color: Color(0xFF3A5068)),
                      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF4A6080), size: 20),
                      filled: true, fillColor: const Color(0xFF0D1B38),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1A2E52))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1A2E52))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3EFFA8), width: 1.5)),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 10),
              Expanded(child: ListView.builder(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                itemCount: filtered.length,
                itemBuilder: (_, i) {
                  final c = filtered[i];
                  final isSelected = c.code == _selectedCurrency.code;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedCurrency = c);
                      Navigator.pop(sheetCtx);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: isSelected ? const Color(0xFF3EFFA8).withOpacity(0.08) : const Color(0xFF0D1B38),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF3EFFA8).withOpacity(0.5) : const Color(0xFF1A2E52),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(children: [
                        Text(c.flag, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(c.code, style: TextStyle(color: isSelected ? const Color(0xFF3EFFA8) : Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                          Text(c.name, style: const TextStyle(color: Color(0xFF4A6080), fontSize: 11)),
                        ])),
                        Text(c.symbol, style: TextStyle(color: isSelected ? const Color(0xFF3EFFA8) : const Color(0xFF4A6080), fontSize: 14, fontWeight: FontWeight.w600)),
                        if (isSelected) ...[const SizedBox(width: 8), const Icon(Icons.check_circle_rounded, color: Color(0xFF3EFFA8), size: 16)],
                      ]),
                    ),
                  );
                },
              )),
            ]),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;
    final hPad = size.shortestSide > 600 ? size.width * 0.2 : 24.0;

    return Scaffold(
      backgroundColor: const Color(0xFF060D1F),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _bgAnim,
            builder: (_, __) => CustomPaint(
              size: size,
              painter: _OnbBgPainter(_bgAnim.value, offset: 0.4),
            ),
          ),
          CustomPaint(size: size, painter: _OnbGridPainter()),
          SafeArea(
            child: AnimatedBuilder(
              animation: _entranceController,
              builder: (_, child) => FadeTransition(
                opacity: _fadeIn,
                child: SlideTransition(position: _slideIn, child: child),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: hPad),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: size.height * 0.10),
                      _buildGreeting(size, l10n),
                      SizedBox(height: size.height * 0.06),
                      _buildCard(l10n),
                      SizedBox(height: size.height * 0.04),
                      _buildStepIndicator(step: 2),
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

  Widget _buildGreeting(Size size, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF3EFFA8), Color(0xFF00D4FF)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3EFFA8).withOpacity(0.35),
                blurRadius: 20,
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.account_balance_wallet_rounded,
                color: Color(0xFF060D1F), size: 26),
          ),
        ),
        const SizedBox(height: 20),
        ShaderMask(
          shaderCallback: (b) => const LinearGradient(
            colors: [Color(0xFF3EFFA8), Color(0xFF00D4FF)],
          ).createShader(b),
          child: Text(
            'Salut ${widget.userName} !',
            style: TextStyle(
              fontSize: (size.width * 0.09).clamp(28.0, 50.0),
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
              height: 1.1,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.onboardingBalanceSubtitle,
          style: TextStyle(
            fontSize: (size.width * 0.038).clamp(13.0, 18.0),
            color: const Color(0xFF6B8CAE),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0xFF0B1535).withOpacity(0.85),
        border: Border.all(
            color: const Color(0xFF1A2E52).withOpacity(0.8), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D4FF).withOpacity(0.05),
            blurRadius: 40,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Sélecteur de devise ──────────────────────────
          GestureDetector(
            onTap: () => _showCurrencyPicker(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFF3EFFA8).withOpacity(0.06),
                border: Border.all(
                    color: const Color(0xFF3EFFA8).withOpacity(0.3)),
              ),
              child: Row(children: [
                Text(_selectedCurrency.flag,
                    style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.onboardingBalanceCurrency,
                          style: const TextStyle(
                              color: Color(0xFF8BA8D4),
                              fontSize: 11)),
                      Text(
                          '${_selectedCurrency.code} — ${_selectedCurrency.name}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF3EFFA8), size: 18),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.onboardingBalanceTitle,
            style: const TextStyle(
              color: Color(0xFF8BA8D4),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _balanceCtrl,
            autofocus: true,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [_DecimalInputFormatter()],
            style: const TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.w400),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return l10n.onboardingBalanceError;
              final parsed = double.tryParse(v.replaceAll(',', '.'));
              if (parsed == null) return l10n.onboardingBalanceError;
              if (parsed < 0) return l10n.onboardingBalanceError;
              return null;
            },
            decoration: InputDecoration(
              hintText: l10n.onboardingBalanceHint,
              hintStyle:
                  const TextStyle(color: Color(0xFF3A5068), fontSize: 15),
              prefixIcon: const Icon(Icons.monetization_on_outlined,
                  color: Color(0xFF3EFFA8), size: 20),
              suffixText: _selectedCurrency.symbol,
              suffixStyle: const TextStyle(
                  color: Color(0xFF8BA8D4),
                  fontSize: 15,
                  fontWeight: FontWeight.w500),
              filled: true,
              fillColor: const Color(0xFF0D1B38),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF1A2E52)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: Color(0xFF1A2E52), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: Color(0xFF3EFFA8), width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: Color(0xFFFF5C7A), width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: Color(0xFFFF5C7A), width: 1.5),
              ),
              errorStyle:
                  const TextStyle(color: Color(0xFFFF5C7A), fontSize: 12),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Vous pourrez modifier ce montant à tout moment dans votre profil.',
            style: TextStyle(color: Color(0xFF4A6080), fontSize: 12),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xFFFF5C7A).withOpacity(0.1),
                border: Border.all(
                    color: const Color(0xFFFF5C7A).withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: Color(0xFFFF5C7A), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                          color: Color(0xFFFF5C7A), fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 28),
          _buildFinishButton(),
        ],
      ),
    );
  }

  Widget _buildFinishButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: _isLoading
          ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  colors: [Color(0xFF3EFFA8), Color(0xFF00D4FF)],
                ),
              ),
              child: const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(Color(0xFF060D1F)),
                  ),
                ),
              ),
            )
          : DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  colors: [Color(0xFF3EFFA8), Color(0xFF00D4FF)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3EFFA8).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _handleFinish,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Commencer',
                      style: TextStyle(
                        color: Color(0xFF060D1F),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.check_rounded,
                        color: Color(0xFF060D1F), size: 18),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStepIndicator({required int step}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(2, (i) {
        final active = i + 1 == step;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: active
                ? const LinearGradient(
                    colors: [Color(0xFF3EFFA8), Color(0xFF00D4FF)])
                : null,
            color: active ? null : const Color(0xFF1A2E52),
          ),
        );
      }),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  SHARED PAINTERS
// ══════════════════════════════════════════════════════════════

class _OnbBgPainter extends CustomPainter {
  final double t;
  final double offset;
  _OnbBgPainter(this.t, {this.offset = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    final positions = [
      Offset(
          size.width * (0.15 + 0.08 * math.sin((t + offset) * math.pi)),
          size.height * (0.2 + 0.06 * math.cos((t + offset) * math.pi))),
      Offset(
          size.width * (0.8 + 0.06 * math.cos((t + offset) * math.pi)),
          size.height * (0.7 + 0.08 * math.sin((t + offset) * math.pi))),
    ];
    final colors = [
      const Color(0xFF3EFFA8).withOpacity(0.06),
      const Color(0xFF00D4FF).withOpacity(0.05),
    ];
    for (int i = 0; i < positions.length; i++) {
      final r = size.width * 0.45;
      canvas.drawCircle(
        positions[i],
        r,
        Paint()
          ..shader = RadialGradient(colors: [colors[i], Colors.transparent])
              .createShader(
                  Rect.fromCircle(center: positions[i], radius: r)),
      );
    }
  }

  @override
  bool shouldRepaint(_OnbBgPainter old) => old.t != t;
}

class _OnbGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A2E52).withOpacity(0.2)
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
  bool shouldRepaint(_OnbGridPainter old) => false;
}
