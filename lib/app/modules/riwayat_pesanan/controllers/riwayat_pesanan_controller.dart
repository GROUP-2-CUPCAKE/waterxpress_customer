import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '/app/data/Pesanan.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RiwayatPesananController extends GetxController {
  // Referensi ke koleksi Riwayat di Firestore
  final CollectionReference ref = FirebaseFirestore.instance.collection('Pesanan');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream untuk mendapatkan Pesanan aktif untuk user saat ini
  Stream<List<Pesanan>> getCurrentUserPesanan({
    // List<String>? excludeStatuses,
    List<String>? includeStatuses,
  }) {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    Query query = FirebaseFirestore.instance
        .collection('Pesanan')
        .where('userId', isEqualTo: currentUser.uid);

    // Filter status
    // if (excludeStatuses != null && excludeStatuses.isNotEmpty) {
    //   query = query.where('status', whereNotIn: excludeStatuses);
    // }

    if (includeStatuses != null && includeStatuses.isNotEmpty) {
      query = query.where('status', whereIn: includeStatuses);
    }

    return query
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => 
                Pesanan.fromJson({
                  ...doc.data() as Map<String, dynamic>, 
                  'id': doc.id
                })
            ).toList()
        );
  }

  // Fungsi untuk mendapatkan detail pesanan berdasarkan ID
  Future<Pesanan?> getPesananById(String pesananId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('Pesanan')
              .doc(pesananId)
              .get();
      
      if (snapshot.exists) {
        return Pesanan.fromJson({
          ...snapshot.data()!, 
          'id': snapshot.id
        });
      }
    } catch (e) {
      print("Error getting pesanan by id: $e");
      Get.snackbar(
        'Error', 
        'Gagal mengambil detail pesanan',
        snackPosition: SnackPosition.BOTTOM,
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
          'Anda harus login terlebih dahulu',
          snackPosition: SnackPosition.BOTTOM,
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
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      print("Error membatalkan pesanan: $e");
      Get.snackbar(
        'Error', 
        'Gagal membatalkan pesanan',
        snackPosition: SnackPosition.BOTTOM,
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
        .map((snapshot) => 
            snapshot.docs.map((doc) => 
                Pesanan.fromJson({
                  ...doc.data() as Map<String, dynamic>, 
                  'id': doc.id
                })
            ).toList()
        );
  }
}