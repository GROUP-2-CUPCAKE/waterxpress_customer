import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '/app/data/Produk.dart';

class DetailPesananController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observables for customer data
  var alamat = ''.obs;
  var ongkir = 0.obs;

  // Observable list for products
  var produkList = <Produk>[].obs;

  // Payment details
  var subtotalProduk = 0.obs;
  var total = 0.obs;

  // Initialize data
  @override
  void onInit() {
    super.onInit();
    fetchCustomerData();
    fetchProdukData();
    calculateSubtotal();
  }

  // Fetch customer data based on the logged-in user's email
  Future<void> fetchCustomerData() async {
    try {
      final email = _auth.currentUser?.email;
      if (email == null) return;

      final snapshot = await _firestore
          .collection('customer')
          .where('email', isEqualTo: email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        alamat.value = data['alamat'] ?? '';
        ongkir.value = data['ongkir'] ?? 0;
        calculateTotal();
      }
    } catch (e) {
      print('Error fetching customer data: $e');
    }
  }

  // Fetch product data from the 'Produk' collection
  Future<void> fetchProdukData() async {
    try {
      final snapshot = await _firestore.collection('Produk').get();
      produkList.value = snapshot.docs
          .map((doc) => Produk.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      calculateSubtotal();
    } catch (e) {
      print('Error fetching product data: $e');
    }
  }

  // Calculate the subtotal for all products in the cart
  void calculateSubtotal() {
    int subtotal = 0;
    for (var produk in produkList) {
      subtotal += produk.harga; // Sesuaikan dengan quantity jika ada
    }
    subtotalProduk.value = subtotal;
    calculateTotal();
  }

  // Calculate the total including shipping cost
  void calculateTotal() {
    total.value = subtotalProduk.value + ongkir.value;
  }

  // Save order to the 'Pesanan' collection in Firebase
  Future<void> buatPesanan() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('User not logged in');
        return;
      }

      final orderData = {
        'userId': user.uid,
        'email': user.email,
        'alamat': alamat.value,
        'ongkir': ongkir.value,
        'subtotalProduk': subtotalProduk.value,
        'total': total.value,
        'produk': produkList.map((p) => p.toJson()).toList(),
        'tanggalPesanan': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('Pesanan').add(orderData);
      print('Pesanan berhasil disimpan');
    } catch (e) {
      print('Error saving order: $e');
    }
  }
}
