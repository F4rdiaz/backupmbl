import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// Sesuaikan import ini dengan lokasi LoginScreen kamu
// import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  late final AnimationController _floatingController;
  int _currentPage = 0;

  // Data 5 Slide (Sama seperti sebelumnya)
  final List<Map<String, dynamic>> _onboardingData = [
    {
      "icon": Icons.location_on_rounded,
      "title": "Kehadiran Presisi",
      "description":
          "Catat kehadiran Anda secara akurat langsung dari titik lokasi yang telah ditentukan oleh perusahaan.",
      "primaryColor": const Color(0xFF6366F1), // Indigo
      "secondaryColor": const Color(0xFFD946EF), // Fuchsia
    },
    {
      "icon": Icons.gpp_bad_rounded,
      "title": "Anti Lokasi Palsu",
      "description":
          "Sistem keamanan cerdas kami otomatis mendeteksi dan memblokir penggunaan aplikasi Fake GPS.",
      "primaryColor": const Color(0xFFEF4444), // Red
      "secondaryColor": const Color(0xFFF59E0B), // Amber
    },
    {
      "icon": Icons.calendar_month_rounded,
      "title": "Kelola Cuti Mudah",
      "description":
          "Ajukan ketidakhadiran, izin, atau cuti serta pantau status persetujuannya langsung dari genggaman.",
      "primaryColor": const Color(0xFF10B981), // Emerald
      "secondaryColor": const Color(0xFF3B82F6), // Blue
    },
    {
      "icon": Icons.bar_chart_rounded,
      "title": "Statistik & Kinerja",
      "description":
          "Pantau grafik kehadiran, jam kerja, dan performa kamu setiap bulan dengan chart yang interaktif.",
      "primaryColor": const Color(0xFF8B5CF6), // Violet
      "secondaryColor": const Color(0xFFEC4899), // Pink
    },
    {
      "icon": Icons.notifications_active_rounded,
      "title": "Notifikasi Real-time",
      "description":
          "Dapatkan pengingat jadwal shift dan update status HR langsung ke layar smartphone Anda.",
      "primaryColor": const Color(0xFFF59E0B), // Amber
      "secondaryColor": const Color(0xFF14B8A6), // Teal
    },
  ];

  @override
  void initState() {
    super.initState();
    // Setup Animasi Melayang (Floating)
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Durasi satu kali naik/turun
    )..repeat(reverse: true); // Looping bolak-balik
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _completeOnboarding() async {
    await _storage.write(key: 'has_seen_onboarding', value: 'true');
    Get.offAllNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final currentData = _onboardingData[_currentPage];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Background Mesh Gradient (Sama seperti sebelumnya)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeInOut,
            top: _currentPage.isEven ? -100 : size.height * 0.2,
            left: _currentPage.isEven ? -100 : size.width * 0.4,
            child: _buildBlob(currentData["primaryColor"], 350),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeInOut,
            bottom: _currentPage.isOdd ? -50 : size.height * 0.1,
            right: _currentPage.isOdd ? -50 : size.width * 0.2,
            child: _buildBlob(currentData["secondaryColor"], 300),
          ),

          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(color: Colors.white.withOpacity(0.4)),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Tombol Skip
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: InkWell(
                      onTap: _completeOnboarding,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Text(
                          "Lewati",
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF334155),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Slider PageView
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _onboardingData.length,
                    itemBuilder: (context, index) {
                      final data = _onboardingData[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Kartu Glassmorphism
                            Container(
                              width: 280,
                              height: 280,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(0.8),
                                    Colors.white.withOpacity(0.3),
                                  ],
                                ),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: data["primaryColor"].withOpacity(
                                      0.15,
                                    ),
                                    blurRadius: 30,
                                    offset: const Offset(0, 15),
                                  ),
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Inner glow background
                                  Container(
                                    width: 140,
                                    height: 140,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          data["secondaryColor"].withOpacity(
                                            0.4,
                                          ),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                  // ANIMASI MELAYANG (FLOATING ICON)
                                  AnimatedBuilder(
                                    animation: _floatingController,
                                    builder: (context, child) {
                                      // Bergerak naik turun sejauh 15 pixel
                                      final dy =
                                          15 * _floatingController.value - 7.5;
                                      return Transform.translate(
                                        offset: Offset(0, dy),
                                        child: child,
                                      );
                                    },
                                    child: ShaderMask(
                                      shaderCallback: (Rect bounds) {
                                        return LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            data["primaryColor"],
                                            data["secondaryColor"],
                                          ],
                                        ).createShader(bounds);
                                      },
                                      child: Icon(
                                        data["icon"],
                                        size: 100,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 50),

                            // Teks Judul & Deskripsi
                            Text(
                              data["title"],
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              data["description"],
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF64748B),
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Navigation
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Dot Indicators
                      Row(
                        children: List.generate(
                          _onboardingData.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 8),
                            height: 8,
                            width: _currentPage == index ? 24 : 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? currentData["primaryColor"]
                                  : const Color(0xFFCBD5E1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),

                      // Tombol Next / Mulai
                      InkWell(
                        onTap: () {
                          if (_currentPage == _onboardingData.length - 1) {
                            _completeOnboarding();
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeOutQuart,
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(30),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                _currentPage == _onboardingData.length - 1
                                ? 24
                                : 20,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: currentData["primaryColor"].withOpacity(
                                  0.3,
                                ),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _currentPage == _onboardingData.length - 1
                                    ? "Mulai Sekarang"
                                    : "Lanjut",
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
        color: color.withOpacity(0.5),
      ),
    );
  }
}
