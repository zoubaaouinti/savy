import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

// Import avec chemin correct selon ton architecture
// lib/views/profileScreen/backup/backup_screen.dart
// donc lib/models = ../../../models
// et lib/services = ../../../services
import '../../../models/export_models.dart';
import '../../../services/export_service.dart';

// ══════════════════════════════════════════════════════════════
//  SAVVY – BACKUP SCREEN
//  lib/views/profileScreen/backup/backup_screen.dart
// ══════════════════════════════════════════════════════════════

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen>
    with TickerProviderStateMixin {

  final Set<ExportSection> _selectedSections = {
    ExportSection.budget,
    ExportSection.transactions,
    ExportSection.objectives,
    ExportSection.revenues,
  };

  ExportFormat _selectedFormat = ExportFormat.pdf;
  bool _isLoading = false;
  String? _errorMessage;

  late final AnimationController _bgController;
  late final Animation<double> _bgAnim;

  IconData _iconFromName(String name) {
    const map = {
      'person':      Icons.person_rounded,
      'wallet':      Icons.account_balance_wallet_rounded,
      'receipt':     Icons.receipt_long_rounded,
      'flag':        Icons.flag_rounded,
      'trending_up': Icons.trending_up_rounded,
    };
    return map[name] ?? Icons.circle;
  }

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
        vsync: this, duration: const Duration(seconds: 8))
      ..repeat(reverse: true);
    _bgAnim =
        CurvedAnimation(parent: _bgController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  UserDataSnapshot _getUserData() {
    final user = FirebaseAuth.instance.currentUser;
    return ExportService.getMockData(
      user?.displayName ?? 'Utilisateur',
      user?.email ?? '',
    );
  }

  Future<void> _previewPdf() async {
    if (_selectedSections.isEmpty) {
      setState(() => _errorMessage = 'Sélectionnez au moins une section');
      return;
    }
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final data = _getUserData();
      final result = await ExportService.exportPdf(data, _selectedSections.toList());

      // 🔍 DEBUG : Affiche toutes les propriétés de result
      print('Result: $result');
      print('isSuccess: ${result.isSuccess}');
      print('filePath: ${result.filePath}');
      print('errorMessage: ${result.errorMessage}');
      print('Runtime type: ${result.runtimeType}');

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result.isSuccess && result.filePath != null) {
        print('✅ Fichier généré: ${result.filePath}');
        await Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => _PdfPreviewScreen(
            filePath: result.filePath!,
            data: data,
            sections: _selectedSections.toList(),
          ),
        ));
      } else {
        setState(() => _errorMessage = result.errorMessage ?? 'Erreur inconnue');
      }
    } catch (e) {
      print('❌ Erreur: $e');
      setState(() { _isLoading = false; _errorMessage = e.toString(); });
    }
  }

  Future<void> _exportCsv() async {
    if (_selectedSections.isEmpty) {
      setState(() => _errorMessage = 'Sélectionnez au moins une section');
      return;
    }
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final data = _getUserData();
      final result = await ExportService.exportCsv(data, _selectedSections.toList());
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result.isSuccess && result.filePath != null) {
        // Partager le fichier - fonctionne sans permissions
        await Share.shareXFiles(
          [XFile(result.filePath!)],
          subject: 'Savy - Export CSV',
          text: 'Voici mon export CSV depuis Savy',
        );

        // Message de confirmation
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Color(0xFF3EFFA8), size: 20),
                  SizedBox(width: 12),
                  Text('Fichier CSV généré avec succès'),
                ],
              ),
              backgroundColor: Color(0xFF0B1535),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        setState(() => _errorMessage = result.errorMessage ?? 'Erreur inconnue');
      }
    } catch (e) {
      setState(() { _isLoading = false; _errorMessage = e.toString(); });
    }
  }

  Future<void> _handleExport() async {
    if (_selectedFormat == ExportFormat.pdf) {
      await _previewPdf();
    } else {
      await _exportCsv();
    }
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
            builder: (_, __) =>
                CustomPaint(size: size, painter: _BgPainter(_bgAnim.value)),
          ),
          CustomPaint(size: size, painter: _GridPainter()),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildIntroCard(),
                        const SizedBox(height: 24),
                        _sectionTitle('Format d\'export'),
                        const SizedBox(height: 12),
                        _buildFormatSelector(),
                        const SizedBox(height: 24),
                        _sectionTitle('Données à inclure'),
                        const SizedBox(height: 12),
                        _buildSectionsSelector(),
                        const SizedBox(height: 24),
                        _buildPreviewCard(),
                        const SizedBox(height: 20),
                        if (_errorMessage != null) _alertWidget(_errorMessage!),
                        const SizedBox(height: 8),
                        _buildExportButton(),
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

  Widget _buildTopBar(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
    child: Row(children: [
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
        child: const Text('Sauvegarder les données',
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
        child: const Icon(Icons.cloud_upload_outlined,
            color: Color(0xFF060D1F), size: 20),
      ),
    ]),
  );

  Widget _buildIntroCard() => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      gradient: LinearGradient(colors: [
        const Color(0xFF3EFFA8).withOpacity(0.08),
        const Color(0xFF00D4FF).withOpacity(0.05),
      ]),
      border: Border.all(color: const Color(0xFF3EFFA8).withOpacity(0.2)),
    ),
    child: const Row(children: [
      Icon(Icons.info_outline_rounded, color: Color(0xFF3EFFA8), size: 22),
      SizedBox(width: 14),
      Expanded(
        child: Text(
          'Exportez vos données financières en PDF ou CSV. Sélectionnez les sections souhaitées puis visualisez l\'aperçu avant de télécharger.',
          style: TextStyle(color: Color(0xFF8BA8D4), fontSize: 12, height: 1.5),
        ),
      ),
    ]),
  );

  Widget _buildFormatSelector() => Row(
    children: ExportFormat.values.map((format) {
      final isSelected = _selectedFormat == format;
      final isPdf = format == ExportFormat.pdf;
      final color = isPdf ? const Color(0xFFFF5C7A) : const Color(0xFF3EFFA8);
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _selectedFormat = format),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: EdgeInsets.only(right: isPdf ? 8 : 0),
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isSelected ? color.withOpacity(0.1) : const Color(0xFF0B1535),
              border: Border.all(
                  color: isSelected ? color : const Color(0xFF1A2E52),
                  width: isSelected ? 1.5 : 1),
            ),
            child: Column(children: [
              Icon(
                isPdf ? Icons.picture_as_pdf_rounded : Icons.table_chart_rounded,
                color: isSelected ? color : const Color(0xFF4A6080),
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(isPdf ? 'PDF' : 'CSV',
                  style: TextStyle(
                      color: isSelected ? color : const Color(0xFF6B8CAE),
                      fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(isPdf ? 'Rapport formaté' : 'Données brutes',
                  style: const TextStyle(color: Color(0xFF4A6080), fontSize: 11)),
              if (isSelected) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: color.withOpacity(0.15),
                  ),
                  child: Text('Sélectionné',
                      style: TextStyle(color: color, fontSize: 10,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ]),
          ),
        ),
      );
    }).toList(),
  );

  Widget _buildSectionsSelector() {
    final filteredSections = ExportSection.values
        .where((s) => s != ExportSection.profile)
        .toList();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color(0xFF0B1535),
        border: Border.all(color: const Color(0xFF1A2E52).withOpacity(0.6)),
      ),
      child: Column(
        children: List.generate(filteredSections.length, (i) {
          final section = filteredSections[i];
          final isSelected = _selectedSections.contains(section);
          final color = Color(section.colorValue);
          final isLast = i == filteredSections.length - 1;

          return Column(children: [
            GestureDetector(
              onTap: () => setState(() {
                isSelected
                    ? _selectedSections.remove(section)
                    : _selectedSections.add(section);
              }),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: isSelected
                          ? color.withOpacity(0.15)
                          : const Color(0xFF0D1B38),
                    ),
                    child: Icon(_iconFromName(section.iconName),
                        color: isSelected ? color : const Color(0xFF4A6080),
                        size: 18),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(section.label,
                        style: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF6B8CAE),
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 22, height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? color : Colors.transparent,
                      border: Border.all(
                          color: isSelected ? color : const Color(0xFF3A5070),
                          width: 1.5),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check_rounded,
                        color: Color(0xFF060D1F), size: 13)
                        : null,
                  ),
                ]),
              ),
            ),
            if (!isLast)
              Divider(height: 1, indent: 66,
                  color: const Color(0xFF1A2E52).withOpacity(0.4)),
          ]);
        }),
      ),
    );
  }

  Widget _buildPreviewCard() {
    final user = FirebaseAuth.instance.currentUser;
    final date = DateTime.now();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color(0xFF0B1535),
        border: Border.all(color: const Color(0xFF1A2E52).withOpacity(0.6)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.description_outlined, color: Color(0xFF8BA8D4), size: 16),
          const SizedBox(width: 8),
          const Text('Aperçu du fichier',
              style: TextStyle(color: Color(0xFF8BA8D4), fontSize: 12,
                  fontWeight: FontWeight.w500)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: (_selectedFormat == ExportFormat.pdf
                  ? const Color(0xFFFF5C7A)
                  : const Color(0xFF3EFFA8))
                  .withOpacity(0.1),
            ),
            child: Text(
              _selectedFormat == ExportFormat.pdf ? 'PDF' : 'CSV',
              style: TextStyle(
                  color: _selectedFormat == ExportFormat.pdf
                      ? const Color(0xFFFF5C7A)
                      : const Color(0xFF3EFFA8),
                  fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        const Divider(height: 1, color: Color(0xFF1A2E52)),
        const SizedBox(height: 12),
        _previewRow(Icons.person_outline_rounded,
            user?.displayName ?? 'Utilisateur', const Color(0xFF3EFFA8)),
        _previewRow(Icons.alternate_email_rounded,
            user?.email ?? '', const Color(0xFF00D4FF)),
        _previewRow(Icons.calendar_today_rounded,
            '${date.day}/${date.month}/${date.year}', const Color(0xFF8BA8D4)),
        _previewRow(Icons.layers_rounded,
            '${_selectedSections.length} section(s) sélectionnée(s)',
            const Color(0xFFFFB340)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 6, runSpacing: 6,
          children: _selectedSections.map((s) {
            final color = Color(s.colorValue);
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: color.withOpacity(0.1),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Text(s.label,
                  style: TextStyle(color: color, fontSize: 11,
                      fontWeight: FontWeight.w500)),
            );
          }).toList(),
        ),
      ]),
    );
  }

  Widget _previewRow(IconData icon, String value, Color color) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      Icon(icon, color: color, size: 14),
      const SizedBox(width: 10),
      Text(value, style: const TextStyle(color: Color(0xFFCDD8F0), fontSize: 12)),
    ]),
  );

  Widget _buildExportButton() {
    final isPdf = _selectedFormat == ExportFormat.pdf;
    final color  = isPdf ? const Color(0xFFFF5C7A) : const Color(0xFF3EFFA8);
    final color2 = isPdf ? const Color(0xFF7B61FF) : const Color(0xFF00D4FF);

    return SizedBox(
      width: double.infinity, height: 56,
      child: _isLoading
          ? Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(colors: [color, color2]),
        ),
        child: const Center(
          child: SizedBox(width: 24, height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(Colors.white))),
        ),
      )
          : DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(colors: [color, color2]),
          boxShadow: [BoxShadow(color: color.withOpacity(0.3),
              blurRadius: 20, offset: const Offset(0, 6))],
        ),
        child: ElevatedButton.icon(
          onPressed: _selectedSections.isEmpty ? null : _handleExport,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
          ),
          icon: Icon(
            isPdf ? Icons.visibility_rounded : Icons.download_rounded,
            color: Colors.white, size: 20,
          ),
          label: Text(
            isPdf ? 'Aperçu & Télécharger PDF' : 'Exporter en CSV',
            style: const TextStyle(color: Colors.white, fontSize: 15,
                fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(
    title.toUpperCase(),
    style: const TextStyle(color: Color(0xFF3A5070), fontSize: 11,
        fontWeight: FontWeight.w700, letterSpacing: 1.2),
  );

  Widget _alertWidget(String msg) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: const Color(0xFFFF5C7A).withOpacity(0.08),
      border: Border.all(color: const Color(0xFFFF5C7A).withOpacity(0.4)),
    ),
    child: Row(children: [
      const Icon(Icons.error_outline_rounded, color: Color(0xFFFF5C7A), size: 16),
      const SizedBox(width: 10),
      Expanded(child: Text(msg, style: const TextStyle(
          color: Color(0xFFFF5C7A), fontSize: 12, height: 1.4))),
    ]),
  );
}

