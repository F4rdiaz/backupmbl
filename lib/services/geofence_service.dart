import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'geofence_task_handler.dart';

class GeofenceService {
  static bool _initialized = false;

  // ==========================================================
  // 1. MINTA IZIN LOKASI "SELALU IZINKAN" (background)
  // ==========================================================
  // Di Android 10+, izin lokasi background HARUS diminta terpisah
  // setelah izin lokasi biasa (while-in-use) diberikan. Kalau user
  // pilih "Hanya saat menggunakan aplikasi", geofence gak akan jalan
  // pas app di-minimize — ini keterbatasan sistem Android, bukan bug.
  static Future<bool> requestPermissions() async {
    // Pastikan GPS aktif
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return false;
    }

    // Izin lokasi dasar dulu
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;

    // Baru minta izin "Allow all the time" via permission_handler
    final status = await Permission.locationAlways.request();
    if (!status.isGranted) return false;

    // Izin notifikasi (wajib di Android 13+)
    await Permission.notification.request();

    return true;
  }

  // ==========================================================
  // 2. INISIALISASI SERVICE (panggil sekali, misal di main.dart)
  // ==========================================================
  static void init() {
    if (_initialized) return;
    _initialized = true;

    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'geofence_service_channel',
        channelName: 'Pemantauan Lokasi Kerja',
        channelDescription:
            'Aktif selama app memantau apakah kamu sudah dekat lokasi kerja.',
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(30000), // tiap 30 detik
        autoRunOnBoot: false,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  // ==========================================================
  // 3. MULAI PANTAU LOKASI, KIRIM DAFTAR ASSIGNMENT HARI INI
  // ==========================================================
  // assignments format: [{id, name, latitude, longitude, radius}, ...]
  static Future<void> start(List<Map<String, dynamic>> assignments) async {
    if (assignments.isEmpty) return;

    final hasPermission = await requestPermissions();
    if (!hasPermission) return;

    init();

    final isRunning = await FlutterForegroundTask.isRunningService;
    if (isRunning) {
      // Kalau service udah jalan, cukup update data assignment-nya aja
      FlutterForegroundTask.sendDataToTask({
        'assignments': assignments,
        'resetNotified': false,
      });
      return;
    }

    await FlutterForegroundTask.startService(
      notificationTitle: 'GeoAttend Aktif',
      notificationText: 'Memantau lokasi kerja kamu...',
      callback: startGeofenceCallback,
    );

    // Kirim data assignment begitu service jalan
    FlutterForegroundTask.sendDataToTask({
      'assignments': assignments,
      'resetNotified': true,
    });
  }

  // ==========================================================
  // 4. HENTIKAN PEMANTAUAN (panggil pas logout / semua shift kelar)
  // ==========================================================
  static Future<void> stop() async {
    final isRunning = await FlutterForegroundTask.isRunningService;
    if (isRunning) {
      await FlutterForegroundTask.stopService();
    }
  }
}
