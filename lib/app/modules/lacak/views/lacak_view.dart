import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:progress_tracker/progress_tracker.dart';
import '../controllers/lacak_controller.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LacakView extends StatelessWidget {
  LacakView({Key? key}) : super(key: key);

  final LacakController lacakController = Get.find();
  final  LacakController statusController = Get.put(LacakController());

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
        centerTitle: true,
        foregroundColor: Colors.white,
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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Pesanan tidak ditemukan.'),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Kembali'),
                )
              ],
            ),
          );
        }

        // Tampilan status pesanan
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Informasi Estimasi
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tanggal',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                          pesanan.tanggalPesanan != null 
                            ? DateFormat('dd MMM yyyy HH:mm').format((pesanan.tanggalPesanan as Timestamp).toDate())
                            : 'Belum ditentukan',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Divider(
                        color: Color(0xFF0288D1),
                        thickness: 2,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'LACAK PESANAN',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      
                      // Progress Tracker
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0, bottom: 10),
                        child: Obx(
                          () => ProgressTracker(
                            currentIndex: statusController.currentStatusIndex.value,
                            statusList: statusController.statusList,
                            activeColor: Colors.green,
                            inActiveColor: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}