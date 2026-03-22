import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/device_settings.dart';
import '../../data/models/wallet_config.dart';
import '../../data/models/gateway_config.dart';
import '../../data/repositories/settings_repository.dart';

/// Settings Screen - Manages all device settings
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SettingsRepository _settings = SettingsRepository();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECEFF1),
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF1E88E5),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.payment), text: 'Gateways'),
            Tab(icon: Icon(Icons.wallet), text: 'Wallets'),
            Tab(icon: Icon(Icons.settings_applications), text: 'System'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _GatewaysTab(),
          _WalletsTab(),
          _SystemTab(),
        ],
      ),
    );
  }
}

/// Gateways Tab
class _GatewaysTab extends StatelessWidget {
  const _GatewaysTab();

  @override
  Widget build(BuildContext context) {
    final settings = SettingsRepository();
    final gatewaySettings = settings.gatewaySettings;
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Fiat Gateway Configuration',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Configure API keys and priority for payment gateways',
          style: TextStyle(color: Color(0xFF78909C)),
        ),
        const SizedBox(height: 16),
        
        ...gatewaySettings.gateways.map((gateway) {
          return _GatewayCard(
            gateway: gateway,
            onUpdate: (updated) {
              // Update gateway
              final index = gatewaySettings.gateways.indexWhere((g) => g.provider == gateway.provider);
              if (index != -1) {
                gatewaySettings.gateways[index] = updated;
                settings.setGatewaySettings(gatewaySettings);
              }
            },
          );
        }),
      ],
    );
  }
}

/// Gateway Card Widget
class _GatewayCard extends StatelessWidget {
  final GatewayConfig gateway;
  final Function(GatewayConfig) onUpdate;
  
  const _GatewayCard({
    required this.gateway,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Icon(
          _getGatewayIcon(gateway.provider),
          color: PosColors.cardModule,
        ),
        title: Text(
          _getGatewayName(gateway.provider),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          gateway.isEnabled ? 'Priority: ${gateway.priority}' : 'Disabled',
          style: TextStyle(
            color: gateway.isEnabled ? PosColors.successColor : PosColors.errorColor,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Enable/Disable Switch
                SwitchListTile(
                  title: const Text('Enable'),
                  value: gateway.isEnabled,
                  onChanged: (value) {
                    onUpdate(gateway.copyWith(isEnabled: value));
                  },
                ),
                
                // API Key
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'API Key',
                    border: OutlineInputBorder(),
                  ),
                  controller: TextEditingController(text: gateway.apiKey),
                  onChanged: (value) {
                    onUpdate(gateway.copyWith(apiKey: value));
                  },
                ),
                const SizedBox(height: 12),
                
                // API Secret
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'API Secret',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  controller: TextEditingController(text: gateway.apiSecret),
                  onChanged: (value) {
                    onUpdate(gateway.copyWith(apiSecret: value));
                  },
                ),
                const SizedBox(height: 12),
                
                // Priority
                DropdownButtonFormField<int>(
                  value: gateway.priority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                  ),
                  items: [1, 2, 3, 4].map((p) {
                    return DropdownMenuItem(
                      value: p,
                      child: Text('$p'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    onUpdate(gateway.copyWith(priority: value!));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  String _getGatewayName(String provider) {
    switch (provider) {
      case 'onramper':
        return 'Onramper';
      case 'transak':
        return 'Transak';
      case 'moonpay':
        return 'MoonPay';
      case 'yellowcard':
        return 'Yellow Card';
      default:
        return provider;
    }
  }
  
  IconData _getGatewayIcon(String provider) {
    switch (provider) {
      case 'onramper':
        return Icons.currency_exchange;
      case 'transak':
        return Icons.swap_horiz;
      case 'moonpay':
        return Icons.moon;
      case 'yellowcard':
        return Icons.credit_card;
      default:
        return Icons.payment;
    }
  }
}

/// Wallets Tab
class _WalletsTab extends StatefulWidget {
  const _WalletsTab();

  @override
  State<_WalletsTab> createState() => _WalletsTabState();
}

class _WalletsTabState extends State<_WalletsTab> {
  final SettingsRepository _settings = SettingsRepository();
  late TextEditingController _btcController;
  late TextEditingController _usdtController;
  late TextEditingController _usdcController;
  late String _defaultWallet;
  
  @override
  void initState() {
    super.initState();
    final wallet = _settings.walletConfig;
    _btcController = TextEditingController(text: wallet.btcAddress);
    _usdtController = TextEditingController(text: wallet.usdtAddress);
    _usdcController = TextEditingController(text: wallet.usdcAddress);
    _defaultWallet = wallet.defaultWallet;
  }

  @override
  void dispose() {
    _btcController.dispose();
    _usdtController.dispose();
    _usdcController.dispose();
    super.dispose();
  }

  void _saveWallets() {
    final wallet = WalletConfig(
      btcAddress: _btcController.text,
      usdtAddress: _usdtController.text,
      usdcAddress: _usdcController.text,
      defaultWallet: _defaultWallet,
    );
    _settings.setWalletConfig(wallet);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Wallets saved successfully'),
        backgroundColor: PosColors.successColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Wallet Addresses',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Enter wallet addresses for receiving crypto',
          style: TextStyle(color: Color(0xFF78909C)),
        ),
        const SizedBox(height: 16),
        
        // BTC Address
        _WalletInput(
          label: 'Bitcoin (BTC)',
          controller: _btcController,
          icon: Icons.currency_bitcoin,
        ),
        const SizedBox(height: 12),
        
        // USDT Address
        _WalletInput(
          label: 'Tether (USDT)',
          controller: _usdtController,
          icon: Icons.attach_money,
        ),
        const SizedBox(height: 12),
        
        // USDC Address
        _WalletInput(
          label: 'USD Coin (USDC)',
          controller: _usdcController,
          icon: Icons.money,
        ),
        const SizedBox(height: 16),
        
        // Default Wallet
        DropdownButtonFormField<String>(
          value: _defaultWallet,
          decoration: const InputDecoration(
            labelText: 'Default Wallet',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.star),
          ),
          items: ['BTC', 'USDT', 'USDC'].map((w) {
            return DropdownMenuItem(
              value: w,
              child: Text(w),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _defaultWallet = value!;
            });
          },
        ),
        const SizedBox(height: 24),
        
        // Save Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _saveWallets,
            child: const Text('Save Wallets'),
          ),
        ),
      ],
    );
  }
}

