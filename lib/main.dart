import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lightman/screens/splash_screen.dart';
import 'package:lightman/constants/app_colors.dart';
import 'firebase_options.dart'; // ✅ Ensure this is imported

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Firebase with platform-specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lightman App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.darkGreen),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
