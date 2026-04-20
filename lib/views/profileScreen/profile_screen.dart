import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../models/currency_model.dart';
import '../../providers/currency_provider.dart';
import '../../providers/language_provider.dart';
import '../../services/auth_service.dart';
import 'edit_profile_screen.dart';
import 'help/help_screen.dart';
import 'security/security_screen.dart';
import '../../models/profile_models.dart';
import '../legalScreen/legal_screens.dart';
import 'backup/backup_screen.dart'; // ← AJOUT IMPORT BACKUP
import 'package:savy/l10n/app_localizations.dart';

// ══════════════════════════════════════════════════════════════
//  SAVVY – PROFILE SCREEN
// ══════════════════════════════════════════════════════════════

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();

  // Données utilisateur depuis Firebase
  String _name = '';
  String _email = '';
  String _initials = '';
  Uint8List? _photoBytes;
  Gender _gender = Gender.notSpecified;
  DateTime? _birthDate;

  // Stats dynamiques
  int _objectivesCount = 0;
  int _transactionsCount = 0;
  int _profileScore = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadPhotoFromFirestore();
    _loadStats();
  }

  void _loadUserData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _email = user.email ?? '';
        _name = user.displayName ?? '';
        _initials = _getInitials(_name);
      });
    }
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
  }

  Future<void> _loadPhotoFromFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists && mounted) {
        final data = doc.data()!;
        final photoBase64 = data['photoBase64'] as String?;
        final firestoreName = data['name'] as String?;
        final gender = GenderExtension.fromValue(data['gender'] as String?);
        final birthDateMs = data['birthDate'];
        final birthDate = birthDateMs != null
            ? DateTime.fromMillisecondsSinceEpoch(birthDateMs as int)
            : null;
        setState(() {
          _photoBytes = photoBase64 != null
              ? Uint8List.fromList(base64Decode(photoBase64))
              : null;
          if (firestoreName != null && firestoreName.isNotEmpty) {
            _name = firestoreName;
            _initials = _getInitials(_name);
          }
          _gender = gender;
          _birthDate = birthDate;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadStats() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final uid = user.uid;
      final db = FirebaseFirestore.instance;

      final results = await Future.wait([
        db.collection('users').doc(uid).collection('objectives').get(),
        db.collection('users').doc(uid).collection('transactions').get(),
        db.collection('users').doc(uid).collection('revenues').get(),
        db.collection('users').doc(uid).collection('budget').get(),
      ]);

      final objectivesSnap = results[0];
      final txSnap = results[1];
      final revenueSnap = results[2];
      final budgetSnap = results[3];

      double totalIncome = 0;
      for (final doc in revenueSnap.docs) {
        totalIncome += ((doc.data())['amount'] ?? 0).toDouble();
      }
      double totalExpenses = 0;
      for (final doc in budgetSnap.docs) {
        totalExpenses += ((doc.data())['spent'] ?? 0).toDouble();
      }
      double totalObjectivesSaved = 0;
      for (final doc in objectivesSnap.docs) {
        totalObjectivesSaved += ((doc.data())['currentAmount'] ?? 0).toDouble();
      }

      int score = 50;
      if (totalIncome > 0) {
        final ratio = (totalExpenses + totalObjectivesSaved) / totalIncome;
        if (ratio <= 0.40) score = 95;
        else if (ratio <= 0.60) score = 80;
        else if (ratio <= 0.80) score = 60;
        else if (ratio <= 1.00) score = 35;
        else score = 15;
      }

      if (mounted) {
        setState(() {
          _objectivesCount = objectivesSnap.docs.length;
          _transactionsCount = txSnap.docs.length;
          _profileScore = score;
        });
      }
    } catch (_) {}
  }

  // ── Naviguer vers EditProfileScreen ──────────────────────
  Future<void> _goToEditProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    final profile = UserProfile(
      uid: user?.uid ?? '',
      name: _name,
      email: _email,
      gender: _gender,
      birthDate: _birthDate,
    );

    final result = await Navigator.of(context).push<UserProfile>(
      PageRouteBuilder(
        pageBuilder: (_, a, __) => EditProfileScreen(profile: profile),
        transitionsBuilder: (_, a, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );

    if (result != null) {
      setState(() {
        _name = result.name;
        _email = result.email;
        _initials = _getInitials(_name);
        _gender = result.gender;
        _birthDate = result.birthDate;
      });
      await _loadPhotoFromFirestore();
    }
  }

  // ── Naviguer vers BackupScreen ────────────────────────────
  void _goToBackup() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, a, __) => const BackupScreen(),
        transitionsBuilder: (_, a, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  // ── Sélecteur de devise ────────────────────────────────────
  void _showCurrencyPicker(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final searchCtrl = TextEditingController();
    List<CurrencyInfo> filtered = CurrencyInfo.allCurrencies;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) {
          void onSearch(String q) {
            final lower = q.toLowerCase();
            setSheet(() {
              filtered = q.isEmpty
                  ? CurrencyInfo.allCurrencies
                  : CurrencyInfo.allCurrencies
                      .where((c) =>
                          c.code.toLowerCase().contains(lower) ||
                          c.name.toLowerCase().contains(lower))
                      .toList();
            });
          }

          final cur = context.read<CurrencyProvider>();

          return DraggableScrollableSheet(
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (_, scrollCtrl) => Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0B1535),
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Handle
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A2E52),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.profileSelectCurrency,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text(
                            l10n.profileCurrencyConvertHint,
                            style: const TextStyle(
                                color: Color(0xFF4A6080),
                                fontSize: 12)),
                        const SizedBox(height: 14),
                        // Barre de recherche
                        TextField(
                          controller: searchCtrl,
                          onChanged: onSearch,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: l10n.profileSearchCurrency,
                            hintStyle: const TextStyle(
                                color: Color(0xFF3A5068),
                                fontSize: 14),
                            prefixIcon: const Icon(Icons.search_rounded,
                                color: Color(0xFF4A6080), size: 20),
                            filled: true,
                            fillColor: const Color(0xFF0D1B38),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFF1A2E52))),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFF1A2E52))),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFF3EFFA8),
                                    width: 1.5)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Text(l10n.profileNoResults,
                                style: const TextStyle(
                                    color: Color(0xFF4A6080),
                                    fontSize: 13)))
                        : ListView.builder(
                            controller: scrollCtrl,
                            padding: const EdgeInsets.fromLTRB(
                                20, 0, 20, 32),
                            itemCount: filtered.length,
                            itemBuilder: (_, i) {
                              final c = filtered[i];
                              final isSelected =
                                  c.code == cur.selected.code;
                              return GestureDetector(
                                onTap: () async {
                                  Navigator.pop(ctx);
                                  await context
                                      .read<CurrencyProvider>()
                                      .setCurrency(c);
                                },
                                child: AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 150),
                                  margin:
                                      const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(12),
                                    color: isSelected
                                        ? const Color(0xFFFFB340)
                                            .withOpacity(0.08)
                                        : const Color(0xFF0D1B38),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFFFFB340)
                                              .withOpacity(0.5)
                                          : const Color(0xFF1A2E52),
                                      width: isSelected ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Row(children: [
                                    Text(c.flag,
                                        style: const TextStyle(
                                            fontSize: 22)),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(c.code,
                                              style: TextStyle(
                                                  color: isSelected
                                                      ? const Color(
                                                          0xFFFFB340)
                                                      : Colors.white,
                                                  fontSize: 13,
                                                  fontWeight:
                                                      FontWeight.w700)),
                                          Text(c.name,
                                              style: const TextStyle(
                                                  color:
                                                      Color(0xFF4A6080),
                                                  fontSize: 11)),
                                        ],
                                      ),
                                    ),
                                    Text(c.symbol,
                                        style: TextStyle(
                                            color: isSelected
                                                ? const Color(0xFFFFB340)
                                                : const Color(0xFF4A6080),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600)),
                                    if (isSelected) ...[
                                      const SizedBox(width: 8),
                                      const Icon(
                                          Icons.check_circle_rounded,
                                          color: Color(0xFFFFB340),
                                          size: 16),
                                    ],
                                  ]),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Sélecteur de langue ────────────────────────────────────
  void _showLanguagePicker(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0B1535),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2E52),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.profileSelectLanguage,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 16),
            Consumer<LanguageProvider>(
              builder: (ctx, langProvider, __) {
                return Column(
                  children: LanguageProvider.supportedLanguages
                      .map((lang) {
                    final isSelected =
                        langProvider.languageCode == lang.code;
                    return GestureDetector(
                      onTap: () {
                        context
                            .read<LanguageProvider>()
                            .setLocale(lang.code);
                        Navigator.pop(context);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: isSelected
                              ? const Color(0xFF00D4FF).withOpacity(0.08)
                              : const Color(0xFF0D1B38),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF00D4FF).withOpacity(0.5)
                                : const Color(0xFF1A2E52),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(children: [
                          Text(lang.flag,
                              style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              lang.label,
                              style: TextStyle(
                                color: isSelected
                                    ? const Color(0xFF00D4FF)
                                    : Colors.white,
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle_rounded,
                                color: Color(0xFF00D4FF), size: 18),
                        ]),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Suppression du compte ─────────────────────────────────
  void _showDeleteAccountSheet() {
    final l10n = AppLocalizations.of(context);

    final deleteReasons = [
      l10n.deleteAccountReason1,
      l10n.deleteAccountReason2,
      l10n.deleteAccountReason3,
      l10n.deleteAccountReason4,
      l10n.deleteAccountReason5,
    ];

    String? selectedReason;
    final customCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool isDeleting = false;
    String? errorMsg;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) {
          final confirmOk = confirmCtrl.text.trim().toLowerCase() ==
              l10n.deleteAccountConfirmWord;
          final lastReason = deleteReasons.last;
          final reasonOk = selectedReason != null &&
              (selectedReason != lastReason ||
                  customCtrl.text.trim().isNotEmpty);
          final canDelete = confirmOk && reasonOk && !isDeleting;

          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0B1535),
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: SingleChildScrollView(
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
                    Row(children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFF5C7A).withOpacity(0.1),
                        ),
                        child: const Icon(Icons.delete_forever_rounded,
                            color: Color(0xFFFF5C7A), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.deleteAccountTitle,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800)),
                          Text(l10n.profileDeleteIrreversible,
                              style: const TextStyle(
                                  color: Color(0xFFFF5C7A), fontSize: 11)),
                        ],
                      ),
                    ]),
                    const SizedBox(height: 20),

                    // Raisons
                    Text(l10n.deleteAccountReasonTitle,
                        style: const TextStyle(
                            color: Color(0xFF8BA8D4),
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),

                    ...deleteReasons.map((reason) {
                      final isSelected = selectedReason == reason;
                      return GestureDetector(
                        onTap: () => setSheet(() => selectedReason = reason),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: isSelected
                                ? const Color(0xFFFF5C7A).withOpacity(0.07)
                                : const Color(0xFF0D1B38),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFFF5C7A).withOpacity(0.5)
                                  : const Color(0xFF1A2E52),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: 18, height: 18,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFFF5C7A)
                                      : const Color(0xFF3A5070),
                                  width: 2,
                                ),
                                color: isSelected
                                    ? const Color(0xFFFF5C7A)
                                    : Colors.transparent,
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check,
                                      color: Colors.white, size: 11)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Text(reason,
                                style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF8BA8D4),
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400)),
                          ]),
                        ),
                      );
                    }),

                    // Textarea si dernière option (Autres)
                    if (selectedReason == lastReason) ...[
                      const SizedBox(height: 4),
                      TextField(
                        controller: customCtrl,
                        maxLines: 3,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 13),
                        onChanged: (_) => setSheet(() {}),
                        decoration: InputDecoration(
                          hintText: l10n.deleteAccountOtherHint,
                          hintStyle: const TextStyle(
                              color: Color(0xFF3A5068), fontSize: 13),
                          filled: true,
                          fillColor: const Color(0xFF0D1B38),
                          contentPadding: const EdgeInsets.all(14),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Color(0xFF1A2E52))),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Color(0xFF1A2E52))),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Color(0xFFFF5C7A), width: 1.5)),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ] else
                      const SizedBox(height: 12),

                    // Avertissement
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFFFF5C7A).withOpacity(0.07),
                        border: Border.all(
                            color: const Color(0xFFFF5C7A).withOpacity(0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: Color(0xFFFF5C7A), size: 16),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              l10n.deleteAccountWarning,
                              style: const TextStyle(
                                  color: Color(0xFFFF5C7A),
                                  fontSize: 12,
                                  height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Champ de confirmation
                    Text(l10n.deleteAccountConfirmLabel,
                        style: const TextStyle(
                            color: Color(0xFF8BA8D4),
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: confirmCtrl,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 14),
                      onChanged: (_) => setSheet(() {}),
                      decoration: InputDecoration(
                        hintText: l10n.deleteAccountConfirmHint,
                        hintStyle: const TextStyle(
                            color: Color(0xFF3A5068), fontSize: 14),
                        filled: true,
                        fillColor: const Color(0xFF0D1B38),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 16),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Color(0xFF1A2E52))),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Color(0xFF1A2E52))),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: confirmOk
                                    ? const Color(0xFFFF5C7A)
                                    : const Color(0xFF1A2E52),
                                width: 1.5)),
                      ),
                    ),

                    if (errorMsg != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(0xFFFF5C7A).withOpacity(0.08),
                          border: Border.all(
                              color:
                                  const Color(0xFFFF5C7A).withOpacity(0.4)),
                        ),
                        child: Text(errorMsg!,
                            style: const TextStyle(
                                color: Color(0xFFFF5C7A), fontSize: 12)),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Bouton supprimer
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: AnimatedOpacity(
                        opacity: canDelete ? 1.0 : 0.4,
                        duration: const Duration(milliseconds: 200),
                        child: ElevatedButton(
                          onPressed: canDelete
                              ? () async {
                                  setSheet(() {
                                    isDeleting = true;
                                    errorMsg = null;
                                  });
                                  final reason =
                                      selectedReason == lastReason
                                          ? customCtrl.text.trim()
                                          : selectedReason!;
                                  final err =
                                      await _deleteAccount(reason);
                                  if (err != null) {
                                    setSheet(() {
                                      isDeleting = false;
                                      errorMsg = err;
                                    });
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF5C7A),
                            disabledBackgroundColor:
                                const Color(0xFFFF5C7A),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: isDeleting
                              ? const SizedBox(
                                  width: 22, height: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation(
                                          Colors.white)))
                              : Text(l10n.deleteAccountButton,
                                  style: const TextStyle(
                                      color: Colors.white,
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

  Future<String?> _deleteAccount(String reason) async {
    final l10n = AppLocalizations.of(context);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return l10n.profileDeleteErrorUserNotFound;
      final uid = user.uid;
      final db = FirebaseFirestore.instance;

      // Supprimer toutes les sous-collections
      for (final col in [
        'revenues',
        'budget',
        'transactions',
        'objectives',
      ]) {
        final snap = await db
            .collection('users')
            .doc(uid)
            .collection(col)
            .get();
        for (final doc in snap.docs) {
          await doc.reference.delete();
        }
      }

      // Supprimer le document utilisateur
      await db.collection('users').doc(uid).delete();

      // Supprimer le compte Firebase Auth
      await user.delete();

      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
            '/login', (_) => false);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        return l10n.profileDeleteErrorSessionExpired;
      }
      return '${l10n.profileDeleteErrorAuth}: ${e.message}';
    } catch (e) {
      return l10n.profileDeleteErrorGeneric;
    }
  }

  // ── Déconnexion ───────────────────────────────────────────
  Future<void> _handleLogout() async {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF0B1535),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
              color: const Color(0xFFFF5C7A).withOpacity(0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF5C7A).withOpacity(0.1),
                ),
                child: const Icon(Icons.logout_rounded,
                    color: Color(0xFFFF5C7A), size: 26),
              ),
              const SizedBox(height: 16),
              Text(l10n.profileLogoutTitle,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(
                l10n.profileLogoutMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Color(0xFF6B8CAE), fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF1A2E52)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(l10n.cancel,
                          style: const TextStyle(
                              color: Color(0xFF8BA8D4),
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await _authService.signOut();
                        if (mounted) {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              '/login', (_) => false);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5C7A),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(l10n.profileLogout,
                          style: const TextStyle(
                              color: Colors.white,
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF060D1F),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(l10n),
              const SizedBox(height: 24),
              _buildProfileCard(),
              const SizedBox(height: 20),
              _buildStatsRow(l10n),
              const SizedBox(height: 20),

              // ── Section Compte ─────────────────────────
              _buildSectionLabel(l10n.profileSectionAccount),
              _buildSettingsGroup([
                _SettingItem(
                    icon: Icons.person_outline_rounded,
                    label: l10n.profileEditProfile,
                    color: const Color(0xFF3EFFA8),
                    onTap: _goToEditProfile),
                _SettingItem(
                    icon: Icons.notifications_outlined,
                    label: l10n.profileNotifications,
                    color: const Color(0xFF00D4FF),
                    trailing: _toggleWidget(true)),
                _SettingItem(
                    icon: Icons.lock_outline_rounded,
                    label: l10n.profileSecurity,
                    color: const Color(0xFF7B61FF),
                    onTap: () => Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (_, a, __) => SecurityScreen(),
                        transitionsBuilder: (_, a, __, child) => SlideTransition(
                          position: Tween<Offset>(
                              begin: const Offset(1, 0), end: Offset.zero)
                              .animate(CurvedAnimation(
                              parent: a, curve: Curves.easeOutCubic)),
                          child: child,
                        ),
                        transitionDuration: const Duration(milliseconds: 350),
                      ),
                    )),
              ]),
              const SizedBox(height: 16),

              // ── Section Préférences ────────────────────
              _buildSectionLabel(l10n.profileSectionPreferences),
              _buildSettingsGroup([
                _SettingItem(
                    icon: Icons.currency_exchange_rounded,
                    label: l10n.profileCurrency,
                    color: const Color(0xFFFFB340),
                    onTap: () => _showCurrencyPicker(context),
                    trailing: Consumer<CurrencyProvider>(
                      builder: (_, cur, __) => Text(
                        '${cur.selected.flag} ${cur.selected.code}',
                        style: const TextStyle(
                            color: Color(0xFFFFB340), fontSize: 13),
                      ),
                    )),
                _SettingItem(
                    icon: Icons.language_rounded,
                    label: l10n.profileLanguage,
                    color: const Color(0xFF00D4FF),
                    onTap: () => _showLanguagePicker(context),
                    trailing: Consumer<LanguageProvider>(
                      builder: (_, langProvider, __) {
                        final current = LanguageProvider.supportedLanguages
                            .firstWhere(
                              (l) => l.code == langProvider.languageCode,
                              orElse: () =>
                                  LanguageProvider.supportedLanguages.first,
                            );
                        return Text(
                          '${current.flag} ${current.label}',
                          style: const TextStyle(
                              color: Color(0xFF00D4FF), fontSize: 13),
                        );
                      },
                    )),
              ]),
              const SizedBox(height: 16),

              // ── Section Données — bouton fusionné ──────
              _buildSectionLabel(l10n.profileSectionData),
              _buildSettingsGroup([
                _SettingItem(
                  icon: Icons.cloud_upload_outlined,
                  label: l10n.profileBackup,
                  color: const Color(0xFF3EFFA8),
                  onTap: _goToBackup,
                ),
                _SettingItem(
                  icon: Icons.delete_forever_rounded,
                  label: l10n.profileDeleteAccount,
                  color: const Color(0xFFFF5C7A),
                  onTap: _showDeleteAccountSheet,
                ),
              ]),
              const SizedBox(height: 16),

              // ── Section Support ────────────────────────
              _buildSectionLabel(l10n.profileSectionSupport),
              _buildSettingsGroup([
                _SettingItem(
                    icon: Icons.help_outline_rounded,
                    label: l10n.profileHelp,
                    color: const Color(0xFF8BA8D4),
                    onTap: () => Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (_, a, __) => HelpScreen(),
                        transitionsBuilder: (_, a, __, child) => SlideTransition(
                          position: Tween<Offset>(
                              begin: const Offset(1, 0), end: Offset.zero)
                              .animate(CurvedAnimation(
                              parent: a, curve: Curves.easeOutCubic)),
                          child: child,
                        ),
                        transitionDuration: const Duration(milliseconds: 350),
                      ),
                    )),
                _SettingItem(
                    icon: Icons.gavel_rounded,
                    label: l10n.profileTermsLabel,
                    color: const Color(0xFF4A6080),
                    onTap: () => Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (_, a, __) => const TermsScreen(),
                        transitionsBuilder: (_, a, __, child) => SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(1, 0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                              parent: a, curve: Curves.easeOutCubic)),
                          child: child,
                        ),
                      ),
                    )),
                _SettingItem(
                    icon: Icons.shield_outlined,
                    label: l10n.profilePrivacyLabel,
                    color: const Color(0xFF4A6080),
                    onTap: () => Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (_, a, __) => const PrivacyScreen(),
                        transitionsBuilder: (_, a, __, child) => SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(1, 0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                              parent: a, curve: Curves.easeOutCubic)),
                          child: child,
                        ),
                      ),
                    )),
                _SettingItem(
                    icon: Icons.info_outline_rounded,
                    label: l10n.profileVersion,
                    color: const Color(0xFF3A5070),
                    showArrow: false),
              ]),
              const SizedBox(height: 24),
              _buildLogoutButton(l10n),
            ],
          ),
        ),
      ),
    );
  }

  // ── Widgets ───────────────────────────────────────────────

  Widget _buildHeader(AppLocalizations l10n) {
    return Text(
      l10n.profileTitle,
      style: const TextStyle(
          color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F2347), Color(0xFF0B1535)],
        ),
        border: Border.all(color: const Color(0xFF3EFFA8).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3EFFA8).withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF3EFFA8), Color(0xFF00D4FF)],
                  ),
                ),
                child: ClipOval(
                  child: _photoBytes != null
                      ? Image.memory(
                    _photoBytes!,
                    fit: BoxFit.cover,
                    width: 70,
                    height: 70,
                  )
                      : Center(
                    child: Text(
                      _initials,
                      style: const TextStyle(
                          color: Color(0xFF060D1F),
                          fontSize: 24,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF3EFFA8),
                    boxShadow: [
                      BoxShadow(
                          color: Color(0xFF060D1F),
                          blurRadius: 0,
                          spreadRadius: 2)
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  _email,
                  style: const TextStyle(
                      color: Color(0xFF4A6080), fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color(0xFF3EFFA8).withOpacity(0.1),
                    border: Border.all(
                        color: const Color(0xFF3EFFA8).withOpacity(0.3)),
                  ),
                  child: const Text(
                    '🎓 Étudiant(e) · Savy',
                    style: TextStyle(color: Color(0xFF3EFFA8), fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _goToEditProfile,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF1A2E52)),
                color: const Color(0xFF0D1B38),
              ),
              child: const Icon(Icons.edit_outlined,
                  color: Color(0xFF8BA8D4), size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
            child: _buildStatTile(l10n.profileObjectivesStat, '$_objectivesCount',
                Icons.flag_rounded, const Color(0xFF3EFFA8))),
        const SizedBox(width: 10),
        Expanded(
            child: _buildStatTile(l10n.profileTransactionsStat, '$_transactionsCount',
                Icons.receipt_long_rounded, const Color(0xFF00D4FF))),
        const SizedBox(width: 10),
        Expanded(
            child: _buildStatTile(l10n.profileHealthScore, '$_profileScore/100',
                Icons.favorite_rounded, const Color(0xFFFFB340))),
      ],
    );
  }

  Widget _buildStatTile(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF0B1535),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w800)),
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF4A6080), fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF3A5070),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<_SettingItem> items) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color(0xFF0B1535),
        border:
        Border.all(color: const Color(0xFF1A2E52).withOpacity(0.6)),
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          final isLast = i == items.length - 1;
          return Column(
            children: [
              GestureDetector(
                onTap: item.onTap,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: item.color.withOpacity(0.12),
                        ),
                        child: Icon(item.icon,
                            color: item.color, size: 17),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          item.label,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      if (item.trailing != null) item.trailing!,
                      if (item.trailing == null && item.showArrow)
                        const Icon(Icons.arrow_forward_ios_rounded,
                            color: Color(0xFF3A5070), size: 13),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  indent: 64,
                  color: const Color(0xFF1A2E52).withOpacity(0.4),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildLogoutButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: _handleLogout,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFFF5C7A), width: 1),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, color: Color(0xFFFF5C7A), size: 18),
            const SizedBox(width: 8),
            Text(
              l10n.profileLogout,
              style: const TextStyle(
                  color: Color(0xFFFF5C7A),
                  fontSize: 15,
                  fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _toggleWidget(bool value) {
    return Switch(
      value: value,
      onChanged: (_) {},
      activeColor: const Color(0xFF3EFFA8),
      activeTrackColor: const Color(0xFF3EFFA8).withOpacity(0.3),
      inactiveThumbColor: const Color(0xFF3A5070),
      inactiveTrackColor: const Color(0xFF1A2E52),
    );
  }
}

// ── Modèle item settings ──────────────────────────────────────
class _SettingItem {
  final IconData icon;
  final String label;
  final Color color;
  final Widget? trailing;
  final bool showArrow;
  final VoidCallback? onTap;

  const _SettingItem({
    required this.icon,
    required this.label,
    required this.color,
    this.trailing,
    this.showArrow = true,
    this.onTap,
  });
}
