import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geo_attend/controllers/profile_controller.dart';
import '../../controllers/auth_controller.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'widgets/change_password_dialog.dart';
import 'notification_settings_screen.dart';
import '../help/help_center_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  final ProfileController controller = Get.put(ProfileController());
  final AuthController authController = Get.find<AuthController>();

  late final AnimationController _animController;
  late final Animation<double> _fadeHeader;
  late final Animation<Offset> _slideHeader;
  late final Animation<double> _fadeCard1;
  late final Animation<Offset> _slideCard1;
  late final Animation<double> _fadeCard2;
  late final Animation<Offset> _slideCard2;
  late final Animation<double> _fadeButtons;

  static const primaryColor = Color(0xFF0284C7);
  static const primaryDark = Color(0xFF0C4A6E);
  static const bgColor = Color(0xFFF4F8FB);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeHeader = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );
    _slideHeader =
        Tween<Offset>(begin: const Offset(0, -0.15), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animController,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
          ),
        );

    _fadeCard1 = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.25, 0.7, curve: Curves.easeOut),
    );
    _slideCard1 = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animController,
            curve: const Interval(0.25, 0.7, curve: Curves.easeOutCubic),
          ),
        );

    _fadeCard2 = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.4, 0.85, curve: Curves.easeOut),
    );
    _slideCard2 = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animController,
            curve: const Interval(0.4, 0.85, curve: Curves.easeOutCubic),
          ),
        );

    _fadeButtons = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ==========================================
  // DIALOG UBAH NAMA (dipicu dari ikon pensil di foto profil)
  // ==========================================
  void _editName(BuildContext context) {
    final tempController = TextEditingController(
      text: controller.nameController.text,
    );
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Ubah Nama'),
        content: TextField(
          controller: tempController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nama',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          Obx(
            () => ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              onPressed: controller.isLoading.value
                  ? null
                  : () async {
                      final newName = tempController.text.trim();
                      if (newName.isEmpty) return;
                      final oldName = controller.nameController.text;
                      controller.nameController.text = newName;

                      final success = await controller.updateProfile();

                      if (!success) {
                        // gagal simpan ke server -> kembalikan nama lama,
                        // dialog tetap terbuka biar user bisa coba lagi
                        controller.nameController.text = oldName;
                        return;
                      }

                      // Paksa layar Profil redraw sendiri sekarang juga,
                      // biar nama baru langsung kelihatan tanpa perlu
                      // keluar-masuk halaman dulu.
                      if (mounted) {
                        setState(() {});
                      }

                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                      }
                    },
              child: controller.isLoading.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Simpan'),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // MAPPING LABEL TAMPILAN UNTUK ROLE
  // ------------------------------------------------------------
  // Ini cuma ngubah TAMPILAN-nya aja di layar Profil. Nilai asli
  // dari backend (dipakai buat ngatur hak akses) tetap sama persis,
  // ga diubah sama sekali. Kalau nanti ada role lain selain 'User'
  // yang perlu label khusus, tinggal tambahin case di bawah ini.
  // ==========================================
  String _displayRole(String rawRole) {
    switch (rawRole.trim().toLowerCase()) {
      case 'user':
        return 'Karyawan';
      default:
        return rawRole.isNotEmpty ? rawRole : '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          // ==========================================
          // HEADER GRADIENT + FOTO PROFIL
          // ==========================================
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeHeader,
              child: SlideTransition(
                position: _slideHeader,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 56, bottom: 36),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [primaryColor, primaryDark],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(36),
                      bottomRight: Radius.circular(36),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Profil Saya',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 19,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 26),

                      // FOTO PROFIL — pilih foto langsung tersimpan otomatis
                      GestureDetector(
                        onTap: () async {
                          await controller.pickImage();
                          if (controller.selectedImagePath.value.isNotEmpty) {
                            await controller.updateProfile();
                          }
                        },
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.9, end: 1.0),
                          duration: const Duration(milliseconds: 700),
                          curve: Curves.easeOutBack,
                          builder: (context, scale, child) {
                            return Transform.scale(scale: scale, child: child);
                          },
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Obx(() {
                                return Container(
                                  width: 112,
                                  height: 112,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(alpha: 0.15),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.18,
                                        ),
                                        blurRadius: 14,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child:
                                        controller
                                            .selectedImagePath
                                            .value
                                            .isNotEmpty
                                        ? (kIsWeb
                                              ? Image.memory(
                                                  controller.webImageBytes!,
                                                  fit: BoxFit.cover,
                                                )
                                              : Image.file(
                                                  File(
                                                    controller
                                                        .selectedImagePath
                                                        .value,
                                                  ),
                                                  fit: BoxFit.cover,
                                                ))
                                        : controller
                                              .dashController
                                              .userProfilePic
                                              .value
                                              .isNotEmpty
                                        ? Image.network(
                                            controller
                                                .dashController
                                                .userProfilePic
                                                .value,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Center(
                                                      child: FaIcon(
                                                        FontAwesomeIcons
                                                            .userAstronaut,
                                                        size: 42,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                          )
                                        : const Center(
                                            child: FaIcon(
                                              FontAwesomeIcons.userAstronaut,
                                              size: 42,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                );
                              }),
                              Obx(
                                () => Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: primaryColor,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: controller.isLoading.value
                                      ? const SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: CircularProgressIndicator(
                                            color: primaryColor,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const FaIcon(
                                          FontAwesomeIcons.camera,
                                          color: primaryColor,
                                          size: 14,
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // NAMA & EMAIL DI HEADER
                      Obx(() {
                        final typedName = controller.nameController.text;
                        final storedName =
                            controller.dashController.userName.value;
                        final displayName = typedName.isNotEmpty
                            ? typedName
                            : (storedName.isNotEmpty ? storedName : 'Pengguna');
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                displayName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => _editName(context),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const FaIcon(
                                  FontAwesomeIcons.pen,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                      const SizedBox(height: 4),
                      Obx(
                        () => Text(
                          controller.dashController.userEmail.value,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ==========================================
          // KONTEN CARD
          // ==========================================
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 26, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ---------- INFORMASI AKUN ----------
                FadeTransition(
                  opacity: _fadeCard1,
                  child: SlideTransition(
                    position: _slideCard1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informasi Akun',
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
                                color: primaryDark.withValues(alpha: 0.06),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // NAMA (read-only, diedit lewat ikon pensil di foto profil)
                              Obx(() {
                                final typedName =
                                    controller.nameController.text;
                                final storedName =
                                    controller.dashController.userName.value;
                                final displayName = typedName.isNotEmpty
                                    ? typedName
                                    : (storedName.isNotEmpty
                                          ? storedName
                                          : 'Pengguna');
                                return _infoRow(
                                  icon: FontAwesomeIcons.solidIdBadge,
                                  iconColor: primaryColor,
                                  label: 'Nama',
                                  value: displayName,
                                );
                              }),
                              const Divider(
                                height: 1,
                                indent: 62,
                                color: Color(0xFFF1F5F9),
                              ),

                              // EMAIL (read-only)
                              Obx(
                                () => _infoRow(
                                  icon: FontAwesomeIcons.solidEnvelope,
                                  iconColor: primaryColor,
                                  label: 'Email',
                                  value:
                                      controller.dashController.userEmail.value,
                                ),
                              ),
                              const Divider(
                                height: 1,
                                indent: 62,
                                color: Color(0xFFF1F5F9),
                              ),

                              // JABATAN (read-only, label ramah dari role backend)
                              Obx(
                                () => _infoRow(
                                  icon: FontAwesomeIcons.briefcase,
                                  iconColor: primaryColor,
                                  label: 'Jabatan',
                                  value: _displayRole(
                                    controller.dashController.userRole.value,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ---------- PENGATURAN ----------
                FadeTransition(
                  opacity: _fadeCard2,
                  child: SlideTransition(
                    position: _slideCard2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pengaturan',
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
                                color: primaryDark.withValues(alpha: 0.06),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _settingTile(
                                icon: FontAwesomeIcons.lock,
                                iconColor: const Color(0xFF0EA5E9),
                                title: 'Ubah Password',
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) =>
                                        const ChangePasswordDialog(),
                                  );
                                },
                              ),
                              const Divider(
                                height: 1,
                                indent: 62,
                                color: Color(0xFFF1F5F9),
                              ),
                              _settingTile(
                                icon: FontAwesomeIcons.solidBell,
                                iconColor: const Color(0xFF0369A1),
                                title: 'Notifikasi',
                                onTap: () {
                                  Get.to(() => NotificationSettingsScreen());
                                },
                              ),
                              const Divider(
                                height: 1,
                                indent: 62,
                                color: Color(0xFFF1F5F9),
                              ),
                              _settingTile(
                                icon: FontAwesomeIcons.circleQuestion,
                                iconColor: const Color(0xFF0284C7),
                                title: 'Bantuan',
                                onTap: () {
                                  Get.to(() => const HelpCenterScreen());
                                },
                                isLast: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // ==========================================
                // TOMBOL KELUAR — foto & nama sudah tersimpan otomatis,
                // jadi tidak perlu tombol "Simpan Perubahan" lagi
                // ==========================================
                FadeTransition(
                  opacity: _fadeButtons,
                  child: Column(
                    children: [
                      TextButton.icon(
                        onPressed: () => authController.logout(),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFDC2626),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(
                              color: Color(0xFFFCA5A5),
                              width: 1,
                            ),
                          ),
                        ),
                        icon: const FaIcon(
                          FontAwesomeIcons.arrowRightFromBracket,
                          size: 13,
                        ),
                        label: const Text(
                          'Keluar',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 60),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // WIDGET HELPER
  // ==========================================
  Widget _iconBadge(FaIconData icon, Color color) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(child: FaIcon(icon, size: 15, color: color)),
    );
  }

  Widget _infoRow({
    required FaIconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          _iconBadge(icon, iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isNotEmpty ? value : '-',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingTile({
    required FaIconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        bottom: isLast ? const Radius.circular(22) : Radius.zero,
        top: !isLast ? const Radius.circular(22) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            _iconBadge(icon, iconColor),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            const FaIcon(
              FontAwesomeIcons.chevronRight,
              size: 12,
              color: Color(0xFFCBD5E1),
            ),
          ],
        ),
      ),
    );
  }
}
