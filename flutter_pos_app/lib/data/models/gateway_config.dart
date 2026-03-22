/// Gateway Configuration Model
class GatewayConfig {
  final String provider;
  final String apiKey;
  final String apiSecret;
  final int priority;
  final bool isEnabled;
  
  GatewayConfig({
    required this.provider,
    this.apiKey = '',
    this.apiSecret = '',
    this.priority = 0,
    this.isEnabled = true,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'provider': provider,
      'apiKey': apiKey,
      'apiSecret': apiSecret,
      'priority': priority,
      'isEnabled': isEnabled,
    };
  }
  
  factory GatewayConfig.fromJson(Map<String, dynamic> json) {
    return GatewayConfig(
      provider: json['provider'] ?? '',
      apiKey: json['apiKey'] ?? '',
      apiSecret: json['apiSecret'] ?? '',
      priority: json['priority'] ?? 0,
      isEnabled: json['isEnabled'] ?? true,
    );
  }
  
  GatewayConfig copyWith({
    String? provider,
    String? apiKey,
    String? apiSecret,
    int? priority,
    bool? isEnabled,
  }) {
    return GatewayConfig(
      provider: provider ?? this.provider,
      apiKey: apiKey ?? this.apiKey,
      apiSecret: apiSecret ?? this.apiSecret,
      priority: priority ?? this.priority,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}

/// Gateway Settings - manages all gateway configurations
class GatewaySettings {
  final List<GatewayConfig> gateways;
  
  GatewaySettings({required this.gateways});
  
  factory GatewaySettings.defaultGateways() {
    return GatewaySettings(
      gateways: [
        GatewayConfig(provider: 'onramper', priority: 1),
        GatewayConfig(provider: 'transak', priority: 2),
        GatewayConfig(provider: 'moonpay', priority: 3),
        GatewayConfig(provider: 'yellowcard', priority: 4),
      ],
    );
  }
  
  GatewayConfig? getPrimaryGateway() {
    final enabled = gateways.where((g) => g.isEnabled).toList();
    if (enabled.isEmpty) return null;
    enabled.sort((a, b) => a.priority.compareTo(b.priority));
    return enabled.first;
  }
  
  Map<String, dynamic> toJson() {
    return {
      'gateways': gateways.map((g) => g.toJson()).toList(),
    };
  }
  
  factory GatewaySettings.fromJson(Map<String, dynamic> json) {
    final List<dynamic> gatewaysJson = json['gateways'] ?? [];
    return GatewaySettings(
      gateways: gatewaysJson.map((g) => GatewayConfig.fromJson(g)).toList(),
    );
  }
}
