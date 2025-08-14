import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = '';
  String phoneNumber = '';

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (snapshot.exists) {
          final data = snapshot.data();
          setState(() {
            userName = data?['name'] ?? user.displayName ?? 'User';
            phoneNumber = data?['phone'] ?? user.phoneNumber ?? '';
          });
        } else {
          setState(() {
            userName = user.displayName ?? 'User';
            phoneNumber = user.phoneNumber ?? '';
          });
        }
      } catch (e) {
        print('Error fetching user details: $e');
        setState(() {
          userName = user.displayName ?? 'User';
          phoneNumber = user.phoneNumber ?? '';
        });
      }
    }
  }

  Widget buildMenuItem({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Color? iconBgColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: iconBgColor ?? Colors.green.shade50,
        child: Icon(icon, color: iconColor ?? Colors.green),
      ),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap ?? () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              "Profile",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Profile Box
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE7F8EC),
                  child: Icon(Icons.person, color: Colors.green),
                ),
                title: Text(
                  userName.isNotEmpty ? userName : 'Loading...',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                    phoneNumber.isNotEmpty ? phoneNumber : 'Fetching phone...'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              "General",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            buildMenuItem(icon: Icons.save, title: "Saved meters"),
            buildMenuItem(
                icon: Icons.notifications_none, title: "Notifications"),
            buildMenuItem(icon: Icons.lock_outline, title: "Change Password"),
            buildMenuItem(icon: Icons.help_outline, title: "Help & Support"),
            buildMenuItem(
              icon: Icons.logout,
              title: "Logout",
              iconBgColor: Colors.red.shade50,
              iconColor: Colors.red,
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.flash_on), label: 'Buy'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/buy');
          }
        },
      ),
    );
  }
}
