import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '/app/data/Produk.dart';
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

  void logout() async {
    await auth.signOut();
    Get.off(() => LoginView());
  }
}
