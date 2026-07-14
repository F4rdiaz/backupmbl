import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Tema Biru - Putih
  static const Color _primaryBlue = Color(0xFF0EA5E9); // Sky blue
  static const Color _secondaryBlue = Color(0xFF3B82F6); // Blue
  static const Color _darkText = Color(0xFF0F172A);
  static const Color _greyText = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    _handleNavigation();
  }

  // LOGIKA NAVIGASI PINTAR
  Future<void> _handleNavigation() async {
    // Tahan splash screen selama 4 detik (biar animasinya puas dilihat)
    await Future.delayed(const Duration(seconds: 4));

    String? hasSeenOnboarding = await _storage.read(key: 'has_seen_onboarding');
    String? token = await _storage.read(key: 'auth_token');

    if (!mounted) return;

    if (hasSeenOnboarding != 'true') {
      Get.offAllNamed('/onboarding');
    } else if (token != null && token.isNotEmpty) {
      Get.offAllNamed('/home');
    } else {
      Get.offAllNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // ==========================================================
          // BASE GRADIENT (Full Screen, biar gak "setengah" lagi)
          // ==========================================================
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Color(0xFFE0F2FE), // biru sangat muda
                    Colors.white,
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // ==========================================================
          // BACKGROUND MESH BLOB (Nuansa Biru)
          // ==========================================================
          Positioned(
            top: -100,
            left: -100,
            child: _buildBlob(_primaryBlue, size.width * 0.9),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: _buildBlob(_secondaryBlue, size.width * 0.9),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
              child: Container(color: Colors.white.withOpacity(0.1)),
            ),
          ),

          // ==========================================================
          // KONTEN UTAMA
          // ==========================================================
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ANIMASI SMARTPHONE SHAKING
              _buildSmartphone()
                  .animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                  )
                  .shimmer(duration: 1200.ms, color: Colors.white54)
                  .shake(hz: 4, curve: Curves.easeInOut, rotation: 0.05),

              const SizedBox(height: 40),

              // NAMA APLIKASI
              Text(
                    "GeoAttend",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: _darkText,
                      letterSpacing: -1,
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 800.ms)
                  .slideY(begin: 0.3, end: 0),

              const SizedBox(height: 8),

              // MOTTO / TAGLINE
              Text(
                "Attendance system simplified for enterprise.",
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _greyText,
                  letterSpacing: 0.5,
                ),
              ).animate().fadeIn(delay: 1200.ms, duration: 800.ms),

              const SizedBox(height: 60),

              // INDICATOR LOADING HALUS
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(_primaryBlue),
                ),
              ).animate().fadeIn(delay: 2000.ms),
            ],
          ),
        ],
      ),
    );
  }

  // WIDGET SMARTPHONE GAYA GLASSMORPHISM
  Widget _buildSmartphone() {
    return Container(
      width: 100,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: _primaryBlue.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          // Speaker smartphone (Notch)
          Container(
            width: 30,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Expanded(child: SizedBox()),
          // Efek Layar Menyala (Icon Lokasi di dalam HP)
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _primaryBlue.withOpacity(0.12),
            ),
            child: Icon(
              Icons.location_on_rounded,
              color: _primaryBlue,
              size: 30,
            ),
          ),
          const Expanded(child: SizedBox()),
          // Tombol Home virtual
          Container(
            width: 40,
            height: 3,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.35),
      ),
    );
  }
}
