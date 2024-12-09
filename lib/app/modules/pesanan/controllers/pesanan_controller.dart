import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '/app/data/Pesanan.dart';

class PesananController extends GetxController {
  // Referensi ke koleksi Riwayat di Firestore
  CollectionReference ref = FirebaseFirestore.instance.collection('Riwayat');

  // Stream untuk mendapatkan Riwayat dengan status 'selesai'
  Stream<List<Pesanan>> getAllCompletedProducts() {
    return FirebaseFirestore.instance
        .collection('Pesanan')
        .where('status',
            isEqualTo: 'Diproses') // Tambahkan filter status 'selesai'
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Pesanan.fromJson(doc.data())).toList());
  }

  // Fungsi untuk mendapatkan detail pesanan berdasarkan ID
  Future<Pesanan?> getPesananById(String id) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('pesanan').doc(id).get();
      if (snapshot.exists) {
        return Pesanan.fromJson(snapshot.data()!);
      }
    } catch (e) {
      print("Error getting pesanan by id: $e");
    }
    return null;
  }
}
