import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio_client;
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart'; 
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geo_attend/controllers/dashboard_controller.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

class ProfileController extends GetxController {
  final String apiUrl = 'http://192.168.18.16:8000/api'; // Sesuaikan IP
  final dio_client.Dio dio = dio_client.Dio();
  final storage = const FlutterSecureStorage();
  final ImagePicker _picker = ImagePicker();

  var isLoading = false.obs;
  
  var selectedImagePath = ''.obs;
  XFile? selectedImageFile;
  Uint8List? webImageBytes;

  late TextEditingController nameController;
  final DashboardController dashController = Get.find<DashboardController>();

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController(text: dashController.userName.value);
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }

  // ==========================================
  // FUNGSI BUKA GALERI & PANGKAS GAMBAR (CROP)
  // ==========================================
  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    
    if (image != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1), // 1:1 Square
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Sesuaikan Foto Profil',
            toolbarColor: const Color(0xFF0EA5E9),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true, 
          ),
          IOSUiSettings(
            title: 'Sesuaikan Foto Profil',
            aspectRatioLockEnabled: true,
          ),
          WebUiSettings(
            context: Get.context!,
            presentStyle: WebPresentStyle.dialog, 
          ),
        ],
      );

      if (croppedFile != null) {
        selectedImageFile = XFile(croppedFile.path); 
        selectedImagePath.value = croppedFile.path;  
        
        if (kIsWeb) {
          webImageBytes = await croppedFile.readAsBytes();
        }
      }
    }
  }

  Future<void> updateProfile() async {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar('Peringatan', 'Nama tidak boleh kosong', backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      String? token = await storage.read(key: 'auth_token');

      dio_client.MultipartFile? photoFile;
      if (selectedImageFile != null) {
        if (kIsWeb && webImageBytes != null) {
          photoFile = dio_client.MultipartFile.fromBytes(webImageBytes!, filename: 'profile.jpg');
        } else {
          photoFile = await dio_client.MultipartFile.fromFile(selectedImageFile!.path, filename: 'profile.jpg');
        }
      }

      dio_client.FormData formData = dio_client.FormData.fromMap({
        'name': nameController.text.trim(),
        if (photoFile != null) 'photo': photoFile,
      });

      final response = await dio.post(
        '$apiUrl/update-profile', 
        data: formData,
        options: dio_client.Options(headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        }),
      );

      if (response.data['success'] == true) {
        // 1. Update nama di Dashboard
        dashController.userName.value = nameController.text.trim();
        
        // 2. Update URL foto profil di Dashboard secara langsung (Real-time)
        if (response.data['data'] != null && response.data['data']['photo'] != null) {
          dashController.userProfilePic.value = response.data['data']['photo'];
        }

        Get.back(); 
        Get.snackbar('Sukses ✅', 'Profil berhasil diperbarui!', backgroundColor: Colors.green, colorText: Colors.white);
      }
    } on dio_client.DioException catch (e) {
      String errorMsg = e.response?.data['message'] ?? 'Gagal memperbarui profil.';
      Get.snackbar('Error Server ❌', errorMsg, backgroundColor: Colors.redAccent, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan pada sistem.', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}