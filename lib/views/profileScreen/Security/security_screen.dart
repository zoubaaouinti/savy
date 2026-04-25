import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:savy/l10n/app_localizations.dart';
import '../../../services/notification_service.dart';

// ══════════════════════════════════════════════════════════════
//  SAVVY – SECURITY SCREEN
//  Changer le mot de passe + conseils de sécurité
// ══════════════════════════════════════════════════════════════

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _currentPassCtrl  = TextEditingController();
  final _newPassCtrl      = TextEditingController();
  final _confirmPassCtrl  = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew     = true;
  bool _obscureConfirm = true;
  bool _isLoading      = false;
  String? _errorMessage;
  String? _successMessage;

  double _passStrength = 0;
  String _passStrengthLabel = '';
  Color  _passStrengthColor = Colors.transparent;

  late final AnimationController _bgController;
  late final Animation<double> _bgAnim;

  // Providers de l'utilisateur
  List<String> _providers = [];
  bool get _isGoogleOnly =>
      _providers.contains('google.com') && !_providers.contains('password');

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
        vsync: this, duration: const Duration(seconds: 7))..repeat(reverse: true);
    _bgAnim = CurvedAnimation(parent: _bgController, curve: Curves.easeInOut);
    _newPassCtrl.addListener(_updateStrength);
    _loadProviders();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  void _loadProviders() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() => _providers = user.providerData.map((p) => p.providerId).toList());
    }
  }

  // ── Force du mot de passe ─────────────────────────────────
  void _updateStrength() {
    final l10n = AppLocalizations.of(context);
    final pass = _newPassCtrl.text;
    double strength = 0;
    if (pass.length >= 8)  strength += 0.25;
    if (pass.length >= 12) strength += 0.10;
    if (pass.contains(RegExp(r'[A-Z]'))) strength += 0.20;
    if (pass.contains(RegExp(r'[0-9]'))) strength += 0.20;
    if (pass.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.25;
    strength = strength.clamp(0.0, 1.0);

    String label;
    Color color;
    if (strength <= 0.25)      { label = l10n.securityPassStrengthVeryWeak; color = const Color(0xFFFF5C7A); }
    else if (strength <= 0.50) { label = l10n.securityPassStrengthWeak;     color = const Color(0xFFFF8C42); }
    else if (strength <= 0.75) { label = l10n.securityPassStrengthMedium;   color = const Color(0xFFFFB340); }
    else if (strength < 1.0)   { label = l10n.securityPassStrengthStrong;   color = const Color(0xFF00D4FF); }
    else                       { label = l10n.securityPassStrengthVeryStrong; color = const Color(0xFF3EFFA8); }

    setState(() {
      _passStrength      = strength;
      _passStrengthLabel = pass.isEmpty ? '' : label;
      _passStrengthColor = color;
    });
  }

  // ── Changer le mot de passe ───────────────────────────────
  Future<void> _handleChangePassword() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; _successMessage = null; });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Ré-authentification obligatoire
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPassCtrl.text,
      );
      await user.reauthenticateWithCredential(credential);

      // Changement du mot de passe
      await user.updatePassword(_newPassCtrl.text);

      // Alerte sécurité — écrite dans Firestore, la Cloud Function
      // envoie ensuite le push FCM (y compris app fermée / arrière-plan).
      await NotificationService.sendPasswordChangedAlert(
        userId: user.uid,
        email: user.email ?? '',
      );

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _successMessage = l10n.securityPasswordChanged;
        _currentPassCtrl.clear();
        _newPassCtrl.clear();
        _confirmPassCtrl.clear();
        _passStrength = 0;
        _passStrengthLabel = '';
      });
    } on FirebaseAuthException catch (e) {
      setState(() { _isLoading = false; _errorMessage = _mapError(e.code); });
    } catch (e) {
      setState(() { _isLoading = false; _errorMessage = AppLocalizations.of(context).errorGeneric; });
    }
  }

  String _mapError(String code) {
    final l10n = AppLocalizations.of(context);
    switch (code) {
      case 'wrong-password':
      case 'invalid-credential':    return l10n.securityErrorWrongPassword;
      case 'weak-password':         return l10n.securityErrorWeakPassword;
      case 'requires-recent-login': return l10n.securityErrorSessionExpired;
      case 'too-many-requests':     return l10n.securityErrorTooManyRequests;
      default: return l10n.errorGeneric;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;
    final hPad = size.shortestSide > 600 ? size.width * 0.2 : 20.0;

    return Scaffold(
      backgroundColor: const Color(0xFF060D1F),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _bgAnim,
            builder: (_, __) => CustomPaint(size: size, painter: _BgPainter(_bgAnim.value)),
          ),
          CustomPaint(size: size, painter: _GridPainter()),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(context, l10n),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 40),
                    child: Column(
                      children: [
                        // ── Bloc Google Only ─────────────
                        if (_isGoogleOnly)
                          _buildGoogleOnlyCard(l10n)
                        else ...[
                          _sectionTitle(l10n.securityChangePassword),
                          const SizedBox(height: 12),
                          _buildPasswordForm(l10n),
                        ],

                        const SizedBox(height: 24),

                        // ── Conseils sécurité ────────────
                        _sectionTitle(l10n.securityTips),
                        const SizedBox(height: 12),
                        _buildSecurityTips(l10n),

                        const SizedBox(height: 24),

                        // ── Infos compte ─────────────────
                        _sectionTitle(l10n.securityAccountInfo),
                        const SizedBox(height: 12),
                        _buildAccountInfo(l10n),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Top Bar ───────────────────────────────────────────────
  Widget _buildTopBar(BuildContext context, AppLocalizations l10n) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
    child: Row(children: [
      GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(width: 40, height: 40,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1A2E52)), color: const Color(0xFF0D1B38)),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF8BA8D4), size: 16)),
      ),
      const SizedBox(width: 16),
      ShaderMask(
        shaderCallback: (b) => const LinearGradient(
            colors: [Color(0xFF7B61FF), Color(0xFF00D4FF)]).createShader(b),
        child: Text(l10n.securityTitle,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
      ),
      const Spacer(),
      Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(colors: [Color(0xFF7B61FF), Color(0xFF00D4FF)]),
          boxShadow: [BoxShadow(color: const Color(0xFF7B61FF).withOpacity(0.3), blurRadius: 12)],
        ),
        child: const Icon(Icons.shield_rounded, color: Colors.white, size: 20),
      ),
    ]),
  );

  // ── Google Only card ──────────────────────────────────────
  Widget _buildGoogleOnlyCard(AppLocalizations l10n) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: const Color(0xFF0B1535),
      border: Border.all(color: const Color(0xFF00D4FF).withOpacity(0.3)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(width: 40, height: 40,
            decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF00D4FF).withOpacity(0.12)),
            child: const Icon(Icons.info_outline_rounded, color: Color(0xFF00D4FF), size: 20)),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.securityGoogleOnlyTitle, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(l10n.securityGoogleOnlyDesc,
                  style: const TextStyle(color: Color(0xFF6B8CAE), fontSize: 12, height: 1.5)),
            ],
          ),
        ),
      ],
    ),
  );

  // ── Password Form ─────────────────────────────────────────
  Widget _buildPasswordForm(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF0B1535),
        border: Border.all(color: const Color(0xFF1A2E52).withOpacity(0.6)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _field(
              label: l10n.securityCurrentPassword,
              controller: _currentPassCtrl,
              icon: Icons.lock_outline_rounded,
              obscure: _obscureCurrent,
              eyeToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
              validator: (v) => (v == null || v.isEmpty) ? l10n.errorRequired : null,
            ),
            const SizedBox(height: 16),
            _field(
              label: l10n.securityNewPassword,
              controller: _newPassCtrl,
              icon: Icons.lock_open_rounded,
              obscure: _obscureNew,
              eyeToggle: () => setState(() => _obscureNew = !_obscureNew),
              validator: (v) {
                if (v == null || v.isEmpty) return l10n.errorRequired;
                if (v.length < 6) return l10n.securityErrorPasswordTooShort;
                return null;
              },
            ),
            // Barre de force
            if (_passStrengthLabel.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _passStrength,
                      minHeight: 5,
                      backgroundColor: const Color(0xFF1A2E52),
                      valueColor: AlwaysStoppedAnimation(_passStrengthColor),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(color: _passStrengthColor, fontSize: 11, fontWeight: FontWeight.w600),
                  child: Text(_passStrengthLabel),
                ),
              ]),
            ],
            const SizedBox(height: 16),
            _field(
              label: l10n.securityConfirmPassword,
              controller: _confirmPassCtrl,
              icon: Icons.lock_rounded,
              obscure: _obscureConfirm,
              eyeToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
              validator: (v) {
                if (v == null || v.isEmpty) return l10n.errorRequired;
                if (v != _newPassCtrl.text) return l10n.securityErrorPasswordMismatch;
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Messages
            if (_errorMessage != null) _alertWidget(_errorMessage!, isError: true),
            if (_successMessage != null) _alertWidget(_successMessage!, isError: false),
            if (_errorMessage != null || _successMessage != null) const SizedBox(height: 8),

            // Bouton
            _buildSaveButton(l10n),
          ],
        ),
      ),
    );
  }

  // ── Security Tips ─────────────────────────────────────────
  Widget _buildSecurityTips(AppLocalizations l10n) {
    final tips = [
      _SecurityTip(
        icon: Icons.lock_rounded,
        color: const Color(0xFF3EFFA8),
        title: l10n.securityTipStrongTitle,
        desc: l10n.securityTipStrongDesc,
      ),
      _SecurityTip(
        icon: Icons.visibility_off_rounded,
        color: const Color(0xFF00D4FF),
        title: l10n.securityTipNeverShareTitle,
        desc: l10n.securityTipNeverShareDesc,
      ),
      _SecurityTip(
        icon: Icons.refresh_rounded,
        color: const Color(0xFFFFB340),
        title: l10n.securityTipChangeRegularlyTitle,
        desc: l10n.securityTipChangeRegularlyDesc,
      ),
      _SecurityTip(
        icon: Icons.devices_rounded,
        color: const Color(0xFF7B61FF),
        title: l10n.securityTipTrustedDevicesTitle,
        desc: l10n.securityTipTrustedDevicesDesc,
      ),
      _SecurityTip(
        icon: Icons.email_rounded,
        color: const Color(0xFF3EFFA8),
        title: l10n.securityTipVerifiedEmailTitle,
        desc: l10n.securityTipVerifiedEmailDesc,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF0B1535),
        border: Border.all(color: const Color(0xFF1A2E52).withOpacity(0.6)),
      ),
      child: Column(
        children: List.generate(tips.length, (i) {
          final tip = tips[i];
          final isLast = i == tips.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: tip.color.withOpacity(0.12)),
                      child: Icon(tip.icon, color: tip.color, size: 18),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tip.title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(tip.desc, style: const TextStyle(color: Color(0xFF6B8CAE), fontSize: 12, height: 1.4)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast) Divider(height: 1, indent: 66, color: const Color(0xFF1A2E52).withOpacity(0.4)),
            ],
          );
        }),
      ),
    );
  }

  // ── Account Info ──────────────────────────────────────────
  Widget _buildAccountInfo(AppLocalizations l10n) {
    final user = FirebaseAuth.instance.currentUser;
    final isVerified = user?.emailVerified ?? false;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF0B1535),
        border: Border.all(color: const Color(0xFF1A2E52).withOpacity(0.6)),
      ),
      child: Column(
        children: [
          _infoRow(l10n.securityEmail, user?.email ?? '-',
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: (isVerified ? const Color(0xFF3EFFA8) : const Color(0xFFFF5C7A)).withOpacity(0.12),
                ),
                child: Text(isVerified ? l10n.securityEmailVerified : l10n.securityEmailNotVerified,
                    style: TextStyle(color: isVerified ? const Color(0xFF3EFFA8) : const Color(0xFFFF5C7A), fontSize: 11, fontWeight: FontWeight.w600)),
              )),
          Divider(height: 1, indent: 0, color: const Color(0xFF1A2E52).withOpacity(0.4)),
          _infoRow(l10n.securityLoginMethod,
              _providers.contains('google.com') ? l10n.securityLoginGoogle : l10n.securityLoginEmailPassword,
              icon: _providers.contains('google.com') ? Icons.g_mobiledata_rounded : Icons.email_rounded),
          Divider(height: 1, indent: 0, color: const Color(0xFF1A2E52).withOpacity(0.4)),
          _infoRow(l10n.securityUid, '${user?.uid.substring(0, 8)}...', isSmall: true),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {Widget? trailing, IconData? icon, bool isSmall = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: const Color(0xFF4A6080), size: 16),
            const SizedBox(width: 8),
          ],
          Text(label, style: const TextStyle(color: Color(0xFF6B8CAE), fontSize: 13)),
          const Spacer(),
          trailing ?? Text(value,
              style: TextStyle(
                  color: isSmall ? const Color(0xFF4A6080) : Colors.white,
                  fontSize: isSmall ? 11 : 13,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────
  Widget _sectionTitle(String title) => Align(
    alignment: Alignment.centerLeft,
    child: Text(title.toUpperCase(),
        style: const TextStyle(color: Color(0xFF3A5070), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
  );

  Widget _field({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool obscure,
    required VoidCallback eyeToggle,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF8BA8D4), fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller, obscureText: obscure, validator: validator,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: label, hintStyle: const TextStyle(color: Color(0xFF3A5068), fontSize: 14),
            prefixIcon: Icon(icon, color: const Color(0xFF7B61FF), size: 18),
            suffixIcon: IconButton(
              icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: const Color(0xFF4A6080), size: 18),
              onPressed: eyeToggle,
            ),
            filled: true, fillColor: const Color(0xFF0D1B38),
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1A2E52))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1A2E52))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF7B61FF), width: 1.5)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFF5C7A))),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFF5C7A), width: 1.5)),
            errorStyle: const TextStyle(color: Color(0xFFFF5C7A), fontSize: 11),
          ),
        ),
      ],
    );
  }

  Widget _alertWidget(String msg, {required bool isError}) {
    final color = isError ? const Color(0xFFFF5C7A) : const Color(0xFF3EFFA8);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: color.withOpacity(0.08), border: Border.all(color: color.withOpacity(0.4))),
      child: Row(children: [
        Icon(isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded, color: color, size: 16),
        const SizedBox(width: 10),
        Expanded(child: Text(msg, style: TextStyle(color: color, fontSize: 12, height: 1.4))),
      ]),
    );
  }

  Widget _buildSaveButton(AppLocalizations l10n) => SizedBox(
    width: double.infinity, height: 52,
    child: _isLoading
        ? Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(colors: [Color(0xFF7B61FF), Color(0xFF00D4FF)])),
        child: const Center(child: SizedBox(width: 22, height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation(Colors.white)))))
        : DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(colors: [Color(0xFF7B61FF), Color(0xFF00D4FF)]),
        boxShadow: [BoxShadow(color: const Color(0xFF7B61FF).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 6))],
      ),
      child: ElevatedButton(
        onPressed: _handleChangePassword,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
        child: Text(l10n.securityChangePassword,
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
      ),
    ),
  );
}

