import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/device_settings.dart';
import '../models/wallet_config.dart';
import '../models/gateway_config.dart';

/// Local Storage Keys
class StorageKeys {
  static const String deviceSettings = 'device_settings';
  static const String walletConfig = 'wallet_config';
  static const String gatewaySettings = 'gateway_settings';
  static const String isAuthenticated = 'is_authenticated';
  static const String authToken = 'auth_token';
}

/// Settings Repository - manages local storage for app settings
class SettingsRepository {
  // In-memory cache
  DeviceSettings? _deviceSettings;
  WalletConfig? _walletConfig;
  GatewaySettings? _gatewaySettings;
  bool _isAuthenticated = false;
  String? _authToken;
  
  // Singleton pattern
  static final SettingsRepository _instance = SettingsRepository._internal();
  factory SettingsRepository() => _instance;
  SettingsRepository._internal();
  
  // Device Settings
  DeviceSettings get deviceSettings {
    _deviceSettings ??= DeviceSettings.defaultSettings();
    return _deviceSettings!;
  }
  
  void setDeviceSettings(DeviceSettings settings) {
    _deviceSettings = settings;
    _saveToPrefs(StorageKeys.deviceSettings, jsonEncode(settings.toJson()));
  }
  
  // Wallet Config
  WalletConfig get walletConfig {
    _walletConfig ??= WalletConfig.empty();
    return _walletConfig!;
  }
  
  void setWalletConfig(WalletConfig config) {
    _walletConfig = config;
    _saveToPrefs(StorageKeys.walletConfig, jsonEncode(config.toJson()));
  }
  
  // Gateway Settings
  GatewaySettings get gatewaySettings {
    _gatewaySettings ??= GatewaySettings.defaultGateways();
    return _gatewaySettings!;
  }
  
  void setGatewaySettings(GatewaySettings settings) {
    _gatewaySettings = settings;
    _saveToPrefs(StorageKeys.gatewaySettings, jsonEncode(settings.toJson()));
  }
  
  // Authentication
  bool get isAuthenticated => _isAuthenticated;
  
  void setAuthenticated(bool value, {String? token}) {
    _isAuthenticated = value;
    _authToken = token;
    _saveToPrefs(StorageKeys.isAuthenticated, value.toString());
    if (token != null) {
      _saveToPrefs(StorageKeys.authToken, token);
    }
  }
  
  String? get authToken => _authToken;
  
  // Clear all settings
  void clearAll() {
    _deviceSettings = null;
    _walletConfig = null;
    _gatewaySettings = null;
    _isAuthenticated = false;
    _authToken = null;
    _clearPrefs(StorageKeys.deviceSettings);
    _clearPrefs(StorageKeys.walletConfig);
    _clearPrefs(StorageKeys.gatewaySettings);
    _clearPrefs(StorageKeys.isAuthenticated);
    _clearPrefs(StorageKeys.authToken);
  }
  
  // Placeholder methods - in production, use shared_preferences
  void _saveToPrefs(String key, String value) {
    // TODO: Implement with shared_preferences
    if (kDebugMode) {
      print('[Settings] Saved: $key = $value');
    }
  }
  
  String? _loadFromPrefs(String key) {
    // TODO: Implement with shared_preferences
    return null;
  }
  
  void _clearPrefs(String key) {
    // TODO: Implement with shared_preferences
  }
  
  /// Load all settings from storage
  Future<void> loadSettings() async {
    // TODO: Implement with shared_preferences
    // Load device settings
    final deviceJson = _loadFromPrefs(StorageKeys.deviceSettings);
    if (deviceJson != null) {
      _deviceSettings = DeviceSettings.fromJson(jsonDecode(deviceJson));
    }
    
    // Load wallet config
    final walletJson = _loadFromPrefs(StorageKeys.walletConfig);
    if (walletJson != null) {
      _walletConfig = WalletConfig.fromJson(jsonDecode(walletJson));
    }
    
    // Load gateway settings
    final gatewayJson = _loadFromPrefs(StorageKeys.gatewaySettings);
    if (gatewayJson != null) {
      _gatewaySettings = GatewaySettings.fromJson(jsonDecode(gatewayJson));
    }
    
    // Load auth state
    final isAuthStr = _loadFromPrefs(StorageKeys.isAuthenticated);
    _isAuthenticated = isAuthStr == 'true';
    _authToken = _loadFromPrefs(StorageKeys.authToken);
  }
}
