import 'package:aplikasi_news/core/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Gunakan Consumer atau Provider.of untuk mendengarkan perubahan
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            title: const Text(
              'Dark Mode',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: Switch(
              // Warna switch aktif (Putih saat dark mode)
              activeColor: Colors.white,
              activeTrackColor: Colors.grey,
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                // Panggil fungsi toggle di provider
                themeProvider.toggleTheme(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}