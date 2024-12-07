import 'package:get/get.dart';

import '../controllers/rincian_pesanan_controller.dart';

class RincianPesananBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RincianPesananController>(
      () => RincianPesananController(),
    );
  }
}
