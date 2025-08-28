import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

import 'summary_page.dart';

class SuccessPage extends StatelessWidget {
  final String token;
  final String units;
  final String amount; // ✅ Total amount (Paystack paid)
  final String meterNumber;
  final String discoName;
  final Map<String, dynamic>? transaction; // ✅ VTpass transaction object
  final String meterType;
  final String customerName;

  const SuccessPage({
    super.key,
    required this.token,
    required this.units,
    required this.amount,
    required this.meterNumber,
    required this.discoName,
    required this.transaction,
    required this.meterType,
    required this.customerName,
  });

  // ✅ Generate and share PDF receipt
  Future<void> _generateAndShareReceipt() async {
    final pdf = pw.Document();

    const brandColor = PdfColor.fromInt(0xFF00C950); // ✅ updated brand green

    // Load logo from assets
    final logo = pw.MemoryImage(
      (await rootBundle.load("assets/images/small_logo.png"))
          .buffer
          .asUint8List(),
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            // ✅ Logo & Title
            pw.Center(child: pw.Image(logo, height: 70)),
            pw.SizedBox(height: 12),
            pw.Center(
              child: pw.Text(
                "Electricity Payment Receipt",
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                  color: brandColor,
                ),
              ),
            ),
            pw.SizedBox(height: 24),

            // ✅ Table with transaction details
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              columnWidths: {
                0: pw.FlexColumnWidth(3),
                1: pw.FlexColumnWidth(5),
              },
              children: [
                _tableRow("Customer Name", customerName),
                _tableRow("Meter Number", meterNumber),
                _tableRow("Disco", discoName),
                _tableRow("Meter Type", meterType),
                _tableRow("Units", "$units kWh"),
                _tableRow("Amount Paid", "₦$amount"),
                _tableRow("Token", token),
                _tableRow(
                    "Transaction ID", transaction?['transactionId'] ?? "N/A"),
                _tableRow("Status", transaction?['status'] ?? "N/A"),
                _tableRow(
                  "Date",
                  transaction?['date'] ??
                      DateTime.now().toString().substring(0, 19),
                ),
              ],
            ),

            pw.SizedBox(height: 40),

            // ✅ Thank you note
            pw.Center(
              child: pw.Text(
                "Thank you for your payment!",
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: brandColor,
                ),
              ),
            ),

            pw.Spacer(),

            // ✅ Footer contact info
            pw.Divider(),
            pw.Center(
              child: pw.Text(
                "Need help? Call us at: +234-800-123-4567",
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
              ),
            ),
          ],
        ),
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/receipt.pdf");
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles(
      [XFile(file.path)],
      text: "Here is your electricity payment receipt.",
    );
  }

  // ✅ Helper for PDF table rows
  pw.TableRow _tableRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            label,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(value),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const brandColor = Color(0xFF00C950); // ✅ updated brand green

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Done",
                  style: TextStyle(
                    color: brandColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Icon(Icons.check_circle, color: brandColor, size: 100),
            const SizedBox(height: 10),

            const Text(
              "Successful",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),

            GestureDetector(
              onLongPress: () {
                Clipboard.setData(ClipboardData(text: amount));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Amount copied")),
                );
              },
              child: Text(
                "₦$amount",
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 5),

            Text("$units units",
                style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 20),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: SelectableText(
                      token,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 22, color: brandColor),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: token));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Token copied")),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _actionButton(
                      Icons.share, "Share Receipt", _generateAndShareReceipt),
                  _actionButton(Icons.receipt_long, "View Details", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SummaryPage(
                          token: token,
                          units: units,
                          amount: amount,
                          meterNumber: meterNumber,
                          discoName: discoName,
                          transaction: transaction,
                          meterType: meterType,
                          customerName: customerName,
                        ),
                      ),
                    );
                  }),
                  _actionButton(Icons.save_alt, "Save meter", () {
                    // TODO: Implement save meter
                  }),
                ],
              ),
            ),

            const Spacer(),

            // ✅ Footer on screen
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                "Need help? Call us at: +234-800-123-4567",
                style: TextStyle(color: Colors.grey[700], fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
    const brandColor = Color(0xFF00C950); // ✅ updated brand green
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: brandColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: brandColor, size: 28),
          ),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
