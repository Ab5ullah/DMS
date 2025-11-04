import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import '../config/app_config.dart';
import '../models/billing_model.dart';
import '../models/patient_model.dart';

class PDFInvoice {
  static Future<void> generateAndPrintInvoice({
    required Billing billing,
    required Patient patient,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              pw.SizedBox(height: 30),

              // Invoice Title
              pw.Center(
                child: pw.Text(
                  'INVOICE',
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 30),

              // Invoice Details
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _buildPatientInfo(patient),
                  _buildInvoiceInfo(billing),
                ],
              ),
              pw.SizedBox(height: 30),

              // Divider
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 20),

              // Treatment Details Table
              _buildTreatmentTable(billing),
              pw.SizedBox(height: 30),

              // Payment Summary
              _buildPaymentSummary(billing),
              pw.SizedBox(height: 40),

              // Footer
              pw.Spacer(),
              _buildFooter(),
            ],
          );
        },
      ),
    );

    // Show print dialog
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  static Future<void> generateAndSaveInvoice({
    required Billing billing,
    required Patient patient,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              pw.SizedBox(height: 30),
              pw.Center(
                child: pw.Text(
                  'INVOICE',
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 30),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _buildPatientInfo(patient),
                  _buildInvoiceInfo(billing),
                ],
              ),
              pw.SizedBox(height: 30),
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 20),
              _buildTreatmentTable(billing),
              pw.SizedBox(height: 30),
              _buildPaymentSummary(billing),
              pw.SizedBox(height: 40),
              pw.Spacer(),
              _buildFooter(),
            ],
          );
        },
      ),
    );

    // Save to Documents folder
    final documentsPath = Platform.environment['USERPROFILE'] ?? '';
    final invoicePath = join(documentsPath, 'Documents', 'DentistClinicData', 'Invoices');

    // Create directory if it doesn't exist
    final directory = Directory(invoicePath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    // Save file
    final fileName = 'Invoice_${billing.id}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File(join(invoicePath, fileName));
    await file.writeAsBytes(await pdf.save());
  }

  static pw.Widget _buildHeader() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          AppConfig.clinicName,
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#1976D2'),
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          AppConfig.clinicShortName,
          style: const pw.TextStyle(
            fontSize: 14,
            color: PdfColors.grey700,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildPatientInfo(Patient patient) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'BILL TO:',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey700,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          patient.name,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        if (patient.patientId != null) ...[
          pw.SizedBox(height: 4),
          pw.Text(
            'Patient ID: ${patient.patientId}',
            style: const pw.TextStyle(fontSize: 12),
          ),
        ],
        if (patient.phone != null) ...[
          pw.SizedBox(height: 4),
          pw.Text(
            'Phone: ${patient.phone}',
            style: const pw.TextStyle(fontSize: 12),
          ),
        ],
        if (patient.cnic != null) ...[
          pw.SizedBox(height: 4),
          pw.Text(
            'CNIC: ${patient.cnic}',
            style: const pw.TextStyle(fontSize: 12),
          ),
        ],
        if (patient.address != null) ...[
          pw.SizedBox(height: 4),
          pw.Text(
            patient.address!,
            style: const pw.TextStyle(fontSize: 12),
          ),
        ],
      ],
    );
  }

  static pw.Widget _buildInvoiceInfo(Billing billing) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Text(
          'Invoice #${billing.id}',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Date: ${DateFormat(AppConfig.dateFormat).format(DateTime.parse(billing.date))}',
          style: const pw.TextStyle(fontSize: 12),
        ),
        pw.SizedBox(height: 4),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: pw.BoxDecoration(
            color: billing.balance > 0 ? PdfColor.fromHex('#FFEBEE') : PdfColor.fromHex('#E8F5E9'),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Text(
            billing.balance > 0 ? 'UNPAID' : 'PAID',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: billing.balance > 0 ? PdfColor.fromHex('#D32F2F') : PdfColor.fromHex('#4CAF50'),
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildTreatmentTable(Billing billing) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        // Header
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('#1976D2'),
          ),
          children: [
            _buildTableCell('Treatment', isHeader: true),
            _buildTableCell('Cost', isHeader: true),
          ],
        ),
        // Data
        pw.TableRow(
          children: [
            _buildTableCell(billing.treatment),
            _buildTableCell('${AppConfig.currencySymbol} ${billing.cost.toStringAsFixed(2)}'),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(12),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 14,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.white : PdfColors.black,
        ),
      ),
    );
  }

  static pw.Widget _buildPaymentSummary(Billing billing) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      padding: const pw.EdgeInsets.all(16),
      child: pw.Column(
        children: [
          _buildSummaryRow('Subtotal:', '${AppConfig.currencySymbol} ${billing.cost.toStringAsFixed(2)}'),
          pw.SizedBox(height: 8),
          pw.Divider(),
          pw.SizedBox(height: 8),
          _buildSummaryRow(
            'Total:',
            '${AppConfig.currencySymbol} ${billing.cost.toStringAsFixed(2)}',
            isBold: true,
          ),
          pw.SizedBox(height: 8),
          _buildSummaryRow(
            'Amount Paid:',
            '${AppConfig.currencySymbol} ${billing.paid.toStringAsFixed(2)}',
            color: PdfColor.fromHex('#4CAF50'),
          ),
          pw.SizedBox(height: 8),
          pw.Divider(),
          pw.SizedBox(height: 8),
          _buildSummaryRow(
            'Balance Due:',
            '${AppConfig.currencySymbol} ${billing.balance.toStringAsFixed(2)}',
            isBold: true,
            color: billing.balance > 0 ? PdfColor.fromHex('#D32F2F') : PdfColor.fromHex('#4CAF50'),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    PdfColor? color,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: color,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: color,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.Divider(),
        pw.SizedBox(height: 10),
        pw.Text(
          'Thank you for choosing ${AppConfig.clinicName}!',
          style: const pw.TextStyle(
            fontSize: 12,
            color: PdfColors.grey700,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          'Generated on ${DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now())}',
          style: const pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey600,
          ),
        ),
      ],
    );
  }
}
