
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'nav_page.dart';

/// =================== SPLASH SCREEN ===================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fade = CurvedAnimation(parent: _ac, curve: Curves.easeIn);
    _ac.forward();

    // ⏱️ 2s পরে Home-এ নেভিগেট
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const TopNavScaffold(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1) বেস গ্রেডিয়েন্ট (পোস্টারের মুডের সাথে ম্যাচড)
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFFFFF), Color(0xFFFFF7FB)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // 2) সফট কালার ব্লবস (পিঙ্ক/গ্রিন/লেমন)
          Positioned(
            left: -80, top: 60,
            child: _SoftBlob(color: const Color(0xFFFF5BAE).withOpacity(.25), size: 220),
          ),
          Positioned(
            right: -70, top: 140,
            child: _SoftBlob(color: const Color(0xFF7EDDAA).withOpacity(.22), size: 200),
          ),
          Positioned(
            right: -60, bottom: 80,
            child: _SoftBlob(color: const Color(0xFFFFE89C).withOpacity(.22), size: 180),
          ),

          // 3) লোগো/পোস্টার + লোডার (ফেড-ইন)
          FadeTransition(
            opacity: _fade,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: Image.asset(
                      'images/img.png', // ⬅️ আপনার ছবি
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const SizedBox(
                    width: 22, height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// সফট ব্লব শেপ (rounded rectangle look)
class _SoftBlob extends StatelessWidget {
  final Color color;
  final double size;
  const _SoftBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 1.2,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size),
      ),
    );
  }
}
