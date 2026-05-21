import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:math';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';
import 'logic/theme_provider.dart';
import 'utils/app_notification.dart';

class PinLockScreen extends StatefulWidget {
  final bool isSettingPin;
  final Function(String)? onPinVerified;
  final int pinLength;

  const PinLockScreen({
    super.key, 
    this.isSettingPin = false, 
    this.onPinVerified,
    this.pinLength = 4,
  });

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> with SingleTickerProviderStateMixin {
  String _enteredPin = "";
  String? _firstPin;
  bool _isSuccess = false;
  bool _isError = false;
  bool _isBiometricLoading = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut))
      ..addListener(() => setState(() {}));
    
    // Auto trigger biometric on lock screen open (not when setting PIN)
    if (!widget.isSettingPin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final themeProvider = context.read<ThemeProvider>();
        if (themeProvider.isBiometricEnabled) {
          _authenticateWithBiometric();
        }
      });
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  int _getTargetPinLength(BuildContext context) => widget.isSettingPin 
      ? widget.pinLength 
      : context.read<ThemeProvider>().userPin.length;

  Future<void> _authenticateWithBiometric() async {
    setState(() => _isBiometricLoading = true);
    try {
      final bool canAuthenticate = await _localAuth.canCheckBiometrics || await _localAuth.isDeviceSupported();
      if (!canAuthenticate) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Perangkat ini tidak mendukung biometrik.'))
          );
        }
        return;
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Verifikasi identitasmu untuk membuka Saldoku',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (didAuthenticate && mounted) {
        setState(() { _isSuccess = true; });
        HapticFeedback.mediumImpact();
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) context.read<ThemeProvider>().unlockApp();
        });
      }
    } catch (e) {
      // Auth cancelled or error, silently fall back to PIN
    } finally {
      if (mounted) setState(() => _isBiometricLoading = false);
    }
  }

  void _onNumberPress(String number) {
    final int targetLen = _getTargetPinLength(context);
    if (_enteredPin.length < targetLen && !_isSuccess && !_isError) {
      setState(() {
        _enteredPin += number;
      });
      
      if (_enteredPin.length == targetLen) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _verifyPin();
        });
      }
    }
  }

  void _backspace() {
    if (_enteredPin.isNotEmpty && !_isSuccess && !_isError) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      });
    }
  }

  void _verifyPin() {
    if (widget.isSettingPin) {
      if (_firstPin == null) {
        setState(() {
          _firstPin = _enteredPin;
          _enteredPin = "";
        });
      } else {
        if (_enteredPin == _firstPin) {
          widget.onPinVerified?.call(_enteredPin);
          Navigator.pop(context);
        } else {
          setState(() { _isError = true; });
          HapticFeedback.heavyImpact();
          _shakeController.forward(from: 0.0).then((_) {
            if (mounted) {
              setState(() {
                _enteredPin = "";
                _isError = false;
              });
            }
          });
        }
      }
    } else {
      final correctPin = context.read<ThemeProvider>().userPin;
      if (_enteredPin == correctPin) {
        setState(() { _isSuccess = true; });
        HapticFeedback.mediumImpact();
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) context.read<ThemeProvider>().unlockApp();
        });
      } else {
        setState(() { _isError = true; });
        HapticFeedback.heavyImpact();
        _shakeController.forward(from: 0.0).then((_) {
          if (mounted) {
            setState(() {
              _enteredPin = "";
              _isError = false;
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final int currentTargetLength = widget.isSettingPin ? widget.pinLength : themeProvider.userPin.length;
    final bool showBiometricButton = !widget.isSettingPin && themeProvider.isBiometricEnabled;

    double shakeOffset = 0.0;
    if (_shakeController.isAnimating) {
      shakeOffset = sin(_shakeAnimation.value * pi * 4) * 10;
    }

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
              if (!widget.isSettingPin) ...[
                // Profile Header with photo support
                _buildProfileAvatar(themeProvider),
                const SizedBox(height: 16),
                Text(
                  'Halo, ${themeProvider.userName}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
              ] else ...[
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                  child: Icon(
                    _isSuccess ? Icons.lock_open_rounded : (_isError ? Icons.lock_outline : Icons.lock_person_rounded), 
                    key: ValueKey('$_isSuccess-$_isError'),
                    size: 64, 
                    color: _isSuccess ? Colors.green : (_isError ? Colors.red : Theme.of(context).primaryColor),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Text(
                  _isSuccess 
                    ? 'Akses Diberikan' 
                    : (_isError 
                        ? (widget.isSettingPin && _firstPin != null ? 'PIN tidak cocok!' : 'PIN Salah gess!') 
                        : (widget.isSettingPin 
                            ? (_firstPin == null ? 'Setel PIN Baru' : 'Konfirmasi PIN Baru') 
                            : 'Masukkan PIN Kamu')),
                  key: ValueKey('$_isSuccess-$_isError-$_firstPin'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: _isSuccess ? Colors.green : (_isError ? Colors.red : null),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.isSettingPin ? 'Keamananmu adalah prioritas kami gess' : 'Silakan masukkan PIN untuk melanjutkan',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 48),
              
              // PIN Dots
              Transform.translate(
                offset: Offset(shakeOffset, 0),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: _isSuccess 
                    ? const SizedBox(height: 16) 
                    : Row(
                        key: const ValueKey('dots'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(currentTargetLength, (index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index < _enteredPin.length 
                                ? (_isError ? Colors.red : Theme.of(context).primaryColor) 
                                : Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                            ),
                          );
                        }),
                      ),
                ),
              ),
              
              const Spacer(),
              
              // Keypad
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                child: Column(
                  children: [
                    _buildRow(['1', '2', '3']),
                    const SizedBox(height: 16),
                    _buildRow(['4', '5', '6']),
                    const SizedBox(height: 16),
                    _buildRow(['7', '8', '9']),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: 70,
                          height: 70,
                          child: showBiometricButton
                            ? Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: _isBiometricLoading ? null : _authenticateWithBiometric,
                                  child: Center(
                                    child: _isBiometricLoading
                                      ? SizedBox(
                                          width: 28,
                                          height: 28,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Theme.of(context).primaryColor,
                                          ),
                                        )
                                      : Icon(Icons.fingerprint, size: 40, color: Theme.of(context).primaryColor),
                                  ),
                                ),
                              )
                            : null,
                        ),
                        _buildNumberButton('0'),
                        SizedBox(
                          width: 70,
                          height: 70,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTapDown: (_) => _backspace(),
                              onTap: () {},
                              child: Center(
                                child: Icon(
                                  Icons.backspace_outlined,
                                  size: 28,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!widget.isSettingPin)
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Silakan hubungi Customer Service untuk Reset PIN')));
                  },
                  child: Text('Lupa PIN?', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(ThemeProvider themeProvider) {
    if (themeProvider.profileImagePath != null) {
      return CircleAvatar(
        radius: 36,
        backgroundImage: FileImage(File(themeProvider.profileImagePath!)),
      );
    }
    return CircleAvatar(
      radius: 36,
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.15),
      child: Text(
        themeProvider.userName.isNotEmpty ? themeProvider.userName.substring(0, 1).toUpperCase() : 'A',
        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
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
    return Container(
      width: 70,
      height: 70,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTapDown: (_) => _onNumberPress(number),
          onTap: () {},
          customBorder: const CircleBorder(),
          splashColor: Theme.of(context).primaryColor.withOpacity(0.2),
          highlightColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Center(
            child: Text(
              number,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}
