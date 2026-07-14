import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'dashboard/dashboard_screen.dart';
import 'history/history.screen.dart';
import 'karyawan/leave/leave_screen.dart';
import 'profile/profile_screen.dart';

// ============================================================
// NavController
// ============================================================
class NavController extends GetxController {
  var currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;
  }
}

// ============================================================
// MainNavScreen
// ============================================================
class MainNavScreen extends StatelessWidget {
  MainNavScreen({super.key});

  final NavController navController = Get.put(NavController());

  final List<Widget> _pages = [
    DashboardScreen(),
    HistoryScreen(),
    LeaveScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      extendBody: true,
      body: Stack(
        children: [
          Obx(
            () => IndexedStack(
              index: navController.currentIndex.value,
              children: _pages,
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: _FloatingPillNav(controller: navController),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// _FloatingPillNav (Stateful + SingleTickerProvider)
// ============================================================
class _FloatingPillNav extends StatefulWidget {
  final NavController controller;

  const _FloatingPillNav({required this.controller});

  @override
  State<_FloatingPillNav> createState() => _FloatingPillNavState();
}

class _FloatingPillNavState extends State<_FloatingPillNav>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    // 1. Ticker diset tanpa ..repeat().
    // Durasinya cukup 600ms (0.6 detik) untuk sekali interaksi
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Mainkan animasi sekali saat navigasi pertama kali dirender
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Widget _buildAnimatedIcon(int index, bool isActive, double t) {
    // Ikon non-aktif (statis)
    if (!isActive) {
      FaIconData inactiveIcon;
      switch (index) {
        case 0:
          inactiveIcon = FontAwesomeIcons.house;
          break;
        case 1:
          inactiveIcon = FontAwesomeIcons.clockRotateLeft;
          break;
        case 2:
          inactiveIcon = FontAwesomeIcons.envelope;
          break;
        case 3:
          inactiveIcon = FontAwesomeIcons.user;
          break;
        default:
          inactiveIcon = FontAwesomeIcons.house;
      }
      return FaIcon(inactiveIcon, color: const Color(0xFF94A3B8), size: 20);
    }

    // Jika aktif, terapkan rumus animasi "Sekali Jalan"
    final color = Colors.white;
    const double size = 22.0;

    switch (index) {
      case 0:
        // 🏠 Beranda - Hop sekali (naik lalu turun lagi)
        // t * PI bikin grafik setengah lingkaran (mulai 0, naik, balik ke 0)
        final dy = math.sin(t * math.pi) * -6.0;
        return Transform.translate(
          offset: Offset(0, dy),
          child: FaIcon(FontAwesomeIcons.house, color: color, size: size),
        );

      case 1:
        // 🕐 Riwayat - Putar 360 derajat sekali pas diklik
        final angle = t * 2 * math.pi;
        return Transform.rotate(
          angle: angle,
          child: FaIcon(
            FontAwesomeIcons.clockRotateLeft,
            color: color,
            size: size,
          ),
        );

      case 2:
        // 📩 Izin & Cuti - Amplop bolak-balik terbuka lalu tertutup kembali
        // Terbuka hanya di pertengahan animasi (antara 30% s.d 70% waktu berjalan)
        final bool isFlappingOpen = t > 0.3 && t < 0.7;
        return FaIcon(
          isFlappingOpen
              ? FontAwesomeIcons.envelopeOpenText
              : FontAwesomeIcons.envelope,
          color: color,
          size: size,
        );

      case 3:
        // 👤 Profil - Goyang kanan-kiri (Wiggle) lalu diam
        // t * 3 * PI bikin efek bolak-balik 1.5 kali sebelum berhenti sempurna di 0
        final wiggleAngle = math.sin(t * 3 * math.pi) * 0.25;
        // Supaya di akhir animasi (t=1) posisinya lurus lagi, kita redam goyangannya
        final damping = 1.0 - t;
        return Transform.rotate(
          angle: wiggleAngle * damping,
          child: FaIcon(FontAwesomeIcons.user, color: color, size: size),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const int itemCount = 4;
          final segmentWidth = constraints.maxWidth / itemCount;
          const double indicatorSize = 48.0;
          const double topPosition = 2.0;

          return Obx(() {
            final activeIndex = widget.controller.currentIndex.value;

            return Stack(
              children: [
                // Indikator BULAT meluncur
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutBack,
                  left:
                      (segmentWidth * activeIndex) +
                      ((segmentWidth - indicatorSize) / 2),
                  width: indicatorSize,
                  height: indicatorSize,
                  top: topPosition,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E293B),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                // Baris Ikon
                AnimatedBuilder(
                  animation: _animCtrl,
                  builder: (context, child) {
                    final t = _animCtrl.value;

                    return Row(
                      children: List.generate(itemCount, (index) {
                        final isActive = activeIndex == index;

                        return Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              // 2. Trigger Perubahan Tab
                              widget.controller.changeTab(index);

                              // 3. JALANKAN ANIMASI SEKALI JALAN SETIAP DIKLIK!
                              // from: 0.0 memaksa timer reset ke awal
                              _animCtrl.forward(from: 0.0);
                            },
                            child: Center(
                              child: _buildAnimatedIcon(index, isActive, t),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ],
            );
          });
        },
      ),
    );
  }
}
