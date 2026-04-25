import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:savy/l10n/app_localizations.dart';

// ── Preference keys ───────────────────────────────────────────
const _kBudgetAlert       = 'notif_budget_alert';
const _kGoalReminder      = 'notif_goal_reminder';
const _kGoalCompletion    = 'notif_goal_completion';
const _kSavingSuggestion  = 'notif_saving_suggestion';
const _kSecurityAlert     = 'notif_security_alert';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _budgetAlert      = true;
  bool _goalReminder     = true;
  bool _goalCompletion   = true;
  bool _savingSuggestion = true;
  bool _securityAlert    = true;
  bool _loading          = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _budgetAlert      = p.getBool(_kBudgetAlert)      ?? true;
      _goalReminder     = p.getBool(_kGoalReminder)     ?? true;
      _goalCompletion   = p.getBool(_kGoalCompletion)   ?? true;
      _savingSuggestion = p.getBool(_kSavingSuggestion) ?? true;
      _securityAlert    = p.getBool(_kSecurityAlert)    ?? true;
      _loading          = false;
    });
  }

  Future<void> _save(String key, bool value) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(key, value);
  }

  bool get _allEnabled =>
      _budgetAlert && _goalReminder && _goalCompletion && _savingSuggestion;

  void _toggleAll(bool value) {
    setState(() {
      _budgetAlert      = value;
      _goalReminder     = value;
      _goalCompletion   = value;
      _savingSuggestion = value;
    });
    _save(_kBudgetAlert,       value);
    _save(_kGoalReminder,      value);
    _save(_kGoalCompletion,    value);
    _save(_kSavingSuggestion,  value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF060D1F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF060D1F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.notifSettingsTitle,
          style: const TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF3EFFA8)))
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              children: [
                // ── Enable all ─────────────────────────────
                _buildCard([
                  _NotifTile(
                    icon: Icons.notifications_rounded,
                    iconColor: const Color(0xFF3EFFA8),
                    title: l10n.notifSettingsEnableAll,
                    value: _allEnabled,
                    onChanged: _toggleAll,
                  ),
                ]),
                const SizedBox(height: 20),

                // ── Individual toggles ──────────────────────
                _buildCard([
                  _NotifTile(
                    icon: Icons.account_balance_wallet_rounded,
                    iconColor: const Color(0xFFFFB340),
                    title: l10n.notifSettingsBudgetAlert,
                    subtitle: l10n.notifSettingsBudgetAlertDesc,
                    value: _budgetAlert,
                    onChanged: (v) {
                      setState(() => _budgetAlert = v);
                      _save(_kBudgetAlert, v);
                    },
                  ),
                  _divider(),
                  _NotifTile(
                    icon: Icons.flag_rounded,
                    iconColor: const Color(0xFF7B61FF),
                    title: l10n.notifSettingsGoalReminder,
                    subtitle: l10n.notifSettingsGoalReminderDesc,
                    value: _goalReminder,
                    onChanged: (v) {
                      setState(() => _goalReminder = v);
                      _save(_kGoalReminder, v);
                    },
                  ),
                  _divider(),
                  _NotifTile(
                    icon: Icons.emoji_events_rounded,
                    iconColor: const Color(0xFF3EFFA8),
                    title: l10n.notifSettingsGoalCompletion,
                    subtitle: l10n.notifSettingsGoalCompletionDesc,
                    value: _goalCompletion,
                    onChanged: (v) {
                      setState(() => _goalCompletion = v);
                      _save(_kGoalCompletion, v);
                    },
                  ),
                  _divider(),
                  _NotifTile(
                    icon: Icons.lightbulb_rounded,
                    iconColor: const Color(0xFF00D4FF),
                    title: l10n.notifSettingsSavingSuggestion,
                    subtitle: l10n.notifSettingsSavingSuggestionDesc,
                    value: _savingSuggestion,
                    onChanged: (v) {
                      setState(() => _savingSuggestion = v);
                      _save(_kSavingSuggestion, v);
                    },
                  ),
                ]),
                const SizedBox(height: 20),

                // ── Section Sécurité ───────────────────────
                _sectionLabel(l10n.notifSettingsSectionSecurity),
                const SizedBox(height: 8),
                _buildCard([
                  _NotifTile(
                    icon: Icons.lock_rounded,
                    iconColor: const Color(0xFFFF5C7A),
                    title: l10n.notifSettingsSecurityAlert,
                    subtitle: l10n.notifSettingsSecurityAlertDesc,
                    value: _securityAlert,
                    onChanged: (v) {
                      setState(() => _securityAlert = v);
                      _save(_kSecurityAlert, v);
                    },
                  ),
                ]),
              ],
            ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B38),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1A2E52)),
      ),
      child: Column(children: children),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF3A5070),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      );

  Widget _divider() => const Divider(
        height: 1, thickness: 1,
        indent: 56, endIndent: 16,
        color: Color(0xFF1A2E52),
      );
}

// ── Individual toggle tile ────────────────────────────────────
class _NotifTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotifTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!,
                      style: const TextStyle(
                          color: Color(0xFF4A6080), fontSize: 11)),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF3EFFA8),
            activeTrackColor: const Color(0xFF3EFFA8).withOpacity(0.3),
            inactiveThumbColor: const Color(0xFF3A5070),
            inactiveTrackColor: const Color(0xFF1A2E52),
          ),
        ],
      ),
    );
  }
}
