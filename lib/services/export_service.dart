import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../models/export_models.dart';

// ══════════════════════════════════════════════════════════════
//  SAVVY – EXPORT SERVICE
//  lib/services/export_service.dart
// ══════════════════════════════════════════════════════════════

class ExportService {
  // ── Couleurs PDF ──────────────────────────────────────────
  static const _green  = PdfColor.fromInt(0xFF3EFFA8);
  static const _blue   = PdfColor.fromInt(0xFF00D4FF);
  static const _dark   = PdfColor.fromInt(0xFF060D1F);
  static const _card   = PdfColor.fromInt(0xFF0B1535);
  static const _grey   = PdfColor.fromInt(0xFF6B8CAE);
  static const _red    = PdfColor.fromInt(0xFFFF5C7A);
  static const _yellow = PdfColor.fromInt(0xFFFFB340);
  static const _purple = PdfColor.fromInt(0xFF7B61FF);
  static const _white  = PdfColors.white;

  // ════════════════════════════════════════════════════════════
  //  EXPORT PDF
  // ════════════════════════════════════════════════════════════
  static Future<ExportResult> exportPdf(
      UserDataSnapshot data,
      List<ExportSection> sections,
      ) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          header: (ctx) => _buildPdfHeader(data),
          footer: (ctx) => _buildPdfFooter(ctx, data),
          build: (ctx) => [
            // Summary card
            _buildPdfSummary(data),
            pw.SizedBox(height: 20),

            // Sections sélectionnées
            if (sections.contains(ExportSection.budget)) ...[
              _buildPdfSectionTitle('Budget par catégorie', _blue),
              pw.SizedBox(height: 8),
              _buildPdfBudgetTable(data.budgetCategories),
              pw.SizedBox(height: 20),
            ],
            if (sections.contains(ExportSection.revenues)) ...[
              _buildPdfSectionTitle('Sources de revenus', _green),
              pw.SizedBox(height: 8),
              _buildPdfRevenueTable(data.revenues),
              pw.SizedBox(height: 20),
            ],
            if (sections.contains(ExportSection.transactions)) ...[
              _buildPdfSectionTitle('Transactions récentes', _yellow),
              pw.SizedBox(height: 8),
              _buildPdfTransactionTable(data.transactions),
              pw.SizedBox(height: 20),
            ],
            if (sections.contains(ExportSection.objectives)) ...[
              _buildPdfSectionTitle("Objectifs d'épargne", _purple),
              pw.SizedBox(height: 8),
              _buildPdfObjectiveTable(data.objectives),
            ],
          ],
        ),
      );

      // Sauvegarde le fichier
      final dir = await getTemporaryDirectory();
      final fileName =
          'savy_rapport_${data.exportDate.day}_${data.exportDate.month}_${data.exportDate.year}.pdf';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      return ExportResult.success(file.path);
    } catch (e) {
      return ExportResult.error('Erreur PDF: ${e.toString()}');
    }
  }

  // ── PDF Header ────────────────────────────────────────────
  static pw.Widget _buildPdfHeader(UserDataSnapshot data) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
            bottom: pw.BorderSide(color: _green, width: 1)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('SAVY',
              style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: _green)),
          pw.Text('Rapport financier — ${data.userName}',
              style: pw.TextStyle(fontSize: 10, color: _grey)),
        ],
      ),
    );
  }

  // ── PDF Footer ────────────────────────────────────────────
  static pw.Widget _buildPdfFooter(
      pw.Context ctx, UserDataSnapshot data) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
          border:
          pw.Border(top: pw.BorderSide(color: _grey, width: 0.5))),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
              'Exporté le ${data.exportDate.day}/${data.exportDate.month}/${data.exportDate.year}',
              style: pw.TextStyle(fontSize: 9, color: _grey)),
          pw.Text('Page ${ctx.pageNumber} / ${ctx.pagesCount}',
              style: pw.TextStyle(fontSize: 9, color: _grey)),
        ],
      ),
    );
  }

  // ── PDF Summary ───────────────────────────────────────────
  static pw.Widget _buildPdfSummary(UserDataSnapshot data) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFF0F4FF),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Résumé financier',
              style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: _dark)),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _summaryItem('Revenus totaux',
                  '${data.totalRevenue.toStringAsFixed(0)} TND', _green),
              _summaryItem('Dépenses totales',
                  '${data.totalSpent.toStringAsFixed(0)} TND', _red),
              _summaryItem('Solde',
                  '${data.balance.toStringAsFixed(0)} TND',
                  data.balance >= 0 ? _green : _red),
              _summaryItem('Épargne',
                  '${data.totalSaved.toStringAsFixed(0)} TND', _purple),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _summaryItem(
      String label, String value, PdfColor color) {
    return pw.Column(children: [
      pw.Text(value,
          style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: color)),
      pw.SizedBox(height: 2),
      pw.Text(label,
          style: pw.TextStyle(fontSize: 9, color: _grey)),
    ]);
  }

  // ── PDF Section Title ─────────────────────────────────────
  static pw.Widget _buildPdfSectionTitle(String title, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: pw.BoxDecoration(
        color: color.shade(0.9),
        borderRadius: pw.BorderRadius.circular(4),
        border: pw.Border.all(color: color, width: 1),  // ← Bordure complète
      ),
      child: pw.Text(title,
          style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: _dark)),
    );
  }
  // ── PDF Budget Table ──────────────────────────────────────
  static pw.Widget _buildPdfBudgetTable(
      List<BudgetCategorySnapshot> cats) {
    return pw.Table(
      border: pw.TableBorder.all(
          color: PdfColor.fromInt(0xFFDDE8FF), width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(2),
        4: const pw.FlexColumnWidth(2),
      },
      children: [
        // Header
        pw.TableRow(
          decoration:
          pw.BoxDecoration(color: PdfColor.fromInt(0xFFE8F0FF)),
          children: ['Catégorie', 'Budget', 'Dépensé', 'Restant', 'Statut']
              .map((h) => pw.Padding(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Text(h,
                style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 9,
                    color: _dark)),
          ))
              .toList(),
        ),
        // Rows
        ...cats.map((cat) => pw.TableRow(
          children: [
            _cell(cat.name),
            _cell('${cat.budget.toStringAsFixed(0)} TND'),
            _cell('${cat.spent.toStringAsFixed(0)} TND',
                color: cat.isOver ? _red : _dark),
            _cell('${(cat.budget - cat.spent).toStringAsFixed(0)} TND'),
            _cell(cat.isOver ? 'Dépassé !' : 'OK',
                color: cat.isOver ? _red : _green),
          ],
        )),
        // Total
        pw.TableRow(
          decoration:
          pw.BoxDecoration(color: PdfColor.fromInt(0xFFF0F4FF)),
          children: [
            _cell('TOTAL',
                bold: true),
            _cell('${cats.fold<double>(0, (s, c) => s + c.budget).toStringAsFixed(0)} TND',
                bold: true),
            _cell('${cats.fold<double>(0, (s, c) => s + c.spent).toStringAsFixed(0)} TND',
                bold: true),
            _cell(''),
            _cell(''),
          ],
        ),
      ],
    );
  }

  // ── PDF Transaction Table ─────────────────────────────────
  static pw.Widget _buildPdfTransactionTable(
      List<TransactionSnapshot> txs) {
    if (txs.isEmpty) {
      return pw.Text('Aucune transaction',
          style: pw.TextStyle(color: _grey, fontSize: 10));
    }
    return pw.Table(
      border: pw.TableBorder.all(
          color: PdfColor.fromInt(0xFFDDE8FF), width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(
          decoration:
          pw.BoxDecoration(color: PdfColor.fromInt(0xFFE8F0FF)),
          children: ['Libellé', 'Catégorie', 'Montant', 'Date']
              .map((h) => pw.Padding(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Text(h,
                style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 9,
                    color: _dark)),
          ))
              .toList(),
        ),
        ...txs.map((tx) => pw.TableRow(children: [
          _cell(tx.label),
          _cell(tx.category),
          _cell(tx.formattedAmount,
              color: tx.isIncome ? _green : _red),
          _cell(tx.formattedDate),
        ])),
      ],
    );
  }

  // ── PDF Objective Table ───────────────────────────────────
  static pw.Widget _buildPdfObjectiveTable(
      List<ObjectiveSnapshot> objs) {
    if (objs.isEmpty) {
      return pw.Text('Aucun objectif',
          style: pw.TextStyle(color: _grey, fontSize: 10));
    }
    return pw.Table(
      border: pw.TableBorder.all(
          color: PdfColor.fromInt(0xFFDDE8FF), width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(
          decoration:
          pw.BoxDecoration(color: PdfColor.fromInt(0xFFE8F0FF)),
          children:
          ['Objectif', 'Épargné', 'Cible', '%', 'Échéance']
              .map((h) => pw.Padding(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Text(h,
                style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 9,
                    color: _dark)),
          ))
              .toList(),
        ),
        ...objs.map((obj) => pw.TableRow(children: [
          _cell(obj.name),
          _cell('${obj.current.toStringAsFixed(0)} TND'),
          _cell('${obj.target.toStringAsFixed(0)} TND'),
          _cell(obj.progressPercent, color: _purple),
          _cell(obj.deadline),
        ])),
      ],
    );
  }

  // ── PDF Revenue Table ─────────────────────────────────────
  static pw.Widget _buildPdfRevenueTable(
      List<RevenueSnapshot> revenues) {
    if (revenues.isEmpty) {
      return pw.Text('Aucun revenu',
          style: pw.TextStyle(color: _grey, fontSize: 10));
    }
    return pw.Table(
      border: pw.TableBorder.all(
          color: PdfColor.fromInt(0xFFDDE8FF), width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(
          decoration:
          pw.BoxDecoration(color: PdfColor.fromInt(0xFFE8F0FF)),
          children: ['Source', 'Montant', 'Fréquence']
              .map((h) => pw.Padding(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Text(h,
                style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 9,
                    color: _dark)),
          ))
              .toList(),
        ),
        ...revenues.map((r) => pw.TableRow(children: [
          _cell(r.source),
          _cell('${r.amount.toStringAsFixed(0)} TND',
              color: _green),
          _cell(r.type),
        ])),
        pw.TableRow(
          decoration:
          pw.BoxDecoration(color: PdfColor.fromInt(0xFFF0F4FF)),
          children: [
            _cell('TOTAL', bold: true),
            _cell(
                '${revenues.fold<double>(0, (s, r) => s + r.amount).toStringAsFixed(0)} TND',
                bold: true,
                color: _green),
            _cell(''),
          ],
        ),
      ],
    );
  }

  static pw.Widget _cell(String text,
      {PdfColor? color, bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(text,
          style: pw.TextStyle(
            fontSize: 9,
            color: color ?? _dark,
            fontWeight:
            bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          )),
    );
  }

  // ════════════════════════════════════════════════════════════
  //  EXPORT CSV
  // ════════════════════════════════════════════════════════════
  static Future<ExportResult> exportCsv(
      UserDataSnapshot data,
      List<ExportSection> sections,
      ) async {
    try {
      final rows = <List<dynamic>>[];

      // En-tête
      rows.add(['SAVY - Export de données']);
      rows.add(['Utilisateur', data.userName]);
      rows.add(['Email', data.userEmail]);
      rows.add(['Date export',
        '${data.exportDate.day}/${data.exportDate.month}/${data.exportDate.year}']);
      rows.add([]);

      // Budget
      if (sections.contains(ExportSection.budget)) {
        rows.add(['=== BUDGET ===']);
        rows.add(['Catégorie', 'Budget (TND)', 'Dépensé (TND)',
          'Restant (TND)', 'Statut']);
        for (final cat in data.budgetCategories) {
          rows.add([
            cat.name,
            cat.budget.toStringAsFixed(2),
            cat.spent.toStringAsFixed(2),
            (cat.budget - cat.spent).toStringAsFixed(2),
            cat.isOver ? 'Dépassé' : 'OK',
          ]);
        }
        rows.add([]);
      }

      // Revenus
      if (sections.contains(ExportSection.revenues)) {
        rows.add(['=== REVENUS ===']);
        rows.add(['Source', 'Montant (TND)', 'Fréquence']);
        for (final r in data.revenues) {
          rows.add([r.source, r.amount.toStringAsFixed(2), r.type]);
        }
        rows.add([]);
      }

      // Transactions
      if (sections.contains(ExportSection.transactions)) {
        rows.add(['=== TRANSACTIONS ===']);
        rows.add(
            ['Libellé', 'Catégorie', 'Montant (TND)', 'Type', 'Date']);
        for (final tx in data.transactions) {
          rows.add([
            tx.label,
            tx.category,
            tx.amount.toStringAsFixed(2),
            tx.isIncome ? 'Revenu' : 'Dépense',
            tx.formattedDate,
          ]);
        }
        rows.add([]);
      }

      // Objectifs
      if (sections.contains(ExportSection.objectives)) {
        rows.add(["=== OBJECTIFS D'ÉPARGNE ==="]);
        rows.add([
          'Objectif',
          'Épargné (TND)',
          'Cible (TND)',
          'Progression',
          'Échéance'
        ]);
        for (final obj in data.objectives) {
          rows.add([
            obj.name,
            obj.current.toStringAsFixed(2),
            obj.target.toStringAsFixed(2),
            obj.progressPercent,
            obj.deadline,
          ]);
        }
        rows.add([]);
      }

      final csvString = const ListToCsvConverter().convert(rows);
      final dir = await getTemporaryDirectory();
      final fileName =
          'savy_export_${data.exportDate.day}_${data.exportDate.month}_${data.exportDate.year}.csv';
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(csvString, encoding: const Utf8Codec());

      return ExportResult.success(file.path);
    } catch (e) {
      return ExportResult.error('Erreur CSV: ${e.toString()}');
    }
  }

  // ════════════════════════════════════════════════════════════
  //  SHARE FILE
  // ════════════════════════════════════════════════════════════
  static Future<void> shareFile(String filePath, String fileName) async {
    await Share.shareXFiles(
      [XFile(filePath)],
      subject: 'Savy - $fileName',
      text: 'Voici mon rapport financier exporté depuis Savy',
    );
  }

  // ── Données mock (à remplacer par Firestore) ──────────────
  static UserDataSnapshot getMockData(
      String userName, String userEmail) {
    return UserDataSnapshot(
      userName: userName,
      userEmail: userEmail,
      exportDate: DateTime.now(),
      budgetCategories: [
        const BudgetCategorySnapshot(
            name: 'Alimentation',
            spent: 145,
            budget: 200,
            color: '#FFB340'),
        const BudgetCategorySnapshot(
            name: 'Transport', spent: 48, budget: 60, color: '#00D4FF'),
        const BudgetCategorySnapshot(
            name: 'Loisirs', spent: 80, budget: 70, color: '#FF5C7A'),
        const BudgetCategorySnapshot(
            name: 'Académique', spent: 60, budget: 100, color: '#7B61FF'),
        const BudgetCategorySnapshot(
            name: 'Santé', spent: 30, budget: 50, color: '#3EFFA8'),
      ],
      transactions: [
        TransactionSnapshot(
            id: '1',
            label: 'Courses supermarché',
            amount: 45,
            category: 'Alimentation',
            isIncome: false,
            date: DateTime.now().subtract(const Duration(days: 1))),
        TransactionSnapshot(
            id: '2',
            label: 'Bourse universitaire',
            amount: 600,
            category: 'Revenu',
            isIncome: true,
            date: DateTime.now().subtract(const Duration(days: 3))),
        TransactionSnapshot(
            id: '3',
            label: 'Ticket de bus',
            amount: 12,
            category: 'Transport',
            isIncome: false,
            date: DateTime.now().subtract(const Duration(days: 5))),
      ],
      objectives: [
        const ObjectiveSnapshot(
            id: '1',
            name: 'Ordinateur portable',
            current: 360,
            target: 900,
            deadline: 'Juin 2025',
            priority: 1),
        const ObjectiveSnapshot(
            id: '2',
            name: 'Voyage Europe',
            current: 150,
            target: 600,
            deadline: 'Août 2025',
            priority: 2),
      ],
      revenues: [
        const RevenueSnapshot(
            id: '1',
            source: 'Bourse universitaire',
            amount: 600,
            type: 'Mensuel'),
        const RevenueSnapshot(
            id: '2',
            source: 'Job étudiant',
            amount: 800,
            type: 'Mensuel'),
        const RevenueSnapshot(
            id: '3',
            source: 'Aide familiale',
            amount: 400,
            type: 'Irrégulier'),
      ],
    );
  }
}