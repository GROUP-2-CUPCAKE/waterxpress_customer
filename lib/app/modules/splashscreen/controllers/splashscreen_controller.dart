import 'dart:async';
import 'package:get/get.dart';
import '/app/routes/app_pages.dart';

class SplashscreenController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    startTimer();
  }

  void startTimer() {
    Timer(const Duration(seconds: 3), () {
      Get.offAllNamed(Routes.LOGIN);
    });
  }
}
