import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NotificationSettingsController extends GetxController {
  final storage = const FlutterSecureStorage();

  var absenReminder = true.obs;
  var izinCutiUpdate = true.obs;
  var jadwalShiftBaru = true.obs;
  var pengumumanUmum = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    absenReminder.value = await _readBool('notif_absen_reminder', true);
    izinCutiUpdate.value = await _readBool('notif_izin_cuti', true);
    jadwalShiftBaru.value = await _readBool('notif_jadwal_shift', true);
    pengumumanUmum.value = await _readBool('notif_pengumuman', true);
  }

  Future<bool> _readBool(String key, bool fallback) async {
    final val = await storage.read(key: key);
    if (val == null) return fallback;
    return val == 'true';
  }

  Future<void> toggle(String key, RxBool target) async {
    target.value = !target.value;
    await storage.write(key: key, value: target.value.toString());
  }
}

class NotificationSettingsScreen extends StatelessWidget {
  NotificationSettingsScreen({super.key});

  final NotificationSettingsController controller = Get.put(
    NotificationSettingsController(),
  );

  static const primaryColor = Color(0xFF0284C7);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        title: const Text(
          'Pengaturan Notifikasi',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Kelola',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Obx(
                  () => _toggleTile(
                    icon: FontAwesomeIcons.clock,
                    title: 'Pengingat Absen',
                    subtitle: 'Notifikasi sebelum jam masuk/pulang',
                    value: controller.absenReminder.value,
                    onChanged: (_) => controller.toggle(
                      'notif_absen_reminder',
                      controller.absenReminder,
                    ),
                  ),
                ),
                const Divider(height: 1, indent: 62, color: Color(0xFFF1F5F9)),
                Obx(
                  () => _toggleTile(
                    icon: FontAwesomeIcons.fileLines,
                    title: 'Izin & Cuti',
                    subtitle: 'Update status pengajuan izin/cuti',
                    value: controller.izinCutiUpdate.value,
                    onChanged: (_) => controller.toggle(
                      'notif_izin_cuti',
                      controller.izinCutiUpdate,
                    ),
                  ),
                ),
                const Divider(height: 1, indent: 62, color: Color(0xFFF1F5F9)),
                Obx(
                  () => _toggleTile(
                    icon: FontAwesomeIcons.calendarDays,
                    title: 'Jadwal Shift Baru',
                    subtitle: 'Saat ada penugasan shift baru',
                    value: controller.jadwalShiftBaru.value,
                    onChanged: (_) => controller.toggle(
                      'notif_jadwal_shift',
                      controller.jadwalShiftBaru,
                    ),
                  ),
                ),
                const Divider(height: 1, indent: 62, color: Color(0xFFF1F5F9)),
                Obx(
                  () => _toggleTile(
                    icon: FontAwesomeIcons.bullhorn,
                    title: 'Pengumuman Umum',
                    subtitle: 'Info dan pengumuman dari perusahaan',
                    value: controller.pengumumanUmum.value,
                    onChanged: (_) => controller.toggle(
                      'notif_pengumuman',
                      controller.pengumumanUmum,
                    ),
                    isLast: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggleTile({
    required FaIconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: FaIcon(icon, size: 15, color: primaryColor)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: primaryColor,
          ),
        ],
      ),
    );
  }
}
