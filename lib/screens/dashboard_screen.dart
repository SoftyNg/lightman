import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lightman/constants/app_colors.dart';
import 'package:lightman/screens/fund_wallet_screen.dart';
import 'package:lightman/screens/buy_power_screen.dart';
import 'package:lightman/screens/profile_screen.dart';
import 'package:lightman/services/transactions.dart';
import 'package:intl/intl.dart';

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
  String email = "";
  int userId = 0;
  double walletBalance = 0.0;
  bool isLoading = true;
  List<dynamic> transactions = [];
  final TransactionService _transactionService = TransactionService();

  @override
  void initState() {
    super.initState();
    _getUserDetails();
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
          email = userData['email'] ?? "";
          userId = int.tryParse(userData['id']?.toString() ?? "0") ?? 0;
          isLoading = false;
        });

        if (userId > 0 && email.isNotEmpty) {
          _getWalletBalance();
          _getTransactions();
        }
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _getWalletBalance() async {
    try {
      if (userId > 0) {
        final balance = await _transactionService.getWalletBalance(userId);
        setState(() => walletBalance = balance);
      }
    } catch (e) {}
  }

  Future<void> _getTransactions() async {
    try {
      final txns = await _transactionService.getTransactions(email);
      setState(() => transactions = txns);
    } catch (e) {}
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);

    if (index == 1) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const BuyPowerScreen()));
    } else if (index == 2) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()));
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
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
                                      "https://paystack.shop/pay/0va83vev7e",
                                ),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.account_balance_wallet,
                            color: Color(0xFF013D32), // Deep green
                          ),
                          label: const Text(
                            'Fund wallet',
                            style: TextStyle(
                              color: Color(0xFF013D32), // Deep green
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Color(0xFFF1F2F6), // Light gray background
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(30), // Pill shape
                            ),
                            elevation: 0, // Flat look
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
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
                          icon: const Icon(Icons.flash_on, color: Colors.white),
                          label: const Text(
                            'Buy electricity',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                AppColors.primaryGreen, // green background
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(30), // pill-shaped
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ✅ Updated Spent & Units using correct types
            Row(
              children: [
                Expanded(
                  child: FutureBuilder<Map<String, dynamic>>(
                    future: _transactionService
                        .getTotalSpent(email)
                        .then((res) => res),
                    builder: (context, snapshot) {
                      double totalSpentAmount = 0.0;
                      if (snapshot.hasData) {
                        totalSpentAmount = double.tryParse(
                                snapshot.data!['total'].toString()) ??
                            0.0;
                      }
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.money_off, color: Colors.red),
                            const SizedBox(height: 8),
                            const Text('Spent'),
                            Text(
                              NumberFormat.currency(
                                      locale: 'en_NG', symbol: '₦')
                                  .format(totalSpentAmount),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FutureBuilder<Map<String, dynamic>>(
                    future: _transactionService.getTotalUnits(email),
                    builder: (context, snapshot) {
                      double totalUnitsPurchased = 0.0;

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return const Text("Error loading units",
                            style: TextStyle(color: Colors.red));
                      }

                      if (snapshot.hasData) {
                        final data = snapshot.data!;
                        if (data['status'] == true && data['total'] != null) {
                          totalUnitsPurchased =
                              double.tryParse(data['total'].toString()) ?? 0.0;
                        }
                        print("🔎 Units API Response: $data"); // Debug log
                      }

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.bolt, color: Colors.green),
                            const SizedBox(height: 8),
                            const Text('Units'),
                            Text(
                              '${totalUnitsPurchased.toStringAsFixed(1)}Kwh',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    },
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

            // ✅ Transactions list with null-safe handling
            if (transactions.isEmpty)
              Column(
                children: [
                  const SizedBox(height: 40),
                  Center(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/no_transactions.png', // Make sure this file exists in your assets folder
                          width: 60,
                          height: 60,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "No transactions yet",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Once you start paying your electricity bills,\nyour recent activity will show up here",
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              )
            else
              Column(
                children: transactions.map((txn) {
                  if (txn == null) return const SizedBox.shrink();

                  String createdAt = txn['created_at'] ?? "";
                  String formattedDate = "";
                  if (createdAt.isNotEmpty) {
                    try {
                      DateTime parsedDate = DateTime.parse(createdAt);
                      formattedDate =
                          DateFormat('dd MMM yyyy').format(parsedDate);
                    } catch (e) {
                      formattedDate = createdAt;
                    }
                  }

                  return _transactionTile(
                    txn['disco_name'] ?? "Abuja",
                    txn['token'] ?? "",
                    "", // location not in API
                    txn['transaction_id']?.toString() ?? "N/A",
                    "₦${txn['total_amount'] ?? 0}",
                    formattedDate,
                  );
                }).toList(),
              ),

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
