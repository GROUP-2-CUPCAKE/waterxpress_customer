import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/app/routes/app_pages.dart';
import 'package:get/get.dart';

class ResetPasswordController extends GetxController {
  TextEditingController emailController = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;

  void resetPassword(String email) async {
    if (email != "" && GetUtils.isEmail(email)) {
      await auth.sendPasswordResetEmail(email: email);
      Get.snackbar(
        'Sukses',
        'Silahkan cek emailmu untuk membuat kata sandi baru!',
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(12),
        backgroundColor: Colors.white,
        colorText: const Color(0xFF0288D1),
      );
      Get.offAllNamed(Routes.LOGIN);
    } else {
      Get.snackbar(
        'Error',
        'Harap masukkan email yang valid!',
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(12),
        backgroundColor: Colors.white,
        colorText: const Color(0xFFFF5252),
      );
    }
  }
}
