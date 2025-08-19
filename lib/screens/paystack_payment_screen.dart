import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'success_page.dart';
import 'failed_page.dart';

class PaymentPaystackScreen extends StatefulWidget {
  final String meterNumber;
  final String meterType;
  final String disco;
  final double amount;
  final String phone;
  final String email;

  const PaymentPaystackScreen({
    super.key,
    required this.meterNumber,
    required this.meterType,
    required this.disco,
    required this.amount,
    required this.phone,
    required this.email,
  });

  @override
  State<PaymentPaystackScreen> createState() => _PaymentPaystackScreenState();
}

class _PaymentPaystackScreenState extends State<PaymentPaystackScreen> {
  late WebViewController _controller;
  String? _checkoutUrl;
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    if (widget.email.isEmpty || widget.disco.isEmpty) {
      setState(() {
        _errorMessage =
            "Missing required parameters: ${widget.email.isEmpty ? "Email " : ""}${widget.disco.isEmpty ? "Disco" : ""}";
        _loading = false;
      });
      return;
    }

    _initializePayment();
  }

  Future<void> _initializePayment() async {
    try {
      final int koboAmount = (widget.amount * 100).toInt();

      final response = await http.post(
        Uri.parse("${Config.paystackBackendUrl}/initialize_payment.php"),
        body: {
          "email": widget.email,
          "amount": koboAmount.toString(),
        },
      );

      final data = jsonDecode(response.body);

      if (data["status"] == true &&
          data["data"]?["authorization_url"] != null) {
        setState(() {
          _checkoutUrl = data["data"]["authorization_url"];
          _controller = WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..setNavigationDelegate(
              NavigationDelegate(
                onNavigationRequest: (request) {
                  final url = request.url;

                  // ✅ Success callback
                  if (url.contains("payment_success.php")) {
                    final uri = Uri.parse(url);
                    final ref = uri.queryParameters["reference"];
                    if (ref != null) _verifyPayment(ref);
                    return NavigationDecision.prevent;
                  }

                  // ❌ Cancelled callback
                  if (url.contains("payment_cancelled.php")) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FailedPage(
                          message: "Payment was cancelled",
                          amount: '',
                          onRetry: () {},
                        ),
                      ),
                      (route) => false,
                    );
                    return NavigationDecision.prevent;
                  }

                  return NavigationDecision.navigate;
                },
              ),
            )
            ..loadRequest(Uri.parse(_checkoutUrl!));
          _loading = false;
        });
      } else {
        setState(() {
          _errorMessage = data["message"] ?? "Failed to initialize payment";
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error initializing payment: $e";
        _loading = false;
      });
    }
  }

  Future<void> _verifyPayment(String reference) async {
    try {
      if (widget.email.isEmpty || widget.disco.isEmpty) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => FailedPage(
              message: "Missing email or disco",
              amount: '',
              onRetry: () {},
            ),
          ),
          (route) => false,
        );
        return;
      }

      final response = await http.post(
        Uri.parse("${Config.paystackBackendUrl}/verify_payment.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "reference": reference,
          "meterNumber": widget.meterNumber,
          "meterType": widget.meterType,
          "disco": widget.disco,
          "amount": widget.amount.toString(),
          "phone": widget.phone,
          "email": widget.email,
        }),
      );

      final data = jsonDecode(response.body);

      switch (data['message'] ?? "") {
        case "Missing required parameters":
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => FailedPage(
                message:
                    "Backend error: Missing required parameters (email/disco)",
                amount: '',
                onRetry: () {},
              ),
            ),
            (route) => false,
          );
          return;
        case "Payment verification failed":
        case "VTPass purchase failed":
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => FailedPage(
                message: data['message'] ?? "Transaction failed",
                amount: '',
                onRetry: () {},
              ),
            ),
            (route) => false,
          );
          return;
      }

      if (data["status"] == true) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => SuccessPage(
              token: data["token"] ?? "",
              units: data["units"]?.toString() ?? "",
              amount: widget.amount.toString(),
              meterNumber: widget.meterNumber,
              discoName: widget.disco,
            ),
          ),
          (Route<dynamic> route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => FailedPage(
              message: data['message'] ?? "Transaction failed",
              amount: '',
              onRetry: () {},
            ),
          ),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      debugPrint("Error verifying payment: $e");
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => FailedPage(
            message: "Error verifying payment: $e",
            amount: '',
            onRetry: () {},
          ),
        ),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Payment"),
        backgroundColor: Colors.green,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                )
              : WebViewWidget(controller: _controller),
    );
  }
}