// ══════════════════════════════════════════════════════════════
//  PDF PREVIEW SCREEN
// ══════════════════════════════════════════════════════════════
class _PdfPreviewScreen extends StatelessWidget {
  final String filePath;
  final UserDataSnapshot data;
  final List<ExportSection> sections;

  const _PdfPreviewScreen({
    required this.filePath,
    required this.data,
    required this.sections,
  });

  Future<Uint8List> _getBytes() async {
    final file = File(filePath);
    return await file.readAsBytes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060D1F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1535),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF8BA8D4), size: 18),
        ),
        title: ShaderMask(
          shaderCallback: (b) => const LinearGradient(
              colors: [Color(0xFF3EFFA8), Color(0xFF00D4FF)]).createShader(b),
          child: const Text('Aperçu PDF',
              style: TextStyle(color: Colors.white, fontSize: 16,
                  fontWeight: FontWeight.w800)),
        ),
        actions: [
          // Bouton partager
          GestureDetector(
            onTap: () async => await Share.shareXFiles(
              [XFile(filePath)],
              subject: 'Savy - Rapport financier',
            ),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xFF3EFFA8).withOpacity(0.1),
                border: Border.all(color: const Color(0xFF3EFFA8).withOpacity(0.3)),
              ),
              child: const Icon(Icons.share_rounded,
                  color: Color(0xFF3EFFA8), size: 18),
            ),
          ),
          // Bouton télécharger
          GestureDetector(
            onTap: () async {
              await Printing.layoutPdf(
                onLayout: (_) async => await _getBytes(),
                name: 'savy_rapport.pdf',
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                    colors: [Color(0xFF3EFFA8), Color(0xFF00D4FF)]),
              ),
              child: const Icon(Icons.download_rounded,
                  color: Color(0xFF060D1F), size: 18),
            ),
          ),
        ],
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFF1A2E52)),
        ),
      ),
      body: PdfPreview(
        build: (_) async => await _getBytes(),
        allowPrinting: true,
        allowSharing: true,
        canChangePageFormat: false,
        canChangeOrientation: false,
        pdfFileName: 'savy_rapport.pdf',
        loadingWidget: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Color(0xFF3EFFA8)),
          ),
        ),
        actions: const [],
      ),
    );
  }
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