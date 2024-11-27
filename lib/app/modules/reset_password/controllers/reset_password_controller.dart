import 'package:firebase_auth/firebase_auth.dart';
import '/app/routes/app_pages.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class ResetPasswordController extends GetxController {
  TextEditingController emailController = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;

  void resetPassword(String email) async {
    if (email != "" && GetUtils.isEmail(email)) {
      await auth.sendPasswordResetEmail(email: email);
      Get.snackbar(
        'Success',
        'Silahkan cek email Anda untuk membuat kata sandi baru!',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 4),
        margin: EdgeInsets.all(12),
      );
      Get.offAllNamed(Routes.LOGIN);
    } else {
      Get.snackbar(
        'Error',
        'Harap masukkan email yang valid!',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
        margin: EdgeInsets.all(12),
      );
    }
  }
}
