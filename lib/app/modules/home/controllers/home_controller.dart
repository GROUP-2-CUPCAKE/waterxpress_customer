import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '/app/data/Produk.dart';
import 'package:flutter/material.dart';
import '/app/modules/login/views/login_view.dart'; // Impor LoginView

class HomeController extends GetxController {
  // Inisialisasi FirebaseAuth
  final FirebaseAuth auth = FirebaseAuth.instance;

  // Referensi ke koleksi Produk di Firestore
  CollectionReference ref = FirebaseFirestore.instance.collection('Produk');

  // Stream untuk mendapatkan semua produk
  Stream<List<Produk>> getAllProducts() {
    return FirebaseFirestore.instance.collection('Produk').snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => Produk.fromJson(doc.data())).toList());
  }

  // Fungsi untuk menghapus produk
  Future<void> deleteProduct(String id) async {
    try {
      await ref.doc(id).delete();
      Get.snackbar(
        'Berhasil',
        'Produk berhasil dihapus',
        backgroundColor: Colors.white,
        colorText: Color(0xFF0288D1),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menghapus produk: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void logout() async {
    await auth.signOut();
    Get.off(() => LoginView());
  }
}
