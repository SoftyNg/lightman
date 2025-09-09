import 'package:flutter/material.dart';
import 'package:lightman/constants/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        "title": "8756-9021-4583-7702.",
        "message":
            "Your ₦5,000 payment to IKEDC was successful. Here’s your token: 8756-9021-4583-7702.",
        "highlight": false,
        "onTap": () {
          // Example action: navigate to transaction details
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Opening payment details...")),
          );
        },
      },
      {
        "title": "Wallet topped up",
        "message": "₦5,000 has been added to your Lightman wallet.",
        "highlight": true,
        "onTap": () {
          // Example action: navigate to wallet screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Opening wallet...")),
          );
        },
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Notifications",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.separated(
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 6),
        itemBuilder: (context, index) {
          final item = notifications[index];
          return InkWell(
            onTap: item["onTap"] as void Function()?,
            child: Container(
              padding: const EdgeInsets.all(14),
              color: item["highlight"] as bool
                  ? AppColors.primaryGreen.withOpacity(0.1)
                  : Colors.white,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                    child: const Icon(
                      Icons.bolt, // Lightning icon
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item["title"] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item["message"] as String,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
