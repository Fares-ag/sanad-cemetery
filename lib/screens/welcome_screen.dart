import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../welcome_state.dart';

/// Splash screen. Fades in, then smooth transition to login.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  static const String _welcomeAsset = 'images/Welcome.png';
  Timer? _timer;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fadeController.forward();

    _timer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      void onStatus(AnimationStatus status) {
        if (status == AnimationStatus.dismissed) {
          _fadeController.removeStatusListener(onStatus);
          if (mounted) {
            setWelcomeCompleted();
            context.go('/login');
          }
        }
      }
      _fadeController.addStatusListener(onStatus);
      _fadeController.reverse();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              _welcomeAsset,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFF3A0B17),
                child: const Center(
                  child: Icon(AppIcons.imageNotSupported, size: 64, color: Colors.white54),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
