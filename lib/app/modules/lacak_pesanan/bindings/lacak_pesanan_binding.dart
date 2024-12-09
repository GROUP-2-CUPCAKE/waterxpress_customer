import 'package:get/get.dart';

import '../controllers/lacak_pesanan_controller.dart';

class LacakPesananBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LacakPesananController>(
      () => LacakPesananController(),
    );
  }
}
