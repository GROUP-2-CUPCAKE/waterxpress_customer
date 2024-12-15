import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:progress_tracker/progress_tracker.dart';
import '../controllers/lacak_controller.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LacakView extends StatelessWidget {
  LacakView({Key? key}) : super(key: key);

  final LacakController lacakController = Get.find();
  final LacakController statusController = Get.put(LacakController());

  @override
  Widget build(BuildContext context) {
    // Ambil pesananId dari argumen
    final String? pesananId = Get.arguments?['pesananId'];

    // Panggil method untuk mengambil detail pesanan
    if (pesananId != null) {
      lacakController.listenToPesananChanges(pesananId);
      // Tambahkan inisialisasi status berdasarkan pesananId
      statusController.initializeStatusForPesanan(pesananId);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Status Pesanan'),
        automaticallyImplyLeading: true,
        foregroundColor: Colors.white,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF40C4FF), Color(0xFF0288D1)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      body: Obx(() {
        // Cek loading
        if (lacakController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Cek apakah pesanan ditemukan
        final pesanan = lacakController.pesanan.value;
        if (pesanan == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(''),
              ],
            ),
          );
        }

        // Tampilan status pesanan
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                colors: [
                  Colors.blue.withOpacity(0.1),
                  Colors.blue.withOpacity(0.02),
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.05),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Card(
              elevation: 0,
              color: Colors.transparent,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: const Color(0xFF0288D1).withOpacity(0.5),
                  width: 0.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Informasi Estimasi
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          child: const Text(
                            'Tanggal',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0288D1),
                            ),
                          ),
                        ),
                        Text(
                          pesanan.tanggalPesanan != null
                              ? DateFormat('dd MMM yyyy HH:mm').format(
                                  (pesanan.tanggalPesanan as Timestamp)
                                      .toDate())
                              : 'Tanggal tidak tersedia',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    //Divider
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1),
                      child: Divider(
                        color: Colors.blue.withOpacity(0.2),
                        thickness: 1,
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0288D1).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'LACAK PESANAN',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0288D1),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Obx(
                            () => ProgressTracker(
                              currentIndex:
                                  statusController.currentStatusIndex.value,
                              statusList: statusController.statusList,
                              activeColor: Colors.green,
                              inActiveColor: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
