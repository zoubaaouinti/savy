import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/faq_models.dart';
import '../../../services/emailjs_service.dart';

// ══════════════════════════════════════════════════════════════
//  SAVVY – HELP & FAQ SCREEN
//  lib/views/profileScreen/help/help_screen.dart
// ══════════════════════════════════════════════════════════════

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen>
    with TickerProviderStateMixin {

  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  int? _selectedCategoryIndex;

  late final AnimationController _bgController;
  late final Animation<double> _bgAnim;

  // Copie mutable des données FAQ
  late final List<FaqCategory> _categories;

  @override
  void initState() {
    super.initState();
    // Copie pour permettre l'expansion
    _categories = faqData.map((cat) => FaqCategory(
      title: cat.title,
      iconName: cat.iconName,
      colorValue: cat.colorValue,
      items: cat.items.map((item) => FaqItem(
        question: item.question,
        answer: item.answer,
      )).toList(),
    )).toList();

    _bgController = AnimationController(
        vsync: this, duration: const Duration(seconds: 8))..repeat(reverse: true);
    _bgAnim = CurvedAnimation(parent: _bgController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _bgController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Icon mapping ──────────────────────────────────────────
  IconData _iconFromName(String name) {
    const map = {
      'rocket':  Icons.rocket_launch_rounded,
      'wallet':  Icons.account_balance_wallet_rounded,
      'flag':    Icons.flag_rounded,
      'person':  Icons.person_rounded,
      'shield':  Icons.shield_rounded,
      'email':   Icons.email_rounded,
      'bug':     Icons.bug_report_rounded,
      'star':    Icons.star_rounded,
    };
    return map[name] ?? Icons.help_outline_rounded;
  }

  // ── Filtrage de la recherche ──────────────────────────────
  List<FaqItem> get _searchResults {
    if (_searchQuery.isEmpty) return [];
    final query = _searchQuery.toLowerCase();
    final results = <FaqItem>[];
    for (final cat in _categories) {
      for (final item in cat.items) {
        if (item.question.toLowerCase().contains(query) ||
            item.answer.toLowerCase().contains(query)) {
          results.add(item);
        }
      }
    }
    return results;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final hPad = size.shortestSide > 600 ? size.width * 0.2 : 20.0;

    return Scaffold(
      backgroundColor: const Color(0xFF060D1F),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _bgAnim,
            builder: (_, __) => CustomPaint(
                size: size, painter: _BgPainter(_bgAnim.value)),
          ),
          CustomPaint(size: size, painter: _GridPainter()),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Search bar ───────────────────
                        _buildSearchBar(),
                        const SizedBox(height: 24),

                        // ── Résultats de recherche ───────
                        if (_searchQuery.isNotEmpty) ...[
                          _buildSearchResults(),
                        ] else ...[
                          // ── Catégories chips ─────────
                          _buildCategoryChips(),
                          const SizedBox(height: 20),

                          // ── FAQ list ─────────────────
                          _buildFaqList(),
                          const SizedBox(height: 28),

                          // ── Contact section ──────────
                          _buildSectionTitle('Nous contacter'),
                          const SizedBox(height: 12),
                          _buildContactSection(),
                          const SizedBox(height: 28),

                          // ── Version ──────────────────
                          _buildVersionCard(),
                        ],
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
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1A2E52)),
                color: const Color(0xFF0D1B38),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF8BA8D4), size: 16),
            ),
          ),
          const SizedBox(width: 16),
          ShaderMask(
            shaderCallback: (b) => const LinearGradient(
                colors: [Color(0xFF3EFFA8), Color(0xFF00D4FF)]).createShader(b),
            child: const Text('Aide & FAQ',
                style: TextStyle(color: Colors.white, fontSize: 18,
                    fontWeight: FontWeight.w800)),
          ),
          const Spacer(),
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                  colors: [Color(0xFF3EFFA8), Color(0xFF00D4FF)]),
              boxShadow: [BoxShadow(
                  color: const Color(0xFF3EFFA8).withOpacity(0.3), blurRadius: 12)],
            ),
            child: const Icon(Icons.help_rounded, color: Color(0xFF060D1F), size: 20),
          ),
        ],
      ),
    );
  }

  // ── Search Bar ────────────────────────────────────────────
  Widget _buildSearchBar() {
    return TextField(
      controller: _searchCtrl,
      onChanged: (v) => setState(() => _searchQuery = v),
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Rechercher dans l\'aide...',
        hintStyle: const TextStyle(color: Color(0xFF3A5068), fontSize: 14),
        prefixIcon: const Icon(Icons.search_rounded,
            color: Color(0xFF4A6080), size: 20),
        suffixIcon: _searchQuery.isNotEmpty
            ? GestureDetector(
          onTap: () {
            _searchCtrl.clear();
            setState(() => _searchQuery = '');
          },
          child: const Icon(Icons.close_rounded,
              color: Color(0xFF4A6080), size: 18),
        )
            : null,
        filled: true,
        fillColor: const Color(0xFF0B1535),
        contentPadding:
        const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF1A2E52)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF1A2E52)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF3EFFA8), width: 1.5),
        ),
      ),
    );
  }

  // ── Search Results ────────────────────────────────────────
  Widget _buildSearchResults() {
    final results = _searchResults;
    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Column(
            children: [
              Icon(Icons.search_off_rounded,
                  color: const Color(0xFF1A2E52), size: 52),
              const SizedBox(height: 12),
              Text('Aucun résultat pour "$_searchQuery"',
                  style: const TextStyle(
                      color: Color(0xFF4A6080), fontSize: 14)),
              const SizedBox(height: 8),
              const Text('Essayez d\'autres mots-clés',
                  style: TextStyle(color: Color(0xFF3A5070), fontSize: 12)),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${results.length} résultat(s) pour "$_searchQuery"',
            style: const TextStyle(color: Color(0xFF6B8CAE), fontSize: 12)),
        const SizedBox(height: 12),
        ...results.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildFaqTile(item, const Color(0xFF3EFFA8)),
        )),
      ],
    );
  }

  // ── Category Chips ────────────────────────────────────────
  Widget _buildCategoryChips() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          if (i == 0) {
            // Chip "Tous"
            final isSelected = _selectedCategoryIndex == null;
            return _chip('Tous', Icons.apps_rounded,
                const Color(0xFF3EFFA8), isSelected, () {
                  setState(() => _selectedCategoryIndex = null);
                });
          }
          final cat = _categories[i - 1];
          final isSelected = _selectedCategoryIndex == i - 1;
          return _chip(cat.title, _iconFromName(cat.iconName),
              Color(cat.colorValue), isSelected, () {
                setState(() => _selectedCategoryIndex = isSelected ? null : i - 1);
              });
        },
      ),
    );
  }

  Widget _chip(String label, IconData icon, Color color,
      bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isSelected ? color.withOpacity(0.15) : const Color(0xFF0B1535),
          border: Border.all(
              color: isSelected ? color : const Color(0xFF1A2E52)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? color : const Color(0xFF4A6080), size: 14),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: isSelected ? color : const Color(0xFF6B8CAE),
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400)),
          ],
        ),
      ),
    );
  }

  // ── FAQ List ──────────────────────────────────────────────
  Widget _buildFaqList() {
    final cats = _selectedCategoryIndex != null
        ? [_categories[_selectedCategoryIndex!]]
        : _categories;

    return Column(
      children: cats.map((cat) {
        final color = Color(cat.colorValue);
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category header
              Row(
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: color.withOpacity(0.12),
                    ),
                    child: Icon(_iconFromName(cat.iconName), color: color, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Text(cat.title,
                      style: TextStyle(
                          color: color, fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: color.withOpacity(0.1),
                    ),
                    child: Text('${cat.items.length}',
                        style: TextStyle(color: color, fontSize: 11)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // FAQ items
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: const Color(0xFF0B1535),
                  border: Border.all(
                      color: const Color(0xFF1A2E52).withOpacity(0.6)),
                ),
                child: Column(
                  children: List.generate(cat.items.length, (i) {
                    final item = cat.items[i];
                    final isLast = i == cat.items.length - 1;
                    return Column(
                      children: [
                        _buildFaqTile(item, color),
                        if (!isLast)
                          Divider(height: 1, indent: 16,
                              color: const Color(0xFF1A2E52).withOpacity(0.4)),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFaqTile(FaqItem item, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: item.isExpanded
            ? color.withOpacity(0.04)
            : Colors.transparent,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding:
          const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 28, height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: item.isExpanded
                  ? color.withOpacity(0.15)
                  : const Color(0xFF1A2E52).withOpacity(0.5),
            ),
            child: Icon(
              item.isExpanded
                  ? Icons.remove_rounded
                  : Icons.add_rounded,
              color: item.isExpanded ? color : const Color(0xFF4A6080),
              size: 16,
            ),
          ),
          title: Text(
            item.question,
            style: TextStyle(
              color: item.isExpanded ? Colors.white : const Color(0xFFCDD8F0),
              fontSize: 13,
              fontWeight: item.isExpanded ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          trailing: const SizedBox.shrink(),
          onExpansionChanged: (val) =>
              setState(() => item.isExpanded = val),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFF0D1B38),
                border: Border.all(color: color.withOpacity(0.2)),
              ),
              child: Text(
                item.answer,
                style: const TextStyle(
                  color: Color(0xFF8BA8D4),
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Contact Section ───────────────────────────────────────
  Widget _buildContactSection() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color(0xFF0B1535),
        border: Border.all(color: const Color(0xFF1A2E52).withOpacity(0.6)),
      ),
      child: Column(
        children: List.generate(contactOptions.length, (i) {
          final opt = contactOptions[i];
          final color = Color(opt.colorValue);
          final isLast = i == contactOptions.length - 1;
          return Column(
            children: [
              GestureDetector(
                onTap: () => _handleContact(opt.action),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: color.withOpacity(0.12),
                        ),
                        child: Icon(_iconFromName(opt.iconName),
                            color: color, size: 18),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(opt.title,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500)),
                            Text(opt.subtitle,
                                style: const TextStyle(
                                    color: Color(0xFF4A6080), fontSize: 11)),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded,
                          color: color.withOpacity(0.5), size: 13),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                Divider(height: 1, indent: 68,
                    color: const Color(0xFF1A2E52).withOpacity(0.4)),
            ],
          );
        }),
      ),
    );
  }

  void _handleContact(String action) {
    switch (action) {
      case 'bug_report':
        _showBugReportDialog();
        break;
      case 'rate_app':
      // TODO: ouvrir le Play Store
        break;
      default:
      // Email support
        _showEmailSupportDialog();
        break;
    }
  }

  // ── Email support dialog ──────────────────────────────────
  void _showEmailSupportDialog() {
    final subjectCtrl = TextEditingController();
    final messageCtrl = TextEditingController();
    bool isSending = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: const Color(0xFF0B1535),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: const Color(0xFF3EFFA8).withOpacity(0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF3EFFA8).withOpacity(0.12),
                      ),
                      child: const Icon(Icons.email_rounded,
                          color: Color(0xFF3EFFA8), size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Contacter le support',
                            style: TextStyle(color: Colors.white,
                                fontSize: 15, fontWeight: FontWeight.w800)),
                        Text('support@savy.app',
                            style: TextStyle(color: Color(0xFF4A6080), fontSize: 11)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Sujet
                const Text('Sujet',
                    style: TextStyle(color: Color(0xFF8BA8D4),
                        fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                TextField(
                  controller: subjectCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Ex: Problème avec mon budget...',
                    hintStyle: const TextStyle(color: Color(0xFF3A5068), fontSize: 13),
                    filled: true,
                    fillColor: const Color(0xFF0D1B38),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF1A2E52))),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF1A2E52))),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF3EFFA8), width: 1.5)),
                  ),
                ),
                const SizedBox(height: 14),

                // Message
                const Text('Message',
                    style: TextStyle(color: Color(0xFF8BA8D4),
                        fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                TextField(
                  controller: messageCtrl,
                  maxLines: 5,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Décrivez votre problème ou réclamation en détail...',
                    hintStyle: const TextStyle(color: Color(0xFF3A5068), fontSize: 13),
                    filled: true,
                    fillColor: const Color(0xFF0D1B38),
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF1A2E52))),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF1A2E52))),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF3EFFA8), width: 1.5)),
                  ),
                ),
                const SizedBox(height: 20),

                // Boutons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isSending ? null : () => Navigator.pop(dialogContext),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF1A2E52)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Annuler',
                            style: TextStyle(color: Color(0xFF8BA8D4),
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: isSending
                                ? [const Color(0xFF3EFFA8).withOpacity(0.5),
                              const Color(0xFF00D4FF).withOpacity(0.5)]
                                : [const Color(0xFF3EFFA8), const Color(0xFF00D4FF)],
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: isSending ? null : () async {
                            final subject = subjectCtrl.text.trim();
                            final message = messageCtrl.text.trim();

                            if (subject.isEmpty || message.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Veuillez remplir tous les champs',
                                      style: TextStyle(color: Colors.white)),
                                  backgroundColor: Color(0xFFFF5C7A),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }

                            setDialogState(() => isSending = true);

                            // Récupère les infos Firebase de l'utilisateur
                            final user = FirebaseAuth.instance.currentUser;
                            final userName  = user?.displayName ?? 'Utilisateur Savy';
                            final userEmail = user?.email ?? 'email inconnu';

                            // Envoi via EmailJS
                            final result = await EmailJSService.sendEmail(
                              userName:  userName,
                              userEmail: userEmail,
                              subject:   subject,
                              message:   message,
                            );

                            if (!dialogContext.mounted) return;

                            if (result.isSuccess) {
                              Navigator.pop(dialogContext);
                              _showConfirmationDialog();
                            } else {
                              setDialogState(() => isSending = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      result.errorMessage ?? "Erreur lors de l'envoi",
                                      style: const TextStyle(color: Colors.white)),
                                  backgroundColor: const Color(0xFFFF5C7A),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: isSending
                              ? const SizedBox(width: 18, height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Color(0xFF060D1F)),
                              ))
                              : const Text('Envoyer',
                              style: TextStyle(color: Color(0xFF060D1F),
                                  fontWeight: FontWeight.w700, fontSize: 14)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Confirmation dialog après envoi ──────────────────────
  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF0B1535),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: const Color(0xFF3EFFA8).withOpacity(0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icône succès animée
              Container(
                width: 70, height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF3EFFA8).withOpacity(0.1),
                  border: Border.all(
                      color: const Color(0xFF3EFFA8).withOpacity(0.4), width: 2),
                  boxShadow: [BoxShadow(
                      color: const Color(0xFF3EFFA8).withOpacity(0.2),
                      blurRadius: 20, spreadRadius: 3)],
                ),
                child: const Icon(Icons.check_rounded,
                    color: Color(0xFF3EFFA8), size: 34),
              ),
              const SizedBox(height: 20),

              ShaderMask(
                shaderCallback: (b) => const LinearGradient(
                    colors: [Color(0xFF3EFFA8), Color(0xFF00D4FF)]).createShader(b),
                child: const Text('Message envoyé !',
                    style: TextStyle(color: Colors.white,
                        fontSize: 18, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 10),

              const Text(
                'Votre message a bien été envoyé à notre équipe. Nous vous répondrons dans les plus brefs délais.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF6B8CAE),
                    fontSize: 13, height: 1.6),
              ),
              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color(0xFF3EFFA8).withOpacity(0.08),
                  border: Border.all(
                      color: const Color(0xFF3EFFA8).withOpacity(0.2)),
                ),
                child: const Text('zouba.aouinti@gmail.com',
                    style: TextStyle(color: Color(0xFF3EFFA8),
                        fontSize: 12, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity, height: 46,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                        colors: [Color(0xFF3EFFA8), Color(0xFF00D4FF)]),
                  ),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Parfait !',
                        style: TextStyle(color: Color(0xFF060D1F),
                            fontWeight: FontWeight.w700, fontSize: 15)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBugReportDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF0B1535),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
              color: const Color(0xFFFFB340).withOpacity(0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Signaler un bug',
                  style: TextStyle(color: Colors.white, fontSize: 16,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Text('Décrivez le problème que vous avez rencontré',
                  style: TextStyle(color: Color(0xFF6B8CAE), fontSize: 12)),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                maxLines: 4,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Ex: L\'app se ferme quand je...',
                  hintStyle: const TextStyle(
                      color: Color(0xFF3A5068), fontSize: 13),
                  filled: true,
                  fillColor: const Color(0xFF0D1B38),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF1A2E52)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF1A2E52)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: Color(0xFFFFB340), width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF1A2E52)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Annuler',
                          style: TextStyle(color: Color(0xFF8BA8D4))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Rapport envoyé, merci !',
                                style: TextStyle(color: Colors.white)),
                            backgroundColor: const Color(0xFF0D1B38),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(
                                  color: Color(0xFFFFB340)),
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFB340),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Envoyer',
                          style: TextStyle(
                              color: Color(0xFF060D1F),
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Version card ──────────────────────────────────────────
  Widget _buildVersionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF3EFFA8).withOpacity(0.05),
            const Color(0xFF00D4FF).withOpacity(0.05),
          ],
        ),
        border: Border.all(
            color: const Color(0xFF3EFFA8).withOpacity(0.15)),
      ),
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (b) => const LinearGradient(
                colors: [Color(0xFF3EFFA8), Color(0xFF00D4FF)]).createShader(b),
            child: const Text('Savy',
                style: TextStyle(color: Colors.white, fontSize: 20,
                    fontWeight: FontWeight.w800, letterSpacing: 1)),
          ),
          const SizedBox(height: 4),
          const Text('Version 1.0.0',
              style: TextStyle(color: Color(0xFF4A6080), fontSize: 12)),
          const SizedBox(height: 8),
          const Text('Application de gestion budgétaire pour étudiants',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF6B8CAE), fontSize: 11, height: 1.4)),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────
  Widget _buildSectionTitle(String title) => Text(
    title.toUpperCase(),
    style: const TextStyle(
        color: Color(0xFF3A5070), fontSize: 11,
        fontWeight: FontWeight.w700, letterSpacing: 1.2),
  );
}

// ══════════════════════════════════════════════════════════════
//  PAINTERS
// ══════════════════════════════════════════════════════════════
class _BgPainter extends CustomPainter {
  final double t;
  _BgPainter(this.t);
  @override
  void paint(Canvas canvas, Size size) {
    void orb(Offset c, double r, Color color) => canvas.drawCircle(c, r,
        Paint()..shader = RadialGradient(colors: [color, Colors.transparent])
            .createShader(Rect.fromCircle(center: c, radius: r)));
    orb(Offset(size.width * (0.1 + 0.06 * math.sin(t * math.pi)), size.height * 0.12),
        size.width * 0.4, const Color(0xFF3EFFA8).withOpacity(0.05));
    orb(Offset(size.width * 0.85, size.height * (0.7 + 0.05 * math.cos(t * math.pi))),
        size.width * 0.35, const Color(0xFF00D4FF).withOpacity(0.04));
  }
  @override
  bool shouldRepaint(_BgPainter old) => old.t != t;
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFF1A2E52).withOpacity(0.15)
      ..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += 44)
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    for (double y = 0; y < size.height; y += 44)
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
  }
  @override
  bool shouldRepaint(_GridPainter _) => false;
}