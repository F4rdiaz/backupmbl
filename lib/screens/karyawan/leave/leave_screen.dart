import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../../controllers/leave_controller.dart';

class LeaveScreen extends StatelessWidget {
  LeaveScreen({super.key});

  final LeaveController controller = Get.put(LeaveController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        title: const Text(
          'Izin & Cuti',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormBottomSheet(context),
        backgroundColor: const Color(0xFF0EA5E9),
        icon: const FaIcon(
          FontAwesomeIcons.plus,
          size: 16,
          color: Colors.white,
        ),
        label: const Text(
          'Ajukan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF0EA5E9)),
          );
        }

        if (controller.leaveList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(
                  FontAwesomeIcons.envelopeOpenText,
                  size: 48,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'Belum ada pengajuan izin/cuti',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchLeaves,
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: controller.leaveList.length,
            itemBuilder: (context, index) {
              final item = controller.leaveList[index];
              return _buildLeaveCard(item);
            },
          ),
        );
      }),
    );
  }

  Widget _buildLeaveCard(dynamic item) {
    Color statusColor;
    String statusLabel;

    switch (item['status']) {
      case 'approved':
        statusColor = const Color(0xFF10B981);
        statusLabel = 'Disetujui';
        break;
      case 'rejected':
        statusColor = const Color(0xFFEF4444);
        statusLabel = 'Ditolak';
        break;
      default:
        statusColor = const Color(0xFFF59E0B);
        statusLabel = 'Menunggu';
    }

    String typeLabel =
        {'izin': 'Izin', 'sakit': 'Sakit', 'cuti': 'Cuti'}[item['type']] ??
        item['type'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                typeLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: Color(0xFF0F172A),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 11.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${item['start_date']} s/d ${item['end_date']}',
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item['reason'] ?? '-',
            style: const TextStyle(color: Color(0xFF334155), fontSize: 13),
          ),
        ],
      ),
    );
  }

  void _showFormBottomSheet(BuildContext context) {
    Get.bottomSheet(
      _LeaveForm(controller: controller),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    );
  }
}

class _LeaveForm extends StatefulWidget {
  final LeaveController controller;
  const _LeaveForm({required this.controller});

  @override
  State<_LeaveForm> createState() => _LeaveFormState();
}

class _LeaveFormState extends State<_LeaveForm> {
  final DateFormat _fmt = DateFormat('dd MMM yyyy');

  // --- PERBAIKAN 1: Logika Date Picker Dinamis ---
  Future<void> _pickDate(bool isStart) async {
    DateTime initial = DateTime.now();
    DateTime firstD = DateTime.now().subtract(const Duration(days: 30));

    // Kalau user memilih Tanggal Selesai, firstDate dikunci mengikuti Tanggal Mulai
    if (!isStart && widget.controller.startDate.value != null) {
      firstD = widget.controller.startDate.value!;
      if (initial.isBefore(firstD)) {
        initial = firstD;
      }
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstD,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      if (isStart) {
        widget.controller.startDate.value = picked;
        // Auto-reset endDate kalau posisinya ternyata di bawah startDate yang baru dipilih
        if (widget.controller.endDate.value != null &&
            widget.controller.endDate.value!.isBefore(picked)) {
          widget.controller.endDate.value = null;
        }
      } else {
        widget.controller.endDate.value = picked;
      }
    }
  }

  Future<void> _pickAttachment() async {
    await widget.controller.pickAttachment();
  }

  // --- PERBAIKAN 2: Validasi Sebelum Kirim (Custom Submit Handler) ---
  void _handleSubmit() {
    final startDate = widget.controller.startDate.value;
    final endDate = widget.controller.endDate.value;
    final reason = widget.controller.reasonController.text.trim();

    if (startDate == null) {
      Get.snackbar(
        'Validasi',
        'Tanggal mulai wajib dipilih.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (endDate == null) {
      Get.snackbar(
        'Validasi',
        'Tanggal selesai wajib dipilih.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (endDate.isBefore(startDate)) {
      Get.snackbar(
        'Validasi',
        'Tanggal selesai tidak boleh sebelum tanggal mulai.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (reason.isEmpty || reason.length < 5) {
      Get.snackbar(
        'Validasi',
        'Alasan wajib diisi dengan jelas (min. 5 karakter).',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // Jika semua lolos validasi, baru jalankan logic backend dari controller-mu
    widget.controller.submitLeave();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Ajukan Izin & Cuti',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Kategori',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Obx(
              () => Row(
                children: [
                  _typeChip('izin', 'Izin', widget.controller),
                  const SizedBox(width: 8),
                  _typeChip('sakit', 'Sakit', widget.controller),
                  const SizedBox(width: 8),
                  _typeChip('cuti', 'Cuti', widget.controller),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Tanggal Mulai',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Obx(
              () => _dateBox(
                widget.controller.startDate.value == null
                    ? 'Pilih tanggal'
                    : _fmt.format(widget.controller.startDate.value!),
                () => _pickDate(true),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Tanggal Selesai',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Obx(
              () => _dateBox(
                widget.controller.endDate.value == null
                    ? 'Pilih tanggal'
                    : _fmt.format(widget.controller.endDate.value!),
                () => _pickDate(false), // Sudah diamankan di fungsi _pickDate
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Alasan',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: widget.controller.reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Tuliskan alasan pengajuan...',
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Dokumen Pendukung (opsional)',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Obx(
              () => GestureDetector(
                onTap: _pickAttachment,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.paperclip,
                        size: 16,
                        color: Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.controller.attachmentFile.value == null
                              ? 'Pilih file (foto/dokumen)'
                              : widget.controller.attachmentFile.value!.name,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Obx(
              () => SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0EA5E9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  // --- PERBAIKAN 3: Tombol Submit dihubungkan ke _handleSubmit ---
                  onPressed: widget.controller.isSubmitting.value
                      ? null
                      : _handleSubmit,
                  child: widget.controller.isSubmitting.value
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Kirim Pengajuan',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeChip(String value, String label, LeaveController controller) {
    final bool selected = controller.selectedType.value == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.selectedType.value = value,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF0EA5E9) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? const Color(0xFF0EA5E9)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFF64748B),
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _dateBox(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            const FaIcon(
              FontAwesomeIcons.calendarDay,
              size: 15,
              color: Color(0xFF94A3B8),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(fontSize: 13.5, color: Color(0xFF334155)),
            ),
          ],
        ),
      ),
    );
  }
}
