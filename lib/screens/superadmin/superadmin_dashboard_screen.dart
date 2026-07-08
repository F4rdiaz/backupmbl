import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../controllers/auth_controller.dart';

class SuperadminDashboardScreen extends StatelessWidget {
  SuperadminDashboardScreen({super.key});

  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Superadmin Dashboard',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          authController.userName.value.isEmpty
                              ? 'Selamat datang, Superadmin'
                              : 'Selamat datang, ${authController.userName.value}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => authController.logout(),
                    icon: const FaIcon(
                      FontAwesomeIcons.arrowRightFromBracket,
                      color: Color(0xFFEF4444),
                    ),
                    tooltip: 'Keluar',
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Info banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFF3B82F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.crown,
                      color: Colors.white,
                      size: 28,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Kamu login sebagai Superadmin. Akses penuh CRUD data master sedang disiapkan.',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              const Text(
                'Manajemen Data',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildMenuCard(
                      'Data User',
                      FontAwesomeIcons.users,
                      const Color(0xFF0EA5E9),
                    ),
                    _buildMenuCard(
                      'Titik Lokasi',
                      FontAwesomeIcons.buildingUser,
                      const Color(0xFF10B981),
                    ),
                    _buildMenuCard(
                      'Jadwal Kerja',
                      FontAwesomeIcons.calendarDays,
                      const Color(0xFFF59E0B),
                    ),
                    _buildMenuCard(
                      'Penugasan',
                      FontAwesomeIcons.userGroup,
                      const Color(0xFF8B5CF6),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(String title, FaIconData icon, Color color) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () {
          Get.snackbar(
            'Segera Hadir',
            'Fitur "$title" sedang dalam pengembangan.',
            backgroundColor: Colors.blue,
            colorText: Colors.white,
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(child: FaIcon(icon, color: color, size: 20)),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Color(0xFF334155),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
