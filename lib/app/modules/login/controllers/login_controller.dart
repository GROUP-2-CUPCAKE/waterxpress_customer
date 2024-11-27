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
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    if (password.isEmpty) {
      Get.snackbar(
        'Error',
        'Password tidak boleh kosong.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(12),
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
          'Success',
          'Anda berhasil masuk',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(12),
        );
        Get.offAllNamed(Routes.HOME);
      } else {
        Get.snackbar(
          'Error',
          'Silahkan verifikasi email Anda!',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(12),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase exceptions
      if (e.code == 'user-not-found') {
        Get.snackbar(
          'Error',
          'Email tidak ditemukan di Firebase',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(12),
        );
      } else if (e.code == 'wrong-password') {
        Get.snackbar(
          'Error',
          'Kata sandi salah. Silahkan coba lagi!',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(12),
        );
      } else if (e.code == 'too-many-requests') {
        Get.snackbar(
          'Error',
          'Terlalu banyak permintaan. Coba lagi nanti!',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(12),
        );
      } else {
        Get.snackbar(
          'Error',
          'Periksa email dan kata sandi. Silakan coba lagi!',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(12),
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
