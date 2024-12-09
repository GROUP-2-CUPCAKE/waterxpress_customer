import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/app/data/Pesanan.dart';

class RincianPesananController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observable untuk detail pesanan
  Rx<Pesanan?> pesanan = Rx<Pesanan?>(null);
  RxBool isLoading = false.obs;
  RxString errorMessage = RxString('');

  // Observable untuk detail pembayaran
  RxString alamat = RxString('');
  RxDouble ongkir = RxDouble(0.0);
  RxDouble subtotalProduk = RxDouble(0.0);
  RxDouble total = RxDouble(0.0);

  // Observable untuk daftar produk
  RxList<dynamic> produkList = RxList<dynamic>([]);

  @override
  void onInit() {
    super.onInit();
    
    // Gunakan WidgetsBinding untuk menunda eksekusi
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pesananId = Get.arguments?['id'] as String?;
      if (pesananId != null && pesananId.isNotEmpty) {
        fetchPesananDetail(pesananId);
      }
    });
  }

  Future<void> fetchPesananDetail(String pesananId) async {
    try {
      // Reset state sebelum memuat
      _resetState();
      
      isLoading.value = true;
      errorMessage.value = '';

      // Ambil dokumen pesanan
      final doc = await _firestore
          .collection('Pesanan')
          .doc(pesananId)
          .get();

      if (doc.exists) {
        // Convert data ke model Pesanan
        final fetchedPesanan = Pesanan.fromJson({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>
        });

        // Update state
        _updatePesananState(fetchedPesanan);
      } else {
        _handleError('Pesanan tidak ditemukan');
      }
    } catch (e) {
      _handleError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void _updatePesananState(Pesanan fetchedPesanan) {
    pesanan.value = fetchedPesanan;
    alamat.value = fetchedPesanan.alamat ?? 'Alamat tidak tersedia';
    ongkir.value = (fetchedPesanan.ongkir ?? 0).toDouble();
    subtotalProduk.value = _calculateSubtotal(fetchedPesanan.produk);
    total.value = (fetchedPesanan.total ?? 0).toDouble();
    produkList.value = fetchedPesanan.produk ?? [];
  }

  // Metode untuk menghitung subtotal produk
  double _calculateSubtotal(List<dynamic>? produkList) {
    if (produkList == null || produkList.isEmpty) return 0.0;

    return produkList.fold(0.0, (total, produk) {
      double harga = (produk['harga'] ?? 0.0).toDouble();
      int jumlah = (produk['jumlah'] ?? 1);
      return total + (harga * jumlah);
    });
  }

  // Metode untuk membatalkan pesanan
  Future<void> batalkanPesanan() async {
    if (pesanan.value == null) {
      _handleError('Tidak ada pesanan yang dapat dibatalkan');
      return;
    }

    try {
      await _firestore.collection('Pesanan').doc(pesanan.value!.id).update({
        'status': 'Dibatalkan',
        'tanggalPembatalan': FieldValue.serverTimestamp()
      });

      // Update status lokal
      pesanan.value?.status = 'Dibatalkan';

      _showSuccessSnackbar('Pesanan berhasil dibatalkan');
      
      // Kembali ke halaman sebelumnya
      Get.back();
    } catch (e) {
      _handleError('Gagal membatalkan pesanan: ${e.toString()}');
    }
  }

  // Reset semua nilai
  void _resetState() {
    pesanan.value = null;
    alamat.value = '';
    ongkir.value = 0.0;
    subtotalProduk.value = 0.0;
    total.value = 0.0;
    produkList.clear();
    errorMessage.value = '';
  }

  // Metode bantuan untuk menampilkan error
  void _handleError(String message) {
    errorMessage.value = message;
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  // Metode bantuan untuk menampilkan pesan sukses
  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Berhasil',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
}