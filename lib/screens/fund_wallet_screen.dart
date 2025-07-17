import 'package:flutter/material.dart';

class FundWalletScreen extends StatefulWidget {
  const FundWalletScreen({super.key});

  @override
  State<FundWalletScreen> createState() => _FundWalletScreenState();
}

class _FundWalletScreenState extends State<FundWalletScreen> {
  final TextEditingController _amountController = TextEditingController();
  bool isLoading = false;

  void _fundWallet() {
    final String amountText = _amountController.text.trim();

    if (amountText.isEmpty || double.tryParse(amountText) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    // This is where you'd normally integrate payment logic
    setState(() => isLoading = true);

    Future.delayed(const Duration(seconds: 2), () {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Simulated funding successful')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fund Wallet')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter amount (NGN)',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : _fundWallet,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Fund Wallet'),
            ),
          ],
        ),
      ),
    );
  }
}
