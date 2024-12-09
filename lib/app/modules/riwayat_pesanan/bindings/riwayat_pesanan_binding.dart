import 'package:get/get.dart';

import '../controllers/riwayat_pesanan_controller.dart';

class RiwayatPesananBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RiwayatPesananController>(
      () => RiwayatPesananController(),
    );
  }
}
