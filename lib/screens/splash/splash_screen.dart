import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Pastikan jalur import ini sesuai dengan struktur folder kamu ya
import '../auth/login_screen.dart';
import '../intro/onboarding_screen.dart';
import '../dashboard/dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Inisialisasi storage untuk membaca memori aplikasi
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    // Panggil fungsi pengecekan status saat layar pertama kali dimuat
    _checkAppStatus();
  }

  void _checkAppStatus() async {
    // 1. Tahan di Splash Screen selama 3.5 detik biar animasi rileks dan elegan
    await Future.delayed(const Duration(milliseconds: 3500));

    // 2. Baca memori: apakah user sudah pernah lihat onboarding?
    String? hasSeenOnboarding = await _storage.read(key: 'has_seen_onboarding');

    // 3. Baca memori: apakah user punya token login yang masih aktif?
    String? token = await _storage.read(key: 'auth_token');

    // 4. Logika Navigasi Pintar (Gunakan Get.offAll agar histori splash dihapus)
    if (mounted) {
      if (hasSeenOnboarding != 'true') {
        // Jika belum pernah lihat onboarding, lempar ke Onboarding Screen
        Get.offAll(
          () => const OnboardingScreen(),
          transition: Transition.fadeIn,
          duration: const Duration(
            milliseconds: 800,
          ), // Transisi lebih halus (0.8 detik)
        );
      } else if (token != null && token.isNotEmpty) {
        // Jika sudah ada token login, LANGSUNG LEMPAR KE DASHBOARD (Auto Login)
        Get.offAll(
          () => DashboardScreen(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 800),
        );
      } else {
        // Jika sudah pernah onboarding tapi belum login, lempar ke Login Screen
        Get.offAll(
          () => LoginScreen(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 800),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0B1B4D),
      body: Stack(
        children: [
          // ==========================================
          // 1. BACKGROUND GRADIENT CORPORATE
          // ==========================================
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xff0B1B4D),
                  Color(0xff1E3A8A),
                  Color(0xff0EA5E9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 0.45, 1],
              ),
            ),
          ),

          // ==========================================
          // 2. KONTEN TENGAH (MINIMALIS & ELEGAN)
          // ==========================================
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon Logo
                Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.location_on_rounded,
                        color: Colors.white,
                        size: 54,
                      ),
                    )
                    .animate()
                    .scale(duration: 600.ms, curve: Curves.easeOutBack)
                    .fadeIn(duration: 400.ms),

                const SizedBox(height: 24),

                // Nama App
                Text(
                      "GeoAttend",
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 500.ms)
                    .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),

                const SizedBox(height: 8),

                // Tagline Profesional
                Text(
                  "ENTERPRISE ATTENDANCE",
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.65),
                    letterSpacing: 3.5,
                    fontWeight: FontWeight.w600,
                  ),
                ).animate().fadeIn(delay: 600.ms, duration: 500.ms),

                const SizedBox(height: 60),

                // Loading Indicator Tipis
                const SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                ).animate().fadeIn(delay: 1000.ms, duration: 500.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
