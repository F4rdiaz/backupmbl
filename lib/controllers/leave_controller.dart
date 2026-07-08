import 'package:flutter/material.dart';
import 'package:get/get.dart' hide MultipartFile, FormData;
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'auth_controller.dart';

class LeaveController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final Dio dio = Dio();
  final storage = const FlutterSecureStorage();

  var isLoading = false.obs;
  var isSubmitting = false.obs;
  var leaveList = [].obs;

  // Form state
  var selectedType = 'izin'.obs; // izin | sakit | cuti
  var startDate = Rxn<DateTime>();
  var endDate = Rxn<DateTime>();
  var attachmentFile = Rxn<XFile>(); // ganti dari File -> XFile (aman buat web)
  final reasonController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchLeaves();
  }

  Future<String?> _getToken() async {
    return await storage.read(key: 'auth_token');
  }

  Future<void> fetchLeaves() async {
    try {
      isLoading.value = true;
      String? token = await _getToken();

      final response = await dio.get(
        '${authController.apiUrl}/leaves',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.data['success'] == true) {
        leaveList.value = response.data['data'];
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

  Future<void> submitLeave() async {
    if (startDate.value == null || endDate.value == null) {
      Get.snackbar(
        'Oops!',
        'Tanggal mulai dan selesai wajib diisi',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }
    if (reasonController.text.trim().isEmpty) {
      Get.snackbar(
        'Oops!',
        'Alasan wajib diisi',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isSubmitting.value = true;
      String? token = await _getToken();

      String fmtStart = startDate.value!.toIso8601String().split('T')[0];
      String fmtEnd = endDate.value!.toIso8601String().split('T')[0];

      MultipartFile? multipartAttachment;
      if (attachmentFile.value != null) {
        final bytes = await attachmentFile.value!.readAsBytes();
        multipartAttachment = MultipartFile.fromBytes(
          bytes,
          filename: attachmentFile.value!.name,
        );
      }

      FormData formData = FormData.fromMap({
        'type': selectedType.value,
        'start_date': fmtStart,
        'end_date': fmtEnd,
        'reason': reasonController.text.trim(),
        if (multipartAttachment != null) 'attachment': multipartAttachment,
      });

      final response = await dio.post(
        '${authController.apiUrl}/leaves',
        data: formData,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.data['success'] == true) {
        Get.back(); // tutup form
        Get.snackbar(
          'Berhasil',
          'Pengajuan izin/cuti berhasil dikirim',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        _resetForm();
        fetchLeaves();
      }
    } on DioException catch (e) {
      String msg = 'Gagal mengirim pengajuan';
      if (e.response != null && e.response?.data != null) {
        msg = e.response?.data['message'] ?? msg;
      }
      Get.snackbar(
        'Gagal',
        msg,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> pickAttachment() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      attachmentFile.value = picked;
    }
  }

  void _resetForm() {
    selectedType.value = 'izin';
    startDate.value = null;
    endDate.value = null;
    attachmentFile.value = null;
    reasonController.clear();
  }
}
