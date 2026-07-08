import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geo_attend/controllers/history_controller.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HistoryController controller = Get.put(HistoryController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const FaIcon(
            FontAwesomeIcons.arrowLeft,
            color: Color(0xFF0F172A),
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Riwayat Absensi',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          // ==============================
          // BAGIAN DROPDOWN FILTER BAR
          // ==============================
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Obx(
              () => Row(
                children: [
                  const FaIcon(
                    FontAwesomeIcons.filter,
                    size: 16,
                    color: Color(0xFF64748B),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: controller.selectedFilter.value,
                        icon: const FaIcon(
                          FontAwesomeIcons.chevronDown,
                          size: 14,
                          color: Color(0xFF64748B),
                        ),
                        items: controller.filterOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value == 'Pilih Tanggal...' &&
                                      controller.customDate.value != null
                                  ? DateFormat('dd MMM yyyy').format(
                                      controller.customDate.value!,
                                    ) // Ubah teks jadi tanggal yg dipilih
                                  : value,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF334155),
                                fontSize: 14,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          if (newValue == 'Pilih Tanggal...') {
                            controller.pickCustomDate(context);
                          } else if (newValue != null) {
                            controller.selectedFilter.value = newValue;
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ==============================
          // LIST DATA RIWAYAT
          // ==============================
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF0EA5E9)),
                );
              }

              var listData = controller
                  .filteredHistory; // Mengambil data yg sudah difilter

              if (listData.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FaIcon(
                        FontAwesomeIcons.boxOpen,
                        size: 48,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tidak ada data absen.',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: listData.length,
                itemBuilder: (context, index) {
                  var item = listData[index];

                  // Menyesuaikan dengan struktur JSON dari Laravel
                  bool isComplete = item['time_out'] != null;
                  // Kalau API lu nyimpen nama shift di schedule.name
                  String shiftName = item['schedule'] != null
                      ? item['schedule']['name']
                      : 'Shift Reguler';

                  return _buildHistoryCard(
                    date: item['date'] ?? 'Tanggal Tidak Diketahui',
                    shift: shiftName,
                    location: item['location']['name'] ?? 'Lokasi',
                    timeIn: item['time_in']?.substring(0, 5) ?? '--:--',
                    timeOut: item['time_out']?.substring(0, 5) ?? '--:--',
                    isComplete: isComplete,
                    status: item['status'] ?? 'Hadir',
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // ==============================
  // WIDGET CARD (ANTI OVERFLOW & LEBIH DETAIL)
  // ==============================
  Widget _buildHistoryCard({
    required String date,
    required String shift,
    required String location,
    required String timeIn,
    required String timeOut,
    required bool isComplete,
    required String status,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF94A3B8).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ICON INDIKATOR
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isComplete
                        ? const Color(0xFF10B981).withValues(alpha: 0.1)
                        : const Color(0xFFF59E0B).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: FaIcon(
                    isComplete
                        ? FontAwesomeIcons.checkDouble
                        : FontAwesomeIcons.clockRotateLeft,
                    color: isComplete
                        ? const Color(0xFF10B981)
                        : const Color(0xFFF59E0B),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 16),

                // INFO DETAIL (SHIFT, TANGGAL, LOKASI)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shift,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        date,
                        style: const TextStyle(
                          color: Color(0xFF3B82F6),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Teks Anti Overflow
                      Text(
                        '$location • $status',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // JAM IN / OUT
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  const Text(
                    'IN: ',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                  ),
                  Text(
                    timeIn,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF10B981),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Text(
                    'OUT: ',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                  ),
                  Text(
                    timeOut,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: isComplete
                          ? const Color(0xFF3B82F6)
                          : const Color(0xFF94A3B8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
