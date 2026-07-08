import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import '../config/api_config.dart';

class HistoryController extends GetxController {
  final String apiUrl = ApiConfig.baseUrl;
  final Dio dio = Dio();
  final storage = const FlutterSecureStorage();

  var isLoading = true.obs;
  var historyList = <dynamic>[].obs; // Data mentah dari server

  // ==========================================
  // STATE UNTUK FILTER
  // ==========================================
  var selectedFilter = '7 Hari Terakhir'.obs;
  var customDate = Rxn<DateTime>(); // Nyimpen tanggal kalau pilih manual
  final List<String> filterOptions = [
    'Hari Ini',
    '7 Hari Terakhir',
    'Semua Data',
    'Pilih Tanggal...',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    try {
      isLoading.value = true;
      String? token = await storage.read(key: 'auth_token');

      final response = await dio.get(
        '$apiUrl/attendance/history', // Pastikan endpoint ini benar di Laravel lu
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.data['success'] == true) {
        historyList.value = response.data['data'];
      }
    } catch (e) {
      print("============= ERROR ASLI: =============");
      print(e.toString());

      // Kode bawaan Anda
      Get.snackbar('Gagal Login', 'Terjadi kesalahan sistem');
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================================
  // GETTER PINTAR UNTUK MENGELUARKAN DATA YG SUDAH DIFILTER
  // ==========================================
  List<dynamic> get filteredHistory {
    if (historyList.isEmpty) return [];

    DateTime now = DateTime.now();

    return historyList.where((item) {
      // Asumsi format API lu YYYY-MM-DD
      DateTime itemDate;
      try {
        itemDate = DateTime.parse(item['date']);
      } catch (e) {
        return true; // Kalau format aneh, lolosin aja
      }

      if (selectedFilter.value == 'Hari Ini') {
        return itemDate.year == now.year &&
            itemDate.month == now.month &&
            itemDate.day == now.day;
      } else if (selectedFilter.value == '7 Hari Terakhir') {
        DateTime sevenDaysAgo = now.subtract(const Duration(days: 7));
        return itemDate.isAfter(sevenDaysAgo) ||
            itemDate.isAtSameMomentAs(sevenDaysAgo);
      } else if (selectedFilter.value == 'Pilih Tanggal...' &&
          customDate.value != null) {
        return itemDate.year == customDate.value!.year &&
            itemDate.month == customDate.value!.month &&
            itemDate.day == customDate.value!.day;
      }

      return true; // Untuk opsi 'Semua Data'
    }).toList();
  }

  // ==========================================
  // FUNGSI MEMILIH TANGGAL MANUAL DARI KALENDER
  // ==========================================
  void pickCustomDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: customDate.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF0EA5E9)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      customDate.value = picked;
      selectedFilter.value = 'Pilih Tanggal...';
    } else {
      // Kalau user batal milih, kembalikan ke filter awal
      if (customDate.value == null) selectedFilter.value = '7 Hari Terakhir';
    }
  }
}
