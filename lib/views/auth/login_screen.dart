import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../legalScreen/legal_screens.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _isLoading = false;

  late final AnimationController _bgController;
  late final AnimationController _entranceController;
  late final Animation<double> _bgAnim;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideIn;
  late final Animation<double> _cardScale;

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
      duration: const Duration(milliseconds: 1000),
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
    _cardScale = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutBack),
    );
    Future.delayed(
      const Duration(milliseconds: 100),
      _entranceController.forward,
    );
  }

  @override
  void dispose() {
    _bgController.dispose();
    _entranceController.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // ════════════════════════════════════════════════════════════
  //  LOGIN → vérifie le formulaire puis redirige vers MainLayout
  // ════════════════════════════════════════════════════════════
  Future<void> _handleLogin() async {
    // Étape 1 : valider email + mot de passe
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Étape 2 : TODO → remplacer par Firebase Auth
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);

    // Étape 3 : rediriger vers MainLayout et vider la pile
    // (l'utilisateur ne peut plus revenir en arrière vers login)
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/home',         // route de MainLayout dans AppRoutes
            (route) => false,
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    // TODO : Google Sign-In via Firebase
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);

    // Même redirection que le login email
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/home',
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide > 600;
    final hPad = isTablet ? size.width * 0.2 : 24.0;

    return Scaffold(
      backgroundColor: const Color(0xFF060D1F),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _bgAnim,
            builder: (_, __) => CustomPaint(
              size: size,
              painter: _BgPainter(_bgAnim.value),
            ),
          ),
          CustomPaint(size: size, painter: _GridPainter()),
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
                      SizedBox(height: size.height * 0.07),
                      _buildHeader(size),
                      SizedBox(height: size.height * 0.055),
                      ScaleTransition(
                        scale: _cardScale,
                        child: _buildCard(size),
                      ),
                      SizedBox(height: size.height * 0.03),
                      _buildSignUpLink(size),
                      SizedBox(height: size.height * 0.04),
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

  Widget _buildHeader(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF3EFFA8), Color(0xFF00D4FF)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3EFFA8).withOpacity(0.35),
                blurRadius: 18,
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.trending_up_rounded,
                color: Color(0xFF060D1F), size: 24),
          ),
        ),
        const SizedBox(height: 22),
        ShaderMask(
          shaderCallback: (b) => const LinearGradient(
            colors: [Color(0xFF3EFFA8), Color(0xFF00D4FF)],
          ).createShader(b),
          child: Text(
            'Bon retour !',
            style: TextStyle(
              fontSize: (size.width * 0.08).clamp(28.0, 48.0),
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
              height: 1.1,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Connectez-vous pour gérer vos finances',
          style: TextStyle(
            fontSize: (size.width * 0.038).clamp(13.0, 18.0),
            color: const Color(0xFF6B8CAE),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildCard(Size size) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0xFF0B1535).withOpacity(0.85),
        border: Border.all(
          color: const Color(0xFF1A2E52).withOpacity(0.8),
          width: 1,
        ),
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
          _buildLabel('Adresse email'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _emailCtrl,
            hint: 'votre@email.com',
            icon: Icons.alternate_email_rounded,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Email requis';
              if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                return 'Email invalide';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildLabel('Mot de passe'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _passCtrl,
            hint: '••••••••',
            icon: Icons.lock_outline_rounded,
            obscure: _obscurePass,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePass
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xFF4A6080),
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscurePass = !_obscurePass),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Mot de passe requis';
              if (v.length < 6) return 'Minimum 6 caractères';
              return null;
            },
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 4, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Mot de passe oublié ?',
                style: TextStyle(
                  color: Color(0xFF3EFFA8),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildPrimaryButton(label: 'Se connecter', onTap: _handleLogin),
          const SizedBox(height: 24),
          _buildDivider(),
          const SizedBox(height: 24),
          _buildGoogleButton(),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
    text,
    style: const TextStyle(
      color: Color(0xFF8BA8D4),
      fontSize: 13,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.3,
    ),
  );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
          color: Colors.white, fontSize: 15, fontWeight: FontWeight.w400),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
        const TextStyle(color: Color(0xFF3A5068), fontSize: 15),
        prefixIcon: Icon(icon, color: const Color(0xFF3EFFA8), size: 20),
        suffixIcon: suffixIcon,
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
          borderSide: const BorderSide(color: Color(0xFF1A2E52), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
          const BorderSide(color: Color(0xFF3EFFA8), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFFF5C7A), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
          const BorderSide(color: Color(0xFFFF5C7A), width: 1.5),
        ),
        errorStyle:
        const TextStyle(color: Color(0xFFFF5C7A), fontSize: 12),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback onTap,
  }) {
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
              valueColor:
              AlwaysStoppedAnimation(Color(0xFF060D1F)),
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
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF060D1F),
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() => Row(
    children: [
      Expanded(
        child: Container(
          height: 1,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.transparent, Color(0xFF1A2E52)]),
          ),
        ),
      ),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 14),
        child: Text('ou continuer avec',
            style: TextStyle(color: Color(0xFF4A6080), fontSize: 12)),
      ),
      Expanded(
        child: Container(
          height: 1,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Color(0xFF1A2E52), Colors.transparent]),
          ),
        ),
      ),
    ],
  );

  Widget _buildGoogleButton() => SizedBox(
    width: double.infinity,
    height: 52,
    child: OutlinedButton(
      onPressed: _isLoading ? null : _handleGoogleSignIn,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFF1A2E52), width: 1),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        backgroundColor: const Color(0xFF0D1B38),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _GoogleIcon(size: 20),
          const SizedBox(width: 12),
          const Text('Continuer avec Google',
              style: TextStyle(
                  color: Color(0xFF8BA8D4),
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    ),
  );

  Widget _buildSignUpLink(Size size) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text("Pas encore de compte ? ",
          style: TextStyle(color: Color(0xFF6B8CAE), fontSize: 14)),
      GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (_, a, __) => const SignUpScreen(),
              transitionsBuilder: (_, a, __, child) =>
                  FadeTransition(opacity: a, child: child),
              transitionDuration: const Duration(milliseconds: 350),
            ),
          );
        },
        child: const Text("S'inscrire",
            style: TextStyle(
                color: Color(0xFF3EFFA8),
                fontSize: 14,
                fontWeight: FontWeight.w700)),
      ),
    ],
  );
}

