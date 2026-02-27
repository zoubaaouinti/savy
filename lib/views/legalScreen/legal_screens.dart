import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ══════════════════════════════════════════════════════════════
//  SAVVY – LEGAL PAGES
//  TermsScreen & PrivacyScreen  ·  Animated · Professional
// ══════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────────────────────
//  SHARED ENUM
// ─────────────────────────────────────────────────────────────
enum LegalType { terms, privacy }

// ══════════════════════════════════════════════════════════════
//  TERMS OF SERVICE SCREEN
// ══════════════════════════════════════════════════════════════
class TermsScreen extends StatelessWidget {
  /// [onAccepted] callback appelé quand l'utilisateur appuie sur "Accepter"
  /// Si null, le bouton navigue simplement en arrière avec result = true
  final VoidCallback? onAccepted;

  const TermsScreen({super.key, this.onAccepted});

  @override
  Widget build(BuildContext context) => _LegalScreen(
    type: LegalType.terms,
    onAccepted: onAccepted,
  );
}

// ══════════════════════════════════════════════════════════════
//  PRIVACY POLICY SCREEN
// ══════════════════════════════════════════════════════════════
class PrivacyScreen extends StatelessWidget {
  final VoidCallback? onAccepted;

  const PrivacyScreen({super.key, this.onAccepted});

  @override
  Widget build(BuildContext context) => _LegalScreen(
    type: LegalType.privacy,
    onAccepted: onAccepted,
  );
}

// ══════════════════════════════════════════════════════════════
//  CORE LEGAL SCREEN  (shared implementation)
// ══════════════════════════════════════════════════════════════
class _LegalScreen extends StatefulWidget {
  final LegalType type;
  final VoidCallback? onAccepted;

  const _LegalScreen({required this.type, this.onAccepted});

  @override
  State<_LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<_LegalScreen>
    with TickerProviderStateMixin {
  late final AnimationController _bgController;
  late final AnimationController _entranceController;
  late final Animation<double> _bgAnim;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideIn;

  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToBottom = false;
  double _scrollProgress = 0.0;

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat(reverse: true);

    _bgAnim = CurvedAnimation(parent: _bgController, curve: Curves.easeInOut);

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );

