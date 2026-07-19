import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ExportService {
  static Future<String> exportInvoicePdf(Map<String, dynamic> invoice, List<Map<String, dynamic>> items) async {
    final pdf = pw.Document();
    final subtotal = items.fold<double>(0, (sum, item) => sum + (item['unitPrice'] as num).toDouble() * (item['quantity'] as int));
    final tax = subtotal * ((invoice['taxRate'] ?? 16) / 100);
    final total = subtotal + tax - (invoice['discount'] ?? 0);

    pdf.addPage(pw.Page(build: (pw.Context context) {
      return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text('Facture PharmaOne', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Text('Numéro: ${invoice['invoiceNumber']}'),
        pw.Text('Client: ${invoice['clientName']}'),
        pw.Text('Date: ${invoice['date']}'),
        pw.SizedBox(height: 12),
        pw.Text('Détails', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        ...items.map((item) => pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Text('${item['productName']} x${item['quantity']}'),
          pw.Text('${((item['unitPrice'] as num).toDouble() * (item['quantity'] as int)).toStringAsFixed(0)} CDF'),
        ])),
        pw.SizedBox(height: 12),
        pw.Text('Sous-total: ${subtotal.toStringAsFixed(0)} CDF'),
        pw.Text('TVA: ${tax.toStringAsFixed(0)} CDF'),
        pw.Text('Remise: ${(invoice['discount'] ?? 0).toStringAsFixed(0)} CDF'),
        pw.Text('Total: ${total.toStringAsFixed(0)} CDF', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      ]);
    }));
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/invoice_${invoice['invoiceNumber']}.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    return filePath;
  }

  static Future<void> printInvoicePdf(Map<String, dynamic> invoice, List<Map<String, dynamic>> items) async {
    final path = await exportInvoicePdf(invoice, items);
    await Printing.layoutPdf(onLayout: (format) async => File(path).readAsBytes());
  }

  static Future<String> exportReportCsv(List<Map<String, dynamic>> rows, String title) async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/${title.replaceAll(' ', '_')}.csv';
    final rowsToCsv = rows.map((row) => row.values.map((e) => e.toString()).toList()).toList();
    final csvData = const ListToCsvConverter().convert(rowsToCsv);
    final file = File(filePath);
    await file.writeAsString(csvData);
    return filePath;
  }
}
