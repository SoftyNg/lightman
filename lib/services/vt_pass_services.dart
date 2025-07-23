import 'dart:convert';
import 'package:http/http.dart' as http;

class VtpassService {
  static const _username = 'thelaw111@gmail.com';
  static const _password = 'Gunner222@insta1';
  static const _baseUrl = 'https://sandbox.vtpass.com/api';

  // Helper method to return headers
  static Map<String, String> _headers() {
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$_username:$_password'));
    return {
      'Authorization': basicAuth,
      'Content-Type': 'application/json',
    };
  }

  // 🔌 Step 1: Meter verification
  static Future<Map<String, dynamic>> verifyMeter({
    required String disco,
    required String meterNumber,
    required String meterType,
  }) async {
    final url = Uri.parse('$_baseUrl/merchant-verify');
    final response = await http.post(
      url,
      headers: _headers(),
      body: jsonEncode({
        "billersCode": meterNumber,
        "serviceID": disco,
        "type": meterType,
      }),
    );

    print("VERIFY METER Response: ${response.body}");
    return jsonDecode(response.body);
  }

  // 🔌 Step 2: Buy electricity
  static Future<Map<String, dynamic>> buyElectricity({
    required String disco,
    required String meterNumber,
    required String meterType,
    required String phone,
    required String amount,
  }) async {
    final url = Uri.parse('$_baseUrl/pay');
    final response = await http.post(
      url,
      headers: _headers(),
      body: jsonEncode({
        "request_id": DateTime.now().millisecondsSinceEpoch.toString(),
        "serviceID": disco,
        "billersCode": meterNumber,
        "variation_code": meterType,
        "amount": amount,
        "phone": phone,
      }),
    );

    print("BUY POWER Response: ${response.body}");
    return jsonDecode(response.body);
  }
}
