import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savy/l10n/app_localizations.dart';
import '../../providers/language_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  // ── Helpers ────────────────────────────────────────────────

  static String _localizedTitle(Map<String, dynamic> data, String lang) {
    if (lang == 'fr') return (data['titleFr'] as String?)?.isNotEmpty == true ? data['titleFr'] : (data['title'] ?? '');
    if (lang == 'ar') return (data['titleAr'] as String?)?.isNotEmpty == true ? data['titleAr'] : (data['title'] ?? '');
    return (data['titleEn'] as String?)?.isNotEmpty == true ? data['titleEn'] : (data['title'] ?? '');
  }

  static String _localizedBody(Map<String, dynamic> data, String lang) {
    if (lang == 'fr') return (data['bodyFr'] as String?)?.isNotEmpty == true ? data['bodyFr'] : (data['body'] ?? '');
    if (lang == 'ar') return (data['bodyAr'] as String?)?.isNotEmpty == true ? data['bodyAr'] : (data['body'] ?? '');
    return (data['bodyEn'] as String?)?.isNotEmpty == true ? data['bodyEn'] : (data['body'] ?? '');
  }

  static String _formatTime(DateTime dt, AppLocalizations l10n) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1)  return l10n.notifTimeJustNow;
    if (diff.inMinutes < 60) return l10n.notifTimeMinutes(diff.inMinutes);
    if (diff.inHours   < 24) return l10n.notifTimeHours(diff.inHours);
    return l10n.notifTimeDays(diff.inDays);
  }

  static IconData _iconForType(String type) {
    switch (type) {
      case 'budget_alert':      return Icons.account_balance_wallet_rounded;
      case 'goal_reminder':     return Icons.flag_rounded;
      case 'goal_completion':   return Icons.emoji_events_rounded;
      case 'saving_suggestion': return Icons.lightbulb_rounded;
      case 'password_changed':  return Icons.lock_rounded;
      default:                  return Icons.notifications_rounded;
    }
  }

  static Color _colorForType(String type) {
    switch (type) {
      case 'budget_alert':      return const Color(0xFFFFB340);
      case 'goal_reminder':     return const Color(0xFF7B61FF);
      case 'goal_completion':   return const Color(0xFF3EFFA8);
      case 'saving_suggestion': return const Color(0xFF00D4FF);
      case 'password_changed':  return const Color(0xFFFF5C7A);
      default:                  return const Color(0xFF8BA8D4);
    }
  }

  // ── Firestore actions ──────────────────────────────────────

  static Future<void> _markAllRead(String uid) async {
    final snap = await FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: uid)
        .where('read', isEqualTo: false)
        .get();
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }

  static Future<void> _deleteAll(String uid) async {
    final snap = await FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: uid)
        .get();
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // ── Dialogs ────────────────────────────────────────────────

  static Future<void> _showDeleteAllDialog(
      BuildContext context, AppLocalizations l10n, String uid) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => _ConfirmDialog(
        icon: Icons.delete_sweep_rounded,
        iconColor: const Color(0xFFFF5C7A),
        title: l10n.notificationsDeleteAllTitle,
        desc: l10n.notificationsDeleteAllDesc,
        confirmLabel: l10n.notificationsDeleteAll,
        cancelLabel: l10n.notificationsCancel,
      ),
    );
    if (confirmed == true) await _deleteAll(uid);
  }

  // ── Build ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n     = AppLocalizations.of(context);
    final uid      = FirebaseAuth.instance.currentUser?.uid;
    final langCode = Provider.of<LanguageProvider>(context, listen: false).languageCode;

    if (uid == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF060D1F),
        appBar: _appBar(context, l10n, false, false, ''),
        body: _emptyState(l10n),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: const Color(0xFF060D1F),
            appBar: _appBar(context, l10n, false, false, uid),
            body: const Center(
                child: CircularProgressIndicator(color: Color(0xFF3EFFA8))),
          );
        }

        final docs      = snap.data?.docs ?? [];
        final hasAny    = docs.isNotEmpty;
        final hasUnread = docs.any((d) => !(d['read'] as bool? ?? false));

        // Group today vs earlier
        final today   = <QueryDocumentSnapshot>[];
        final earlier = <QueryDocumentSnapshot>[];
        final now     = DateTime.now();
        for (final doc in docs) {
          final ts = (doc['createdAt'] as Timestamp?)?.toDate();
          if (ts != null &&
              ts.year == now.year &&
              ts.month == now.month &&
              ts.day == now.day) {
            today.add(doc);
          } else {
            earlier.add(doc);
          }
        }

        return Scaffold(
          backgroundColor: const Color(0xFF060D1F),
          appBar: _appBar(context, l10n, hasUnread, hasAny, uid),
          body: !hasAny
              ? _emptyState(l10n)
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                  children: [
                    if (today.isNotEmpty) ...[
                      _sectionHeader(l10n.notificationsToday),
                      ...today.map((d) => _DismissibleCard(
                          doc: d, langCode: langCode, l10n: l10n)),
                    ],
                    if (earlier.isNotEmpty) ...[
                      _sectionHeader(l10n.notificationsEarlier),
                      ...earlier.map((d) => _DismissibleCard(
                          doc: d, langCode: langCode, l10n: l10n)),
                    ],
                  ],
                ),
        );
      },
    );
  }

  AppBar _appBar(BuildContext context, AppLocalizations l10n,
      bool hasUnread, bool hasAny, String uid) {
    return AppBar(
      backgroundColor: const Color(0xFF060D1F),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.white, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(l10n.notificationsPageTitle,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700)),
      centerTitle: true,
      actions: [
        if (hasUnread)
          IconButton(
            icon: const Icon(Icons.done_all_rounded,
                color: Color(0xFF3EFFA8), size: 22),
            tooltip: l10n.notificationsMarkAllRead,
            onPressed: () => _markAllRead(uid),
          ),
        if (hasAny)
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: Color(0xFFFF5C7A), size: 22),
            tooltip: l10n.notificationsDeleteAll,
            onPressed: () => _showDeleteAllDialog(context, l10n, uid),
          ),
      ],
    );
  }

  Widget _emptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF0D1B38),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF1A2E52)),
            ),
            child: const Icon(Icons.notifications_off_outlined,
                color: Color(0xFF4A6080), size: 36),
          ),
          const SizedBox(height: 16),
          Text(l10n.notificationsEmpty,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(l10n.notificationsEmptyDesc,
              style: const TextStyle(
                  color: Color(0xFF4A6080), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8, left: 4),
      child: Text(text,
          style: const TextStyle(
              color: Color(0xFF4A6080),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8)),
    );
  }
}

