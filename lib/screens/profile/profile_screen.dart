import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geo_attend/controllers/profile_controller.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft, color: Color(0xFF0F172A), size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text('Edit Profil', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            
            GestureDetector(
              onTap: () => controller.pickImage(),
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Obx(() {
                    return Container(
                      width: 120, height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFE2E8F0),
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 5))],
                      ),
                      child: ClipOval(
                        // LOGIKA BARU: Cek urutan ketersediaan foto
                        child: controller.selectedImagePath.value.isNotEmpty
                            // 1. Jika ada foto BARU dari galeri
                            ? (kIsWeb
                                ? Image.memory(controller.webImageBytes!, fit: BoxFit.cover)
                                : Image.file(File(controller.selectedImagePath.value), fit: BoxFit.cover))
                            // 2. Jika tidak ada foto baru, tampilkan foto LAMA dari Dashboard (kalau ada)
                            : controller.dashController.userProfilePic.value.isNotEmpty
                                ? Image.network(
                                    // Catatan: Pastikan ini berupa Full URL (http://...). Jika ini cuma path (cth: /uploads/foto.jpg), tambahkan base URL API kamu di depannya.
                                    controller.dashController.userProfilePic.value,
                                    fit: BoxFit.cover,
                                    // Handle jika gambar gagal dimuat dari server
                                    errorBuilder: (context, error, stackTrace) => const Center(
                                      child: FaIcon(FontAwesomeIcons.userAstronaut, size: 50, color: Color(0xFF94A3B8)),
                                    ),
                                  )
                            // 3. Jika keduanya kosong, tampilkan avatar default
                                : const Center(child: FaIcon(FontAwesomeIcons.userAstronaut, size: 50, color: Color(0xFF94A3B8))),
                      ),
                    );
                  }),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Color(0xFF0EA5E9), shape: BoxShape.circle),
                    child: const FaIcon(FontAwesomeIcons.camera, color: Colors.white, size: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nama Lengkap', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                const SizedBox(height: 8),
                TextField(
                  controller: controller.nameController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Padding(
                      padding: EdgeInsets.all(14.0),
                      child: FaIcon(FontAwesomeIcons.solidIdBadge, size: 20, color: Color(0xFF94A3B8)),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF0EA5E9), width: 2)),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 48),
            
            SizedBox(
              width: double.infinity,
              height: 55,
              child: Obx(() => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0EA5E9),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: controller.isLoading.value ? null : () => controller.updateProfile(),
                child: controller.isLoading.value
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Simpan Perubahan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              )),
            ),
          ],
        ),
      ),
    );
  }
}