// ══════════════════════════════════════════════════════════════
//  SIGN UP SCREEN  (inchangé)
// ══════════════════════════════════════════════════════════════
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _acceptTerms = false;

  late final AnimationController _bgController;
  late final AnimationController _entranceController;
  late final Animation<double> _bgAnim;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideIn;

  double _passStrength = 0;
  String _passStrengthLabel = '';
  Color _passStrengthColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
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
    _slideIn = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _entranceController, curve: Curves.easeOutCubic));
    Future.delayed(
        const Duration(milliseconds: 100), _entranceController.forward);
    _passCtrl.addListener(_updatePasswordStrength);
  }

  void _updatePasswordStrength() {
    final pass = _passCtrl.text;
    double strength = 0;
    if (pass.length >= 8) strength += 0.25;
    if (pass.contains(RegExp(r'[A-Z]'))) strength += 0.25;
    if (pass.contains(RegExp(r'[0-9]'))) strength += 0.25;
    if (pass.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.25;
    String label;
    Color color;
    if (strength <= 0.25) {
      label = 'Faible';
      color = const Color(0xFFFF5C7A);
    } else if (strength <= 0.5) {
      label = 'Moyen';
      color = const Color(0xFFFFB340);
    } else if (strength <= 0.75) {
      label = 'Bon';
      color = const Color(0xFF00D4FF);
    } else {
      label = 'Excellent';
      color = const Color(0xFF3EFFA8);
    }
    setState(() {
      _passStrength = strength;
      _passStrengthLabel = pass.isEmpty ? '' : label;
      _passStrengthColor = color;
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _entranceController.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Veuillez accepter les conditions d'utilisation",
              style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF0D1B38),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFFF5C7A)),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    // TODO: Firebase Auth createUser
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);

    // Après inscription réussie → rediriger vers MainLayout
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/home',
            (route) => false,
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/home',
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide > 600;
    final hPad = isTablet ? size.width * 0.2 : 24.0;

    return Scaffold(
      backgroundColor: const Color(0xFF060D1F),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _bgAnim,
            builder: (_, __) => CustomPaint(
              size: size,
              painter: _BgPainter(_bgAnim.value, offset: 0.3),
            ),
          ),
          CustomPaint(size: size, painter: _GridPainter()),
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
                      SizedBox(height: size.height * 0.06),
                      _buildHeader(size),
                      SizedBox(height: size.height * 0.045),
                      _buildCard(size),
                      SizedBox(height: size.height * 0.03),
                      _buildLoginLink(),
                      SizedBox(height: size.height * 0.04),
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

  Widget _buildHeader(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1A2E52)),
              color: const Color(0xFF0D1B38),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF8BA8D4), size: 16),
          ),
        ),
        const SizedBox(height: 20),
        ShaderMask(
          shaderCallback: (b) => const LinearGradient(
            colors: [Color(0xFF3EFFA8), Color(0xFF00D4FF)],
          ).createShader(b),
          child: Text(
            'Créer un compte',
            style: TextStyle(
              fontSize: (size.width * 0.078).clamp(26.0, 44.0),
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
              height: 1.1,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Rejoignez Savy et commencez à épargner',
          style: TextStyle(
            fontSize: (size.width * 0.038).clamp(13.0, 18.0),
            color: const Color(0xFF6B8CAE),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(Size size) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0xFF0B1535).withOpacity(0.85),
        border: Border.all(color: const Color(0xFF1A2E52).withOpacity(0.8)),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF00D4FF).withOpacity(0.05),
              blurRadius: 40,
              offset: const Offset(0, 8)),
          BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 30,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Nom complet'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _nameCtrl,
            hint: 'Votre nom',
            icon: Icons.person_outline_rounded,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Nom requis';
              return null;
            },
          ),
          const SizedBox(height: 18),
          _buildLabel('Adresse email'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _emailCtrl,
            hint: 'votre@email.com',
            icon: Icons.alternate_email_rounded,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Email requis';
              if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                return 'Email invalide';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),
          _buildLabel('Mot de passe'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _passCtrl,
            hint: '••••••••',
            icon: Icons.lock_outline_rounded,
            obscure: _obscurePass,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePass
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xFF4A6080),
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscurePass = !_obscurePass),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Mot de passe requis';
              if (v.length < 6) return 'Minimum 6 caractères';
              return null;
            },
          ),
          if (_passStrengthLabel.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildPasswordStrength(),
          ],
          const SizedBox(height: 18),
          _buildLabel('Confirmer le mot de passe'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _confirmCtrl,
            hint: '••••••••',
            icon: Icons.lock_outline_rounded,
            obscure: _obscureConfirm,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirm
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xFF4A6080),
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Confirmation requise';
              if (v != _passCtrl.text) {
                return 'Les mots de passe ne correspondent pas';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildTermsCheckbox(),
          const SizedBox(height: 24),
          _buildPrimaryButton(label: "Créer mon compte", onTap: _handleSignUp),
          const SizedBox(height: 24),
          _buildDivider(),
          const SizedBox(height: 24),
          _buildGoogleButton(),
        ],
      ),
    );
  }

  Widget _buildPasswordStrength() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 4,
                  child: LinearProgressIndicator(
                    value: _passStrength,
                    backgroundColor: const Color(0xFF1A2E52),
                    valueColor: AlwaysStoppedAnimation(_passStrengthColor),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: _passStrengthColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              child: Text(_passStrengthLabel),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text('Utilisez majuscules, chiffres et symboles',
            style: TextStyle(color: Color(0xFF4A6080), fontSize: 11)),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return GestureDetector(
      onTap: () => setState(() => _acceptTerms = !_acceptTerms),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _acceptTerms
                    ? const Color(0xFF3EFFA8)
                    : const Color(0xFF1A2E52),
                width: 1.5,
              ),
              gradient: _acceptTerms
                  ? const LinearGradient(
                  colors: [Color(0xFF3EFFA8), Color(0xFF00D4FF)])
                  : null,
              color: _acceptTerms ? null : const Color(0xFF0D1B38),
            ),
            child: _acceptTerms
                ? const Icon(Icons.check_rounded,
                color: Color(0xFF060D1F), size: 13)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                    color: Color(0xFF6B8CAE), fontSize: 13, height: 1.5),
                children: [
                  const TextSpan(text: "J'accepte les "),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: GestureDetector(
                      onTap: () async {
                        final accepted =
                        await Navigator.of(context).push<bool>(
                          PageRouteBuilder(
                            pageBuilder: (_, a, __) => TermsScreen(
                              onAccepted: () {
                                setState(() => _acceptTerms = true);
                                Navigator.of(context).pop(true);
                              },
                            ),
                            transitionsBuilder: (_, a, __, child) =>
                                SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(1, 0),
                                    end: Offset.zero,
                                  ).animate(CurvedAnimation(
                                      parent: a, curve: Curves.easeOutCubic)),
                                  child: child,
                                ),
                            transitionDuration:
                            const Duration(milliseconds: 350),
                          ),
                        );
                        if (accepted == true) {
                          setState(() => _acceptTerms = true);
                        }
                      },
                      child: const Text(
                        "Conditions d'utilisation",
                        style: TextStyle(
                          color: Color(0xFF3EFFA8),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFF3EFFA8),
                        ),
                      ),
                    ),
                  ),
                  const TextSpan(text: " et la "),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: GestureDetector(
                      onTap: () async {
                        final accepted =
                        await Navigator.of(context).push<bool>(
                          PageRouteBuilder(
                            pageBuilder: (_, a, __) => PrivacyScreen(
                              onAccepted: () {
                                setState(() => _acceptTerms = true);
                                Navigator.of(context).pop(true);
                              },
                            ),
                            transitionsBuilder: (_, a, __, child) =>
                                SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(1, 0),
                                    end: Offset.zero,
                                  ).animate(CurvedAnimation(
                                      parent: a, curve: Curves.easeOutCubic)),
                                  child: child,
                                ),
                            transitionDuration:
                            const Duration(milliseconds: 350),
                          ),
                        );
                        if (accepted == true) {
                          setState(() => _acceptTerms = true);
                        }
                      },
                      child: const Text(
                        "Politique de confidentialité",
                        style: TextStyle(
                          color: Color(0xFF00D4FF),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFF00D4FF),
                        ),
                      ),
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

  Widget _buildLabel(String text) => Text(text,
      style: const TextStyle(
          color: Color(0xFF8BA8D4),
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3));

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
        const TextStyle(color: Color(0xFF3A5068), fontSize: 15),
        prefixIcon: Icon(icon, color: const Color(0xFF3EFFA8), size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFF0D1B38),
        contentPadding:
        const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF1A2E52))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
            const BorderSide(color: Color(0xFF1A2E52), width: 1)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
            const BorderSide(color: Color(0xFF3EFFA8), width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
            const BorderSide(color: Color(0xFFFF5C7A), width: 1)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
            const BorderSide(color: Color(0xFFFF5C7A), width: 1.5)),
        errorStyle:
        const TextStyle(color: Color(0xFFFF5C7A), fontSize: 12),
      ),
    );
  }

  Widget _buildPrimaryButton(
      {required String label, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: _isLoading
          ? Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
              colors: [Color(0xFF3EFFA8), Color(0xFF00D4FF)]),
        ),
        child: const Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor:
              AlwaysStoppedAnimation(Color(0xFF060D1F)),
            ),
          ),
        ),
      )
          : DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
              colors: [Color(0xFF3EFFA8), Color(0xFF00D4FF)]),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3EFFA8).withOpacity(0.28),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          child: Text(label,
              style: const TextStyle(
                  color: Color(0xFF060D1F),
                  fontSize: 15,
                  fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }

  Widget _buildDivider() => Row(children: [
    Expanded(
      child: Container(
        height: 1,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.transparent, Color(0xFF1A2E52)])),
      ),
    ),
    const Padding(
      padding: EdgeInsets.symmetric(horizontal: 14),
      child: Text('ou continuer avec',
          style: TextStyle(color: Color(0xFF4A6080), fontSize: 12)),
    ),
    Expanded(
      child: Container(
        height: 1,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Color(0xFF1A2E52), Colors.transparent])),
      ),
    ),
  ]);

  Widget _buildGoogleButton() => SizedBox(
    width: double.infinity,
    height: 52,
    child: OutlinedButton(
      onPressed: _isLoading ? null : _handleGoogleSignIn,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFF1A2E52), width: 1),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        backgroundColor: const Color(0xFF0D1B38),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _GoogleIcon(size: 20),
          const SizedBox(width: 12),
          const Text('Continuer avec Google',
              style: TextStyle(
                  color: Color(0xFF8BA8D4),
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    ),
  );

  Widget _buildLoginLink() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text("Déjà un compte ? ",
          style: TextStyle(color: Color(0xFF6B8CAE), fontSize: 14)),
      GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: const Text("Se connecter",
            style: TextStyle(
                color: Color(0xFF3EFFA8),
                fontSize: 14,
                fontWeight: FontWeight.w700)),
      ),
    ],
  );
}

