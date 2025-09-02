import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lightman/constants/app_colors.dart';
import 'package:lightman/screens/fund_wallet_screen.dart'; // <-- for webview
import 'package:lightman/screens/buy_power_screen.dart';
import 'package:lightman/screens/profile_screen.dart';
import 'package:lightman/services/transactions.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _showBalance = true;
  int _selectedIndex = 0;

  String firstName = "";
  String lastName = "";
  int userId = 0;
  double walletBalance = 0.0;
  bool isLoading = true;
  final TransactionService _transactionService = TransactionService();

  @override
  void initState() {
    super.initState();
    _getUserDetails();
    //_getWalletBalance();
  }

  Future<void> _getUserDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');

      if (userDataString != null) {
        final userData = jsonDecode(userDataString);
        setState(() {
          firstName = userData['first_name'] ?? "";
          lastName = userData['last_name'] ?? "";
          userId = (userData['id']?.toString() ?? "") as int;
          isLoading = false;
        });
      } else {
        // Fallback: No stored user data found
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BuyPowerScreen()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  void _showMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(leading: Icon(Icons.settings), title: Text('Settings')),
          ListTile(leading: Icon(Icons.help_outline), title: Text('Help')),
          ListTile(leading: Icon(Icons.logout), title: Text('Logout')),
        ],
      ),
    );
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
              leading: Icon(Icons.notifications),
              title: Text("Your wallet was funded successfully.")),
          ListTile(
              leading: Icon(Icons.notifications),
              title: Text("Your electricity purchase is complete.")),
          ListTile(
              leading: Icon(Icons.notifications),
              title: Text("You earned a bonus unit!")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: _showMenu,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined,
                color: Colors.black),
            onPressed: _showNotifications,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getGreeting(),
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 4),
            isLoading
                ? const Text(
                    'Loading...',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  )
                : Text(
                    "$firstName $lastName",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Wallet balance',
                      style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _showBalance
                            ? '₦${walletBalance.toStringAsFixed(0)}'
                            : '••••••',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _showBalance
                              ? Icons.visibility_off_outlined
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() => _showBalance = !_showBalance);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FundWalletScreen(
                                  paymentUrl:
                                      "https://paystack.shop/pay/0va83vev7e", // keep same
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.account_balance_wallet),
                          label: const Text('Fund wallet'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const BuyPowerScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.flash_on),
                          label: const Text('Buy electricity'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.money_off, color: Colors.red),
                        SizedBox(height: 8),
                        Text('Spent'),
                        Text('₦45,700',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.bolt, color: Colors.green),
                        SizedBox(height: 8),
                        Text('Units'),
                        Text('800',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent transactions',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text('See all', style: TextStyle(color: AppColors.primaryGreen))
              ],
            ),
            const SizedBox(height: 12),
            _transactionTile('AEDC', '14273567892', 'Abuja',
                '72cty937293726292012', '₦40,700', '12 jan 2025'),
            _transactionTile('EKEDC', '14273567893', 'Lagos',
                '82cty937293726292013', '₦45,500', '15 jan 2025'),
            _transactionTile('AEDC', '14273567894', 'Abuja',
                '92cty937293726292014', '₦38,250', '20 jan 2025'),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppColors.primaryGreen,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.flash_on), label: 'Buy'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _transactionTile(String company, String meter, String location,
      String ref, String amount, String date) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          backgroundImage:
              AssetImage('assets/images/${company.toLowerCase()}.png'),
        ),
        title: Text('$meter • $location'),
        subtitle: Text(ref),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(amount, style: const TextStyle(color: Colors.green)),
            Text(date, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
