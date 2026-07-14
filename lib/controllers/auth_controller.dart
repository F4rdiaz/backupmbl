import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../screens/main_nav_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/auth/login_screen.dart';
import '../config/api_config.dart';
import '../services/geofence_service.dart';

class AuthController extends GetxController {
  // PENTING: Ganti dengan IP Address WiFi lokal Anda
  final String apiUrl = ApiConfig.baseUrl;
  final Dio dio = Dio();
  final storage = const FlutterSecureStorage();

  // Variabel reaktif
  var isLoading = false.obs;
  var userRole = ''.obs; // 'karyawan' | 'admin'
  var userName = ''.obs;
  var userEmail = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSession(); // biar kalau app dibuka ulang, role kesimpen (auto-login)
  }

  Future<void> _loadSession() async {
    String? role = await storage.read(key: 'user_role');
    String? name = await storage.read(key: 'user_name');
    String? email = await storage.read(key: 'user_email');
    if (role != null) userRole.value = role;
    if (name != null) userName.value = name;
    if (email != null) userEmail.value = email;
  }

  // ==========================================
  // FUNGSI LOGIN
  // ==========================================
  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Oops!',
        'Email dan Password tidak boleh kosong',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true; // Nyalakan loading spinner

      final response = await dio.post(
        '$apiUrl/login',
        data: {'email': email, 'password': password},
        options: Options(headers: {'Accept': 'application/json'}),
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        String token = data['token'];

        // TODO: sesuaikan path field ini dengan response asli Laravel kamu.
        // Kalau strukturnya beda (misal role ada di data['user']['role']),
        // kabarin aku, nanti aku pas-in.
        final user = data['user'] ?? {};
        String role = (user['role'] ?? '').toString().toLowerCase();
        String name = user['name'] ?? '';
        String userEmailValue = user['email'] ?? '';

        // ---> BLOKIR SUPERADMIN DI MOBILE
        // Superadmin cuma dikelola lewat web, bukan mobile app.
        if (role == 'superadmin') {
          isLoading.value = false;
          Get.snackbar(
            'Akses Ditolak',
            'Akun Superadmin hanya bisa login melalui website, bukan aplikasi mobile.',
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 4),
          );
          return;
        }

        final photo = user['photo'];

        // Simpan semua ke brankas HP
        await storage.write(key: 'auth_token', value: token);
        await storage.write(key: 'user_role', value: role);
        await storage.write(key: 'user_name', value: name);
        await storage.write(key: 'user_email', value: userEmailValue);

        if (photo != null && photo.toString().isNotEmpty) {
          await storage.write(key: 'user_photo', value: photo.toString());
        }

        userRole.value = role;
        userName.value = name;
        userEmail.value = userEmailValue;

        Get.snackbar(
          'Berhasil',
          'Selamat datang kembali, $name!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );

        _redirectByRole(role);
      } else {
        // Kasus success:false tapi status HTTP tetap 200
        Get.snackbar(
          'Gagal Login',
          response.data['message'] ?? 'Email atau password salah',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Terjadi kesalahan sistem';
      if (e.response != null && e.response?.data != null) {
        errorMessage =
            e.response?.data['message'] ?? 'Email atau password salah';
      }

      Get.snackbar(
        'Gagal Login',
        errorMessage,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false; // Matikan loading spinner
    }
  }

  // Arahkan ke dashboard sesuai role (mobile cuma admin & karyawan)
  void _redirectByRole(String role) {
    switch (role) {
      case 'admin':
        Get.offAll(() => AdminDashboardScreen());
        break;
      case 'karyawan':
      case 'user':
      default:
        // ---> Diarahkan ke MainNavScreen (wadah 4-tab dengan
        // floating pill navbar), bukan langsung ke DashboardScreen.
        Get.offAll(() => MainNavScreen());
        break;
    }
  }

  // ==========================================
  // FUNGSI LOGOUT
  // ==========================================
  Future<void> logout() async {
    try {
      String? token = await storage.read(key: 'auth_token');
      if (token != null) {
        await dio.post(
          '$apiUrl/logout',
          options: Options(
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          ),
        );
      }
    } catch (e) {
      print("============= ERROR ASLI: =============");
      print(e.toString());

      // Kode bawaan Anda
      Get.snackbar('Gagal Login', 'Terjadi kesalahan sistem');
      // Abaikan jika error dari server (misal: token sudah terlanjur hangus)
    } finally {
      // Bersihkan semua data sesi dari memori HP
      await storage.delete(key: 'auth_token');
      await storage.delete(key: 'user_role');
      await storage.delete(key: 'user_name');
      await storage.delete(key: 'user_email');
      // ---> Hapus cache foto juga, biar gak ketuker kalau user lain
      // login di HP yang sama.
      await storage.delete(key: 'user_photo');

      // ---> Hentikan background geofence, biar gak terus mantau lokasi
      // padahal user udah logout.
      await GeofenceService.stop();

      userRole.value = '';
      userName.value = '';
      userEmail.value = '';

      Get.offAll(() => LoginScreen());
    }
  }
}
