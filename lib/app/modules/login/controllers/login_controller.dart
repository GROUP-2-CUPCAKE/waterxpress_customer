import 'dart:developer';
import '/app/routes/app_pages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;
  var obscureText = true.obs;

  Stream<User?> get streamAuthStatus =>
      FirebaseAuth.instance.authStateChanges();

  bool isUserLoggedIn() => FirebaseAuth.instance.currentUser != null;

  void togglePasswordView() {
    obscureText.value = !obscureText.value;
  }

  void login(String email, [String? password]) async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    // Check if email or password is empty
    if (email.isEmpty) {
      Get.snackbar(
        'Error',
        'Email tidak boleh kosong.',
        margin: const EdgeInsets.all(12),
        backgroundColor: Colors.white,
        colorText: const Color(0xFFFF5252),
      );
      return;
    }

    if (password.isEmpty) {
      Get.snackbar(
        'Error',
        'Password tidak boleh kosong.',
        margin: const EdgeInsets.all(12),
        backgroundColor: Colors.white,
        colorText: const Color(0xFFFF5252),
      );
      return;
    }

    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Check if email is verified
      if (userCredential.user!.emailVerified) {
        Get.snackbar(
          'Sukses',
          'Kamu sudah berhasil masuk',
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(12),
          backgroundColor: Colors.white,
          colorText: const Color(0xFF0288D1),
        );
        Get.offAllNamed(Routes.HOME);
      } else {
        Get.snackbar(
          'Error',
          'Silahkan verifikasi email terlebih dahulu!',
          margin: const EdgeInsets.all(12),
          backgroundColor: Colors.white,
          colorText: const Color(0xFFFF5252),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase exceptions
      if (e.code == 'user-not-found') {
        Get.snackbar(
          'Error',
          'Email tidak ditemukan di Firebase',
          margin: const EdgeInsets.all(12),
          backgroundColor: Colors.white,
          colorText: const Color(0xFFFF5252),
        );
      } else if (e.code == 'wrong-password') {
        Get.snackbar(
          'Error',
          'Kata sandi salah. Silahkan coba lagi!',
          margin: const EdgeInsets.all(12),
          backgroundColor: Colors.white,
          colorText: const Color(0xFFFF5252),
        );
      } else if (e.code == 'too-many-requests') {
        Get.snackbar(
          'Error',
          'Terlalu banyak permintaan. Coba lagi nanti!',
          margin: const EdgeInsets.all(12),
          backgroundColor: Colors.white,
          colorText: const Color(0xFFFF5252),
        );
      } else {
        Get.snackbar(
          'Error',
          'Periksa email dan kata sandi. Silakan coba lagi!',
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(12),
          backgroundColor: Colors.white,
          colorText: const Color(0xFFFF5252),
        );
      }
      log("FirebaseAuthException: ${e.code}");
    } catch (e) {
      log("Error: $e");
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
