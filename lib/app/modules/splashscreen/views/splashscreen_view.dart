import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/app/modules/login/controllers/login_controller.dart';
import '/app/routes/app_pages.dart';

class SplashscreenView extends StatelessWidget {
  const SplashscreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final authC = Get.find<LoginController>();

    Future.delayed(const Duration(seconds: 1), () {
      if (authC.isUserLoggedIn()) {
        Get.offAllNamed(Routes.HOME);
      } else {
        Get.offAllNamed(Routes.LOGIN);
      }
    });
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.blue[200],
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF40C4FF), Color(0xFF0288D1), Color(0xFF40C4FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.3),
              const CircleAvatar(
                radius: 110,
                backgroundImage: AssetImage('assets/images/logo1.jpeg'),
              ),
              const SizedBox(height: 30),
              const CircularProgressIndicator.adaptive(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              SizedBox(height: screenHeight * 0.3),
              const Padding(
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
