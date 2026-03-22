/// Wallet Configuration Model
class WalletConfig {
  final String btcAddress;
  final String usdtAddress;
  final String usdcAddress;
  final String defaultWallet;
  
  WalletConfig({
    required this.btcAddress,
    required this.usdtAddress,
    required this.usdcAddress,
    required this.defaultWallet,
  });
  
  factory WalletConfig.empty() {
    return WalletConfig(
      btcAddress: '',
      usdtAddress: '',
      usdcAddress: '',
      defaultWallet: 'USDT',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'btcAddress': btcAddress,
      'usdtAddress': usdtAddress,
      'usdcAddress': usdcAddress,
      'defaultWallet': defaultWallet,
    };
  }
  
  factory WalletConfig.fromJson(Map<String, dynamic> json) {
    return WalletConfig(
      btcAddress: json['btcAddress'] ?? '',
      usdtAddress: json['usdtAddress'] ?? '',
      usdcAddress: json['usdcAddress'] ?? '',
      defaultWallet: json['defaultWallet'] ?? 'USDT',
    );
  }
  
  String getAddressForCrypto(String crypto) {
    switch (crypto.toUpperCase()) {
      case 'BTC':
        return btcAddress;
      case 'USDT':
        return usdtAddress;
      case 'USDC':
        return usdcAddress;
      default:
        return '';
    }
  }
}
