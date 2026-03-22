/// API Configuration Constants
class ApiConstants {
  // Server settings (VPS)
  static const String defaultServerUrl = 'http://144.172.100.67:8000';
  static const String defaultServerIp = '144.172.100.67';
  static const int defaultServerPort = 8000;
  
  // Endpoints
  static const String authVerify = '/auth/verify';
  static const String logs = '/logs';
  static const String p2pTransaction = '/p2p/transaction';
  static const String prices = '/prices';
  
  // Webhook endpoints
  static const String webhookOnramper = '/webhooks/onramper';
  static const String webhookTransak = '/webhooks/transak';
  static const String webhookMoonpay = '/webhooks/moonpay';
  static const String webhookYellowcard = '/webhooks/yellowcard';
  
  // Health check
  static const String healthCheck = '/health';
}

/// App Constants
class AppConstants {
  // Default PIN
  static const String defaultPin = '1234';
  
  // Device settings
  static const String defaultDeviceId = 'POS-001';
  static const String defaultBusinessName = 'My POS Business';
  
  // Supported Cryptocurrencies
  static const List<String> supportedCrypto = ['BTC', 'USDT', 'USDC', 'ETH'];
  
  // Supported Fiat Currencies
  static const List<String> supportedFiat = ['USD', 'EUR', 'GBP', 'NGN'];
  
  // Supported Exchanges for P2P
  static const List<String> supportedExchanges = ['OKX', 'Bybit'];
  
  // Default commission rate (percentage)
  static const double defaultCommissionRate = 1.5;
}

/// Payment Gateway Providers
class PaymentProviders {
  static const String onramper = 'onramper';
  static const String transak = 'transak';
  static const String moonpay = 'moonpay';
  static const String yellowcard = 'yellowcard';
  
  static const List<String> all = [onramper, transak, moonpay, yellowcard];
  
  static String getDisplayName(String provider) {
    switch (provider) {
      case onramper:
        return 'Onramper';
      case transak:
        return 'Transak';
      case moonpay:
        return 'MoonPay';
      case yellowcard:
        return 'Yellow Card';
      default:
        return provider;
    }
  }
}

/// Network Types for Crypto
class NetworkTypes {
  static const String bitcoin = 'bitcoin';
  static const String ethereum = 'ethereum';
  static const String trc20 = 'trc20';
  static const String erc20 = 'erc20';
  
  static Map<String, List<String>> cryptoNetworks = {
    'BTC': [bitcoin],
    'ETH': [ethereum],
    'USDT': [erc20, trc20],
    'USDC': [erc20, trc20],
  };
  
  static List<String> getNetworksForCrypto(String crypto) {
    return cryptoNetworks[crypto] ?? [ethereum];
  }
}
