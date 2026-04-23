import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:savy/l10n/app_localizations.dart';
import 'package:savy/providers/language_provider.dart';

// ══════════════════════════════════════════════════════════════
//  WIDGET – LanguageSwitcherButton
//  lib/widgets/language_switcher_button.dart
//
//  Pill button showing the active language flag + code.
//  Tap opens a bottom sheet to switch between FR / EN / AR.
//  Uses LanguageProvider → persisted via SharedPreferences.
//  RTL (Arabic) is handled automatically by main.dart's
//  Directionality wrapper; no extra work needed here.
// ══════════════════════════════════════════════════════════════

class LanguageSwitcherButton extends StatelessWidget {
  const LanguageSwitcherButton({super.key});

  @override
  Widget build(BuildContext context) {
    final langProvider = context.watch<LanguageProvider>();
    final currentCode = langProvider.languageCode;

    // Find the active language option to show its flag
    final current = LanguageProvider.supportedLanguages.firstWhere(
      (l) => l.code == currentCode,
      orElse: () => LanguageProvider.supportedLanguages.first,
    );

    return SafeArea(
      child: Align(
        // Always physical top-right regardless of RTL
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.only(top: 12, right: 16),
          child: GestureDetector(
            onTap: () => _showPicker(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xFF0D1B38).withOpacity(0.90),
                border: Border.all(color: const Color(0xFF1A2E52), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(current.flag, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(
                    current.code.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF3EFFA8),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF8BA8D4),
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentCode = context.read<LanguageProvider>().languageCode;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0B1535),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Handle bar ──────────────────────────────────
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2E52),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // ── Title ───────────────────────────────────────
              Text(
                l10n.langPickerTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 20),

              // ── Language options ─────────────────────────────
              ...LanguageProvider.supportedLanguages.map((lang) {
                final isSelected = lang.code == currentCode;
                return GestureDetector(
                  onTap: () {
                    // Update locale via provider → SharedPreferences + notifyListeners
                    context.read<LanguageProvider>().setLocale(lang.code);
                    Navigator.of(sheetCtx).pop();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: isSelected
                          ? const Color(0xFF3EFFA8).withOpacity(0.08)
                          : const Color(0xFF0D1B38),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF3EFFA8).withOpacity(0.4)
                            : const Color(0xFF1A2E52),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(lang.flag,
                            style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            lang.nativeLabel,
                            style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFF3EFFA8)
                                  : Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle_rounded,
                              color: Color(0xFF3EFFA8), size: 20),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
