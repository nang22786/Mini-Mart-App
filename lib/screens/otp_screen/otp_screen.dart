import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_mart/bloc/auth/auth_bloc.dart';
import 'package:mini_mart/bloc/auth/auth_event.dart';
import 'package:mini_mart/bloc/auth/auth_state.dart';
import 'package:mini_mart/screens/screen_controller/screen_controller.dart';
import 'package:mini_mart/styles/fonts.dart';

class OtpScreen extends StatefulWidget {
  final String email;

  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _resendTimer = 60;
  Timer? _timer;
  bool _canResend = false;
  bool _hasNavigated = false; // Add this flag to prevent multiple navigations

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _canResend = false;
    _resendTimer = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_resendTimer > 0) {
            _resendTimer--;
          } else {
            _canResend = true;
            timer.cancel();
          }
        });
      }
    });
  }

  void _resendOtp() {
    if (_canResend) {
      print('🔄 Resending OTP to: ${widget.email}');
      context.read<AuthBloc>().add(ResendOtpEvent(email: widget.email));
      _startTimer();

      // Clear all OTP fields
      for (var controller in _controllers) {
        controller.clear();
      }
      // Focus on first field
      _focusNodes[0].requestFocus();
    }
  }

  void _verifyOtp() {
    // Get OTP and trim whitespace
    final otp = _controllers.map((c) => c.text.trim()).join();

    print('🔐 Verifying OTP: $otp (Length: ${otp.length})');
    print('📧 Email: ${widget.email}');

    // Validate OTP length
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter complete 6-digit OTP code'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Validate OTP contains only numbers
    if (!RegExp(r'^[0-9]{6}$').hasMatch(otp)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP must contain only numbers'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Trigger verify OTP event
    context.read<AuthBloc>().add(
      VerifyOtpEvent(email: widget.email, code: otp),
    );
  }

  void _navigateToHome() {
    if (_hasNavigated) {
      print('⚠️ Navigation already triggered, skipping...');
      return;
    }

    _hasNavigated = true;
    print('🚀 Navigating to ScreenController...');

    // Use WidgetsBinding to ensure navigation happens after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const ScreenController()),
              (route) => false,
            )
            .then((_) {
              print('✅ Navigation completed');
            })
            .catchError((error) {
              print('❌ Navigation error: $error');
            });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          print('📱 OTP Screen State: ${state.runtimeType}');

          if (state is AuthAuthenticated) {
            print('✅ OTP Verified Successfully!');
            print('👤 User: ${state.user.email}');

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Account verified successfully!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 1),
              ),
            );

            // Navigate immediately without delay
            _navigateToHome();
          } else if (state is AuthError) {
            print('❌ OTP Error: ${state.message}');
            _hasNavigated = false; // Reset flag on error

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );

            // Clear OTP fields on error
            for (var controller in _controllers) {
              controller.clear();
            }
            if (mounted && _focusNodes[0].canRequestFocus) {
              _focusNodes[0].requestFocus();
            }
          } else if (state is RegistrationSuccess) {
            print('✅ OTP Resent: ${state.message}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Verify OTP',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: kantumruyPro,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'We have sent a verification code to\n${widget.email}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontFamily: kantumruyPro,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 50),
                  // OTP Input Fields
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 45,
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          enabled: !isLoading,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: kantumruyPro,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFE53935),
                                width: 2,
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              if (index < 5) {
                                _focusNodes[index + 1].requestFocus();
                              } else {
                                _focusNodes[index].unfocus();
                                _verifyOtp();
                              }
                            } else if (value.isEmpty && index > 0) {
                              _focusNodes[index - 1].requestFocus();
                            }
                          },
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 40),
                  // Resend OTP
                  Center(
                    child: TextButton(
                      onPressed: _canResend && !isLoading ? _resendOtp : null,
                      child: Text(
                        _canResend
                            ? 'Resend OTP'
                            : 'Resend OTP in $_resendTimer seconds',
                        style: TextStyle(
                          fontSize: 14,
                          color: _canResend ? Colors.red : Colors.grey,
                          fontFamily: kantumruyPro,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Verify Button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        disabledBackgroundColor: Colors.grey[400],
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              "VERIFY",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 1,
                                fontFamily: kantumruyPro,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Debug info
                  if (isLoading)
                    Center(
                      child: Text(
                        'Verifying OTP...',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontFamily: kantumruyPro,
                        ),
                      ),
                    ),
                  // Add current state for debugging
                  if (state is AuthAuthenticated)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          'State: Authenticated ✅',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontFamily: kantumruyPro,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