    _slideIn = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
    );

    Future.delayed(
      const Duration(milliseconds: 80),
      _entranceController.forward,
    );

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    final current = _scrollController.offset;
    final progress = max == 0 ? 1.0 : (current / max).clamp(0.0, 1.0);

    setState(() {
      _scrollProgress = progress;
      if (progress >= 0.92 && !_hasScrolledToBottom) {
        _hasScrolledToBottom = true;
      }
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _entranceController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleAccept() {
    HapticFeedback.mediumImpact();
    if (widget.onAccepted != null) {
      widget.onAccepted!();
    } else {
      Navigator.of(context).pop(true);
    }
  }

  // ── Content data ─────────────────────────────────────────
  String get _title => widget.type == LegalType.terms
      ? "Conditions d'utilisation"
      : "Politique de confidentialité";

  String get _lastUpdated => "Dernière mise à jour : 1er janvier 2025";

  List<_LegalSection> get _sections => widget.type == LegalType.terms
      ? _termsSections
      : _privacySections;

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide > 600;
    final hPad = isTablet ? size.width * 0.15 : 22.0;

    return Scaffold(
      backgroundColor: const Color(0xFF060D1F),
      body: Stack(
        children: [
          // Background animated orbs
          AnimatedBuilder(
            animation: _bgAnim,
            builder: (_, __) => CustomPaint(
              size: size,
              painter: _LegalBgPainter(
                _bgAnim.value,
                isPrivacy: widget.type == LegalType.privacy,
              ),
            ),
          ),

          // Grid
          CustomPaint(size: size, painter: _LegalGridPainter()),

          // Main content
          SafeArea(
            child: AnimatedBuilder(
              animation: _entranceController,
              builder: (_, child) => FadeTransition(
                opacity: _fadeIn,
                child: SlideTransition(position: _slideIn, child: child),
              ),
              child: Column(
                children: [
                  // ── Top bar ──────────────────────────────
                  _buildTopBar(context, hPad),

                  // ── Scroll progress bar ──────────────────
                  _buildProgressBar(),

                  // ── Scrollable content ───────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeroHeader(size),
                          const SizedBox(height: 28),
                          ..._sections.map((s) => _buildSection(s)),
                          const SizedBox(height: 16),
                          _buildFooterNote(),
                          const SizedBox(height: 100), // space for button
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Sticky bottom button ─────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomButton(hPad),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, double hPad) {
    return Padding(
      padding: EdgeInsets.fromLTRB(hPad - 4, 12, hPad, 4),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(false),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1A2E52)),
                color: const Color(0xFF0D1B38),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF8BA8D4),
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              _title,
              style: const TextStyle(
                color: Color(0xFF8BA8D4),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Icon badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: widget.type == LegalType.terms
                    ? [const Color(0xFF3EFFA8), const Color(0xFF00D4FF)]
                    : [const Color(0xFF00D4FF), const Color(0xFF7B61FF)],
              ),
              boxShadow: [
                BoxShadow(
                  color: (widget.type == LegalType.terms
                      ? const Color(0xFF3EFFA8)
                      : const Color(0xFF00D4FF))
                      .withOpacity(0.3),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Icon(
              widget.type == LegalType.terms
                  ? Icons.gavel_rounded
                  : Icons.shield_outlined,
              color: const Color(0xFF060D1F),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 0),
      child: Stack(
        children: [
          Container(color: const Color(0xFF1A2E52).withOpacity(0.4)),
          FractionallySizedBox(
            widthFactor: _scrollProgress,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.type == LegalType.terms
                      ? [const Color(0xFF3EFFA8), const Color(0xFF00D4FF)]
                      : [const Color(0xFF00D4FF), const Color(0xFF7B61FF)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        ShaderMask(
          shaderCallback: (b) => LinearGradient(
            colors: widget.type == LegalType.terms
                ? [const Color(0xFF3EFFA8), const Color(0xFF00D4FF)]
                : [const Color(0xFF00D4FF), const Color(0xFF7B61FF)],
          ).createShader(b),
          child: Text(
            _title,
            style: TextStyle(
              fontSize: (size.width * 0.072).clamp(24.0, 40.0),
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
              height: 1.15,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _lastUpdated,
          style: const TextStyle(
            color: Color(0xFF4A6080),
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 20),
        // Divider line
        Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.type == LegalType.terms
                    ? const Color(0xFF3EFFA8)
                    : const Color(0xFF00D4FF),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(_LegalSection section) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    colors: widget.type == LegalType.terms
                        ? [
                      const Color(0xFF3EFFA8).withOpacity(0.15),
                      const Color(0xFF00D4FF).withOpacity(0.1),
                    ]
                        : [
                      const Color(0xFF00D4FF).withOpacity(0.15),
                      const Color(0xFF7B61FF).withOpacity(0.1),
                    ],
                  ),
                  border: Border.all(
                    color: widget.type == LegalType.terms
                        ? const Color(0xFF3EFFA8).withOpacity(0.2)
                        : const Color(0xFF00D4FF).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  section.icon,
                  size: 16,
                  color: widget.type == LegalType.terms
                      ? const Color(0xFF3EFFA8)
                      : const Color(0xFF00D4FF),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  section.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Content
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: const Color(0xFF0B1535).withOpacity(0.7),
              border: Border.all(
                color: const Color(0xFF1A2E52).withOpacity(0.6),
                width: 1,
              ),
            ),
            child: Text(
              section.content,
              style: const TextStyle(
                color: Color(0xFF8BA8D4),
                fontSize: 13.5,
                height: 1.7,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: widget.type == LegalType.terms
              ? [
            const Color(0xFF3EFFA8).withOpacity(0.05),
            const Color(0xFF00D4FF).withOpacity(0.05),
          ]
              : [
            const Color(0xFF00D4FF).withOpacity(0.05),
            const Color(0xFF7B61FF).withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: widget.type == LegalType.terms
              ? const Color(0xFF3EFFA8).withOpacity(0.15)
              : const Color(0xFF00D4FF).withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: widget.type == LegalType.terms
                ? const Color(0xFF3EFFA8)
                : const Color(0xFF00D4FF),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.type == LegalType.terms
                  ? "En utilisant Savvy, vous acceptez ces conditions. Pour toute question, contactez-nous à support@savvy.app"
                  : "Pour exercer vos droits ou pour toute question concernant vos données, contactez notre DPO à privacy@savvy.app",
              style: const TextStyle(
                color: Color(0xFF6B8CAE),
                fontSize: 12,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(double hPad) {
    return Container(
      padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF060D1F).withOpacity(0.0),
            const Color(0xFF060D1F).withOpacity(0.95),
            const Color(0xFF060D1F),
          ],
          stops: const [0.0, 0.3, 1.0],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Hint to scroll if not at bottom
          if (!_hasScrolledToBottom)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 14,
                    color: const Color(0xFF4A6080),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Faites défiler pour lire',
                    style: TextStyle(color: Color(0xFF4A6080), fontSize: 11),
                  ),
                ],
              ),
            ),

          // Accept button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: AnimatedOpacity(
              opacity: _hasScrolledToBottom ? 1.0 : 0.55,
              duration: const Duration(milliseconds: 400),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    colors: widget.type == LegalType.terms
                        ? [const Color(0xFF3EFFA8), const Color(0xFF00D4FF)]
                        : [const Color(0xFF00D4FF), const Color(0xFF7B61FF)],
                  ),
                  boxShadow: _hasScrolledToBottom
                      ? [
                    BoxShadow(
                      color: (widget.type == LegalType.terms
                          ? const Color(0xFF3EFFA8)
                          : const Color(0xFF00D4FF))
                          .withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ]
                      : [],
                ),
                child: ElevatedButton(
                  onPressed: _handleAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 18,
                        color: const Color(0xFF060D1F),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.type == LegalType.terms
                            ? "J'accepte les conditions"
                            : "J'accepte la politique",
                        style: const TextStyle(
                          color: Color(0xFF060D1F),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
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
}

// ══════════════════════════════════════════════════════════════
//  LEGAL CONTENT DATA
// ══════════════════════════════════════════════════════════════
class _LegalSection {
  final String title;
  final String content;
  final IconData icon;
  const _LegalSection({
    required this.title,
    required this.content,
    required this.icon,
  });
}

const List<_LegalSection> _termsSections = [
  _LegalSection(
    title: "1. Acceptation des conditions",
    icon: Icons.handshake_outlined,
    content:
    "En accédant à l'application Savvy ou en l'utilisant, vous acceptez d'être lié par ces Conditions d'utilisation. Si vous n'acceptez pas l'intégralité de ces conditions, vous n'êtes pas autorisé à utiliser nos services. Ces conditions constituent un accord légalement contraignant entre vous et Savvy.",
  ),
  _LegalSection(
    title: "2. Description du service",
    icon: Icons.description_outlined,
    content:
    "Savvy est une application de gestion financière personnelle qui vous permet de suivre vos dépenses, gérer vos budgets, définir des objectifs d'épargne et analyser votre santé financière. Nous nous réservons le droit de modifier, suspendre ou interrompre tout ou partie du service à tout moment.",
  ),
  _LegalSection(
    title: "3. Inscription et compte",
    icon: Icons.person_outline_rounded,
    content:
    "Pour utiliser Savvy, vous devez créer un compte en fournissant des informations exactes et complètes. Vous êtes responsable de la confidentialité de vos identifiants de connexion et de toutes les activités effectuées sous votre compte. Vous devez avoir au moins 18 ans pour créer un compte.",
  ),
  _LegalSection(
    title: "4. Utilisation acceptable",
    icon: Icons.rule_outlined,
    content:
    "Vous acceptez de ne pas utiliser Savvy à des fins illicites, de ne pas tenter d'accéder sans autorisation à nos systèmes, de ne pas transmettre de virus ou code malveillant, et de ne pas utiliser le service de manière à perturber son fonctionnement normal ou à nuire à d'autres utilisateurs.",
  ),
  _LegalSection(
    title: "5. Données financières",
    icon: Icons.account_balance_outlined,
    content:
    "Savvy ne fournit pas de conseils financiers, juridiques ou fiscaux. Les informations présentées dans l'application sont à titre informatif uniquement. Nous ne sommes pas responsables des décisions financières que vous prenez sur la base des données affichées dans l'application.",
  ),
  _LegalSection(
    title: "6. Propriété intellectuelle",
    icon: Icons.copyright_outlined,
    content:
    "Tous les contenus de Savvy, incluant mais non limité au code, design, logos, textes et graphiques, sont la propriété exclusive de Savvy et sont protégés par les lois sur la propriété intellectuelle. Toute reproduction non autorisée est strictement interdite.",
  ),
  _LegalSection(
    title: "7. Limitation de responsabilité",
    icon: Icons.security_outlined,
    content:
    "Dans la mesure permise par la loi applicable, Savvy ne saurait être tenu responsable des dommages indirects, accessoires ou consécutifs résultant de l'utilisation ou de l'impossibilité d'utiliser nos services. Notre responsabilité totale ne peut excéder le montant payé pour le service au cours des 12 derniers mois.",
  ),
  _LegalSection(
    title: "8. Modifications des conditions",
    icon: Icons.edit_note_outlined,
    content:
    "Nous nous réservons le droit de modifier ces conditions à tout moment. Les modifications entrent en vigueur dès leur publication dans l'application. Votre utilisation continue du service après la publication constitue votre acceptation des nouvelles conditions. Nous vous notifierons des changements importants par email.",
  ),
];

const List<_LegalSection> _privacySections = [
  _LegalSection(
    title: "1. Données collectées",
    icon: Icons.data_usage_outlined,
    content:
    "Nous collectons les informations que vous nous fournissez directement : nom, adresse email, et données financières que vous saisissez dans l'application. Nous collectons également automatiquement des données d'utilisation, des informations sur votre appareil, et des données de navigation pour améliorer nos services.",
  ),
  _LegalSection(
    title: "2. Utilisation des données",
    icon: Icons.manage_search_outlined,
    content:
    "Vos données sont utilisées pour fournir et améliorer nos services, personnaliser votre expérience, envoyer des communications liées au service, assurer la sécurité de votre compte, et répondre à vos demandes d'assistance. Nous n'utilisons jamais vos données financières à des fins publicitaires.",
  ),
  _LegalSection(
    title: "3. Partage des données",
    icon: Icons.share_outlined,
    content:
    "Nous ne vendons jamais vos données personnelles à des tiers. Nous pouvons partager vos informations avec des prestataires de services de confiance qui nous aident à opérer notre plateforme (hébergement, analyse), toujours sous strict accord de confidentialité. Nous divulguerons vos données si la loi l'exige.",
  ),
  _LegalSection(
    title: "4. Sécurité des données",
    icon: Icons.lock_outline_rounded,
    content:
    "Nous mettons en œuvre des mesures de sécurité techniques et organisationnelles de pointe pour protéger vos données : chiffrement AES-256 au repos, TLS 1.3 en transit, authentification multi-facteurs, et audits de sécurité réguliers. Vos données financières sont traitées avec le plus haut niveau de sécurité.",
  ),
  _LegalSection(
    title: "5. Conservation des données",
    icon: Icons.schedule_outlined,
    content:
    "Nous conservons vos données personnelles aussi longtemps que votre compte est actif ou aussi longtemps que nécessaire pour fournir nos services. Après suppression de votre compte, vos données sont effacées dans un délai de 30 jours, sauf obligation légale de conservation plus longue.",
  ),
  _LegalSection(
    title: "6. Vos droits (RGPD)",
    icon: Icons.gavel_rounded,
    content:
    "Conformément au RGPD, vous disposez du droit d'accès, de rectification, d'effacement, de portabilité et d'opposition au traitement de vos données. Vous pouvez exercer ces droits depuis les paramètres de l'application ou en nous contactant. Vous avez également le droit d'introduire une réclamation auprès de la CNIL.",
  ),
  _LegalSection(
    title: "7. Cookies et traceurs",
    icon: Icons.cookie_outlined,
    content:
    "Nous utilisons des cookies essentiels pour le fonctionnement de l'application et des cookies analytiques anonymisés pour comprendre comment vous utilisez nos services. Vous pouvez gérer vos préférences de cookies dans les paramètres de l'application. Aucun cookie publicitaire n'est utilisé.",
  ),
  _LegalSection(
    title: "8. Transferts internationaux",
    icon: Icons.public_outlined,
    content:
    "Vos données peuvent être transférées et traitées dans des pays autres que votre pays de résidence. Dans ce cas, nous nous assurons que des garanties appropriées sont en place, notamment via des clauses contractuelles types approuvées par la Commission européenne, pour protéger vos données.",
  ),
];

// ══════════════════════════════════════════════════════════════
//  BACKGROUND PAINTERS
// ══════════════════════════════════════════════════════════════
class _LegalBgPainter extends CustomPainter {
  final double t;
  final bool isPrivacy;
  _LegalBgPainter(this.t, {this.isPrivacy = false});

  @override
  void paint(Canvas canvas, Size size) {
    final c1 = isPrivacy ? const Color(0xFF00D4FF) : const Color(0xFF3EFFA8);
    final c2 = isPrivacy ? const Color(0xFF7B61FF) : const Color(0xFF00D4FF);

    final positions = [
      Offset(
        size.width * (0.1 + 0.07 * math.sin(t * math.pi)),
        size.height * (0.12 + 0.05 * math.cos(t * math.pi)),
      ),
      Offset(
        size.width * (0.85 + 0.05 * math.cos(t * math.pi)),
        size.height * (0.8 + 0.06 * math.sin(t * math.pi)),
      ),
    ];

    final colors = [
      c1.withOpacity(0.055),
      c2.withOpacity(0.04),
    ];

    for (int i = 0; i < positions.length; i++) {
      final r = size.width * 0.45;
      canvas.drawCircle(
        positions[i],
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [colors[i], Colors.transparent],
          ).createShader(Rect.fromCircle(center: positions[i], radius: r)),
      );
    }
  }

  @override
  bool shouldRepaint(_LegalBgPainter old) => old.t != t;
}

class _LegalGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A2E52).withOpacity(0.18)
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
  bool shouldRepaint(_LegalGridPainter old) => false;
}