import 'package:aplikasi_news/core/theme/theme_provider.dart';
import 'package:aplikasi_news/features/main_navigation.dart'; // Ganti ke MainNavigation setelah splash
import 'package:aplikasi_news/features/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart'; // Untuk mengatur warna status bar HP

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Provider.of(context) akan memicu build ulang saat toggle diubah
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Chronicles',
      debugShowCheckedModeBanner: false,

      // Hubungkan dengan provider
      themeMode: themeProvider.themeMode,

      // --- TEMA LIGHT (Putih Bersih) ---
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white, // Latar belakang Putih
        primaryColor: Colors.black,

        // Pengaturan AppBar (Atas)
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white, // Putih
          foregroundColor: Colors.black, // Ikon & Teks Hitam
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          systemOverlayStyle: SystemUiOverlayStyle.dark, // Status bar HP jadi ikon gelap
        ),

        // Pengaturan Bottom Navigation (Bawah)
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white, // Putih
          selectedItemColor: Colors.black, // Ikon aktif Hitam
          unselectedItemColor: Colors.grey, // Ikon pasif Abu
          elevation: 10, // Sedikit bayangan agar terpisah dari konten
          type: BottomNavigationBarType.fixed,
        ),
      ),

      // --- TEMA DARK (Hitam Pekat) ---
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black, // Latar belakang Hitam
        primaryColor: Colors.white,

        // Pengaturan AppBar (Atas)
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black, // Hitam
          foregroundColor: Colors.white, // Ikon & Teks Putih
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          systemOverlayStyle: SystemUiOverlayStyle.light, // Status bar HP jadi ikon terang
        ),

        // Pengaturan Bottom Navigation (Bawah)
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.black, // Hitam
          selectedItemColor: Colors.white, // Ikon aktif Putih
          unselectedItemColor: Colors.grey, // Ikon pasif Abu
          elevation: 0,
          type: BottomNavigationBarType.fixed,
        ),
      ),

      home: const SplashScreen(),
    );
  }
}