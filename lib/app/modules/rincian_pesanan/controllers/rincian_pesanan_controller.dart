import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/app/data/Pesanan.dart';

class RincianPesananController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observable untuk detail pesanan
  Rx<Pesanan?> pesanan = Rx<Pesanan?>(null);
  RxBool isLoading = false.obs;

  // Observable untuk detail pembayaran
  RxString alamat = RxString('');
  RxInt ongkir = RxInt(0);
  RxInt subtotalProduk = RxInt(0);
  RxInt total = RxInt(0);

  // Observable untuk daftar produk
  RxList<dynamic> produkList = RxList<dynamic>([]);

  @override
  void onInit() {
    super.onInit();
    final pesananId = Get.arguments?['pesananId'];
    if (pesananId != null) {
      fetchPesananDetail(pesananId);
    } else {
      Get.snackbar(
        'Error',
        'ID Pesanan tidak ditemukan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> fetchPesananDetail(String id) async {
    try {
      isLoading.value = true;

      // DocumentSnapshot doc = await _firestore.collection('Pesanan').doc(id).get();
      // Reset semua value
      // pesanan.value = null;
      // alamat.value = '';
      // ongkir.value = 0;
      // subtotalProduk.value = 0;
      // total.value = 0;
      // produkList.clear();

      // Query untuk mendapatkan pesanan berdasarkan userId
      QuerySnapshot querySnapshot = await _firestore
          .collection('Pesanan')
          .where('userId', isEqualTo: id)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var doc = querySnapshot.docs.first;
        Pesanan fetchedPesanan = Pesanan.fromJson(
            {'userId': doc.id, ...doc.data() as Map<String, dynamic>});

        // Set nilai pesanan
        pesanan.value = fetchedPesanan;

        // Set detail alamat dan pembayaran
        alamat.value = fetchedPesanan.alamat ?? 'Alamat tidak tersedia';
        ongkir.value = fetchedPesanan.ongkir ?? 0;

        // Hitung subtotal produk
        subtotalProduk.value = fetchedPesanan.subtotalProduk ?? 0;

        // Set total pembayaran
        total.value = fetchedPesanan.total ?? 0;

        // Set daftar produk
        produkList.value = fetchedPesanan.produk ?? [];
      } else {
        // Jika tidak ada pesanan ditemukan
        Get.snackbar(
          'Error',
          'Pesanan tidak ditemukan',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error fetching pesanan detail: $e');
      Get.snackbar(
        'Error',
        'Gagal memuat detail pesanan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Metode untuk membatalkan pesanan
  Future<void> batalkanPesanan() async {
    if (pesanan.value == null) return;

    try {
      await _firestore.collection('Pesanan').doc(pesanan.value!.id).update({
        'status': 'Dibatalkan',
        'tanggalPembatalan': FieldValue.serverTimestamp()
      });

      Get.snackbar('Berhasil', 'Pesanan berhasil dibatalkan');
      // Kembali ke halaman sebelumnya
      Get.back();
    } catch (e) {
      print('Error membatalkan pesanan: $e');
      Get.snackbar('Gagal', 'Gagal membatalkan pesanan');
    }
  }
}
