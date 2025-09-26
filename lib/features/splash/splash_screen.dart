import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../providers/startup_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _dotsController;
  late Animation<double> _fadeAnimation;

  bool showLogo = false;
  bool fadeOut = false;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _dotsController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();

    // Start fade-in animation after 300ms
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => showLogo = true);
        _fadeController.forward();
      }
    });

    // Start DB check
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(startupProvider.notifier).initialize();
    });

    // Wait 6 seconds total, then fade out and navigate
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        setState(() => fadeOut = true);

        // Give it 600ms to fade out before navigating
        Future.delayed(const Duration(milliseconds: 600), () {
          final state = ref.read(startupProvider);

          if (state == StartupState.needsAdmin) {
            context.go('/admin/register');
          } else if (state == StartupState.ready) {
            context.go('/home');
          } else {
            context.go('/welcome'); // fallback
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  Widget _buildDots() {
    return AnimatedBuilder(
      animation: _dotsController,
      builder: (context, child) {
        int activeDot = (_dotsController.value * 3).floor() % 3;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            double scaleFactor = activeDot == index ? 1.3 : 0.8;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              transform: Matrix4.identity()..scaleByDouble(scaleFactor, scaleFactor, scaleFactor, 1),
            );
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade400,
      body: AnimatedOpacity(
        opacity: fadeOut ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 500),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedOpacity(
                  opacity: showLogo ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 1000),
                  child: SvgPicture.asset(
                    'assets/svg/logo.svg',
                    width: 100,
                    height: 100,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildDots(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
