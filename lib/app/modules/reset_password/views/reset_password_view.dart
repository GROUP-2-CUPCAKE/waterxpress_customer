import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../login/views/login_view.dart';
import '/app/modules/reset_password/controllers/reset_password_controller.dart';
import '/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResetPasswordView extends GetView<ResetPasswordController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF40C4FF),
              Color(0xFF0288D1),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 350,
                    padding: const EdgeInsets.only(top: 50),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Ganti Kata Sandi',
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Lupa kata sandi?',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: Container(
                            height: 160,
                            width: 160,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(
                                'assets/images/reset.jpeg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 435.h, // Responsif untuk tinggi
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.r),
                        topRight: Radius.circular(30.r),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0288D1),
                          blurRadius: 10.r,
                          offset: Offset(5.w, 8.h),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 18.0),
                          child: Text(
                            'Perbarui kata sandi Anda disini!',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF0277BD),
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  offset: Offset(1.5, 1.5),
                                  color: Colors.black12,
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Field for Email
                        Container(
                          decoration: textFieldDecoration(),
                          child: TextFormField(
                            controller: controller.emailController,
                            decoration: InputDecoration(
                              hintText: "Masukkan Email",
                              hintStyle: const TextStyle(
                                color: Color(0xFF37474F),
                                fontSize: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              fillColor: Colors.transparent,
                              filled: true,
                              prefixIcon: const Icon(
                                Icons.email,
                                color: Color(0xFF0277BD),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF40C4FF),
                                    Color(0xFF0288D1),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: const Text(
                                  'Konfirmasi',
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                // Memanggil fungsi resetPassword tanpa parameter
                                onPressed: () {
                                  String email =
                                      controller.emailController.text.trim();
                                  controller.resetPassword(email);
                                },
                              ),
                            )),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Kembali ke halaman ➔',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF37474F),
                              ),
                            ),
                            TextButton(
                              child: const Text(
                                'Masuk',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF40C4FF),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onPressed: () => Get.back(),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 50,
              left: 15,
              child: Container(
                width: 35,
                height: 35,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Color(0xFF0288D1),
                  ),
                  onPressed: () {
                    Get.toNamed(Routes.LOGIN);
                  },
                  padding: EdgeInsets.zero,
                  iconSize: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
