import 'package:flutter/material.dart';
import 'login_screen.dart'; // Import halaman login yang baru dibuat

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Bengkel',
      debugShowCheckedModeBanner: false, // Menghilangkan pita "DEBUG" di pojok kanan atas
      theme: ThemeData(
        // Menyesuaikan tema dasar dengan warna navy aplikasi kita
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF041033)),
        useMaterial3: true,
      ),
      // Arahkan halaman utama langsung ke LoginScreen
      home: LoginScreen(), 
    );
  }
}