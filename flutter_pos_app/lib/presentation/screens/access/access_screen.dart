import 'package:flutter/material.dart';
import '../widgets/pinpad/numeric_pinpad.dart';
import '../../core/services/api_service.dart';
import '../../data/repositories/settings_repository.dart';

/// Access Screen - PIN Entry and Verification
class AccessScreen extends StatefulWidget {
  const AccessScreen({super.key});

  @override
  State<AccessScreen> createState() => _AccessScreenState();
}

class _AccessScreenState extends State<AccessScreen> {
  final ApiService _apiService = ApiService();
  final SettingsRepository _settings = SettingsRepository();
  
  String _enteredPin = '';
  bool _isLoading = false;
  String? _errorMessage;
  String _deviceId = 'POS-001';
  
  @override
  void initState() {
    super.initState();
    _deviceId = _settings.deviceSettings.deviceId;
  }

  void _onPinChanged(String pin) {
    setState(() {
      _enteredPin = pin;
      _errorMessage = null;
    });
  }

  Future<void> _verifyPin() async {
    if (_enteredPin.length < 4) {
      setState(() {
        _errorMessage = 'Please enter 4-digit PIN';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final result = await _apiService.verifyPin(_deviceId, _enteredPin);
      
      if (result['success'] == true) {
        _settings.setAuthenticated(true, token: result['token']);
        
        // Log successful login
        await _apiService.sendLog(_deviceId, 'INFO', 'Device unlocked successfully');
        
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/main');
        }
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Invalid PIN';
          _enteredPin = '';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Connection error. Please try again.';
        _enteredPin = '';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECEFF1),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(
                    Icons.lock_outline,
                    size: 64,
                    color: Color(0xFF1E88E5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'POS Device',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF37474F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your PIN to access',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF78909C),
                    ),
                  ),
                ],
              ),
            ),
            
            // PIN Display
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final isFilled = index < _enteredPin.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFilled 
                          ? const Color(0xFF1E88E5) 
                          : const Color(0xFFB0BEC5),
                    ),
                  );
                }),
              ),
            ),
            
            // Error Message
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Color(0xFFF44336),
                    fontSize: 14,
                  ),
                ),
              ),
            
            const SizedBox(height: 20),
            
            // Numeric Keypad
            Expanded(
              child: NumericPinpad(
                onPinChanged: _onPinChanged,
                onSubmit: _verifyPin,
                isLoading: _isLoading,
              ),
            ),
            
            // Settings Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed('/settings');
                },
                icon: const Icon(Icons.settings, color: Color(0xFF78909C)),
                label: const Text(
                  'Settings',
                  style: TextStyle(color: Color(0xFF78909C)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
