import 'dart:async';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import '../config/api_config.dart';
import '../services/geofence_service.dart';

class DashboardController extends GetxController {
  final String apiUrl = ApiConfig.baseUrl;

  final Dio dio = Dio();
  final storage = const FlutterSecureStorage();

  var isLoading = true.obs;
  var userName = 'Karyawan'.obs;
  var userProfilePic = ''.obs; // ---> VARIABEL FOTO PROFIL

  // ==========================================
  // TAMBAHAN: EMAIL & ROLE untuk halaman Profil
  // ==========================================
  var userEmail = ''.obs;
  var userRole = ''.obs;

  // Menyimpan seluruh list shift dan ID shift yang sedang dipilih
  var assignmentsList = <dynamic>[].obs;
  var selectedAssignmentId = ''.obs;

  var shiftName = 'Memuat...'.obs;
  var shiftTime = '--:-- - --:--'.obs;
  var locationName = 'Memuat lokasi...'.obs;

  var currentTime = ''.obs;
  var currentDate = ''.obs;
  Timer? _timer;

  // ---> Satpam buat ngecek status shift aktif dari server
  var hasActiveShift = false.obs;

  @override
  void onInit() {
    super.onInit();
    _startRealtimeClock();
    _loadCachedPhoto(); // Tampilkan foto dari cache dulu biar gak kosong pas loading
    _loadCachedProfile(); // ---> Tampilkan email & role dari cache dulu
    fetchDashboardData();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void _startRealtimeClock() {
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    currentTime.value = DateFormat('HH:mm:ss').format(now);
    currentDate.value = DateFormat('dd MMM yyyy').format(now);
  }

  // ---> BACA FOTO YANG SUDAH DI-CACHE, biar begitu dashboard dibuka foto
  // langsung ada tanpa nunggu response server, dan gak hilang kalau
  // kebetulan server telat/lupa ngirim field 'photo'.
  Future<void> _loadCachedPhoto() async {
    String? cachedPhoto = await storage.read(key: 'user_photo');
    if (cachedPhoto != null && cachedPhoto.isNotEmpty) {
      userProfilePic.value = cachedPhoto;
    }
  }

  // ---> BACA EMAIL & ROLE DARI CACHE, sama alasannya kayak foto di atas
  Future<void> _loadCachedProfile() async {
    String? cachedEmail = await storage.read(key: 'user_email');
    String? cachedRole = await storage.read(key: 'user_role');
    if (cachedEmail != null && cachedEmail.isNotEmpty) {
      userEmail.value = cachedEmail;
    }
    if (cachedRole != null && cachedRole.isNotEmpty) {
      userRole.value = cachedRole;
    }
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoading.value = true;
      String? token = await storage.read(key: 'auth_token');

      final response = await dio.get(
        '$apiUrl/dashboard',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.data['success'] == true) {
        var data = response.data['data'];
        userName.value = data['user']['name'];

        // ---> ISI FOTO PROFIL DARI SERVER, SEKALIGUS SIMPAN KE CACHE <---
        final photoFromServer = data['user']['photo'];
        if (photoFromServer != null && photoFromServer.toString().isNotEmpty) {
          userProfilePic.value = photoFromServer.toString();
          await storage.write(
            key: 'user_photo',
            value: photoFromServer.toString(),
          );
        }
        // Kalau server gak ngirim foto (null/kosong), userProfilePic tetap
        // pakai nilai dari cache yang sudah dimuat di _loadCachedPhoto(),
        // jadi gak tiba-tiba kosong.

        // ==========================================
        // TAMBAHAN: ISI EMAIL & ROLE DARI SERVER, CACHE JUGA
        // ==========================================
        final emailFromServer = data['user']['email'];
        if (emailFromServer != null && emailFromServer.toString().isNotEmpty) {
          userEmail.value = emailFromServer.toString();
          await storage.write(
            key: 'user_email',
            value: emailFromServer.toString(),
          );
        }

        final roleFromServer = data['user']['role'];
        if (roleFromServer != null && roleFromServer.toString().isNotEmpty) {
          userRole.value = roleFromServer.toString();
          await storage.write(
            key: 'user_role',
            value: roleFromServer.toString(),
          );
        }

        // ---> BACA STATUS ABSENSI HARI INI DARI LARAVEL <---
        var activeAttendance = data['active_attendance'];
        if (activeAttendance != null) {
          hasActiveShift.value = true; // Ada shift yang lagi jalan
        } else {
          hasActiveShift.value = false; // Belum absen masuk hari ini
        }

        List assignments = data['assignments'];

        if (assignments.isNotEmpty) {
          // =======================================================
          // 1. LOGIKA SORTING (Urutkan dari pagi ke malam)
          // =======================================================
          assignments.sort((a, b) {
            String timeA = a['schedule']['time_in'];
            String timeB = b['schedule']['time_in'];
            return timeA.compareTo(timeB);
          });

          assignmentsList.value = assignments;

          // ---> MULAI PANTAU LOKASI di background, biar pas HP kamu
          // masuk radius lokasi kerja, notifikasi otomatis muncul
          // walau app di-minimize.
          final geofenceTargets = assignments.map<Map<String, dynamic>>((a) {
            return {
              'id': '${a['location_id']}_${a['schedule_id']}',
              'name': a['location']['name'],
              'latitude': a['location']['latitude'],
              'longitude': a['location']['longitude'],
              'radius': a['location']['radius'] ?? 100.0,
            };
          }).toList();
          GeofenceService.start(geofenceTargets);

          // =======================================================
          // 2. LOGIKA AUTO-SELECT (Pilih shift terdekat saat ini)
          // =======================================================
          int selectedIndex = 0;
          final now = DateTime.now();
          String currentJam = DateFormat('HH:mm:ss').format(now);

          for (int i = 0; i < assignments.length; i++) {
            String timeOut = assignments[i]['schedule']['time_out'];
            // Jika jam pulang shift ini belum terlewat, jadikan prioritas
            if (currentJam.compareTo(timeOut) < 0) {
              selectedIndex = i;
              break;
            }
          }

          // Pasang shift hasil perhitungan ke UI
          changeShift(assignments[selectedIndex]);
        } else {
          assignmentsList.value = [];
          shiftName.value = 'Libur';
          shiftTime.value = 'Tidak ada jadwal';
          locationName.value = 'Tidak ada penugasan';
          selectedAssignmentId.value = '';

          // Gak ada shift lagi hari ini, gak perlu pantau lokasi terus
          GeofenceService.stop();
        }
      }
    } catch (e) {
      print('=== ERROR DASHBOARD: $e ===');
      Get.snackbar('Error', 'Gagal memuat data dari server');
    } finally {
      isLoading.value = false;
    }
  }

  // FUNGSI: Mengubah data di UI saat Dropdown dipilih
  void changeShift(dynamic assignment) {
    String locId = assignment['location_id'].toString();
    String schId = assignment['schedule_id'].toString();

    // Format ID gabungan untuk dikirim ke API Clock-In (cth: "1_2")
    selectedAssignmentId.value = '${locId}_${schId}';

    shiftName.value = assignment['schedule']['name'];
    String timeIn = assignment['schedule']['time_in'].substring(0, 5);
    String timeOut = assignment['schedule']['time_out'].substring(0, 5);
    shiftTime.value = '$timeIn - $timeOut';
    locationName.value = assignment['location']['name'];
  }
}
