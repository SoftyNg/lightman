// lib/config.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  static late final String vtPassPublicKey;
  static late final String vtPassSecretKey;
  static late final String vtPassApiKey;
  static late final String vtPassBaseUrl;
  static late final String paystackPublicKey;
  static const String paystackBackendUrl =
      "https://realestatearena.com.ng/lightman";

  static void init() {
    vtPassPublicKey = dotenv.env['VT_PASS_PUBLIC_KEY'] ?? '';
    vtPassSecretKey = dotenv.env['VT_PASS_SECRET_KEY'] ?? '';
    vtPassApiKey = dotenv.env['VT_PASS_API_KEY'] ?? '';
    vtPassBaseUrl = dotenv.env['VT_PASS_BASE_URL'] ?? '';
    paystackPublicKey = dotenv.env['PAYSTACK_PUBLIC_KEY'] ?? '';

    if (vtPassPublicKey.isEmpty ||
        vtPassSecretKey.isEmpty ||
        vtPassApiKey.isEmpty ||
        vtPassBaseUrl.isEmpty ||
        paystackPublicKey.isEmpty) {
      throw Exception("One or more environment variables are missing in .env");
    }
  }
}
