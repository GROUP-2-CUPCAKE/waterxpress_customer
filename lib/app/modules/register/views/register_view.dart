import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../login/views/login_view.dart';
import '/app/modules/register/controllers/register_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/app/routes/app_pages.dart';

class RegisterView extends GetView<RegisterController> {
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
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 370,
                        padding: const EdgeInsets.only(top: 50),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Daftar',
                              style: TextStyle(
                                fontSize: 30,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Selamat Datang Pengguna Baru!',
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
                                    'assets/images/register.jpeg',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
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
                                  'Daftar dengan akun baru disini!',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0288D1),
                                  ),
                                ),
                              ),
                              Container(
                                decoration: textFieldDecoration(),
                                child: TextFormField(
                                  controller: controller.usernameController,
                                  decoration: InputDecoration(
                                    hintText: "Nama Pengguna",
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
                                      Icons.person,
                                      color: Color(0xFF0277BD),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              Container(
                                decoration: textFieldDecoration(),
                                child: TextFormField(
                                  controller: controller.nohpController,
                                  decoration: InputDecoration(
                                    hintText: "Nomor Handphone",
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
                                      Icons.call,
                                      color: Color(0xFF0277BD),
                                    ),
                                  ),
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                ),
                              ),
                              const SizedBox(height: 15),
                              Container(
                                decoration: textFieldDecoration(),
                                child: TextFormField(
                                  controller: controller.emailController,
                                  decoration: InputDecoration(
                                    hintText: "Email",
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
                              const SizedBox(height: 15),
                              Container(
                                  decoration: textFieldDecoration(),
                                  child: Obx(() => TextFormField(
                                        controller:
                                            controller.passwordController,
                                        obscureText:
                                            controller.obscureText.value,
                                        decoration: InputDecoration(
                                          hintText: "Password",
                                          hintStyle: const TextStyle(
                                            color: Color(0xFF37474F),
                                            fontSize: 16,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            borderSide: BorderSide.none,
                                          ),
                                          fillColor: Colors.transparent,
                                          filled: true,
                                          prefixIcon: const Icon(
                                            Icons.key,
                                            color: Color(0xFF0277BD),
                                          ),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              controller.obscureText.value
                                                  ? Icons.visibility_off
                                                  : Icons.visibility,
                                            ),
                                            onPressed: () =>
                                                controller.togglePasswordView(),
                                          ),
                                        ),
                                      ))),
                              const SizedBox(height: 15),
                              Container(
                                  decoration: textFieldDecoration(),
                                  child: Obx(() => TextFormField(
                                        controller: controller
                                            .confirmPasswordController,
                                        obscureText: controller 
                                            .obscureText2.value,
                                        decoration: InputDecoration(
                                          hintText: "Confirm Password",
                                          hintStyle: const TextStyle(
                                            color: Color(0xFF37474F),
                                            fontSize: 16,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            borderSide: BorderSide.none,
                                          ),
                                          fillColor: Colors.transparent,
                                          filled: true,
                                          prefixIcon: const Icon(
                                            Icons.key,
                                            color: Color(0xFF0277BD),
                                          ),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              controller.obscureText2.value
                                                  ? Icons.visibility_off
                                                  : Icons.visibility,
                                            ),
                                            onPressed: () => controller
                                                .togglePasswordView2(),
                                          ),
                                        ),
                                      ))),
                              const SizedBox(height: 25),
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
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                      ),
                                      child: const Text(
                                        'Daftar',
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      onPressed: () => controller.register(
                                        controller.usernameController.text,
                                        controller.nohpController.text,
                                        controller.emailController.text,
                                        controller.passwordController.text,
                                        controller
                                            .confirmPasswordController.text,
                                      ),
                                    ),
                                  )),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Sudah punya akun?',
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
                                        color: Color(0xFF0288D1),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    onPressed: () => Get.back(),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
