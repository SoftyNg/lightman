import 'package:flutter/material.dart';
import '../services/vt_pass_services.dart'; // Make sure path is correct

class BuyPowerScreen extends StatefulWidget {
  const BuyPowerScreen({Key? key}) : super(key: key);

  @override
  State<BuyPowerScreen> createState() => _BuyPowerScreenState();
}

class _BuyPowerScreenState extends State<BuyPowerScreen> {
  final _formKey = GlobalKey<FormState>();

  final List<Map<String, String>> discos = [
    {"name": "Ikeja Electric", "code": "ikeja-electric"},
    {"name": "Eko Electric", "code": "eko-electric"},
    {"name": "Abuja Electric", "code": "abuja-electric"},
    {"name": "Kano Electric", "code": "kano-electric"},
    {"name": "Port Harcourt Electric", "code": "portharcourt-electric"},
    {"name": "Jos Electric", "code": "jos-electric"},
    {"name": "Benin Electric", "code": "benin-electric"},
    {"name": "Ibadan Electric", "code": "ibadan-electric"},
    {"name": "Enugu Electric", "code": "enugu-electric"},
    {"name": "Yola Electric", "code": "yola-electric"},
  ];

  String? selectedDisco;
  String? meterType = 'Prepaid';

  final meterNumberController = TextEditingController();
  final amountController = TextEditingController();

  @override
  void dispose() {
    meterNumberController.dispose();
    amountController.dispose();
    super.dispose();
  }

  Future<void> _buyElectricity() async {
    if (!_formKey.currentState!.validate()) return;

    final discoCode = selectedDisco!;
    final meterNumber = meterNumberController.text.trim();
    final amount = amountController.text.trim();
    final type = meterType!.toLowerCase(); // 'prepaid' or 'postpaid'

    showLoading(true);

    try {
      // 🔍 Step 1: Verify meter number
      final verifyResult = await VtPassService.verifyMeter(
        disco: discoCode,
        meterNumber: meterNumber,
        meterType: type,
      );

      if (verifyResult['code'] != '000') {
        showLoading(false);
        final errorMsg = verifyResult['message'] ??
            verifyResult['response_description'] ??
            verifyResult['content']?['error'] ??
            'Meter verification failed';
        showSnack('❌ $errorMsg');
        return;
      }

      final customerName = verifyResult['Customer_Name'] ??
          verifyResult['content']?['Customer_Name'] ??
          'Customer';

      showSnack('✅ Verified: $customerName');

      // ⚡ Step 2: Buy electricity
      final buyResult = await VtPassService.buyElectricity(
        disco: discoCode,
        meterNumber: meterNumber,
        meterType: type,
        phone: '08012345678', // Replace with user's phone
        amount: amount,
      );

      showLoading(false);

      if (buyResult['code'] == '000') {
        showSnack('✅ Electricity purchase successful!');
      } else {
        final errorMsg = buyResult['message'] ??
            buyResult['response_description'] ??
            'Purchase failed';
        showSnack('❌ $errorMsg');
      }
    } catch (e) {
      showLoading(false);
      showSnack('❌ Error: ${e.toString()}');
    }
  }

  void showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
    ));
  }

  void showLoading(bool loading) {
    if (loading) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
    } else {
      if (Navigator.canPop(context)) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Buy Electricity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: selectedDisco,
                        decoration: _inputDecoration('Select a Disco'),
                        items: discos.map((disco) {
                          return DropdownMenuItem<String>(
                            value: disco['code'],
                            child: Text(disco['name'] ?? ''),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedDisco = value;
                          });
                        },
                        validator: (value) =>
                            value == null ? 'Please select a disco' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: meterNumberController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('Meter number'),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Enter meter number'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: meterType,
                        decoration: _inputDecoration('Meter type'),
                        items: ['Prepaid', 'Postpaid'].map((type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            meterType = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('Amount'),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Enter amount'
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _buyElectricity,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C853),
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: const Color(0xFF00C853),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flash_on),
            label: 'Buy',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF1F1F5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
