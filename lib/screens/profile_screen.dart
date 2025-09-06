import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_services.dart';
import 'profile_settings_screen.dart'; // ✅ Import your settings screen

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  String firstName = '';
  String lastName = '';
  String email = '';
  String phoneNumber = '';

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
          firstName = userData['first_name'] ?? '';
          lastName = userData['last_name'] ?? '';
          email = userData['email'] ?? '';
          phoneNumber = userData['phone'] ?? '';
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error fetching user details: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await AuthService().signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    "Profile",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // ✅ Profile Box with navigation to settings
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFE7F8EC),
                        child: Icon(Icons.person, color: Colors.green),
                      ),
                      title: Text(
                        firstName.isNotEmpty || lastName.isNotEmpty
                            ? '$firstName $lastName'
                            : 'User',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                          phoneNumber.isNotEmpty ? phoneNumber : 'No phone'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),

                      // ✅ Navigate to ProfileSettingsScreen on tap
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProfileSettingsScreen(),
                          ),
                        );
                      },
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
                  buildMenuItem(
                      icon: Icons.lock_outline, title: "Change Password"),
                  buildMenuItem(
                      icon: Icons.help_outline, title: "Help & Support"),
                  buildMenuItem(
                    icon: Icons.logout,
                    title: "Logout",
                    iconBgColor: Colors.red.shade50,
                    iconColor: Colors.red,
                    onTap: _logout,
                  ),
                ],
              ),
      ),
    );
  }
}
