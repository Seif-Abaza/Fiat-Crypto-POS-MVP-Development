/// Device Settings Model
class DeviceSettings {
  final String deviceId;
  final String businessName;
  final String serverUrl;
  final String themeColor;
  
  DeviceSettings({
    required this.deviceId,
    required this.businessName,
    required this.serverUrl,
    required this.themeColor,
  });
  
  factory DeviceSettings.defaultSettings() {
    return DeviceSettings(
      deviceId: 'POS-001',
      businessName: 'My POS Business',
      serverUrl: 'http://144.172.100.67:8000',
      themeColor: '#1E88E5',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'businessName': businessName,
      'serverUrl': serverUrl,
      'themeColor': themeColor,
    };
  }
  
  factory DeviceSettings.fromJson(Map<String, dynamic> json) {
    return DeviceSettings(
      deviceId: json['deviceId'] ?? 'POS-001',
      businessName: json['businessName'] ?? 'My POS Business',
      serverUrl: json['serverUrl'] ?? 'http://144.172.100.67:8000',
      themeColor: json['themeColor'] ?? '#1E88E5',
    );
  }
  
  DeviceSettings copyWith({
    String? deviceId,
    String? businessName,
    String? serverUrl,
    String? themeColor,
  }) {
    return DeviceSettings(
      deviceId: deviceId ?? this.deviceId,
      businessName: businessName ?? this.businessName,
      serverUrl: serverUrl ?? this.serverUrl,
      themeColor: themeColor ?? this.themeColor,
    );
  }
}
