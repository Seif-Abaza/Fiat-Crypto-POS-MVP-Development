import 'dart:convert';
import 'package:http/http.dart' as http;

/// P2P Price Service - Searches for best prices from exchanges
class P2PPriceService {
  // In production, these would be actual API endpoints
  static const String _okxApiUrl = 'https://www.okx.com';
  static const String _bybitApiUrl = 'https://api.bybit.com';
  
  /// Get P2P prices from OKX (simulated)
  Future<P2PPrice?> getOKXPrice({
    required String crypto,
    required String fiat,
    required String bank,
  }) async {
    try {
      // In production, make actual API call to OKX P2P
      // For now, return simulated prices
      final basePrice = await _getBasePrice(crypto, fiat);
      if (basePrice == null) return null;
      
      // Simulate OKX P2P spread
      final spread = 0.005 + (bank.length % 10) * 0.001;
      final price = basePrice * (1 + spread);
      final commission = price * 0.001;
      
      return P2PPrice(
        exchange: 'OKX',
        cryptoCurrency: crypto,
        fiatCurrency: fiat,
        price: price,
        commission: commission,
        availableAmount: 10000.0,
        bank: bank,
      );
    } catch (e) {
      return null;
    }
  }
  
  /// Get P2P prices from Bybit (simulated)
  Future<P2PPrice?> getBybitPrice({
    required String crypto,
    required String fiat,
    required String bank,
  }) async {
    try {
      final basePrice = await _getBasePrice(crypto, fiat);
      if (basePrice == null) return null;
      
      // Simulate Bybit P2P spread (slightly different from OKX)
      final spread = 0.006 + (bank.length % 10) * 0.001;
      final price = basePrice * (1 + spread);
      final commission = price * 0.001;
      
      return P2PPrice(
        exchange: 'Bybit',
        cryptoCurrency: crypto,
        fiatCurrency: fiat,
        price: price,
        commission: commission,
        availableAmount: 15000.0,
        bank: bank,
      );
    } catch (e) {
      return null;
    }
  }
  
  /// Get best price from all exchanges
  Future<P2PPrice?> getBestPrice({
    required String crypto,
    required String fiat,
    required String bank,
  }) async {
    final results = await Future.wait([
      getOKXPrice(crypto: crypto, fiat: fiat, bank: bank),
      getBybitPrice(crypto: crypto, fiat: fiat, bank: bank),
    ]);
    
    final validPrices = results.where((p) => p != null).toList();
    if (validPrices.isEmpty) return null;
    
    // Find lowest price
    validPrices.sort((a, b) => a!.price.compareTo(b!.price));
    return validPrices.first;
  }
  
  /// Get all prices from all exchanges
  Future<List<P2PPrice>> getAllPrices({
    required String crypto,
    required String fiat,
    required String bank,
  }) async {
    final results = await Future.wait([
      getOKXPrice(crypto: crypto, fiat: fiat, bank: bank),
      getBybitPrice(crypto: crypto, fiat: fiat, bank: bank),
    ]);
    
    return results.where((p) => p != null).cast<P2PPrice>().toList();
  }
  
  /// Get base price from market (simulated)
  Future<double?> _getBasePrice(String crypto, String fiat) async {
    // Simulated base prices - in production, fetch from real APIs
    final prices = {
      'BTC': {'USD': 67500.0, 'EUR': 62000.0, 'GBP': 53000.0},
      'ETH': {'USD': 3450.0, 'EUR': 3170.0, 'GBP': 2700.0},
      'USDT': {'USD': 1.0, 'EUR': 0.92, 'GBP': 0.79},
      'USDC': {'USD': 1.0, 'EUR': 0.92, 'GBP': 0.79},
    };
    
    return prices[crypto]?[fiat];
  }
  
  /// Get supported banks for P2P
  static List<String> getSupportedBanks() {
    return [
      'Chase',
      'Bank of America',
      'Wells Fargo',
      'Citibank',
      'US Bank',
      'PNC Bank',
      'TD Bank',
      'HSBC',
      'Standard Chartered',
      'First Bank of Nigeria',
      'Guaranty Trust Bank',
      'Access Bank',
    ];
  }
}

/// P2P Price Model
class P2PPrice {
  final String exchange;
  final String cryptoCurrency;
  final String fiatCurrency;
  final double price;
  final double commission;
  final double availableAmount;
  final String bank;
  
  P2PPrice({
    required this.exchange,
    required this.cryptoCurrency,
    required this.fiatCurrency,
    required this.price,
    required this.commission,
    required this.availableAmount,
    required this.bank,
  });
  
  double get totalPrice => price + commission;
  
  double getCryptoAmount(double fiatAmount) {
    return fiatAmount / price;
  }
  
  @override
  String toString() {
    return 'P2PPrice(exchange: $exchange, price: $price $fiatCurrency, commission: $commission)';
  }
}
