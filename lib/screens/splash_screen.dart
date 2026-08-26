import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/logo_widget.dart';
import '../widgets/bottom_wave_painter.dart';
import '../features/auth/presentation/auth_controller.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startInit();
  }

  Future<void> _startInit() async {
    // Show splash screen for 2.5 seconds
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;
    
    // Initialize auth session
    await ref.read(authControllerProvider.notifier).initialize();
    
    if (!mounted) return;
    final user = ref.read(authControllerProvider).valueOrNull;
    if (user != null) {
      context.go('/dashboard');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Stack(
          children: [
            // Center Logo
            Center(
              child: Image.asset(
                'assets/images/LogoRev.png',
                width: MediaQuery.of(context).size.width * 0.35 * 1.5,
                fit: BoxFit.contain,
              ),
            ),
            // Bottom Wave with Company Details
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BottomWaveWidget(
                height: 200,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'CV. TATA SAKA CONSULTANT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        fontFamily: 'Inter',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'KONSULTANT : PERENCANAAN DAN SUPERVISI',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                        fontFamily: 'Inter',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
