import 'dart:async';
import 'package:aplikasi_news/features/main_navigation.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Setup Animasi Fade-In
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500), // Sedikit lebih lambat biar elegan (2 detik)
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    // Mulai animasi
    _controller.forward();

    // 2. Timer: Tahan sebentar setelah animasi selesai, lalu pindah
    Timer(const Duration(seconds: 4), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainNavigation()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background Hitam Pekat ala Bloomberg
      backgroundColor: Colors.black,
      body: Center(
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- NAMA APLIKASI ---
              const Text(
                'CHRONICLES',
                style: TextStyle(
                  // Font Serif (ada kakinya) memberi kesan koran/berita kredibel
                  fontFamily: 'Times New Roman',
                  fontSize: 36, // Ukuran pas untuk kata yang agak panjang
                  fontWeight: FontWeight.w900, // Sangat tebal
                  color: Colors.white,
                  letterSpacing: 5.0, // Jarak antar huruf biar mewah
                ),
              ),
              const SizedBox(height: 16),


              const SizedBox(height: 16),

              // --- TAGLINE ---
              Text(
                'Global Perspective',
                style: TextStyle(
                  fontFamily: 'Arial', // Sans-serif untuk kontras
                  fontSize: 10,
                  color: Colors.grey[400],
                  letterSpacing: 3.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}