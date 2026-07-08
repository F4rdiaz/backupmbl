import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio_client;
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:typed_data';
import '../config/api_config.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geo_attend/controllers/dashboard_controller.dart';

class AttendanceController extends GetxController {
  final String apiUrl = ApiConfig.baseUrl;
  final dio_client.Dio dio = dio_client.Dio();
  final storage = const FlutterSecureStorage();
  final ImagePicker _picker = ImagePicker();

  var isClockingIn = false.obs;
  var isClockingOut = false.obs;

  Future<Position?> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    print("=== SEDANG CEK GPS ===");
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("=== GPS TERNYATA MATI ===");
      Get.snackbar(
        'GPS Nonaktif',
        'Harap nyalakan GPS / Lokasi di HP/Browser Anda.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return null;
    }

    print("=== GPS AKTIF, CEK IZIN ===");
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar(
          'Akses Ditolak',
          'Aplikasi butuh izin lokasi untuk absen.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar(
        'Akses Diblokir',
        'Izin lokasi diblokir permanen. Ubah di Pengaturan.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return null;
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // ---> CEK APAKAH LOKASI TERDETEKSI PALSU (FAKE GPS / MOCK LOCATION) <---
  // Catatan: isMocked hanya reliable di Android.
  // Di iOS & web selalu false
  // (Apple tidak menyediakan API resmi untuk deteksi ini), jadi validasi
  // kecepatan gerak di backend jadi lapisan pertahanan tambahan untuk iOS.
  bool _isFakeLocation(Position position) {
    return position.isMocked;
  }

  // --- FUNGSI ABSEN MASUK ---
  Future<void> clockIn(
    String assignmentId,
    double targetLat,
    double targetLng,
    double allowedRadius,
  ) async {
    if (assignmentId.isEmpty) {
      Get.snackbar(
        'Peringatan',
        'Pilih shift / lokasi kerja terlebih dahulu!',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isClockingIn.value = true;
      Position? position = await _determinePosition();
      if (position == null) return;

      // ---> BLOKIR JIKA TERDETEKSI FAKE GPS <---
      if (_isFakeLocation(position)) {
        Get.snackbar(
          'Lokasi Palsu Terdeteksi ⛔',
          'Aplikasi mendeteksi Anda menggunakan lokasi palsu (Fake GPS). Nonaktifkan aplikasi tersebut untuk melanjutkan absen.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          duration: const Duration(seconds: 6),
        );
        return;
      }

      // NOTE (TESTING): threshold dilonggarkan jadi 500m karena GPS
      // browser/laptop kurang presisi dibanding GPS chip di HP asli.
      // Kembalikan ke 60.0 lagi sebelum deploy / build APK final.
      if (position.accuracy > 500.0) {
        Get.snackbar(
          'Sinyal GPS Lemah',
          'Akurasi GPS Anda rendah (${position.accuracy.toStringAsFixed(0)}m). Pindah ke area terbuka.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      double distanceInMeters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        targetLat,
        targetLng,
      );
      if (distanceInMeters > allowedRadius) {
        Get.snackbar(
          'Di Luar Jangkauan ❌',
          'Anda berada ${distanceInMeters.toStringAsFixed(0)} meter dari lokasi. Maksimal radius: ${allowedRadius.toStringAsFixed(0)} meter.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
        return;
      }

      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 50,
      );
      if (photo == null) {
        Get.snackbar(
          'Dibatalkan',
          'Anda harus mengambil foto untuk absen.',
          backgroundColor: Colors.grey,
          colorText: Colors.white,
        );
        return;
      }

      dio_client.MultipartFile photoFile;
      if (kIsWeb) {
        Uint8List photoBytes = await photo.readAsBytes();
        photoFile = dio_client.MultipartFile.fromBytes(
          photoBytes,
          filename: 'clock_in_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      } else {
        photoFile = await dio_client.MultipartFile.fromFile(
          photo.path,
          filename: 'clock_in_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      }

      String? token = await storage.read(key: 'auth_token');

      // PERBAIKAN: Menggunakan 1 atau 0 agar sesuai dengan validasi boolean Laravel
      dio_client.FormData formData = dio_client.FormData.fromMap({
        'assignment_id': assignmentId,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'is_mocked': position.isMocked ? 1 : 0,
        'photo_in': photoFile,
      });

      final response = await dio.post(
        '$apiUrl/clock-in',
        data: formData,
        options: dio_client.Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.data['success'] == true) {
        // ---> INSTANT LOCK UI Sesaat Setelah API Bales Sukses <---
        Get.find<DashboardController>().hasActiveShift.value = true;
        Get.find<DashboardController>().fetchDashboardData();

        Get.snackbar(
          'Absen Berhasil! ✅',
          response.data['message'],
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
    } on dio_client.DioException catch (e) {
      String errorMsg = 'Gagal melakukan absensi.';
      if (e.response != null && e.response?.data != null) {
        errorMsg = e.response?.data['message'] ?? errorMsg;
      }
      Get.snackbar(
        'Absen Ditolak ❌',
        errorMsg,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      print("============= ERROR ASLI: =============");
      print(e.toString());
      Get.snackbar(
        'Gagal Memuat Data',
        'Terjadi kesalahan sistem saat mengambil data',
      );
    } finally {
      isClockingIn.value = false;
    }
  }

  // --- FUNGSI ABSEN PULANG ---
  Future<void> clockOut(
    String assignmentId,
    double targetLat,
    double targetLng,
    double allowedRadius,
  ) async {
    if (assignmentId.isEmpty) {
      Get.snackbar(
        'Peringatan',
        'Pilih shift / lokasi kerja terlebih dahulu!',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isClockingOut.value = true;
      Position? position = await _determinePosition();
      if (position == null) return;

      // ---> BLOKIR JIKA TERDETEKSI FAKE GPS <---
      if (_isFakeLocation(position)) {
        Get.snackbar(
          'Lokasi Palsu Terdeteksi ⛔',
          'Aplikasi mendeteksi Anda menggunakan lokasi palsu (Fake GPS). Nonaktifkan aplikasi tersebut untuk melanjutkan absen.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          duration: const Duration(seconds: 6),
        );
        return;
      }

      // NOTE (TESTING): threshold dilonggarkan jadi 2000m karena GPS
      // browser/laptop kurang presisi dibanding GPS chip di HP asli.
      // Kembalikan ke 60.0 lagi sebelum deploy / build APK final.
      if (position.accuracy > 2000.0) {
        Get.snackbar(
          'Sinyal GPS Lemah',
          'Akurasi GPS Anda rendah (${position.accuracy.toStringAsFixed(0)}m). Silakan pindah ke area terbuka.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      double distanceInMeters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        targetLat,
        targetLng,
      );
      if (distanceInMeters > allowedRadius) {
        Get.snackbar(
          'Di Luar Jangkauan ❌',
          'Anda berada ${distanceInMeters.toStringAsFixed(0)} meter dari lokasi. Maksimal radius: ${allowedRadius.toStringAsFixed(0)} meter.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
        return;
      }

      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 50,
      );
      if (photo == null) {
        Get.snackbar(
          'Dibatalkan',
          'Anda harus mengambil foto untuk absen pulang.',
          backgroundColor: Colors.grey,
          colorText: Colors.white,
        );
        return;
      }

      dio_client.MultipartFile photoFile;
      if (kIsWeb) {
        Uint8List photoBytes = await photo.readAsBytes();
        photoFile = dio_client.MultipartFile.fromBytes(
          photoBytes,
          filename: 'clock_out_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      } else {
        photoFile = await dio_client.MultipartFile.fromFile(
          photo.path,
          filename: 'clock_out_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      }

      String? token = await storage.read(key: 'auth_token');

      // PERBAIKAN: Menggunakan 1 atau 0 agar sesuai dengan validasi boolean Laravel
      dio_client.FormData formData = dio_client.FormData.fromMap({
        'assignment_id': assignmentId,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'is_mocked': position.isMocked ? 1 : 0,
        'photo_out': photoFile,
      });

      final response = await dio.post(
        '$apiUrl/clock-out',
        data: formData,
        options: dio_client.Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.data['success'] == true) {
        // ---> INSTANT UNLOCK UI <---
        Get.find<DashboardController>().hasActiveShift.value = false;
        Get.find<DashboardController>().fetchDashboardData();

        Get.snackbar(
          'Absen Pulang Berhasil! 🏠',
          response.data['message'],
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
    } on dio_client.DioException catch (e) {
      String errorMsg = 'Gagal melakukan absen pulang.';
      if (e.response != null && e.response?.data != null) {
        errorMsg = e.response?.data['message'] ?? errorMsg;
      }
      Get.snackbar(
        'Ditolak ❌',
        errorMsg,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan sistem perangkat.');
    } finally {
      isClockingOut.value = false;
    }
  }
}
