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

  const SuccessPage({
    super.key,
    required this.token,
    required this.units,
    required this.amount,
    required this.meterNumber,
    required this.discoName,
  });

  // ✅ Generate and share PDF receipt
  Future<void> _generateAndShareReceipt() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("Electricity Payment Receipt",
                style:
                    pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Text("Meter Number: $meterNumber"),
            pw.Text("Disco: $discoName"),
            pw.Text("Units: $units"),
            pw.Text("Amount Paid: ₦$amount"),
            pw.Text("Token: $token"),
            pw.SizedBox(height: 20),
            pw.Text("Thank you for your payment!",
                style: pw.TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/receipt.pdf");
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([XFile(file.path)],
        text: "Here is your electricity payment receipt.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ✅ Done button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Done",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ✅ Success icon
            const Icon(Icons.check_circle, color: Colors.green, size: 100),

            const SizedBox(height: 10),

            const Text(
              "Successful",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 10),

            // ✅ Total amount (copyable)
            GestureDetector(
              onLongPress: () {
                Clipboard.setData(ClipboardData(text: amount));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Amount copied")),
                );
              },
              child: Text(
                "₦$amount",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 5),

            // ✅ Units
            Text(
              "$units units",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 20),

            // ✅ Token box
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
                    icon: const Icon(Icons.copy, size: 22, color: Colors.green),
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

            // ✅ Action buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _actionButton(Icons.share, "Share Receipt", () {
                    _generateAndShareReceipt();
                  }),
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
                          transaction: null,
                          meterType: '',
                          customerName: '',
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
          ],
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.green, size: 28),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
