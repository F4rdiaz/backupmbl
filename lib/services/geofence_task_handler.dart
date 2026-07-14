import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Callback ini WAJIB top-level function (di luar class), dipanggil
// Android buat nyalain background isolate terpisah dari isolate utama.
@pragma('vm:entry-point')
void startGeofenceCallback() {
  FlutterForegroundTask.setTaskHandler(GeofenceTaskHandler());
}

class GeofenceTaskHandler extends TaskHandler {
  // Daftar lokasi kerja yang dikirim dari isolate utama (lihat
  // geofence_service.dart). Format tiap item:
  // { id, name, latitude, longitude, radius }
  List<Map<String, dynamic>> _assignments = [];

  // Biar notifikasi buat 1 lokasi cuma muncul sekali per hari,
  // gak spam tiap kali cek posisi.
  final Set<String> _notifiedToday = {};

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _notifications.initialize(initSettings);
  }

  // Dipanggil pas isolate utama kirim data lewat
  // FlutterForegroundTask.sendDataToTask(...)
  @override
  void onReceiveData(Object data) {
    if (data is Map && data['assignments'] is List) {
      _assignments = (data['assignments'] as List).cast<Map<String, dynamic>>();
    }
    // Reset daftar "sudah dinotif" kalau ganti hari / assignment baru dikirim
    if (data is Map && data['resetNotified'] == true) {
      _notifiedToday.clear();
    }
  }

  // Dipanggil berkala sesuai interval yang di-set di geofence_service.dart
  @override
  void onRepeatEvent(DateTime timestamp) async {
    if (_assignments.isEmpty) return;

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      for (final loc in _assignments) {
        final id = loc['id'].toString();
        final lat = double.parse(loc['latitude'].toString());
        final lng = double.parse(loc['longitude'].toString());
        final radius = double.parse(loc['radius'].toString());
        final name = loc['name'].toString();

        final distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          lat,
          lng,
        );

        if (distance <= radius && !_notifiedToday.contains(id)) {
          _notifiedToday.add(id);
          await _showNotification(
            'Sudah Sampai Lokasi 📍',
            'Kamu sudah berada di area $name. Yuk absen masuk sekarang!',
          );
        }
      }
    } catch (e) {
      // Diamkan dulu kalau GPS lagi gak stabil, biar dicoba lagi di
      // siklus berikutnya, gak bikin service crash.
    }
  }

  Future<void> _showNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'geofence_alert_channel',
      'Notifikasi Lokasi Kerja',
      channelDescription: 'Muncul saat kamu mendekati lokasi kerja',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {}

  @override
  void onNotificationButtonPressed(String id) {}

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp();
  }
}
