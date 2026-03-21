import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import 'edit_profile_screen.dart';
import '../legalScreen/legal_screens.dart';

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

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadPhotoFromFirestore();
  }

  void _loadUserData() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _name = user.displayName ?? 'Utilisateur';
        _email = user.email ?? '';
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

      if (doc.exists && doc.data()?['photoBase64'] != null) {
        final base64Str = doc.data()!['photoBase64'] as String;
        final bytes = base64Decode(base64Str);
        if (mounted) setState(() => _photoBytes = Uint8List.fromList(bytes));
      }
    } catch (_) {}
  }

  // ── Naviguer vers EditProfileScreen ──────────────────────
  Future<void> _goToEditProfile() async {
    final result = await Navigator.of(context).push<Map<String, String>>(
      PageRouteBuilder(
        pageBuilder: (_, a, __) => EditProfileScreen(
          currentName: _name,
          currentEmail: _email,
        ),
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

    // Met à jour les données si modifiées
    if (result != null) {
      setState(() {
        _name = result['name'] ?? _name;
        _email = result['email'] ?? _email;
        _initials = _getInitials(_name);
      });
      // Recharge la photo depuis Firestore
      await _loadPhotoFromFirestore();
    }
  }

  // ── Déconnexion ───────────────────────────────────────────
  Future<void> _handleLogout() async {
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
              const Text('Se déconnecter ?',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Text(
                'Vous devrez vous reconnecter pour accéder à vos données.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF6B8CAE), fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  // Annuler
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF1A2E52)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Annuler',
                          style: TextStyle(
                              color: Color(0xFF8BA8D4),
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Confirmer
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
                      child: const Text('Déconnecter',
                          style: TextStyle(
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
    return Scaffold(
      backgroundColor: const Color(0xFF060D1F),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildProfileCard(),
              const SizedBox(height: 20),
              _buildStatsRow(),
              const SizedBox(height: 20),
              _buildSectionLabel('Compte'),
              _buildSettingsGroup([
                _SettingItem(
                    icon: Icons.person_outline_rounded,
                    label: 'Modifier le profil',
                    color: const Color(0xFF3EFFA8),
                    onTap: _goToEditProfile),
                _SettingItem(
                    icon: Icons.notifications_outlined,
                    label: 'Notifications',
                    color: const Color(0xFF00D4FF),
                    trailing: _toggleWidget(true)),
                _SettingItem(
                    icon: Icons.lock_outline_rounded,
                    label: 'Sécurité et mot de passe',
                    color: const Color(0xFF7B61FF),
                    onTap: _goToEditProfile),
              ]),
              const SizedBox(height: 16),
              _buildSectionLabel('Préférences'),
              _buildSettingsGroup([
                _SettingItem(
                    icon: Icons.currency_exchange_rounded,
                    label: 'Devise',
                    color: const Color(0xFFFFB340),
                    trailing: const Text('TND',
                        style: TextStyle(
                            color: Color(0xFFFFB340), fontSize: 13))),
                _SettingItem(
                    icon: Icons.dark_mode_outlined,
                    label: 'Thème sombre',
                    color: const Color(0xFF8BA8D4),
                    trailing: _toggleWidget(true)),
                _SettingItem(
                    icon: Icons.language_rounded,
                    label: 'Langue',
                    color: const Color(0xFF00D4FF),
                    trailing: const Text('Français',
                        style: TextStyle(
                            color: Color(0xFF00D4FF), fontSize: 13))),
              ]),
              const SizedBox(height: 16),
              _buildSectionLabel('Données'),
              _buildSettingsGroup([
                _SettingItem(
                    icon: Icons.cloud_upload_outlined,
                    label: 'Sauvegarder les données',
                    color: const Color(0xFF3EFFA8)),
                _SettingItem(
                    icon: Icons.download_rounded,
                    label: 'Exporter en CSV',
                    color: const Color(0xFF00D4FF)),
                _SettingItem(
                    icon: Icons.delete_outline_rounded,
                    label: 'Supprimer les données',
                    color: const Color(0xFFFF5C7A)),
              ]),
              const SizedBox(height: 16),
              _buildSectionLabel('Support'),
              _buildSettingsGroup([
                _SettingItem(
                    icon: Icons.help_outline_rounded,
                    label: 'Aide et FAQ',
                    color: const Color(0xFF8BA8D4)),
                _SettingItem(
                    icon: Icons.gavel_rounded,
                    label: 'Conditions d\'utilisation',
                    color: const Color(0xFF4A6080),
                    onTap: () => Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (_, a, __) => const TermsScreen(),
                        transitionsBuilder: (_, a, __, child) =>
                            SlideTransition(
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
                    label: 'Politique de confidentialité',
                    color: const Color(0xFF4A6080),
                    onTap: () => Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (_, a, __) => const PrivacyScreen(),
                        transitionsBuilder: (_, a, __, child) =>
                            SlideTransition(
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
                    label: 'Version 1.0.0',
                    color: const Color(0xFF3A5070),
                    showArrow: false),
              ]),
              const SizedBox(height: 24),
              _buildLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Text(
      'Profil',
      style: TextStyle(
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
          // Avatar avec initiales Firebase
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
                // Nom depuis Firebase
                Text(
                  _name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                // Email depuis Firebase
                Text(
                  _email,
                  style: const TextStyle(
                      color: Color(0xFF4A6080), fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color(0xFF3EFFA8).withOpacity(0.1),
                    border: Border.all(
                        color: const Color(0xFF3EFFA8).withOpacity(0.3)),
                  ),
                  child: const Text(
                    '🎓 Étudiant(e) · Savy',
                    style: TextStyle(
                        color: Color(0xFF3EFFA8), fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
          // Bouton modifier
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

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
            child: _buildStatTile('Objectifs', '3',
                Icons.flag_rounded, const Color(0xFF3EFFA8))),
        const SizedBox(width: 10),
        Expanded(
            child: _buildStatTile('Transactions', '47',
                Icons.receipt_long_rounded, const Color(0xFF00D4FF))),
        const SizedBox(width: 10),
        Expanded(
            child: _buildStatTile('Score', '74/100',
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

  Widget _buildLogoutButton() {
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
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFFF5C7A), size: 18),
            SizedBox(width: 8),
            Text(
              'Se déconnecter',
              style: TextStyle(
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