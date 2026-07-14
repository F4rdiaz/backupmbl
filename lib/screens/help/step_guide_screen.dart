import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GuideItem {
  final String title;
  final FaIconData icon;
  final List<String> steps;

  const GuideItem({
    required this.title,
    required this.icon,
    required this.steps,
  });
}

/// Contoh daftar panduan. Ganti/tambah sesuai fitur geo_attend kamu.
const List<GuideItem> guideList = [
  GuideItem(
    title: 'Cara Absen Masuk',
    icon: FontAwesomeIcons.rightToBracket,
    steps: [
      'Buka aplikasi dan pastikan lokasi (GPS) aktif.',
      'Tekan tombol "Absen Masuk" di halaman utama.',
      'Tunggu aplikasi mendeteksi lokasi kamu.',
      'Ambil foto selfie sebagai bukti kehadiran (jika diminta).',
      'Tekan "Kirim" — status absen akan langsung tercatat.',
    ],
  ),
  GuideItem(
    title: 'Cara Mengajukan Izin/Cuti',
    icon: FontAwesomeIcons.calendarDays,
    steps: [
      'Buka menu "Pengajuan" dari halaman utama.',
      'Pilih jenis pengajuan: Izin, Sakit, atau Cuti.',
      'Isi tanggal mulai dan selesai.',
      'Tuliskan alasan dan unggah dokumen pendukung jika ada.',
      'Tekan "Ajukan" dan tunggu persetujuan atasan.',
    ],
  ),
  GuideItem(
    title: 'Cara Melihat Riwayat Absensi',
    icon: FontAwesomeIcons.clockRotateLeft,
    steps: [
      'Buka menu "Riwayat" dari halaman utama.',
      'Pilih rentang tanggal yang ingin dilihat.',
      'Daftar kehadiran harian akan ditampilkan lengkap dengan jam.',
      'Tekan salah satu tanggal untuk melihat detail.',
    ],
  ),
];

class StepGuideScreen extends StatelessWidget {
  const StepGuideScreen({super.key});

  static const primaryColor = Color(0xFF0284C7);
  static const primaryDark = Color(0xFF0C4A6E);
  static const bgColor = Color(0xFFF4F8FB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          'Panduan Penggunaan',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: guideList.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final guide = guideList[index];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: primaryDark.withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: FaIcon(guide.icon, size: 15, color: primaryColor),
                  ),
                ),
                title: Text(
                  guide.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: guide.steps.asMap().entries.map((entry) {
                  final stepNumber = entry.key + 1;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '$stepNumber',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF334155),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
