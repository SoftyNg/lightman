import 'dart:convert';
import 'package:http/http.dart' as http;

class TransactionService {
  final String baseUrl =
      "https://realestatearena.com.ng"; // change to your server URL

  /// Credit a user's wallet
  Future<Map<String, dynamic>> creditWallet({
    required int userId,
    required double amount,
    String type = "credit",
    String description = "Wallet credited",
  }) async {
    final url = Uri.parse("$baseUrl/transactions/credit.php");

    final response = await http.post(
      url,
      body: {
        "user_id": userId.toString(),
        "amount": amount.toString(),
        "type": type,
        "description": description,
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to credit wallet");
    }
  }

  /// Debit a user's wallet
  Future<Map<String, dynamic>> debitWallet({
    required int userId,
    required double amount,
    String type = "debit",
    String description = "Wallet debited",
  }) async {
    final url = Uri.parse("$baseUrl/transactions/debit.php");

    final response = await http.post(
      url,
      body: {
        "user_id": userId.toString(),
        "amount": amount.toString(),
        "type": type,
        "description": description,
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to debit wallet");
    }
  }

  /// Fetch transaction history
  Future<List<dynamic>> getTransactions(int userId) async {
    final url = Uri.parse("$baseUrl/transactions/history.php?user_id=$userId");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to fetch transactions");
    }
  }

  /// Fetch wallet balance
  Future<double> getWalletBalance(int userId) async {
    final url = Uri.parse("$baseUrl/get_wallet_balance.php");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({"user_id": userId}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data["status"] == "success") {
        return double.tryParse(data["balance"].toString()) ?? 0.0;
      } else {
        throw Exception(data["message"] ?? "Failed to get wallet balance");
      }
    } else {
      throw Exception("Failed to fetch wallet balance");
    }
  }
}
