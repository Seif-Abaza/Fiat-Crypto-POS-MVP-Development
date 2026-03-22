import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/settings_repository.dart';

/// Main Screen - Dashboard with Card and P2P buttons
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = SettingsRepository();
    final deviceSettings = settings.deviceSettings;
    
    return Scaffold(
      backgroundColor: const Color(0xFFECEFF1),
      appBar: AppBar(
        title: Text(deviceSettings.businessName),
        backgroundColor: Color(int.parse(deviceSettings.themeColor.replaceFirst('#', '0xFF'))),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).pushNamed('/settings');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              settings.setAuthenticated(false);
              Navigator.of(context).pushReplacementNamed('/access');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.point_of_sale,
                      size: 80,
                      color: Color(0xFF1E88E5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Select Transaction Type',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF37474F),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Device ID: ${deviceSettings.deviceId}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF78909C),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Card and P2P Buttons
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Card Button
                    _MainButton(
                      icon: Icons.credit_card,
                      label: 'CARD',
                      subtitle: 'Crypto Purchase via Gateway',
                      color: PosColors.cardModule,
                      onTap: () {
                        Navigator.of(context).pushNamed('/card');
                      },
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // P2P Button
                    _MainButton(
                      icon: Icons.swap_horiz,
                      label: 'P2P',
                      subtitle: 'Peer-to-Peer Exchange',
                      color: PosColors.p2pModule,
                      onTap: () {
                        Navigator.of(context).pushNamed('/p2p');
                      },
                    ),
                  ],
                ),
              ),
              
              // Footer
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/settings');
                      },
                      icon: const Icon(Icons.wallet, color: Color(0xFF78909C)),
                      label: const Text(
                        'Wallets',
                        style: TextStyle(color: Color(0xFF78909C)),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/settings', arguments: 'gateways');
                      },
                      icon: const Icon(Icons.payment, color: Color(0xFF78909C)),
                      label: const Text(
                        'Gateways',
                        style: TextStyle(color: Color(0xFF78909C)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Large Main Button Widget
class _MainButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  
  const _MainButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withOpacity(0.6),
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
