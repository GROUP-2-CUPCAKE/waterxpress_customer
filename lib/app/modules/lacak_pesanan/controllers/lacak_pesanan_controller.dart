import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:progress_tracker/progress_tracker.dart';

class LacakPesananController extends GetxController {
  // Menggunakan Rx untuk membuat index menjadi observable
  var index = 0.obs;

  // Daftar status yang menampilkan langkah-langkah dalam progress tracker
  final List<Status> statusList = [
    Status(
        name: 'Order',
        icon: Icons.shopping_bag,
        active: true), // Status pertama diaktifkan
    Status(name: 'Dikemas', icon: Icons.hourglass_full_outlined),
    Status(name: 'Diantarkan', icon: Icons.local_shipping),
    Status(name: 'Selesai', icon: Icons.check_circle),
  ];

  // Method untuk mengubah index dan menandai status berikutnya sebagai aktif
  void nextButton() {
    if (index.value < statusList.length - 1) {
      index.value++;
      // Menandai status yang aktif
      statusList[index.value].active = true;
      update(); // Memperbarui state jika menggunakan Rx dalam controller
    }
  }
}
