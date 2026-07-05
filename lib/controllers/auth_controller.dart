import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/auth/login_screen.dart'; // Import layar login untuk fungsi logout

class AuthController extends GetxController {
  // PENTING: Ganti dengan IP Address WiFi lokal Anda
  final String apiUrl = 'http://192.168.18.16:8000/api'; 
  
  final Dio dio = Dio();
  final storage = const FlutterSecureStorage();

  // Variabel reaktif untuk mengubah status tombol menjadi loading
  var isLoading = false.obs;

  // ==========================================
  // FUNGSI LOGIN
  // ==========================================
  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Oops!', 'Email dan Password tidak boleh kosong',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
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
        // Simpan token ke brankas HP
        String token = response.data['data']['token'];
        await storage.write(key: 'auth_token', value: token);

        Get.snackbar(
          'Berhasil', 
          'Selamat datang kembali!',
          backgroundColor: Colors.green, 
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );

        // PERBAIKAN: Komentar dihapus dan tanpa keyword 'const'
        Get.offAll(() => DashboardScreen());
      }
    } on DioException catch (e) {
      String errorMessage = 'Terjadi kesalahan sistem';
      if (e.response != null && e.response?.data != null) {
        errorMessage = e.response?.data['message'] ?? 'Email atau password salah';
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

  // ==========================================
  // FUNGSI LOGOUT
  // ==========================================
  Future<void> logout() async {
    try {
      String? token = await storage.read(key: 'auth_token');
      if (token != null) {
        // Beritahu backend Laravel untuk menghapus token
        await dio.post(
          '$apiUrl/logout',
          options: Options(headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          }),
        );
      }
    } catch (e) {
      // Abaikan jika error dari server (misal: token sudah terlanjur hangus)
    } finally {
      // Bersihkan token dari memori HP dan kembalikan ke halaman Login
      await storage.delete(key: 'auth_token');
      Get.offAll(() => LoginScreen());
    }
  }
}