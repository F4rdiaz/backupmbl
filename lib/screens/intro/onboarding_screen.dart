import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// Sesuaikan import ini dengan lokasi LoginScreen kamu
import '../auth/login_screen.dart';

// ==========================================================
// PALET WARNA - diselaraskan dengan dashboard (navy corporate)
// ==========================================================
class _Palette {
  static const navy = Color(0xFF1E293B);
  static const slate900 = Color(0xFF0F172A);
  static const slate500 = Color(0xFF64748B);
  static const border = Color(0xFFE2E8F0);
  static const info = Color(0xFF2563EB);
  static const success = Color(0xFF059669);
  static const warning = Color(0xFFD97706);
  static const danger = Color(0xFFDC2626);
  static const pro = Color(0xFF7C3AED);
}

enum _SlideType { kehadiran, antiFake, keamanan, cuti, notifikasi }

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  late final AnimationController _iconCtrl;
  int _currentPage = 0;
  double _pageOffset = 0;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      "type": _SlideType.kehadiran,
      "accent": _Palette.info,
      "title": "Kehadiran Presisi",
      "description":
          "Catat kehadiran Anda secara akurat langsung dari titik lokasi yang telah ditentukan oleh perusahaan.",
    },
    {
      "type": _SlideType.antiFake,
      "accent": _Palette.danger,
      "title": "Anti Lokasi Palsu",
      "description":
          "Sistem otomatis mendeteksi dan menolak aplikasi Fake GPS, memastikan Anda benar-benar hadir di lokasi kerja.",
    },
    {
      "type": _SlideType.keamanan,
      "accent": _Palette.success,
      "title": "Verifikasi Foto",
      "description":
          "Ambil foto langsung saat absen untuk memastikan yang hadir adalah Anda sendiri, bukan orang lain.",
    },
    {
      "type": _SlideType.cuti,
      "accent": _Palette.warning,
      "title": "Kelola Cuti Mudah",
      "description":
          "Ajukan ketidakhadiran, izin, atau cuti serta pantau status persetujuannya langsung dari genggaman.",
    },
    {
      "type": _SlideType.notifikasi,
      "accent": _Palette.pro,
      "title": "Notifikasi Real-time",
      "description":
          "Dapatkan pengingat jadwal shift dan update status persetujuan cuti langsung ke perangkat Anda.",
    },
  ];

  @override
  void initState() {
    super.initState();
    _iconCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _pageController.addListener(() {
      setState(() {
        _pageOffset = _pageController.page ?? _currentPage.toDouble();
      });
    });
  }

  @override
  void dispose() {
    _iconCtrl.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _completeOnboarding() async {
    // Simpan memori bahwa user sudah melihat onboarding
    await _storage.write(key: 'has_seen_onboarding', value: 'true');
    // Lempar ke halaman Login dan hapus histori halaman sebelumnya
    Get.offAll(
      () => LoginScreen(),
      transition: Transition.rightToLeftWithFade,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Tombol Skip di pojok kanan atas
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _completeOnboarding,
                child: Text(
                  "Lewati",
                  style: GoogleFonts.poppins(
                    color: _Palette.slate500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // Konten Slider
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
                  final delta = (_pageOffset - index).clamp(-1.0, 1.0);
                  final scale = (1 - delta.abs() * 0.18).clamp(0.8, 1.0);
                  final opacity = (1 - delta.abs() * 0.7).clamp(0.0, 1.0);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Kartu ilustrasi animasi
                        Opacity(
                          opacity: opacity,
                          child: Transform.scale(
                            scale: scale,
                            child: Transform.translate(
                              offset: Offset(delta * 30, 0),
                              child: AnimatedBuilder(
                                animation: _iconCtrl,
                                builder: (context, _) {
                                  return _buildIllustrationCard(
                                    type: data["type"] as _SlideType,
                                    accent: data["accent"] as Color,
                                    t: _iconCtrl.value,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Judul
                        Text(
                          data["title"],
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: _Palette.slate900,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Deskripsi
                        Text(
                          data["description"],
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            height: 1.5,
                            color: _Palette.slate500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Indikator Titik & Tombol Navigasi
            Padding(
              padding: const EdgeInsets.all(32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dot Indicators
                  Row(
                    children: List.generate(
                      _onboardingData.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 6),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? (_onboardingData[_currentPage]["accent"]
                                    as Color)
                              : _Palette.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  // Tombol Lanjut / Mulai
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage == _onboardingData.length - 1) {
                        _completeOnboarding();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _Palette.navy,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentPage == _onboardingData.length - 1
                              ? "Mulai"
                              : "Lanjut",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // KARTU ILUSTRASI - background lembut + karakter animasi sesuai
  // tema slide. t adalah nilai 0..1 dari _iconCtrl yang looping
  // terus-menerus.
  // ============================================================
  Widget _buildIllustrationCard({
    required _SlideType type,
    required Color accent,
    required double t,
  }) {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: accent.withValues(alpha: 0.15)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: switch (type) {
          _SlideType.kehadiran => _kehadiranIllustration(accent, t),
          _SlideType.antiFake => _antiFakeIllustration(accent, t),
          _SlideType.keamanan => _keamananIllustration(accent, t),
          _SlideType.cuti => _cutiIllustration(accent, t),
          _SlideType.notifikasi => _notifikasiIllustration(accent, t),
        },
      ),
    );
  }

  // ------------------- SLIDE 1: Kehadiran Presisi -------------------
  Widget _kehadiranIllustration(Color accent, double t) {
    final bob = sin(t * 2 * pi) * 6;
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: const Size(150, 150),
          painter: _DashedCirclePainter(color: accent.withValues(alpha: 0.3)),
        ),
        for (final phase in [0.0, 0.5])
          Builder(
            builder: (context) {
              final local = (t + phase) % 1.0;
              return Opacity(
                opacity: (1 - local).clamp(0.0, 1.0) * 0.5,
                child: Transform.scale(
                  scale: 0.4 + local * 1.1,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: accent, width: 2),
                    ),
                  ),
                ),
              );
            },
          ),
        Transform.translate(
          offset: Offset(0, -bob - 10),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.4),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
        ),
      ],
    );
  }

  // ------------------- SLIDE 2: Anti Lokasi Palsu -------------------
  Widget _antiFakeIllustration(Color accent, double t) {
    final shake = sin(t * 2 * pi * 6) * 3;
    final pulse = 0.6 + 0.4 * ((sin(t * 2 * pi) + 1) / 2);
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 130 * (0.9 + 0.1 * pulse),
          height: 130 * (0.9 + 0.1 * pulse),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accent.withValues(alpha: 0.08 + 0.05 * pulse),
          ),
        ),
        Transform.translate(
          offset: Offset(shake, 0),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.4),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.gps_off_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
        Positioned(
          top: 36,
          right: 46,
          child: Opacity(
            opacity: pulse,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: accent, width: 2),
              ),
              child: Icon(Icons.priority_high_rounded, color: accent, size: 14),
            ),
          ),
        ),
      ],
    );
  }

  // ------------------- SLIDE 3: Verifikasi Foto -------------------
  Widget _keamananIllustration(Color accent, double t) {
    final pulse = 1 + 0.04 * sin(t * 2 * pi * 2);
    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.translate(
          offset: const Offset(10, 10),
          child: Icon(
            Icons.shield_rounded,
            size: 110,
            color: accent.withValues(alpha: 0.15),
          ),
        ),
        Transform.translate(
          offset: const Offset(-6, -6),
          child: Icon(
            Icons.shield_rounded,
            size: 110,
            color: accent.withValues(alpha: 0.25),
          ),
        ),
        Transform.scale(
          scale: pulse,
          child: ClipPath(
            clipper: _ShieldClipper(),
            child: Container(
              width: 100,
              height: 112,
              color: accent,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
                  Positioned(
                    top: (t % 1.0) * 112 - 6,
                    child: Container(
                      width: 100,
                      height: 6,
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ------------------- SLIDE 4: Kelola Cuti Mudah -------------------
  Widget _cutiIllustration(Color accent, double t) {
    final badgeScale = 1 + 0.15 * sin(t * 2 * pi * 1.5).clamp(0, 1);
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 110,
          height: 130,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: accent.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_month_rounded, color: accent, size: 30),
              const SizedBox(height: 14),
              for (int i = 0; i < 3; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Opacity(
                    opacity: (0.4 + 0.6 * ((sin(t * 2 * pi + i * 1.4) + 1) / 2))
                        .clamp(0.0, 1.0),
                    child: Container(
                      height: 5,
                      width: i == 2 ? 30 : 60,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Positioned(
          bottom: 46,
          right: 46,
          child: Transform.scale(
            scale: badgeScale.toDouble(),
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: accent,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ------------------- SLIDE 5: Notifikasi Real-time -------------------
  Widget _notifikasiIllustration(Color accent, double t) {
    final swing = sin(t * 2 * pi * 2) * 0.12;
    final dotPulse = 0.7 + 0.3 * ((sin(t * 2 * pi * 2) + 1) / 2);
    return Stack(
      alignment: Alignment.center,
      children: [
        for (final ring in [0.0, 0.4])
          Builder(
            builder: (context) {
              final local = (t + ring) % 1.0;
              return Opacity(
                opacity: (1 - local).clamp(0.0, 1.0) * 0.4,
                child: Transform.scale(
                  scale: 0.5 + local * 0.9,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: accent, width: 2),
                    ),
                  ),
                ),
              );
            },
          ),
        Transform.rotate(
          angle: swing,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.4),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.notifications_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
        ),
        Positioned(
          top: 50,
          right: 60,
          child: Transform.scale(
            scale: dotPulse,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;
  _DashedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);
    const dashCount = 28;
    const gapFraction = 0.5;
    for (int i = 0; i < dashCount; i++) {
      final startAngle = (2 * pi / dashCount) * i;
      final sweep = (2 * pi / dashCount) * gapFraction;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) => false;
}

class _ShieldClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w / 2, 0)
      ..lineTo(w, h * 0.18)
      ..lineTo(w, h * 0.55)
      ..quadraticBezierTo(w, h * 0.85, w / 2, h)
      ..quadraticBezierTo(0, h * 0.85, 0, h * 0.55)
      ..lineTo(0, h * 0.18)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