// ══════════════════════════════════════════════════════════════
//  SHARED PAINTERS
// ══════════════════════════════════════════════════════════════
class _BgPainter extends CustomPainter {
  final double t;
  final double offset;
  _BgPainter(this.t, {this.offset = 0.0});
  @override
  void paint(Canvas canvas, Size size) {
    final positions = [
      Offset(size.width * (0.15 + 0.08 * math.sin((t + offset) * math.pi)),
          size.height * (0.2 + 0.06 * math.cos((t + offset) * math.pi))),
      Offset(size.width * (0.8 + 0.06 * math.cos((t + offset) * math.pi)),
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
              .createShader(Rect.fromCircle(center: positions[i], radius: r)),
      );
    }
  }
  @override
  bool shouldRepaint(_BgPainter old) => old.t != t;
}

class _GridPainter extends CustomPainter {
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
  bool shouldRepaint(_GridPainter old) => false;
}

class _GoogleIcon extends StatelessWidget {
  final double size;
  const _GoogleIcon({required this.size});
  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: CustomPaint(painter: _GoogleIconPainter()),
  );
}

class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w / 2;
    canvas.drawCircle(center, radius, Paint()..color = Colors.white);
    final colors = [
      const Color(0xFF4285F4),
      const Color(0xFF34A853),
      const Color(0xFFFBBC05),
      const Color(0xFFEA4335),
    ];
    final strokeW = w * 0.16;
    final innerR = radius * 0.58;
    final angles = [
      [-math.pi / 6, math.pi * 2 / 3],
      [math.pi / 2, math.pi * 2 / 3],
      [math.pi * 7 / 6, math.pi * 2 / 3],
      [-math.pi * 5 / 6, math.pi * 2 / 3],
    ];
    for (int i = 0; i < 4; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: innerR),
        angles[i][0],
        angles[i][1],
        false,
        Paint()
          ..color = colors[i]
          ..strokeWidth = strokeW
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.butt,
      );
    }
    canvas.drawRect(Rect.fromLTWH(w * 0.5, h * 0.42, w * 0.34, h * 0.16),
        Paint()..color = const Color(0xFF4285F4));
  }
  @override
  bool shouldRepaint(_GoogleIconPainter old) => false;
}