// ── Dismissible wrapper ───────────────────────────────────────
class _DismissibleCard extends StatelessWidget {
  final QueryDocumentSnapshot doc;
  final String langCode;
  final AppLocalizations l10n;

  const _DismissibleCard({
    required this.doc,
    required this.langCode,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(doc.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => doc.reference.delete(),
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFF5C7A).withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: const Color(0xFFFF5C7A).withOpacity(0.3)),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.delete_rounded,
                color: Color(0xFFFF5C7A), size: 22),
            const SizedBox(height: 4),
            Text(l10n.notificationsDelete,
                style: const TextStyle(
                    color: Color(0xFFFF5C7A),
                    fontSize: 10,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      child: _NotifCard(doc: doc, langCode: langCode, l10n: l10n),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => _ConfirmDialog(
        icon: Icons.delete_rounded,
        iconColor: const Color(0xFFFF5C7A),
        title: l10n.notificationsDeleteTitle,
        desc: l10n.notificationsDeleteDesc,
        confirmLabel: l10n.notificationsDelete,
        cancelLabel: l10n.notificationsCancel,
      ),
    );
  }
}

// ── Improved notification card ────────────────────────────────
class _NotifCard extends StatelessWidget {
  final QueryDocumentSnapshot doc;
  final String langCode;
  final AppLocalizations l10n;

  const _NotifCard({
    required this.doc,
    required this.langCode,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final data   = doc.data() as Map<String, dynamic>;
    final isRead = data['read'] as bool? ?? false;
    final type   = data['type'] as String? ?? '';
    final ts     = (data['createdAt'] as Timestamp?)?.toDate();
    final title  = NotificationsScreen._localizedTitle(data, langCode);
    final body   = NotificationsScreen._localizedBody(data, langCode);
    final color  = NotificationsScreen._colorForType(type);

    return GestureDetector(
      onTap: () {
        if (!isRead) doc.reference.update({'read': true});
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF0D1B38),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isRead
                ? const Color(0xFF1A2E52)
                : color.withOpacity(0.45),
            width: isRead ? 0.5 : 1.0,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Colored left stripe for unread
                if (!isRead)
                  Container(width: 3, color: color),

                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        isRead ? 14 : 11, 12, 14, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon badge
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Icon(
                              NotificationsScreen._iconForType(type),
                              color: color, size: 18),
                        ),
                        const SizedBox(width: 12),

                        // Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title row
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(title,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            height: 1.3,
                                            fontWeight: isRead
                                                ? FontWeight.w500
                                                : FontWeight.w700)),
                                  ),
                                  if (!isRead) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 7, height: 7,
                                      margin: const EdgeInsets.only(top: 3),
                                      decoration: BoxDecoration(
                                          color: color,
                                          shape: BoxShape.circle),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 5),

                              // Body
                              Text(body,
                                  style: TextStyle(
                                      color: isRead
                                          ? const Color(0xFF4A6080)
                                          : const Color(0xFF8BA8D4),
                                      fontSize: 12,
                                      height: 1.45),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),

                              // Timestamp
                              if (ts != null) ...[
                                const SizedBox(height: 7),
                                Row(
                                  children: [
                                    Icon(
                                      isRead
                                          ? Icons.check_rounded
                                          : Icons.access_time_rounded,
                                      size: 11,
                                      color: isRead
                                          ? const Color(0xFF3EFFA8)
                                          : const Color(0xFF4A6080),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      NotificationsScreen._formatTime(ts, l10n),
                                      style: TextStyle(
                                          color: isRead
                                              ? const Color(0xFF3A5070)
                                              : const Color(0xFF4A6080),
                                          fontSize: 11),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Reusable confirmation dialog ──────────────────────────────
class _ConfirmDialog extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String desc;
  final String confirmLabel;
  final String cancelLabel;

  const _ConfirmDialog({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.desc,
    required this.confirmLabel,
    required this.cancelLabel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF0D1B38),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      title: Row(children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: iconColor, size: 17),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700)),
        ),
      ]),
      content: Text(desc,
          style: const TextStyle(
              color: Color(0xFF8BA8D4), fontSize: 13, height: 1.5)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelLabel,
              style: const TextStyle(
                  color: Color(0xFF4A6080), fontWeight: FontWeight.w500)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(
            backgroundColor: iconColor.withOpacity(0.1),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(confirmLabel,
              style: TextStyle(
                  color: iconColor, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}
