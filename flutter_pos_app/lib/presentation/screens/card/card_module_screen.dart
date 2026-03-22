import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/payment_url_generator.dart';
import '../../core/services/api_service.dart';
import '../../data/repositories/settings_repository.dart';

/// Card Module - Crypto purchase via payment gateways
class CardModuleScreen extends StatefulWidget {
  const CardModuleScreen({super.key});

  @override
  State<CardModuleScreen> createState() => _CardModuleScreenState();
}

class _CardModuleScreenState extends State<CardModuleScreen> {
  final SettingsRepository _settings = SettingsRepository();
  final ApiService _apiService = ApiService();
  
  // Card entry mode
  enum CardMode { selectMode, manualEntry, emulatedNFC }
  CardMode _currentMode = CardMode.selectMode;
  
  // Amount and crypto
  String _amount = '';
  String _selectedCrypto = 'USDT';
  String _selectedNetwork = 'ERC20';
  String _walletAddress = '';
  
  // WebView
  WebViewController? _webViewController;
  bool _isWebViewLoading = true;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  void _loadSettings() {
    final walletConfig = _settings.walletConfig;
    _walletAddress = walletConfig.getAddressForCrypto(_selectedCrypto);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECEFF1),
      appBar: AppBar(
        title: const Text('Card Payment'),
        backgroundColor: PosColors.cardModule,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _buildBody(),
    );
  }
  
  Widget _buildBody() {
    switch (_currentMode) {
      case CardMode.selectMode:
        return _buildModeSelection();
      case CardMode.manualEntry:
        return _buildManualEntry();
      case CardMode.emulatedNFC:
        return _buildEmulatedNFC();
    }
  }
  
  Widget _buildModeSelection() {
    return SafeArea(
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
                    Icons.credit_card,
                    size: 64,
                    color: PosColors.cardModule,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Select Entry Method',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF37474F),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Manual Entry Button
            _ModeButton(
              icon: Icons.keyboard,
              label: 'Manual Entry',
              subtitle: 'Enter amount and crypto details manually',
              color: PosColors.cardModule,
              onTap: () {
                setState(() {
                  _currentMode = CardMode.manualEntry;
                });
              },
            ),
            
            const SizedBox(height: 20),
            
            // Emulated NFC/Swipe Button
            _ModeButton(
              icon: Icons.nfc,
              label: 'Emulated NFC/Swipe',
              subtitle: 'Simulate card tap or swipe',
              color: PosColors.cardModule,
              onTap: () {
                setState(() {
                  _currentMode = CardMode.emulatedNFC;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildManualEntry() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button and title
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _currentMode = CardMode.selectMode;
                    });
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  'Enter Amount',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Amount Input
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Amount (USD)',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF78909C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      hintText: '0.00',
                      prefixText: '\$ ',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _amount = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Crypto Selection
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cryptocurrency',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF78909C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedCrypto,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: ['BTC', 'ETH', 'USDT', 'USDC'].map((crypto) {
                      return DropdownMenuItem(
                        value: crypto,
                        child: Text(crypto),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCrypto = value!;
                        _walletAddress = _settings.walletConfig.getAddressForCrypto(_selectedCrypto);
                        // Update network based on crypto
                        if (_selectedCrypto == 'BTC') {
                          _selectedNetwork = 'Bitcoin';
                        } else if (_selectedCrypto == 'ETH') {
                          _selectedNetwork = 'Ethereum';
                        } else {
                          _selectedNetwork = 'ERC20';
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Network Selection
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Network',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF78909C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedNetwork,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: _getNetworkOptions().map((network) {
                      return DropdownMenuItem(
                        value: network,
                        child: Text(network),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedNetwork = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Wallet Address Display
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Wallet Address',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF78909C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _walletAddress.isEmpty ? 'No wallet configured' : _walletAddress,
                    style: TextStyle(
                      fontSize: 14,
                      color: _walletAddress.isEmpty ? Colors.red : Colors.black87,
                    ),
                  ),
                  if (_walletAddress.isEmpty)
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/settings');
                      },
                      child: const Text('Configure in Settings'),
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Proceed Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _canProceed() ? _proceedToPayment : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: PosColors.cardModule,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Proceed to Payment',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmulatedNFC() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Back button
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _currentMode = CardMode.selectMode;
                    });
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  'Emulated NFC',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 40),
            
            // NFC Animation
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: PosColors.cardModule.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.nfc,
                    size: 100,
                    color: PosColors.cardModule,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Ready to Scan',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Simulating NFC card tap...',
                    style: TextStyle(
                      color: Color(0xFF78909C),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const CircularProgressIndicator(
                    color: PosColors.cardModule,
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Manual fallback button
            TextButton(
              onPressed: () {
                setState(() {
                  _currentMode = CardMode.manualEntry;
                });
              },
              child: const Text('Enter manually instead'),
            ),
          ],
        ),
      ),
    );
  }
  
  List<String> _getNetworkOptions() {
    switch (_selectedCrypto) {
      case 'BTC':
        return ['Bitcoin'];
      case 'ETH':
        return ['Ethereum'];
      case 'USDT':
      case 'USDC':
        return ['ERC20', 'TRC20'];
      default:
        return ['Ethereum'];
    }
  }
  
  bool _canProceed() {
    return _amount.isNotEmpty && 
           double.tryParse(_amount) != null && 
           double.parse(_amount) > 0 &&
           _walletAddress.isNotEmpty;
  }
  
  void _proceedToPayment() {
    // Get gateway settings
    final gatewaySettings = _settings.gatewaySettings;
    final primaryGateway = gatewaySettings.getPrimaryGateway();
    
    if (primaryGateway == null) {
      setState(() {
        _errorMessage = 'No payment gateway configured';
      });
      return;
    }
    
    // Generate payment URL
    final paymentUrl = PaymentUrlGenerator.generateUrl(
      provider: primaryGateway.provider,
      apiKey: primaryGateway.apiKey,
      amount: _amount,
      walletAddress: _walletAddress,
      cryptoCurrency: _selectedCrypto,
      network: _selectedNetwork,
    );
    
    // Log the transaction
    _apiService.sendLog(
      _settings.deviceSettings.deviceId,
      'INFO',
      'Initiating ${primaryGateway.provider} payment: $_amount $_selectedCrypto',
    );
    
    // Navigate to WebView
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaymentWebViewScreen(
          url: paymentUrl,
          provider: primaryGateway.provider,
          amount: _amount,
          crypto: _selectedCrypto,
        ),
      ),
    );
  }
}

/// Mode Selection Button
class _ModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  
  const _ModeButton({
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
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 36, color: color),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF78909C),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFFB0BEC5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Payment WebView Screen
class PaymentWebViewScreen extends StatefulWidget {
  final String url;
  final String provider;
  final String amount;
  final String crypto;
  
  const PaymentWebViewScreen({
    super.key,
    required this.url,
    required this.provider,
    required this.amount,
    required this.crypto,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            // Handle navigation
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.provider} Payment'),
        backgroundColor: PosColors.cardModule,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _controller.reload();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Transaction Info
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFF5F5F5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _InfoChip(label: 'Amount', value: '\$${widget.amount}'),
                _InfoChip(label: 'Crypto', value: widget.crypto),
                _InfoChip(label: 'Provider', value: widget.provider),
              ],
            ),
          ),
          
          // WebView
          Expanded(
            child: Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  
  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF78909C),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
