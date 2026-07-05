import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// IMPORT CONTROLLERS
import 'package:geo_attend/controllers/auth_controller.dart';
import 'package:geo_attend/controllers/dashboard_controller.dart';
import 'package:geo_attend/controllers/attendance_controller.dart';

// IMPORT SCREENS (UNTUK ROUTING)
import 'package:geo_attend/screens/history/history_screen.dart';
import 'package:geo_attend/screens/profile/profile_screen.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final AuthController authController = Get.find<AuthController>();
  final DashboardController dashController = Get.put(DashboardController());
  final AttendanceController attendanceController = Get.put(AttendanceController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Obx(() {
          if (dashController.isLoading.value) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF0EA5E9)));
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==============================
                  // 1. BANNER NOTIFIKASI PINTAR (PALING ATAS)
                  // ==============================
                  if (dashController.assignmentsList.isNotEmpty && !dashController.hasActiveShift.value)
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF), // Biru sangat muda
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Row(
                        children: [
                          const FaIcon(FontAwesomeIcons.solidBell, color: Color(0xFF3B82F6), size: 18),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Anda memiliki jadwal shift hari ini. Jangan lupa untuk Absen Masuk!',
                              style: TextStyle(color: Colors.blue[800], fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // ==============================
                  // 2. HEADER: Profil (BISA DIKLIK) & Logout
                  // ==============================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // GESTURE DETECTOR: Biar area foto & nama bisa ditekan
                      GestureDetector(
                        onTap: () {
                          // PERBAIKAN: Langsung routing ke profil, tanpa const, tanpa snackbar
                          Get.to(() => ProfileScreen());
                        },
                        child: Row(
                          children: [
                            Container(
                              width: 50, height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(colors: [Color(0xFF0EA5E9), Color(0xFF3B82F6)]),
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [BoxShadow(color: const Color(0xFF0EA5E9).withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
                              ),
                              child: ClipOval(
                                // PERBAIKAN: Logika dinamis untuk menampilkan foto profil dari URL
                                child: dashController.userProfilePic.value.isEmpty
                                    ? const Center(child: FaIcon(FontAwesomeIcons.userAstronaut, color: Colors.white, size: 24))
                                    : Image.network(
                                        dashController.userProfilePic.value,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => const Center(
                                          child: FaIcon(FontAwesomeIcons.userAstronaut, color: Colors.white, size: 24),
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Halo, ${dashController.userName.value}!', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                                const Text('Siap produktif hari ini?', style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // TOMBOL LOGOUT
                      IconButton(
                        onPressed: () => authController.logout(),
                        icon: const FaIcon(FontAwesomeIcons.arrowRightFromBracket, color: Color(0xFFEF4444)),
                        tooltip: 'Keluar',
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // ==============================
                  // KARTU STATUS SHIFT (BIRU)
                  // ==============================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(colors: [Color(0xFF0EA5E9), Color(0xFF3B82F6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      boxShadow: [BoxShadow(color: const Color(0xFF0EA5E9).withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                              child: Row(
                                children: [
                                  const FaIcon(FontAwesomeIcons.clock, color: Colors.white, size: 14),
                                  const SizedBox(width: 6),
                                  Text(dashController.shiftName.value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                                ],
                              ),
                            ),
                            Text(dashController.currentDate.value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(dashController.currentTime.value, style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w800, letterSpacing: 2)),
                        const SizedBox(height: 8),
                        Text('${dashController.locationName.value} • ${dashController.shiftTime.value}', style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ==============================
                  // KONDISI TAMPILAN SHIFT
                  // ==============================
                  if (dashController.hasActiveShift.value)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Status Shift Berjalan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF10B981), width: 1.5),
                          ),
                          child: Row(
                            children: [
                              const FaIcon(FontAwesomeIcons.circleCheck, color: Color(0xFF10B981)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text('Anda sudah Absen Masuk. Dropdown jadwal dikunci hingga Anda Absen Pulang.',
                                  style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    )
                  else if (dashController.assignmentsList.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Pilih Lokasi & Shift', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5)),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              icon: const FaIcon(FontAwesomeIcons.chevronDown, size: 16, color: Color(0xFF64748B)),
                              value: dashController.selectedAssignmentId.value.isEmpty ? null : dashController.selectedAssignmentId.value,
                              hint: const Text('Memuat shift...', style: TextStyle(color: Color(0xFF94A3B8))),
                              items: dashController.assignmentsList.map((assignment) {
                                String id = '${assignment['location_id']}_${assignment['schedule_id']}';
                                String locName = assignment['location']['name'];
                                String shfName = assignment['schedule']['name'];
                                String timeIn = assignment['schedule']['time_in'].substring(0, 5);
                                return DropdownMenuItem<String>(
                                  value: id,
                                  child: Text('$locName - $shfName ($timeIn)', style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155), fontSize: 14), overflow: TextOverflow.ellipsis),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  var selected = dashController.assignmentsList.firstWhere((a) => '${a['location_id']}_${a['schedule_id']}' == newValue);
                                  dashController.changeShift(selected);
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    )
                  else 
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Status Hari Ini', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF3B82F6), width: 1.5),
                          ),
                          child: Row(
                            children: [
                              const FaIcon(FontAwesomeIcons.champagneGlasses, color: Color(0xFF3B82F6)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text('Semua shift Anda hari ini telah selesai! Selamat beristirahat.',
                                  style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),

                  // ==============================
                  // MENU UTAMA (Grid Actions)
                  // ==============================
                  const Text('Aksi Cepat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      // TOMBOL 1: ABSEN MASUK
                      Expanded(
                        child: Obx(() => _buildActionCard(
                          attendanceController.isClockingIn.value ? 'Memproses...' : 'Absen Masuk', 
                          FontAwesomeIcons.cameraRetro, 
                          (dashController.hasActiveShift.value || dashController.assignmentsList.isEmpty) ? const Color(0xFF94A3B8) : const Color(0xFF10B981), 
                          onTap: () {
                            if (dashController.assignmentsList.isEmpty && !dashController.hasActiveShift.value) {
                              Get.snackbar('Selesai 🎉', 'Semua shift hari ini sudah selesai.', backgroundColor: Colors.blue, colorText: Colors.white);
                              return;
                            }
                            if (dashController.hasActiveShift.value) {
                              Get.snackbar('Shift Sedang Berjalan', 'Anda sudah absen masuk.', backgroundColor: Colors.orange, colorText: Colors.white);
                              return;
                            }
                            
                            if (!attendanceController.isClockingIn.value) {
                              String selectedId = dashController.selectedAssignmentId.value;
                              if (selectedId.isNotEmpty) {
                                var selectedAssignment = dashController.assignmentsList.firstWhere((a) => '${a['location_id']}_${a['schedule_id']}' == selectedId);
                                
                                double targetLat = double.parse(selectedAssignment['location']['latitude'].toString());
                                double targetLng = double.parse(selectedAssignment['location']['longitude'].toString());
                                double allowedRadius = selectedAssignment['location']['radius'] != null ? double.parse(selectedAssignment['location']['radius'].toString()) : 100.0;
                                
                                attendanceController.clockIn(selectedId, targetLat, targetLng, allowedRadius);
                              } else {
                                Get.snackbar('Peringatan', 'Pilih shift / lokasi kerja terlebih dahulu!', backgroundColor: Colors.orange, colorText: Colors.white);
                              }
                            }
                          }
                        )),
                      ),
                      const SizedBox(width: 16),
                      // TOMBOL 2: ABSEN PULANG
                      Expanded(
                        child: Obx(() => _buildActionCard(
                          attendanceController.isClockingOut.value ? 'Memproses...' : 'Absen Pulang', 
                          FontAwesomeIcons.houseUser, 
                          !dashController.hasActiveShift.value ? const Color(0xFF94A3B8) : const Color(0xFFF59E0B), 
                          onTap: () {
                            if (!dashController.hasActiveShift.value) {
                              if (dashController.assignmentsList.isEmpty) {
                                Get.snackbar('Selesai 🎉', 'Semua shift hari ini sudah selesai.', backgroundColor: Colors.blue, colorText: Colors.white);
                              } else {
                                Get.snackbar('Belum Mulai Shift', 'Tidak bisa absen pulang sebelum absen masuk.', backgroundColor: Colors.orange, colorText: Colors.white);
                              }
                              return; 
                            }

                            if (!attendanceController.isClockingOut.value) {
                              String selectedId = dashController.selectedAssignmentId.value;
                              if (selectedId.isNotEmpty) {
                                var selectedAssignment = dashController.assignmentsList.firstWhere((a) => '${a['location_id']}_${a['schedule_id']}' == selectedId);
                                
                                double targetLat = double.parse(selectedAssignment['location']['latitude'].toString());
                                double targetLng = double.parse(selectedAssignment['location']['longitude'].toString());
                                double allowedRadius = selectedAssignment['location']['radius'] != null ? double.parse(selectedAssignment['location']['radius'].toString()) : 100.0;
                                
                                attendanceController.clockOut(selectedId, targetLat, targetLng, allowedRadius);
                              }
                            }
                          }
                        )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // BARIS KEDUA MENU
                  Row(
                    children: [
                      // TOMBOL 3: RIWAYAT ABSEN
                      Expanded(
                        child: _buildActionCard(
                          'Riwayat Absen', 
                          FontAwesomeIcons.clockRotateLeft, 
                          const Color(0xFF8B5CF6), 
                          // PERBAIKAN: Telah menghapus const dengan benar
                          onTap: () => Get.to(() => HistoryScreen()) 
                        )
                      ),
                      const SizedBox(width: 16),
                      // TOMBOL 4: IZIN & CUTI
                      Expanded(
                        child: _buildActionCard(
                          'Izin & Cuti', 
                          FontAwesomeIcons.envelopeOpenText, 
                          const Color(0xFFEC4899), 
                          onTap: () {
                            Get.snackbar('Info', 'Fitur Izin & Cuti sedang disiapkan.', backgroundColor: Colors.blue, colorText: Colors.white);
                          }
                        )
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

  // ==============================
  // WIDGET BANTUAN TOMBOL
  // ==============================
  Widget _buildActionCard(String title, IconData icon, Color color, {required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: () {
          debugPrint("DEBUG: Tombol $title ditekan!"); 
          onTap();
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 2),
            color: Colors.white, 
            boxShadow: [BoxShadow(color: const Color(0xFF94A3B8).withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5))],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Center(child: FaIcon(icon, color: color, size: 24)),
              ),
              const SizedBox(height: 16),
              Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color == const Color(0xFF94A3B8) ? const Color(0xFF94A3B8) : const Color(0xFF334155))),
            ],
          ),
        ),
      ),
    );
  }
}