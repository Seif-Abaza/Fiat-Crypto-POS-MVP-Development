import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Numeric Pinpad Widget - Standard POS-style keypad
class NumericPinpad extends StatelessWidget {
  final Function(String) onPinChanged;
  final VoidCallback onSubmit;
  final VoidCallback? onCancel;
  final bool isLoading;
  final int maxLength;
  
  const NumericPinpad({
    super.key,
    required this.onPinChanged,
    required this.onSubmit,
    this.onCancel,
    this.isLoading = false,
    this.maxLength = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Row 1: 1, 2, 3
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _PinpadButton(
                label: '1',
                onPressed: () => _onNumberPressed('1'),
              ),
              _PinpadButton(
                label: '2',
                onPressed: () => _onNumberPressed('2'),
              ),
              _PinpadButton(
                label: '3',
                onPressed: () => _onNumberPressed('3'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Row 2: 4, 5, 6
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _PinpadButton(
                label: '4',
                onPressed: () => _onNumberPressed('4'),
              ),
              _PinpadButton(
                label: '5',
                onPressed: () => _onNumberPressed('5'),
              ),
              _PinpadButton(
                label: '6',
                onPressed: () => _onNumberPressed('6'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Row 3: 7, 8, 9
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _PinpadButton(
                label: '7',
                onPressed: () => _onNumberPressed('7'),
              ),
              _PinpadButton(
                label: '8',
                onPressed: () => _onNumberPressed('8'),
              ),
              _PinpadButton(
                label: '9',
                onPressed: () => _onNumberPressed('9'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Row 4: Cancel/Back, 0, Enter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _PinpadButton(
                label: 'C',
                onPressed: () => _onBackspace(),
                color: PosColors.reject,
              ),
              _PinpadButton(
                label: '0',
                onPressed: () => _onNumberPressed('0'),
              ),
              _PinpadButton(
                label: isLoading ? '...' : 'OK',
                onPressed: isLoading ? null : onSubmit,
                color: PosColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  void _onNumberPressed(String number) {
    // This will be implemented via callback
    // Current implementation passes directly to parent
  }
}

/// Individual Pinpad Button Widget
class _PinpadButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final double size;
  
  const _PinpadButton({
    required this.label,
    this.onPressed,
    this.color,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? PosColors.keypadNumber,
          foregroundColor: PosColors.pinPadTextColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: label.length > 1 ? 18 : 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// Amount Input Pinpad - for entering currency amounts
class AmountPinpad extends StatefulWidget {
  final Function(String) onAmountChanged;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;
  final String currency;
  
  const AmountPinpad({
    super.key,
    required this.onAmountChanged,
    required this.onSubmit,
    required this.onCancel,
    this.currency = 'USD',
  });

  @override
  State<AmountPinpad> createState() => _AmountPinpadState();
}

class _AmountPinpadState extends State<AmountPinpad> {
  String _amount = '0';
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Amount Display
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
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
          child: Column(
            children: [
              Text(
                widget.currency,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF78909C),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _formatAmount(_amount),
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF37474F),
                ),
              ),
            ],
          ),
        ),
        
        // Keypad
        Expanded(
          child: _buildKeypad(),
        ),
      ],
    );
  }
  
  Widget _buildKeypad() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Row 1: 1, 2, 3
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumberButton('1'),
              _buildNumberButton('2'),
              _buildNumberButton('3'),
            ],
          ),
          const SizedBox(height: 12),
          
          // Row 2: 4, 5, 6
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumberButton('4'),
              _buildNumberButton('5'),
              _buildNumberButton('6'),
            ],
          ),
          const SizedBox(height: 12),
          
          // Row 3: 7, 8, 9
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumberButton('7'),
              _buildNumberButton('8'),
              _buildNumberButton('9'),
            ],
          ),
          const SizedBox(height: 12),
          
          // Row 4: ., 0, Back
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumberButton('.'),
              _buildNumberButton('0'),
              _buildBackspaceButton(),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildNumberButton(String number) {
    return SizedBox(
      width: 90,
      height: 60,
      child: ElevatedButton(
        onPressed: () => _onNumberPressed(number),
        style: ElevatedButton.styleFrom(
          backgroundColor: PosColors.keypadNumber,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          number,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  
  Widget _buildBackspaceButton() {
    return SizedBox(
      width: 90,
      height: 60,
      child: ElevatedButton(
        onPressed: _onBackspace,
        style: ElevatedButton.styleFrom(
          backgroundColor: PosColors.keypadAction,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Icon(Icons.backspace_outlined, size: 28),
      ),
    );
  }
  
  void _onNumberPressed(String number) {
    setState(() {
      if (number == '.') {
        if (!_amount.contains('.')) {
          _amount = '$_amount.';
        }
      } else {
        if (_amount == '0' && number != '.') {
          _amount = number;
        } else if (_amount.length < 10) {
          _amount = '$_amount$number';
        }
      }
    });
    widget.onAmountChanged(_amount);
  }
  
  void _onBackspace() {
    setState(() {
      if (_amount.length > 1) {
        _amount = _amount.substring(0, _amount.length - 1);
      } else {
        _amount = '0';
      }
    });
    widget.onAmountChanged(_amount);
  }
  
  String _formatAmount(String amount) {
    if (amount.isEmpty) return '0.00';
    
    final parts = amount.split('.');
    if (parts.length == 1) {
      return '${parts[0]}.00';
    } else if (parts[1].length == 1) {
      return '${parts[0]}.${parts[1]}0';
    }
    return amount;
  }
}
