import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Maps a category's canonical `iconName` (stored in Firestore) to the
/// localized display name, or falls back to the stored raw name for
/// user-created custom categories.
class CategoryTranslator {
  // ── iconName → localized string ───────────────────────────────
  static String byIconName(String iconName, AppLocalizations l10n) {
    switch (iconName) {
      case 'restaurant':     return l10n.catFood;
      case 'directions_bus': return l10n.catTransport;
      case 'movie':          return l10n.catLeisure;
      case 'menu_book':      return l10n.catAcademic;
      case 'favorite':       return l10n.catHealth;
      case 'category':       return l10n.catOther;
      case 'trending_up':    return l10n.transactionsRevenueBadge;
      default:               return iconName;
    }
  }

  // ── iconName → IconData ────────────────────────────────────────
  static IconData iconDataFor(String iconName) {
    switch (iconName) {
      case 'restaurant':     return Icons.restaurant_rounded;
      case 'directions_bus': return Icons.directions_bus_rounded;
      case 'movie':          return Icons.movie_rounded;
      case 'menu_book':      return Icons.menu_book_rounded;
      case 'favorite':       return Icons.local_pharmacy_rounded;
      case 'trending_up':    return Icons.trending_up_rounded;
      default:               return Icons.shopping_cart_outlined;
    }
  }

  // ── iconName → Color ───────────────────────────────────────────
  static Color colorFor(String iconName) {
    switch (iconName) {
      case 'restaurant':     return const Color(0xFFFFB340);
      case 'directions_bus': return const Color(0xFF00D4FF);
      case 'movie':          return const Color(0xFFFF5C7A);
      case 'menu_book':      return const Color(0xFF7B61FF);
      case 'favorite':       return const Color(0xFF3EFFA8);
      case 'trending_up':    return const Color(0xFF3EFFA8);
      default:               return const Color(0xFF8BA8D4);
    }
  }

  // ── French legacy name → iconName ─────────────────────────────
  static String? _nameToIconName(String name) {
    switch (name.toLowerCase()) {
      case 'alimentation':  return 'restaurant';
      case 'transport':     return 'directions_bus';
      case 'loisirs':       return 'movie';
      case 'académique':    return 'menu_book';
      case 'santé':         return 'favorite';
      case 'autres':
      case 'autre':         return 'category';
      case 'revenu':
      case 'income':
      case 'دخل':           return 'trending_up';
      default:              return null;
    }
  }

  /// Translate any stored category value — handles both the new iconName
  /// format ('restaurant') and the legacy French name ('Alimentation').
  static String byStoredName(String name, AppLocalizations l10n) {
    // New format: value is already an iconName
    final direct = byIconName(name, l10n);
    if (direct != name) return direct;
    // Legacy format: French display name
    final key = _nameToIconName(name);
    if (key != null) return byIconName(key, l10n);
    return name;
  }

  /// Returns the icon for any stored category value (iconName or French legacy).
  static IconData iconFor(String name, {bool isIncome = false}) {
    if (isIncome) return Icons.trending_up_rounded;
    final direct = iconDataFor(name);
    if (direct != Icons.shopping_cart_outlined) return direct;
    final key = _nameToIconName(name);
    return key != null ? iconDataFor(key) : Icons.shopping_cart_outlined;
  }

  /// Returns the color for any stored category value (iconName or French legacy).
  static Color colorForName(String name, {bool isIncome = false}) {
    if (isIncome) return const Color(0xFF3EFFA8);
    final direct = colorFor(name);
    if (direct != const Color(0xFF8BA8D4)) return direct;
    final key = _nameToIconName(name);
    return key != null ? colorFor(key) : const Color(0xFF8BA8D4);
  }

  /// Returns the display title for a transaction.
  ///
  /// - Empty label → translated category name.
  /// - Legacy French auto-label `'Dépense Académique'` → translated category name.
  /// - User-typed label → returned as-is.
  static String resolveLabel(
      String label, String category, AppLocalizations l10n) {
    if (label.isEmpty) return byStoredName(category, l10n);

    // Detect legacy French auto-generated labels: "Dépense <categoryName>"
    const prefix = 'Dépense ';
    if (label.startsWith(prefix)) {
      final suffix = label.substring(prefix.length);
      final translated = byStoredName(suffix, l10n);
      if (translated != suffix) return translated; // known category
    }

    return label;
  }
}
