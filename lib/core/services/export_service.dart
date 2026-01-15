import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../../data/models/group_model.dart';
import '../../../data/models/expense_model.dart';
import '../../../data/models/member_model.dart';

/// Export service for generating and sharing reports
class ExportService {
  final ScreenshotController screenshotController = ScreenshotController();

  /// Export group summary as PDF
  Future<void> exportToPDF({
    required Group group,
    required List<Expense> expenses,
    required List<Member> members,
    required Map<int, double> balances,
  }) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Text(
                  group.name,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),

                // Summary
                pw.Text(
                  'Summary',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text('Total Expenses: ${expenses.length}'),
                pw.Text(
                  'Total Amount: ${group.currency} ${expenses.fold(0.0, (sum, e) => sum + e.amount).toStringAsFixed(2)}',
                ),
                pw.Text('Members: ${members.length}'),
                pw.SizedBox(height: 20),

                // Expenses
                pw.Text(
                  'Expenses',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Title',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Amount',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Category',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    ...expenses.map((expense) {
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(expense.title),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              '${group.currency} ${expense.amount.toStringAsFixed(2)}',
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(expense.category),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),

                pw.SizedBox(height: 20),

                // Balances
                pw.Text(
                  'Balances',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                ...balances.entries.where((e) => e.value.abs() > 0.01).map((
                  entry,
                ) {
                  final member = members.firstWhere((m) => m.id == entry.key);
                  final isPositive = entry.value > 0;
                  return pw.Text(
                    '${member.name}: ${isPositive ? "Gets back" : "Owes"} ${group.currency} ${entry.value.abs().toStringAsFixed(2)}',
                  );
                }).toList(),
              ],
            );
          },
        ),
      );

      // Save and share
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: '${group.name}_summary.pdf',
      );

      Get.snackbar(
        'Success',
        'PDF exported successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to export PDF: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Capture and share screenshot
  Future<void> shareScreenshot(Widget widget) async {
    try {
      final imageBytes = await screenshotController.captureFromWidget(
        widget,
        delay: const Duration(milliseconds: 100),
      );

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/expense_summary.png');
      await file.writeAsBytes(imageBytes);

      await Share.shareXFiles([XFile(file.path)], text: 'Expense Summary');

      Get.snackbar(
        'Success',
        'Screenshot shared successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to share screenshot: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Generate summary image widget
  Widget buildSummaryImage({
    required Group group,
    required List<Expense> expenses,
    required Map<int, double> balances,
    required List<Member> members,
  }) {
    final total = expenses.fold(0.0, (sum, e) => sum + e.amount);

    return Container(
      width: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF98E6D8), const Color(0xFFB8A4E8)],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            group.name,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Spent',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${group.currency} ${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${expenses.length} expenses • ${members.length} members',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Smart Expense Splitter',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
