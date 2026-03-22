import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/p2p_price_service.dart';
import '../../core/services/api_service.dart';
import '../../data/repositories/settings_repository.dart';

/// P2P Module Screen
class P2PScreen extends StatefulWidget {
  const P2PScreen({super.key});

  @override
  State<P2PScreen> createState() => _P2PScreenState();
}

class _P2PScreenState extends State<P2PScreen> {
  final SettingsRepository _settings = SettingsRepository();
  final ApiService _apiService = ApiService();
  final P2PPriceService _priceService = P2PPriceService();
  
  // State
  String _amount = '';
  String _selectedCrypto = 'USDT';
  String _selectedFiat = 'USD';
  String _selectedBank = 'Chase';
  P2PPrice? _bestPrice;
  bool _isLoadingPrices = false;
  
  @override
  void initState() {
    super.initState();
    _selectedCrypto = _settings.walletConfig.defaultWallet;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECEFF1),
      appBar: AppBar(
        title: const Text('P2P Exchange'),
        backgroundColor: PosColors.p2pModule,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _buildBody(),
    );
  }
  
  Widget _buildBody() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    'Enter Amount',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      prefixText: '\$ ',
                      suffixText: _selectedFiat,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _amount = value;
                        _bestPrice = null;
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
                        _bestPrice = null;
                      });
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Bank Selection
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
                    'Select Bank',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF78909C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedBank,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: P2PPriceService.getSupportedBanks().map((bank) {
                      return DropdownMenuItem(
                        value: bank,
                        child: Text(bank),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedBank = value!;
                        _bestPrice = null;
                      });
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Search Prices Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _canSearch() ? _searchPrices : null,
                icon: _isLoadingPrices 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.search),
                label: Text(
                  _isLoadingPrices ? 'Searching...' : 'Search Best Price',
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PosColors.p2pModule,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            
            // Price Results
            if (_bestPrice != null) ...[
              const SizedBox(height: 24),
              _buildPriceConfirmation(),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildPriceConfirmation() {
    final amount = double.tryParse(_amount) ?? 0;
    final cryptoAmount = _bestPrice!.getCryptoAmount(amount);
    final finalAmount = amount + _bestPrice!.commission;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PosColors.p2pModule, width: 2),
        boxShadow: [
          BoxShadow(
            color: PosColors.p2pModule.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: PosColors.success, size: 28),
              const SizedBox(width: 8),
              const Text(
                'Best Price Found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: PosColors.success,
                ),
              ),
            ],
          ),
          
          const Divider(height: 32),
          
          // Exchange
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Exchange', style: TextStyle(color: Color(0xFF78909C))),
              Text(
                _bestPrice!.exchange,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Rate', style: TextStyle(color: Color(0xFF78909C))),
              Text(
                '1 ${_selectedCrypto} = ${_bestPrice!.price.toStringAsFixed(2)} $_selectedFiat',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Commission
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Commission', style: TextStyle(color: Color(0xFF78909C))),
              Text(
                '${_bestPrice!.commission.toStringAsFixed(2)} $_selectedFiat',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Final Amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                '${finalAmount.toStringAsFixed(2)} $_selectedFiat',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: PosColors.p2pModule,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Crypto Amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('You will receive', style: TextStyle(color: Color(0xFF78909C))),
              Text(
                '${cryptoAmount.toStringAsFixed(8)} $_selectedCrypto',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: PosColors.success,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Action Buttons
          Row(
            children: [
              // Reject Button
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _bestPrice = null;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: PosColors.reject,
                      side: const BorderSide(color: PosColors.reject),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Start Button
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _executeTransaction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PosColors.success,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Start'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  bool _canSearch() {
    return _amount.isNotEmpty && 
           double.tryParse(_amount) != null && 
           double.parse(_amount) > 0;
  }
  
  Future<void> _searchPrices() async {
    setState(() {
      _isLoadingPrices = true;
    });
    
    try {
      final price = await _priceService.getBestPrice(
        crypto: _selectedCrypto,
        fiat: _selectedFiat,
        bank: _selectedBank,
      );
      
      setState(() {
        _bestPrice = price;
        _isLoadingPrices = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPrices = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error searching prices: $e'),
            backgroundColor: PosColors.errorColor,
          ),
        );
      }
    }
  }
  
  Future<void> _executeTransaction() async {
    if (_bestPrice == null) return;
    
    final amount = double.parse(_amount);
    final walletAddress = _settings.walletConfig.getAddressForCrypto(_selectedCrypto);
    
    if (walletAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please configure wallet address in settings'),
          backgroundColor: PosColors.errorColor,
        ),
      );
      return;
    }
    
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    try {
      // Record transaction with backend
      final result = await _apiService.createP2PTransaction(
        deviceId: _settings.deviceSettings.deviceId,
        amount: amount,
        currency: _selectedFiat,
        cryptoCurrency: _selectedCrypto,
        walletAddress: walletAddress,
        exchange: _bestPrice!.exchange,
        price: _bestPrice!.price,
        commission: _bestPrice!.commission,
        finalAmount: amount + _bestPrice!.commission,
      );
      
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();
      
      if (result['success'] == true) {
        // Show success
        if (mounted) {
          _showTransactionSuccess(result['transaction_id']);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Transaction failed'),
              backgroundColor: PosColors.errorColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: PosColors.errorColor,
          ),
        );
      }
    }
  }
  
  void _showTransactionSuccess(String transactionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: PosColors.success, size: 32),
            const SizedBox(width: 8),
            const Text('Success'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Transaction completed successfully!'),
            const SizedBox(height: 16),
            Text(
              'Transaction ID: $transactionId',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF78909C),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
