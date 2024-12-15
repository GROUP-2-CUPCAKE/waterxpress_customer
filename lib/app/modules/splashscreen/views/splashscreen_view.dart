import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/app/modules/login/controllers/login_controller.dart';
import '/app/routes/app_pages.dart';

class SplashscreenView extends StatelessWidget {
  const SplashscreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final authC = Get.find<LoginController>();

    Future.delayed(const Duration(seconds: 3), () {
      if (authC.isUserLoggedIn()) {
        Get.offAllNamed(Routes.HOME);
      } else {
        Get.offAllNamed(Routes.LOGIN);
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF40C4FF), Color(0xFF0288D1), Color(0xFF40C4FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Spacer(flex: 2),
              Center(
                child: CircleAvatar(
                  radius: 110,
                  backgroundImage: AssetImage('assets/images/logo.jpeg'),
                ),
              ),
              SizedBox(height: 30),
              // Progress Indicator
              Center(
                child: CircularProgressIndicator.adaptive(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              Spacer(flex: 2),
              Padding(
                padding: EdgeInsets.only(bottom: 20.0),
                child: Text(
                  "by CupCake Team",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
