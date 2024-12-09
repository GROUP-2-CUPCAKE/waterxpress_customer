
  import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:progress_tracker/progress_tracker.dart';
import 'package:waterxpress_customer/app/data/Pesanan.dart';

class LacakController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observable untuk index status saat ini
  RxInt index = 0.obs;
  // Status list untuk progress tracker dengan icon
  List<Status> statusList = [
    Status(name: 'Diproses', icon: Icons.pending_outlined, active: true),
    Status(name: 'Dikemas', icon: Icons.build_circle_outlined, active: true),
    Status(name: 'Dikirim', icon: Icons.local_shipping_outlined, active: true),
    Status(name: 'Selesai', icon: Icons.check_circle_outline, active: true)
  ];

  // Stream untuk mendapatkan pesanan yang menunggu konfirmasi
  // Stream<List<Pesanan>> getPesananMenungguKonfirmasi() {
  //   return _firestore
  //     .collection('Pesanan')
  //     .snapshots()
  //     .map((snapshot) =>
  //       snapshot.docs.map((doc) =>
  //         Pesanan.fromMap(doc.data() as Map<String, dynamic>)
  //       ).toList()
  //     );
  // }
  // Method untuk mendapatkan index terakhir dari Firestore
  Future<void> initializeIndexFromFirestore(String pesananId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('Pesanan').doc(pesananId).get();

      if (doc.exists) {
        String? currentStatus = doc.get('status');
        int savedIndex =
            statusList.indexWhere((status) => status.name == currentStatus);

        // Set index ke status terakhir yang tersimpan
        if (savedIndex != -1) {
          index.value = savedIndex;
        }
      }
    } catch (e) {
      print('Error initializing index: $e');
    }
  }

  // Metode untuk memperbarui status pesanan
  Future<bool> updateStatusPesanan(String? pesananId, String status) async {
    try {
      // Validasi pesananId
      if (pesananId == null || pesananId.isEmpty) {
        print('Error: ID Pesanan tidak valid');
        return false;
      }

      // Update status langsung menggunakan ID dokumen
      await _firestore.collection('Pesanan').doc(pesananId).update({
        'status': status, 'updatedAt': FieldValue.serverTimestamp(),
        'currentStatusIndex': index.value // Simpan index status saat ini
      });

      // Logging untuk debugging
      print('Pesanan diupdate:');
      print('Document ID: $pesananId');
      print('New Status: $status');

      return true;
    } catch (e) {
      print('Error updating status: $e');
      return false;
    }
  }

  // Metode untuk maju ke status berikutnya
  void nextButton(String pesananId) {
    if (index.value < statusList.length - 1) {
      index.value++;
      // Update status langsung setelah tombol ditekan
      // Menandai status yang aktif
      statusList[index.value].active = true;
      updateStatusPesanan(pesananId, statusList[index.value].name);
    }
  }

  // Metode untuk mendapatkan detail pesanan berdasarkan ID
  Future<Pesanan?> getPesananById(String id) async {
    // print ($ id');
    try {
      DocumentSnapshot doc =
          await _firestore.collection('Pesanan').doc(id).get();

      if (doc.exists) {
        // Membuat objek Pesanan dengan menambahkan ID dokumen
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Menambahkan ID dokumen ke dalam map data

        // Ambil index status yang tersimpan
        int? savedIndex = data['currentStatusIndex'];
        if (savedIndex != null) {
          index.value = savedIndex;
        }

        return Pesanan.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error getting pesanan: $e');
      return null;
    }
  }
}