class _WalletInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  
  const _WalletInput({
    required this.label,
    required this.controller,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      controller: controller,
    );
  }
}

/// System Tab
class _SystemTab extends StatefulWidget {
  const _SystemTab();

  @override
  State<_SystemTab> createState() => _SystemTabState();
}

class _SystemTabState extends State<_SystemTab> {
  final SettingsRepository _settings = SettingsRepository();
  late TextEditingController _deviceIdController;
  late TextEditingController _businessNameController;
  late TextEditingController _serverUrlController;
  late String _themeColor;
  
  @override
  void initState() {
    super.initState();
    final device = _settings.deviceSettings;
    _deviceIdController = TextEditingController(text: device.deviceId);
    _businessNameController = TextEditingController(text: device.businessName);
    _serverUrlController = TextEditingController(text: device.serverUrl);
    _themeColor = device.themeColor;
  }

  @override
  void dispose() {
    _deviceIdController.dispose();
    _businessNameController.dispose();
    _serverUrlController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    final device = DeviceSettings(
      deviceId: _deviceIdController.text,
      businessName: _businessNameController.text,
      serverUrl: _serverUrlController.text,
      themeColor: _themeColor,
    );
    _settings.setDeviceSettings(device);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved successfully'),
        backgroundColor: PosColors.successColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'System Configuration',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Device ID
        TextField(
          decoration: const InputDecoration(
            labelText: 'Device ID',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.devices),
          ),
          controller: _deviceIdController,
        ),
        const SizedBox(height: 12),
        
        // Business Name
        TextField(
          decoration: const InputDecoration(
            labelText: 'Business Name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.business),
          ),
          controller: _businessNameController,
        ),
        const SizedBox(height: 12),
        
        // Server URL
        TextField(
          decoration: const InputDecoration(
            labelText: 'Server URL',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.dns),
            hintText: 'http://144.172.100.67:8000',
          ),
          controller: _serverUrlController,
        ),
        const SizedBox(height: 16),
        
        // Theme Color
        const Text(
          'Theme Color',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _ColorOption(color: '#1E88E5', name: 'Blue', selected: _themeColor == '#1E88E5', onTap: () => setState(() => _themeColor = '#1E88E5')),
            _ColorOption(color: '#43A047', name: 'Green', selected: _themeColor == '#43A047', onTap: () => setState(() => _themeColor = '#43A047')),
            _ColorOption(color: '#E53935', name: 'Red', selected: _themeColor == '#E53935', onTap: () => setState(() => _themeColor = '#E53935')),
            _ColorOption(color: '#FB8C00', name: 'Orange', selected: _themeColor == '#FB8C00', onTap: () => setState(() => _themeColor = '#FB8C00')),
            _ColorOption(color: '#8E24AA', name: 'Purple', selected: _themeColor == '#8E24AA', onTap: () => setState(() => _themeColor = '#8E24AA')),
          ],
        ),
        const SizedBox(height: 24),
        
        // Save Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _saveSettings,
            child: const Text('Save Settings'),
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Reset Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Reset Settings'),
                  content: const Text('Are you sure you want to reset all settings to default?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        _settings.clearAll();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Settings reset to default'),
                          ),
                        );
                      },
                      child: const Text('Reset', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: PosColors.errorColor,
              side: const BorderSide(color: PosColors.errorColor),
            ),
            child: const Text('Reset to Default'),
          ),
        ),
      ],
    );
  }
}

class _ColorOption extends StatelessWidget {
  final String color;
  final String name;
  final bool selected;
  final VoidCallback onTap;
  
  const _ColorOption({
    required this.color,
    required this.name,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
          borderRadius: BorderRadius.circular(20),
          border: selected ? Border.all(color: Colors.black, width: 2) : null,
        ),
        child: Text(
          name,
          style: TextStyle(
            color: Colors.white,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
