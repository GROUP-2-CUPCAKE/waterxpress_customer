import 'package:get/get.dart';

import '../controllers/lacak_controller.dart';

class LacakBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LacakController>(
      () => LacakController(),
    );
  }
}
