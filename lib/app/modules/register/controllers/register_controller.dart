import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterController extends GetxController {
  TextEditingController usernameController = TextEditingController();
  TextEditingController nohpController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  var obscureText = true.obs;
  var obscureText2 = true.obs;

  final String defaultProfileImageUrl = 'https://firebasestorage.googleapis.com/v0/b/katalog-makanan-45b5c.appspot.com/o/Produk%2Fdata%2Fuser%2F0%2Fcom.example.waterxpress_admin%2Fcache%2F06a4c880-f4b3-40fa-93f6-8d2c4a9228ac%2F1000302020.jpg?alt=media&token=4ae0e9f1-3259-4aae-9113-60bd0fa28139';

  void togglePasswordView() {
    obscureText.value = !obscureText.value;
  }

  void togglePasswordView2() {
    obscureText2.value = !obscureText2.value;
  }

  void register(String username, String nohp, String email, String password,
      String confirmPassword) async {
    //  Validasi apakah semua field diisi
    if (username.isEmpty &&
        nohp.isEmpty &&
        email.isEmpty &&
        password.isEmpty &&
        confirmPassword.isEmpty) {
      Get.snackbar(
        'Error',
        'Kolom tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(12),
      );
      return;
    } else if (username.isEmpty) {
      Get.snackbar(
        'Error',
        'Silahkan masukkan nama pengguna',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(12),
      );
      return;
    } else if (nohp.isEmpty) {
      Get.snackbar(
        'Error',
        'Silahkan masukkan nomor handphone',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(12),
      );
      return;
    } else if (email.isEmpty) {
      Get.snackbar(
        'Error',
        'Silahkan masukkan email',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(12),
      );
      return;
    } else if (password.isEmpty) {
      Get.snackbar(
        'Error',
        'Silahkan masukkan password',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(12),
      );
      return;
    } else if (confirmPassword.isEmpty) {
      Get.snackbar(
        'Error',
        'Silahkan masukkan konfirmari ulang password',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    // Validasi apakah password dan confirm password sesuai
    if (password != confirmPassword) {
      Get.snackbar(
        'Error',
        'Kata sandi tidak cocok',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);

      String uid = userCredential.user!.uid;
      //simpan username ke firestore
      await firestore.collection('customer').doc(uid).set({
        'username': username,
        'nohp': nohp,
        'email': email,
        'uid': uid,
        'profileImageUrl': defaultProfileImageUrl,
      });

      await userCredential.user!.sendEmailVerification();
      Get.snackbar(
        'Success',
        'Pendaftaran berhasil! Harap verifikasi email Anda!',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(12),
      );
      Get.offAllNamed(Routes.LOGIN);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        Get.snackbar(
          'Error',
          'Kata sandi yang diberikan terlalu lemah.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
          margin: const EdgeInsets.all(12),
        );
      } else if (e.code == 'email-already-in-use') {
        Get.snackbar(
          'Error',
          'Akun Email sudah terdaftar. Silahkan coba lagi!',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
          margin: const EdgeInsets.all(12),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    nohpController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
