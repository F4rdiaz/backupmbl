import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/auth/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GeoAttendApp());
}

class GeoAttendApp extends StatelessWidget {
  const GeoAttendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'GeoAttend',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Skema Warna Modern
        primaryColor: const Color(0xFF0EA5E9), // Biru Cerah
        scaffoldBackgroundColor: const Color(0xFFF8FAFC), // Putih Abu-abu bersih
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0EA5E9),
          primary: const Color(0xFF0EA5E9),
          secondary: const Color(0xFF3B82F6),
        ),
        
        // Integrasi Plus Jakarta Sans ke seluruh aplikasi
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          Theme.of(context).textTheme,
        ),
        
        // Styling Global untuk Tombol
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: const Color(0xFF0EA5E9),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
        
        // Styling Global untuk Input Text (TextField)
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF0EA5E9), width: 2),
          ),
          hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
        ),
      ),
      
      // Halaman pertama yang akan diload (Nanti kita ubah ke Splash Screen / Login)
      home: LoginScreen(),
    );
  }
}