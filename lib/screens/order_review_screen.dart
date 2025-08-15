import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ For fetching logged-in user
import 'paystack_payment_screen.dart'; // Import your Paystack WebView screen

class ReviewOrderScreen extends StatelessWidget {
  final String discoName;
  final String discoCode;
  final String meterNumber;
  final String meterType;
  final String customerName;
  final String meterName;
  final String address;
  final String customerAddress;
  final double electricityAmount;
  final double serviceCharge;

  const ReviewOrderScreen({
    super.key,
    required this.discoName,
    required this.discoCode,
    required this.meterNumber,
    required this.meterType,
    required this.customerName,
    required this.customerAddress,
    required this.electricityAmount,
    required this.serviceCharge,
    required this.meterName,
    required this.address,
  });

  /// Calculates ₦100 per ₦5,000 block
  int _serviceChargeFromAmount(double amount) {
    if (amount <= 0) return 0;
    final blocks = (amount / 5000).ceil();
    return blocks * 100;
  }

  @override
  Widget build(BuildContext context) {
    final computedServiceCharge =
        _serviceChargeFromAmount(electricityAmount).toDouble();
    final total = electricityAmount + computedServiceCharge;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F9),
      appBar: AppBar(
        title: const Text("Review your order"),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Amount Display
            Center(
              child: Text(
                "₦${total.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Order Details Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildRow("Disco", discoName),
                    _buildRow("Meter Number", meterNumber),
                    _buildRow("Meter Type", meterType),
                    _buildRow("Customer Name", customerName),
                    _buildRow("Address", customerAddress),
                    _buildRow(
                      "Electricity Amount",
                      "₦${electricityAmount.toStringAsFixed(2)}",
                    ),
                    _buildRow(
                      "Service Charge",
                      "₦${computedServiceCharge.toStringAsFixed(2)}",
                    ),
                    const Divider(),
                    _buildRow(
                      "Total",
                      "₦${total.toStringAsFixed(2)}",
                      isBold: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Choose Payment Method Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  final user = FirebaseAuth.instance.currentUser;
                  final email = user?.email ?? "";

                  if (email.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("No logged in user found"),
                      ),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaystackPaymentScreen(
                        amount: total, // Pass total amount
                        email: email, // ✅ Logged-in user's email
                      ),
                    ),
                  );
                },
                child: const Text(
                  "Choose payment method",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          Flexible(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
