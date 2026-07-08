import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio_client;
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_storage/get_storage.dart'; // Tambahkan ini
import 'package:geo_attend/controllers/dashboard_controller.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../config/api_config.dart';

class ProfileController extends GetxController {
  final String apiUrl = ApiConfig.baseUrl;
  final dio_client.Dio dio = dio_client.Dio();
  final storage = const FlutterSecureStorage();
  final box = GetStorage(); // Inisialisasi GetStorage
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

    // Mengambil path foto yang tersimpan jika aplikasi dibuka kembali
    selectedImagePath.value = box.read('saved_image_path') ?? '';
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (image != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Sesuaikan Foto Profil',
            toolbarColor: const Color(0xFF0EA5E9),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
        ],
      );

      if (croppedFile != null) {
        selectedImageFile = XFile(croppedFile.path);
        selectedImagePath.value = croppedFile.path;
        print("Path foto tersimpan di: ${selectedImagePath.value}");

        // Simpan path ke storage agar tidak hilang saat restart
        await box.write('saved_image_path', croppedFile.path);

        if (kIsWeb) {
          webImageBytes = await croppedFile.readAsBytes();
        }
      }
    }
  }

  Future<void> updateProfile() async {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Peringatan',
        'Nama tidak boleh kosong',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      String? token = await storage.read(key: 'auth_token');

      dio_client.MultipartFile? photoFile;
      if (selectedImageFile != null) {
        photoFile = await dio_client.MultipartFile.fromFile(
          selectedImageFile!.path,
          filename: 'profile.jpg',
        );
      }

      dio_client.FormData formData = dio_client.FormData.fromMap({
        'name': nameController.text.trim(),
        if (photoFile != null) 'photo': photoFile,
      });

      final response = await dio.post(
        '$apiUrl/update-profile',
        data: formData,
        options: dio_client.Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.data['success'] == true) {
        // Hapus path lokal dari storage setelah sukses upload ke server
        await box.remove('saved_image_path');
        selectedImagePath.value = '';

        dashController.userName.value = nameController.text.trim();
        if (response.data['data'] != null &&
            response.data['data']['photo'] != null) {
          final newPhoto = response.data['data']['photo'].toString();
          dashController.userProfilePic.value = newPhoto;

          // ---> SIMPAN FOTO BARU KE CACHE, biar gak hilang pas logout-login
          await storage.write(key: 'user_photo', value: newPhoto);
        }

        Get.back();
        Get.snackbar(
          'Sukses ✅',
          'Profil berhasil diperbarui!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } on dio_client.DioException catch (e) {
      Get.snackbar(
        'Error',
        e.response?.data['message'] ?? 'Gagal memperbarui profil',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
