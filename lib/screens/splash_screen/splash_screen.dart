import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_mart/bloc/auth/auth_bloc.dart';
import 'package:mini_mart/bloc/auth/auth_event.dart';
import 'package:mini_mart/bloc/auth/auth_state.dart';
import 'package:mini_mart/screens/login_screen/login_screen.dart';
import 'package:mini_mart/screens/screen_controller/screen_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.forward();

    // Check authentication status
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Wait for animation to complete
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      // Trigger auth check
      context.read<AuthBloc>().add(const CheckAuthStatusEvent());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // User is logged in - go to home
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ScreenController()),
          );
        } else if (state is AuthUnauthenticated) {
          // User not logged in - go to login screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Center(
              child: Image.asset(
                'assets/logo/logo.png',
                width: 200,
                height: 200,
              ),
            ),
            Center(
              child: FadeTransition(
                opacity: _animation,
                child: const CircularProgressIndicator(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