// ── Data class ────────────────────────────────────────────────
class _SecurityTip {
  final IconData icon;
  final Color color;
  final String title;
  final String desc;
  const _SecurityTip({required this.icon, required this.color, required this.title, required this.desc});
}

// ══════════════════════════════════════════════════════════════
//  PAINTERS
// ══════════════════════════════════════════════════════════════
class _BgPainter extends CustomPainter {
  final double t;
  _BgPainter(this.t);
  @override
  void paint(Canvas canvas, Size size) {
    void orb(Offset c, double r, Color color) => canvas.drawCircle(c, r, Paint()..shader = RadialGradient(colors: [color, Colors.transparent]).createShader(Rect.fromCircle(center: c, radius: r)));
    orb(Offset(size.width * 0.15, size.height * (0.1 + 0.05 * math.sin(t * math.pi))), size.width * 0.4, const Color(0xFF7B61FF).withOpacity(0.05));
    orb(Offset(size.width * 0.85, size.height * (0.75 + 0.05 * math.cos(t * math.pi))), size.width * 0.35, const Color(0xFF00D4FF).withOpacity(0.04));
  }
  @override
  bool shouldRepaint(_BgPainter old) => old.t != t;
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0xFF1A2E52).withOpacity(0.15)..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += 44) canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    for (double y = 0; y < size.height; y += 44) canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
  }
  @override
  bool shouldRepaint(_GridPainter _) => false;
}
