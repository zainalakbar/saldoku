import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'logic/theme_provider.dart';

class PinLockScreen extends StatefulWidget {
  final bool isSettingPin;
  final Function(String)? onPinVerified;

  const PinLockScreen({super.key, this.isSettingPin = false, this.onPinVerified});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  String _enteredPin = "";
  final String _correctPin = "1234"; // Mock correct PIN, in real app load from storage

  void _onNumberPress(String number) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += number;
      });
      
      if (_enteredPin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _backspace() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      });
    }
  }

  void _verifyPin() {
    if (widget.isSettingPin) {
      widget.onPinVerified?.call(_enteredPin);
      Navigator.pop(context);
    } else {
      if (_enteredPin == _correctPin) {
        // Success!
        context.read<ThemeProvider>().unlockApp();
      } else {
        // Fail
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PIN Salah gess!', textAlign: TextAlign.center), backgroundColor: Colors.red),
        );
        setState(() {
          _enteredPin = "";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 60),
              Icon(Icons.lock_person_rounded, size: 64, color: Theme.of(context).primaryColor),
              const SizedBox(height: 24),
              Text(
                widget.isSettingPin ? 'Setel PIN Baru' : 'Masukkan PIN Kamu',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Keamananmu adalah prioritas kami gess',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 48),
              
              // PIN Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index < _enteredPin.length 
                        ? Theme.of(context).primaryColor 
                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                    ),
                  );
                }),
              ),
              
              const Spacer(),
              
              // Keypad
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                child: Column(
                  children: [
                    _buildRow(['1', '2', '3']),
                    const SizedBox(height: 20),
                    _buildRow(['4', '5', '6']),
                    const SizedBox(height: 20),
                    _buildRow(['7', '8', '9']),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const SizedBox(width: 60), // Placeholder for alignment
                        _buildNumberButton('0'),
                        IconButton(
                          onPressed: _backspace,
                          icon: const Icon(Icons.backspace_outlined),
                          iconSize: 28,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: numbers.map((n) => _buildNumberButton(n)).toList(),
    );
  }

  Widget _buildNumberButton(String number) {
    return InkWell(
      onTap: () => _onNumberPress(number),
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 70,
        height: 70,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Text(
          number,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
