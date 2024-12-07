import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/rincian_pesanan_controller.dart';

class RincianPesananView extends GetView<RincianPesananController> {
  const RincianPesananView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RincianPesananView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'RincianPesananView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
