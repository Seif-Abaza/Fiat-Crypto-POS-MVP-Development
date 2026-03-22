import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

/// API Service for communicating with the backend
class ApiService {
  String _baseUrl;
  
  ApiService({String? baseUrl}) : _baseUrl = baseUrl ?? ApiConstants.defaultServerUrl;
  
  void setBaseUrl(String url) {
    _baseUrl = url;
  }
  
  String get baseUrl => _baseUrl;
  
  /// Verify PIN
  Future<Map<String, dynamic>> verifyPin(String deviceId, String pin) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl${ApiConstants.authVerify}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'device_id': deviceId, 'pin': pin}),
      );
      
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
  
  /// Send log to server
  Future<Map<String, dynamic>> sendLog(String deviceId, String level, String message) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl${ApiConstants.logs}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'device_id': deviceId,
          'level': level,
          'message': message,
        }),
      );
      
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
  
  /// Create P2P transaction
  Future<Map<String, dynamic>> createP2PTransaction({
    required String deviceId,
    required double amount,
    required String currency,
    required String cryptoCurrency,
    required String walletAddress,
    required String exchange,
    required double price,
    required double commission,
    required double finalAmount,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl${ApiConstants.p2pTransaction}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'device_id': deviceId,
          'amount': amount,
          'currency': currency,
          'crypto_currency': cryptoCurrency,
          'wallet_address': walletAddress,
          'exchange': exchange,
          'price': price,
          'commission': commission,
          'final_amount': finalAmount,
        }),
      );
      
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
  
  /// Get prices
  Future<Map<String, dynamic>> getPrices() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl${ApiConstants.prices}'),
      );
      
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e', 'prices': {}};
    }
  }
  
  /// Health check
  Future<bool> healthCheck() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl${ApiConstants.healthCheck}'),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
