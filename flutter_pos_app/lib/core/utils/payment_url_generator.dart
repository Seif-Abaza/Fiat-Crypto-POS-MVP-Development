import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Payment Gateway URL Generator
/// Dynamically generates URLs for different providers based on settings
class PaymentUrlGenerator {
  /// Generate payment URL for Onramper
  static String generateOnramperUrl({
    required String apiKey,
    required String amount,
    required String walletAddress,
    required String cryptoCurrency,
    String? network,
  }) {
    final baseUrl = 'https://widget.onramper.com';
    final params = <String, String>{
      'apiKey': apiKey,
      'amount': amount,
      'walletAddress': walletAddress,
      'cryptoCurrency': cryptoCurrency,
      if (network != null) 'network': network,
    };
    
    final queryString = params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
    return '$baseUrl?$queryString';
  }
  
  /// Generate payment URL for Transak
  static String generateTransakUrl({
    required String apiKey,
    required String amount,
    required String walletAddress,
    required String cryptoCurrency,
    String? network,
  }) {
    final baseUrl = 'https://global.transak.com';
    final params = <String, String>{
      'apiKey': apiKey,
      'fiatAmount': amount,
      'cryptoCurrency': cryptoCurrency,
      'walletAddress': walletAddress,
      if (network != null) 'network': network,
    };
    
    // Sign URL for security (Transak requires URL signing)
    final unsignedUrl = '$baseUrl?${params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&')}';
    return _signTransakUrl(unsignedUrl, apiKey);
  }
  
  /// Generate payment URL for MoonPay
  static String generateMoonpayUrl({
    required String apiKey,
    required String amount,
    required String walletAddress,
    required String cryptoCurrency,
    String? network,
  }) {
    final baseUrl = 'https://buy.moonpay.com';
    final params = <String, String>{
      'apiKey': apiKey,
      'amount': amount,
      'walletAddress': walletAddress,
      'currencyCode': cryptoCurrency.toLowerCase(),
      if (network != null) 'network': network,
    };
    
    // MoonPay requires signature for sensitive params
    final queryString = params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
    final signature = _generateMoonpaySignature(queryString, apiKey);
    
    return '$baseUrl?$queryString&signature=$signature';
  }
  
  /// Generate payment URL for Yellow Card
  static String generateYellowCardUrl({
    required String apiKey,
    required String amount,
    required String walletAddress,
    required String cryptoCurrency,
  }) {
    final baseUrl = 'https://yellowcard.io/widget';
    final params = <String, String>{
      'api_key': apiKey,
      'amount': amount,
      'address': walletAddress,
      'currency': cryptoCurrency,
    };
    
    final queryString = params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
    return '$baseUrl?$queryString';
  }
  
  /// Generate URL based on provider
  static String generateUrl({
    required String provider,
    required String apiKey,
    required String amount,
    required String walletAddress,
    required String cryptoCurrency,
    String? network,
  }) {
    switch (provider.toLowerCase()) {
      case 'onramper':
        return generateOnramperUrl(
          apiKey: apiKey,
          amount: amount,
          walletAddress: walletAddress,
          cryptoCurrency: cryptoCurrency,
          network: network,
        );
      case 'transak':
        return generateTransakUrl(
          apiKey: apiKey,
          amount: amount,
          walletAddress: walletAddress,
          cryptoCurrency: cryptoCurrency,
          network: network,
        );
      case 'moonpay':
        return generateMoonpayUrl(
          apiKey: apiKey,
          amount: amount,
          walletAddress: walletAddress,
          cryptoCurrency: cryptoCurrency,
          network: network,
        );
      case 'yellowcard':
        return generateYellowCardUrl(
          apiKey: apiKey,
          amount: amount,
          walletAddress: walletAddress,
          cryptoCurrency: cryptoCurrency,
        );
      default:
        throw Exception('Unknown provider: $provider');
    }
  }
  
  /// Sign URL for Transak (simplified - in production use proper HMAC)
  static String _signTransakUrl(String url, String apiKey) {
    // In production, implement proper HMAC signing with Transak's secret
    // This is a simplified version for demonstration
    final key = utf8.encode(apiKey);
    final bytes = utf8.encode(url);
    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(bytes);
    return '$url&signature=${digest.toString()}';
  }
  
  /// Generate signature for MoonPay
  static String _generateMoonpaySignature(String queryString, String apiKey) {
    // In production, implement proper MoonPay signature generation
    final key = utf8.encode(apiKey);
    final bytes = utf8.encode(queryString);
    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(bytes);
    return digest.toString();
  }
  
  /// Validate URL signature for MoonPay webhook
  static bool validateMoonpaySignature(String payload, String signature, String apiSecret) {
    final key = utf8.encode(apiSecret);
    final bytes = utf8.encode(payload);
    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(bytes);
    return digest.toString() == signature;
  }
  
  /// Generate default/fallback URLs for testing
  static Map<String, String> getDefaultUrls() {
    return {
      'onramper': 'https://widget.onramper.com?apiKey=demo&amount=100&walletAddress=demo',
      'transak': 'https://global.transak.com?apiKey=demo&fiatAmount=100',
      'moonpay': 'https://buy.moonpay.com?apiKey=demo&amount=100',
      'yellowcard': 'https://yellowcard.io/widget?api_key=demo&amount=100',
    };
  }
}
