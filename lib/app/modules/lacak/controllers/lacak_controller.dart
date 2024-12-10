import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:waterxpress_customer/app/data/Pesanan.dart';
import 'package:flutter/material.dart';
import 'package:progress_tracker/progress_tracker.dart';

class LacakController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observable untuk pesanan dengan stream
  final Rx<Pesanan?> pesanan = Rx<Pesanan?>(null);
  
  // Status loading
  final RxBool isLoading = false.obs;
  
  // Current status index - buat bisa diupdate real-time
  final RxInt currentStatusIndex = RxInt(0);

  // List status tracking dengan observable
  RxList<Status> statusList = RxList<Status>([
    Status(name: 'Diproses', icon: Icons.pending_outlined, active: false),
    Status(name: 'Dikemas', icon: Icons.build_circle_outlined, active: false),
    Status(name: 'Dikirim', icon: Icons.local_shipping_outlined, active: false),
    Status(name: 'Selesai', icon: Icons.check_circle_outline, active: false)
  ]);

  // Stream subscription untuk real-time update
  StreamSubscription? _pesananSubscription;

  // Method untuk update status list berdasarkan current status
  void _updateStatusList(String currentStatus) {
    // Reset semua status terlebih dahulu
    for (var status in statusList) {
      status.active = false;
    }

    // Update status sesuai current status
    switch (currentStatus.toLowerCase()) {
      case 'diproses':
        statusList[0].active = true;
        currentStatusIndex.value = 0;
        break;
      case 'dikemas':
        statusList[0].active = true;
        statusList[1].active = true;
        currentStatusIndex.value = 1;
        break;
      case 'dikirim':
        statusList[0].active = true;
        statusList[1].active = true;
        statusList[2].active = true;
        currentStatusIndex.value = 2;
        break;
      case 'selesai':
        statusList[0].active = true;
        statusList[1].active = true;
        statusList[2].active = true;
        statusList[3].active = true;
        currentStatusIndex.value = 3;
        break;
      default:
        currentStatusIndex.value = 0;
    }

    // Trigger update pada statusList
    statusList.refresh();
  }

  // Method untuk listen perubahan pesanan secara real-time
  void listenToPesananChanges(String pesananId) {
    try {
      // Cancel existing subscription jika ada
      _pesananSubscription?.cancel();

      // Mulai listen perubahan dokumen
      _pesananSubscription = _firestore
          .collection('Pesanan')
          .doc(pesananId)
          .snapshots()
          .listen((DocumentSnapshot snapshot) {
        if (snapshot.exists) {
          // Konversi data ke model Pesanan
          Pesanan pesananData = Pesanan.fromJson(
            snapshot.data() as Map<String, dynamic>
          );
          
          // Update pesanan
          pesanan.value = pesananData;

          // Update status list dan index
          _updateStatusList(pesananData.status ?? 'Pesanan Dibuat');
        } else {
          pesanan.value = null;
          currentStatusIndex.value = 0;
          
          // Reset status list
          _updateStatusList('Pesanan Dibuat');
        }
      }, onError: (error) {
        print('Error listening to pesanan changes: $error');
        pesanan.value = null;
        currentStatusIndex.value = 0;
        
        // Reset status list
        _updateStatusList('Pesanan Dibuat');
      });
    } catch (e) {
      print('Error setting up real-time listener: $e');
    }
  }

  // Method untuk menginisialisasi status
  void initializeStatusForPesanan(String pesananId) {
    listenToPesananChanges(pesananId);
  }

  @override
  void onClose() {
    // Pastikan subscription dibatalkan saat controller ditutup
    _pesananSubscription?.cancel();
    super.onClose();
  }
}