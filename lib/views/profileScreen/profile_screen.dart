import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════════════
//  SAVVY – PROFILE SCREEN
//  Profil étudiant, paramètres, statistiques personnelles
// ══════════════════════════════════════════════════════════════

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
                    color: const Color(0xFF3EFFA8)),
                _SettingItem(
                    icon: Icons.notifications_outlined,
                    label: 'Notifications',
                    color: const Color(0xFF00D4FF),
                    trailing: _toggleWidget(true)),
                _SettingItem(
                    icon: Icons.lock_outline_rounded,
                    label: 'Sécurité et mot de passe',
                    color: const Color(0xFF7B61FF)),
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
                    color: const Color(0xFF4A6080)),
                _SettingItem(
                    icon: Icons.shield_outlined,
                    label: 'Politique de confidentialité',
                    color: const Color(0xFF4A6080)),
                _SettingItem(
                    icon: Icons.info_outline_rounded,
                    label: 'Version 1.0.0',
                    color: const Color(0xFF3A5070),
                    showArrow: false),
              ]),
              const SizedBox(height: 24),
              _buildLogoutButton(context),
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
        border: Border.all(
            color: const Color(0xFF3EFFA8).withOpacity(0.2)),
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
          // Avatar
          Stack(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3EFFA8), Color(0xFF00D4FF)],
                  ),
                ),
                child: const Center(
                  child: Text(
                    'ZA',
                    style: TextStyle(
                        color: Color(0xFF060D1F),
                        fontSize: 24,
                        fontWeight: FontWeight.w800),
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
                const Text(
                  'Zeineb Aouinti',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                const Text(
                  'zeineb.aouinti@student.edu',
                  style: TextStyle(color: Color(0xFF4A6080), fontSize: 12),
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
                    '🎓 Étudiante · 3ème année BI',
                    style:
                    TextStyle(color: Color(0xFF3EFFA8), fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {},
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
            child: _buildStatTile(
                'Objectifs', '3', Icons.flag_rounded,
                const Color(0xFF3EFFA8))),
        const SizedBox(width: 10),
        Expanded(
            child: _buildStatTile(
                'Transactions', '47', Icons.receipt_long_rounded,
                const Color(0xFF00D4FF))),
        const SizedBox(width: 10),
        Expanded(
            child: _buildStatTile(
                'Score', '74/100', Icons.favorite_rounded,
                const Color(0xFFFFB340))),
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
        border: Border.all(color: const Color(0xFF1A2E52).withOpacity(0.6)),
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          final isLast = i == items.length - 1;
          return Column(
            children: [
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: item.color.withOpacity(0.12),
                      ),
                      child: Icon(item.icon, color: item.color, size: 17),
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

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: () {
          // TODO: logout Firebase
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/login', (_) => false);
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFFF5C7A), width: 1),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
  const _SettingItem({
    required this.icon,
    required this.label,
    required this.color,
    this.trailing,
    this.showArrow = true,
  });
}