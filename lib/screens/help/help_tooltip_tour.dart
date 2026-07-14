import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

/// Helper untuk menampilkan TOOLTIP TUR (bukan halaman onboarding penuh)
/// yang menyorot widget tertentu di halaman utama, misalnya tombol Absen,
/// menu Pengajuan, dan ikon Bantuan.
///
/// Sengaja diberi nama `HelpTooltipTour` (bukan `OnboardingTour`) dan file
/// `help_tooltip_tour.dart` supaya tidak bentrok dengan `onboarding_screen.dart`
/// yang sudah ada di project kamu (biasanya halaman intro/slide saat pertama
/// install app — beda fungsi dengan tooltip ini).
///
/// CARA PAKAI (biasanya di HomeScreen / DashboardScreen):
///
/// 1. Buat GlobalKey untuk widget yang ingin disorot:
///    final GlobalKey _absenKey = GlobalKey();
///    final GlobalKey _helpKey = GlobalKey();
///
/// 2. Pasang key ke widget terkait, misal:
///    ElevatedButton(key: _absenKey, ...)
///
/// 3. Panggil di initState (idealnya dicek dulu via SharedPreferences
///    apakah user sudah pernah lihat tur ini):
///
///    WidgetsBinding.instance.addPostFrameCallback((_) {
///      HelpTooltipTour.show(
///        context: context,
///        targets: [
///          HelpTooltipTarget(
///            key: _absenKey,
///            title: 'Absen Masuk & Pulang',
///            description: 'Tekan tombol ini untuk mencatat kehadiranmu.',
///          ),
///          HelpTooltipTarget(
///            key: _helpKey,
///            title: 'Pusat Bantuan',
///            description: 'Butuh bantuan? Semua panduan ada di sini.',
///          ),
///        ],
///      );
///    });
class HelpTooltipTarget {
  final GlobalKey key;
  final String title;
  final String description;
  final ContentAlign align;

  HelpTooltipTarget({
    required this.key,
    required this.title,
    required this.description,
    this.align = ContentAlign.bottom,
  });
}

class HelpTooltipTour {
  static void show({
    required BuildContext context,
    required List<HelpTooltipTarget> targets,
    VoidCallback? onFinish,
  }) {
    final tutorialTargets = targets.map((t) {
      return TargetFocus(
        identify: t.title,
        keyTarget: t.key,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        contents: [
          TargetContent(
            align: t.align,
            builder: (context, controller) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    t.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.description,
                    style: const TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                ],
              );
            },
          ),
        ],
      );
    }).toList();

    TutorialCoachMark(
      targets: tutorialTargets,
      colorShadow: Colors.black,
      textSkip: 'LEWATI',
      paddingFocus: 6,
      opacityShadow: 0.85,
      onFinish: onFinish,
      onClickTarget: (target) {},
      onSkip: () {
        onFinish?.call();
        return true;
      },
    ).show(context: context);
  }
}
