import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// IMPORT CONTROLLERS
import '../../controllers/auth_controller.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/attendance_controller.dart';

// IMPORT SCREENS (UNTUK ROUTING)
import '../history/history.screen.dart';
import '../profile/profile_screen.dart';
import '../karyawan/leave/leave_screen.dart';

// ==========================================================
// PALET WARNA — dibatasi sengaja biar kesan corporate/formal.
// Warna status (hijau/oranye) HANYA dipakai untuk indikator,
// bukan dekorasi, sesuai gaya corporate yang diminta.
// ==========================================================
class _Palette {
  static const navy = Color(0xFF1E293B); // dipakai untuk shadow kartu
  static const navySoft = Color(0xFF334155);
  static const slate900 = Color(0xFF0F172A); // Teks utama
  static const slate500 = Color(0xFF64748B); // Teks sekunder
  static const slate400 = Color(0xFF94A3B8); // Teks tersier / disabled
  static const border = Color(0xFFE2E8F0);
  static const bg = Color(0xFFF8FAFC);
  static const success = Color(0xFF059669);
  static const warning = Color(0xFFD97706);
  static const danger = Color(0xFFDC2626);
  static const info = Color(0xFF2563EB);
}

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final AuthController authController = Get.find<AuthController>();
  final DashboardController dashController = Get.put(DashboardController());
  final AttendanceController attendanceController = Get.put(
    AttendanceController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Palette.bg,
      body: SafeArea(
        child: Obx(() {
          if (dashController.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                color: _Palette.navy,
                strokeWidth: 2.5,
              ),
            );
          }

          return SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---------------- HEADER ----------------
                  _buildHeader(),
                  const SizedBox(height: 24),

                  if (dashController.assignmentsList.isNotEmpty &&
                      !dashController.hasActiveShift.value)
                    _buildNoticeBar(
                      icon: FontAwesomeIcons.solidBell,
                      color: _Palette.info,
                      text:
                          'Anda memiliki jadwal shift hari ini. Jangan lupa untuk Absen Masuk!',
                    ),

                  // ---------------- HERO: JAM & SHIFT ----------------
                  _buildTimeCard(),
                  const SizedBox(height: 18),

                  // ---------------- STATUS SECTION ----------------
                  if (dashController.hasActiveShift.value)
                    _buildStatusSection(
                      title: 'Status Shift Berjalan',
                      child: _buildInfoStrip(
                        icon: FontAwesomeIcons.circleCheck,
                        color: _Palette.success,
                        text:
                            'Anda sudah Absen Masuk. Dropdown jadwal dikunci hingga Anda Absen Pulang.',
                      ),
                    )
                  else if (dashController.assignmentsList.isNotEmpty)
                    _buildStatusSection(
                      title: 'Pilih Lokasi & Shift',
                      child: _buildShiftDropdown(),
                    )
                  else
                    _buildStatusSection(
                      title: 'Status Hari Ini',
                      child: _buildInfoStrip(
                        icon: FontAwesomeIcons.champagneGlasses,
                        color: _Palette.info,
                        text:
                            'Semua shift Anda hari ini telah selesai! Selamat beristirahat.',
                      ),
                    ),

                  const SizedBox(height: 18),

                  // ---------------- AKSI CEPAT ----------------
                  const Text(
                    'Aksi Cepat',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _Palette.slate900,
                      letterSpacing: 0.1,
                    ),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: Obx(
                          () => _buildActionCard(
                            attendanceController.isClockingIn.value
                                ? 'Memproses...'
                                : 'Absen Masuk',
                            FontAwesomeIcons.cameraRetro,
                            (dashController.hasActiveShift.value ||
                                    dashController.assignmentsList.isEmpty)
                                ? _Palette.slate400
                                : _Palette.success,
                            onTap: () {
                              if (dashController.assignmentsList.isEmpty &&
                                  !dashController.hasActiveShift.value) {
                                Get.snackbar(
                                  'Selesai 🎉',
                                  'Semua shift hari ini sudah selesai.',
                                  backgroundColor: Colors.blue,
                                  colorText: Colors.white,
                                );
                                return;
                              }
                              if (dashController.hasActiveShift.value) {
                                Get.snackbar(
                                  'Shift Sedang Berjalan',
                                  'Anda sudah absen masuk.',
                                  backgroundColor: Colors.orange,
                                  colorText: Colors.white,
                                );
                                return;
                              }

                              if (!attendanceController.isClockingIn.value) {
                                String selectedId =
                                    dashController.selectedAssignmentId.value;
                                if (selectedId.isNotEmpty) {
                                  var selectedAssignment = dashController
                                      .assignmentsList
                                      .firstWhere(
                                        (a) =>
                                            '${a['location_id']}_${a['schedule_id']}' ==
                                            selectedId,
                                      );

                                  double targetLat = double.parse(
                                    selectedAssignment['location']['latitude']
                                        .toString(),
                                  );
                                  double targetLng = double.parse(
                                    selectedAssignment['location']['longitude']
                                        .toString(),
                                  );
                                  double allowedRadius =
                                      selectedAssignment['location']['radius'] !=
                                          null
                                      ? double.parse(
                                          selectedAssignment['location']['radius']
                                              .toString(),
                                        )
                                      : 100.0;

                                  attendanceController.clockIn(
                                    selectedId,
                                    targetLat,
                                    targetLng,
                                    allowedRadius,
                                  );
                                } else {
                                  Get.snackbar(
                                    'Peringatan',
                                    'Pilih shift / lokasi kerja terlebih dahulu!',
                                    backgroundColor: Colors.orange,
                                    colorText: Colors.white,
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Obx(
                          () => _buildActionCard(
                            attendanceController.isClockingOut.value
                                ? 'Memproses...'
                                : 'Absen Pulang',
                            FontAwesomeIcons.houseUser,
                            !dashController.hasActiveShift.value
                                ? _Palette.slate400
                                : _Palette.warning,
                            onTap: () {
                              if (!dashController.hasActiveShift.value) {
                                if (dashController.assignmentsList.isEmpty) {
                                  Get.snackbar(
                                    'Selesai 🎉',
                                    'Semua shift hari ini sudah selesai.',
                                    backgroundColor: Colors.blue,
                                    colorText: Colors.white,
                                  );
                                } else {
                                  Get.snackbar(
                                    'Belum Mulai Shift',
                                    'Tidak bisa absen pulang sebelum absen masuk.',
                                    backgroundColor: Colors.orange,
                                    colorText: Colors.white,
                                  );
                                }
                                return;
                              }

                              if (!attendanceController.isClockingOut.value) {
                                String selectedId =
                                    dashController.selectedAssignmentId.value;
                                if (selectedId.isNotEmpty) {
                                  var selectedAssignment = dashController
                                      .assignmentsList
                                      .firstWhere(
                                        (a) =>
                                            '${a['location_id']}_${a['schedule_id']}' ==
                                            selectedId,
                                      );

                                  double targetLat = double.parse(
                                    selectedAssignment['location']['latitude']
                                        .toString(),
                                  );
                                  double targetLng = double.parse(
                                    selectedAssignment['location']['longitude']
                                        .toString(),
                                  );
                                  double allowedRadius =
                                      selectedAssignment['location']['radius'] !=
                                          null
                                      ? double.parse(
                                          selectedAssignment['location']['radius']
                                              .toString(),
                                        )
                                      : 100.0;

                                  attendanceController.clockOut(
                                    selectedId,
                                    targetLat,
                                    targetLng,
                                    allowedRadius,
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          'Riwayat Absen',
                          FontAwesomeIcons.clockRotateLeft,
                          _Palette.navySoft,
                          onTap: () => Get.to(() => HistoryScreen()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionCard(
                          'Izin & Cuti',
                          FontAwesomeIcons.envelopeOpenText,
                          _Palette.navySoft,
                          onTap: () => Get.to(() => LeaveScreen()),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ============================================================
  // HEADER: avatar kotak-rounded, teks rapi, tombol keluar minimal
  // ============================================================
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Get.to(() => ProfileScreen()),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: _Palette.navy,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: dashController.userProfilePic.value.isEmpty
                      ? const Center(
                          child: FaIcon(
                            FontAwesomeIcons.user,
                            color: Colors.white,
                            size: 18,
                          ),
                        )
                      : Image.network(
                          dashController.userProfilePic.value,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(
                                child: FaIcon(
                                  FontAwesomeIcons.user,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dashController.userName.value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _Palette.slate900,
                    ),
                  ),
                  Text(
                    dashController.currentDate.value,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: _Palette.slate500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        InkWell(
          onTap: () => authController.logout(),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: _Palette.border),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const FaIcon(
              FontAwesomeIcons.arrowRightFromBracket,
              color: _Palette.slate500,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // NOTICE BAR: reminder shift, dipakai untuk banner atas
  // ============================================================
  Widget _buildNoticeBar({
    required FaIconData icon,
    required Color color,
    required String text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _Palette.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          FaIcon(icon, color: color, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: _Palette.slate900,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HERO CARD: waktu & shift.
  // SEKARANG background-nya adalah _AnimatedSkyCard yang mengisi
  // SELURUH kartu dan otomatis ganti tampilan sesuai jam:
  //   Pagi (05:00-10:59) / Siang (11:00-14:59) /
  //   Sore (15:00-17:59) / Malam (18:00-04:59)
  // Konten (nama shift, jam, lokasi) tetap sama persis, cuma
  // sekarang ditumpuk di atas animasi lewat Stack, dengan overlay
  // gelap tipis di bawah supaya teks tetap kebaca di semua fase.
  // ============================================================
  Widget _buildTimeCard() {
    return Container(
      width: double.infinity,
      height: 170,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _Palette.navy.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Lapisan animasi langit - mengisi seluruh kartu
          const _AnimatedSkyCard(),

          // Konten di atas animasi
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Row(
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.clock,
                            color: Colors.white70,
                            size: 12,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            dashController.shiftName.value,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildPeriodLabel(),
                  ],
                ),
                const Spacer(),
                Text(
                  dashController.currentTime.value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    fontFeatures: [FontFeature.tabularFigures()],
                    shadows: [Shadow(color: Colors.black38, blurRadius: 12)],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.locationDot,
                      color: Colors.white70,
                      size: 12,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${dashController.locationName.value}  •  ${dashController.shiftTime.value}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Label kecil nama fase waktu (Pagi/Siang/Sore/Malam) di pojok
  // kanan atas, menggantikan badge ikon kecil yang lama - sekarang
  // tidak perlu ikon lagi karena seluruh kartu sudah jadi animasinya.
  Widget _buildPeriodLabel() {
    final period = _skyPeriodFromHour(DateTime.now().hour);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Text(
        _skyPeriodLabel(period),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 11.5,
        ),
      ),
    );
  }

  // ============================================================
  // STATUS SECTION wrapper: judul kecil + isi (dropdown/info strip)
  // ============================================================
  Widget _buildStatusSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _Palette.slate500,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }

  // ============================================================
  // INFO STRIP: dipakai untuk status "sudah absen" / "shift selesai"
  // Gaya corporate: aksen warna cuma di garis kiri, bukan seluruh
  // background, biar tidak terlalu ramai.
  // ============================================================
  Widget _buildInfoStrip({
    required FaIconData icon,
    required Color color,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _Palette.border),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          FaIcon(icon, color: color, size: 17),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: _Palette.slate900,
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DROPDOWN PILIH SHIFT - logika identik dengan versi sebelumnya
  // ============================================================
  Widget _buildShiftDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _Palette.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          icon: const FaIcon(
            FontAwesomeIcons.chevronDown,
            size: 14,
            color: _Palette.slate500,
          ),
          value: dashController.selectedAssignmentId.value.isEmpty
              ? null
              : dashController.selectedAssignmentId.value,
          hint: const Text(
            'Memuat shift...',
            style: TextStyle(color: _Palette.slate400),
          ),
          items: dashController.assignmentsList.map((assignment) {
            String id =
                '${assignment['location_id']}_${assignment['schedule_id']}';
            String locName = assignment['location']['name'];
            String shfName = assignment['schedule']['name'];
            String timeIn = assignment['schedule']['time_in'].substring(0, 5);
            return DropdownMenuItem<String>(
              value: id,
              child: Text(
                '$locName - $shfName ($timeIn)',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: _Palette.navySoft,
                  fontSize: 13.5,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              var selected = dashController.assignmentsList.firstWhere(
                (a) => '${a['location_id']}_${a['schedule_id']}' == newValue,
              );
              dashController.changeShift(selected);
            }
          },
        ),
      ),
    );
  }

  // ============================================================
  // ACTION CARD - signature SAMA PERSIS seperti versi lama supaya
  // semua pemanggilan di atas tidak perlu diubah sama sekali.
  // ============================================================
  Widget _buildActionCard(
    String title,
    FaIconData icon,
    Color color, {
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () {
          debugPrint("DEBUG: Tombol $title ditekan!");
          onTap();
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _Palette.border),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: FaIcon(icon, color: color, size: 18)),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: color == _Palette.slate400
                      ? _Palette.slate400
                      : _Palette.slate900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// PERIODE WAKTU - 4 fase, dipakai bersama oleh label & animasi
// ============================================================
enum _SkyPeriod { pagi, siang, sore, malam }

_SkyPeriod _skyPeriodFromHour(int hour) {
  if (hour >= 5 && hour < 11) return _SkyPeriod.pagi;
  if (hour >= 11 && hour < 15) return _SkyPeriod.siang;
  if (hour >= 15 && hour < 18) return _SkyPeriod.sore;
  return _SkyPeriod.malam;
}

String _skyPeriodLabel(_SkyPeriod p) {
  switch (p) {
    case _SkyPeriod.pagi:
      return 'Pagi';
    case _SkyPeriod.siang:
      return 'Siang';
    case _SkyPeriod.sore:
      return 'Sore';
    case _SkyPeriod.malam:
      return 'Malam';
  }
}

// ============================================================
// _AnimatedSkyCard
// ------------------------------------------------------------
// Mengisi SELURUH hero card. Cek jam tiap dibangun ulang lewat
// _skyPeriodFromHour, lalu render gradient + elemen animasi yang
// sesuai. Satu AnimationController dipakai untuk semua gerakan
// (rotasi sinar, drift awan, kedip bintang) dengan frekuensi
// berbeda-beda supaya ringan.
// ============================================================
class _AnimatedSkyCard extends StatefulWidget {
  const _AnimatedSkyCard();

  @override
  State<_AnimatedSkyCard> createState() => _AnimatedSkyCardState();
}

class _AnimatedSkyCardState extends State<_AnimatedSkyCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_StarSpec> _stars;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
    _stars = List.generate(24, (i) => _StarSpec.random(Random(i * 91)));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final period = _skyPeriodFromHour(DateTime.now().hour);

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = _ctrl.value;
        return Stack(
          fit: StackFit.expand,
          children: [
            Container(decoration: BoxDecoration(gradient: _gradient(period))),
            ..._skyContent(period, t),
            // overlay gelap tipis dari atas (transparan) ke bawah
            // (agak gelap) supaya teks jam & lokasi tetap terbaca
            // di semua fase, termasuk siang yang terang.
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black45],
                  stops: [0.35, 1.0],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  LinearGradient _gradient(_SkyPeriod period) {
    switch (period) {
      case _SkyPeriod.pagi:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF5B8FD9), Color(0xFFFFB27A), Color(0xFFFFDDA8)],
        );
      case _SkyPeriod.siang:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF3E8FEF), Color(0xFF7EC0FA)],
        );
      case _SkyPeriod.sore:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF3B4A78), Color(0xFFE07A4F), Color(0xFFF6B05C)],
        );
      case _SkyPeriod.malam:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0B1130), Color(0xFF1B2559), Color(0xFF2C3568)],
        );
    }
  }

  List<Widget> _skyContent(_SkyPeriod period, double t) {
    switch (period) {
      case _SkyPeriod.pagi:
        return [
          _cloud(left: 24, topFrac: 0.16, scale: 0.8, phase: t),
          _cloud(left: 160, topFrac: 0.24, scale: 1.05, phase: t + 0.35),
          Align(
            alignment: const Alignment(-0.15, 0.45),
            child: _sun(
              t: t,
              size: 78,
              color: const Color(0xFFFFD27A),
              glow: const Color(0x99FFB74D),
              rayCount: 10,
              rayLength: 16,
              pulsing: false,
            ),
          ),
        ];
      case _SkyPeriod.siang:
        return [
          _cloud(left: 20, topFrac: 0.14, scale: 0.9, phase: t + 0.5),
          _cloud(left: 190, topFrac: 0.1, scale: 0.7, phase: t),
          Align(
            alignment: const Alignment(0, -0.15),
            child: _sun(
              t: t,
              size: 92,
              color: const Color(0xFFFFF176),
              glow: const Color(0xAAFFEB3B),
              rayCount: 14,
              rayLength: 26,
              pulsing: true,
            ),
          ),
        ];
      case _SkyPeriod.sore:
        return [
          _cloud(left: 30, topFrac: 0.2, scale: 0.85, phase: t + 0.2),
          Align(
            alignment: const Alignment(0.2, 0.55),
            child: _sun(
              t: t,
              size: 100,
              color: const Color(0xFFFF9D5C),
              glow: const Color(0x99FF7043),
              rayCount: 12,
              rayLength: 20,
              pulsing: false,
            ),
          ),
        ];
      case _SkyPeriod.malam:
        return [
          for (final star in _stars)
            Positioned(
              left: star.dxFrac * 300,
              top: star.dyFrac * 150,
              child: Opacity(
                opacity:
                    (0.25 +
                            0.75 *
                                ((sin(t * 2 * pi * star.speed + star.phase) +
                                        1) /
                                    2))
                        .clamp(0.0, 1.0),
                child: Container(
                  width: star.size,
                  height: star.size,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          _shootingStar(t),
          Align(
            alignment: const Alignment(0.55, -0.35),
            child: _moon(size: 62),
          ),
        ];
    }
  }

  Widget _shootingStar(double t) {
    const start = 0.55, end = 0.63;
    if (t < start || t > end) return const SizedBox.shrink();
    final local = (t - start) / (end - start);
    return Positioned(
      left: 30 + local * 140,
      top: 20 + local * 50,
      child: Opacity(
        opacity: (1 - local).clamp(0.0, 1.0),
        child: Transform.rotate(
          angle: pi / 4,
          child: Container(
            width: 38,
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white.withValues(alpha: 0), Colors.white],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _moon({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFF3EFE0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF3EFE0).withValues(alpha: 0.5),
            blurRadius: 24,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: size * 0.2,
            top: size * 0.25,
            child: _crater(size * 0.18),
          ),
          Positioned(
            right: size * 0.15,
            top: size * 0.5,
            child: _crater(size * 0.12),
          ),
          Positioned(
            left: size * 0.45,
            bottom: size * 0.15,
            child: _crater(size * 0.14),
          ),
        ],
      ),
    );
  }

  Widget _crater(double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.black.withValues(alpha: 0.08),
    ),
  );

  Widget _cloud({
    required double left,
    required double topFrac,
    required double scale,
    required double phase,
  }) {
    final dx = (phase % 1.0) * 220 - 30;
    return Positioned(
      left: left + dx,
      top: topFrac * 240,
      child: Transform.scale(
        scale: scale,
        child: const Opacity(opacity: 0.85, child: _CloudShape()),
      ),
    );
  }

  Widget _sun({
    required double t,
    required double size,
    required Color color,
    required Color glow,
    required int rayCount,
    required double rayLength,
    required bool pulsing,
  }) {
    final pulseScale = pulsing ? 1 + 0.04 * sin(t * 2 * pi * 3) : 1.0;
    return Transform.scale(
      scale: pulseScale,
      child: SizedBox(
        width: size + rayLength * 2 + 20,
        height: size + rayLength * 2 + 20,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Transform.rotate(
              angle: t * 2 * pi,
              child: CustomPaint(
                size: Size(size + rayLength * 2, size + rayLength * 2),
                painter: _RaysPainter(
                  rayCount: rayCount,
                  rayLength: rayLength,
                  color: color.withValues(alpha: 0.8),
                  radius: size / 2 + 6,
                ),
              ),
            ),
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                boxShadow: [
                  BoxShadow(color: glow, blurRadius: 36, spreadRadius: 6),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StarSpec {
  final double dxFrac, dyFrac, size, phase, speed;
  _StarSpec(this.dxFrac, this.dyFrac, this.size, this.phase, this.speed);

  factory _StarSpec.random(Random r) {
    return _StarSpec(
      r.nextDouble(),
      r.nextDouble() * 0.7,
      1.4 + r.nextDouble() * 2,
      r.nextDouble() * 2 * pi,
      0.4 + r.nextDouble() * 1.3,
    );
  }
}

class _RaysPainter extends CustomPainter {
  final int rayCount;
  final double rayLength;
  final double radius;
  final Color color;

  _RaysPainter({
    required this.rayCount,
    required this.rayLength,
    required this.radius,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < rayCount; i++) {
      final angle = (2 * pi / rayCount) * i;
      final start = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      final end = Offset(
        center.dx + (radius + rayLength) * cos(angle),
        center.dy + (radius + rayLength) * sin(angle),
      );
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RaysPainter oldDelegate) => true;
}

class _CloudShape extends StatelessWidget {
  const _CloudShape();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 40,
      child: Stack(
        children: [
          Positioned(left: 10, top: 12, child: _blob(45, 26)),
          Positioned(left: 30, top: 0, child: _blob(50, 34)),
          Positioned(left: 55, top: 14, child: _blob(38, 22)),
        ],
      ),
    );
  }

  Widget _blob(double w, double h) => Container(
    width: w,
    height: h,
    decoration: const BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
    ),
  );
}
