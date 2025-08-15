import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import '../config.dart';

class PaystackPaymentScreen extends StatefulWidget {
  final double amount;
  final String email;

  const PaystackPaymentScreen({
    super.key,
    required this.amount,
    required this.email,
  });

  @override
  State<PaystackPaymentScreen> createState() => _PaystackPaymentScreenState();
}

class _PaystackPaymentScreenState extends State<PaystackPaymentScreen> {
  late final WebViewController _controller;
  String? _checkoutUrl;
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePayment();
  }

  Future<void> _initializePayment() async {
    try {
      final int koboAmount = (widget.amount * 100).toInt();

      // Call your PHP backend to initialize payment
      final response = await http.post(
        Uri.parse("${Config.paystackBackendUrl}/initialize_payment.php"),
        body: {
          "email": widget.email,
          "amount": koboAmount.toString(),
        },
      );

      final data = jsonDecode(response.body);

      if (data["status"] == true && data["data"]["authorization_url"] != null) {
        setState(() {
          _checkoutUrl = data["data"]["authorization_url"];
          _controller = WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..setNavigationDelegate(
              NavigationDelegate(
                onPageFinished: (url) {
                  if (url.contains("payment_success.php")) {
                    final uri = Uri.parse(url);
                    final ref = uri.queryParameters["reference"];
                    if (ref != null) {
                      _verifyPayment(ref);
                    }
                  }
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
      final response = await http.get(
        Uri.parse(
            "${Config.paystackBackendUrl}/verify_payment.php?reference=$reference"),
      );

      final data = jsonDecode(response.body);
      if (data["status"] == true && data["data"]["status"] == "success") {
        Navigator.pop(context, true); // Payment successful
      } else {
        Navigator.pop(context, false); // Payment failed
      }
    } catch (e) {
      debugPrint("Error verifying payment: $e");
      Navigator.pop(context, false);
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
