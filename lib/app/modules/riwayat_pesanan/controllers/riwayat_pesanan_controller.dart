import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/app/data/Pesanan.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RiwayatPesananController extends GetxController {
  // Referensi ke koleksi Riwayat di Firestore
  final CollectionReference ref =
      FirebaseFirestore.instance.collection('Pesanan');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream untuk mendapatkan Pesanan aktif untuk user saat ini
  Stream<List<Pesanan>> getCurrentUserPesanan({
    List<String>? includeStatuses,
  }) {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    Query query = FirebaseFirestore.instance
        .collection('Pesanan')
        .where('userId', isEqualTo: currentUser.uid);

    if (includeStatuses != null && includeStatuses.isNotEmpty) {
      query = query.where('status', whereIn: includeStatuses);
    }
    return query.snapshots().map((snapshot) {
      List<Pesanan> pesananList = snapshot.docs
          .map((doc) => Pesanan.fromJson(
              {...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();

      // Sorting manual berdasarkan tanggal
      pesananList.sort((a, b) {
        DateTime dateA =
            (a.tanggalPesanan as Timestamp?)?.toDate() ?? DateTime.now();
        DateTime dateB =
            (b.tanggalPesanan as Timestamp?)?.toDate() ?? DateTime.now();
        // Urutkan dari yang paling baru
        return dateB.compareTo(dateA);
      });

      return pesananList;
    });
  }

  // Fungsi untuk mendapatkan detail pesanan berdasarkan ID
  Future<Pesanan?> getPesananById(String pesananId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('Pesanan')
          .doc(pesananId)
          .get();

      if (snapshot.exists) {
        return Pesanan.fromJson({...snapshot.data()!, 'id': snapshot.id});
      }
    } catch (e) {
      print("Error getting pesanan by id: $e");
      Get.snackbar(
        'Error',
        'Gagal mengambil detail pesanan',
        margin: const EdgeInsets.all(12),
        backgroundColor: Colors.white,
        colorText: const Color(0xFFFF5252),
      );
    }
    return null;
  }

  // Fungsi untuk membatalkan pesanan
  Future<bool> batalkanPesanan(String pesananId) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        Get.snackbar(
          'Error',
          'Kamu harus login terlebih dahulu',
          margin: const EdgeInsets.all(12),
          backgroundColor: Colors.white,
          colorText: const Color(0xFFFF5252),
        );
        return false;
      }

      await ref.doc(pesananId).update({
        'status': 'Dibatalkan',
        'tanggalPembatalan': FieldValue.serverTimestamp()
      });

      Get.snackbar(
        'Berhasil',
        'Pesanan berhasil dibatalkan',
        margin: const EdgeInsets.all(12),
        backgroundColor: Colors.white,
        colorText: const Color(0xFF0288D1),
      );
      return true;
    } catch (e) {
      print("Error membatalkan pesanan: $e");
      Get.snackbar(
        'Error',
        'Gagal membatalkan pesanan',
        margin: const EdgeInsets.all(12),
        backgroundColor: Colors.white,
        colorText: const Color(0xFFFF5252),
      );
      return false;
    }
  }

  // Fungsi untuk mendapatkan pesanan berdasarkan status tertentu
  Stream<List<Pesanan>> getPesananByStatus(String status) {
    return FirebaseFirestore.instance
        .collection('Pesanan')
        .where('status', isEqualTo: status)
        .orderBy('tanggalPesanan', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Pesanan.fromJson(
                {...doc.data() as Map<String, dynamic>, 'id': doc.id}))
            .toList());
  }
}
