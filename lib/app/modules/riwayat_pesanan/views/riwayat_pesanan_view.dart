import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/app/data/Pesanan.dart';
import 'package:waterxpress_customer/app/modules/riwayat_pesanan/controllers/riwayat_pesanan_controller.dart';
import '/app/routes/app_pages.dart'; // Pastikan import routes
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RiwayatPesananView extends StatelessWidget {
  RiwayatPesananView({Key? key}) : super(key: key);

  // Inisialisasi controller
  final RiwayatPesananController controller = Get.put(RiwayatPesananController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pesanan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF40C4FF), Color(0xFF0288D1)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10, left: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Pesanan yang diproses',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Pesanan>>(
                stream: controller.getCurrentUserPesanan(includeStatuses: ['Selesai']),
                builder: (context, snapshot) {
                  // Tampilkan loading indicator saat data sedang dimuat
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  // Tampilkan pesan jika tidak ada data
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'Tidak ada pesanan',
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }

                  // Tampilkan daftar pesanan
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      Pesanan pesanan = snapshot.data![index];
                      return _buildPesananCard(
                        pesanan: pesanan,
                        produk: _getProdukNames(pesanan.produk),
                        subtitle: 'Total Pembayaran',
                        tanggalPesanan: _formatTanggal(pesanan.tanggalPesanan),
                        total: 'Rp${pesanan.total?.toString() ?? '0'}',
                        status: '${pesanan.status}',
                        images: _getProdukImages(pesanan.produk),
                        jumlahProduk: pesanan.produk?.length ?? 0,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Metode untuk mendapatkan nama produk dari index 0
  String _getProdukNames(List<dynamic>? produkList) {
    if (produkList == null || produkList.isEmpty) {
      return 'Tidak ada produk';
    }

    // Ambil nama produk dari item pertama
    return produkList[0]['nama'] ?? 'Produk Tidak Diketahui';
  }

   // Metode untuk mendapatkan ngal
  String _formatTanggal(Timestamp? tanggalPesanan) {
    if (tanggalPesanan == null) {
      return '-'; // atau pesan default lainnya
    }
    return DateFormat('dd MMM yyyy HH:mm').format(tanggalPesanan.toDate());
  }

  // Metode untuk mendapatkan gambar produk dari index 0
  String _getProdukImages(List<dynamic>? produkList) {
    if (produkList == null || produkList.isEmpty) {
      return '';
    }

    // Ambil gambar dari item pertama
    return produkList[0]['images'] ?? '';
  }


  Widget _buildPesananCard({
    required Pesanan pesanan,
    required String produk,
    required String subtitle,
    required String tanggalPesanan,
    required String total,
    required String status,
    required String images,
    required int jumlahProduk,
  }) {
    return GestureDetector(
      onTap: () {
        print('Pesanan ID: ${pesanan.id}');
        // Navigate to RincianPesanan with pesanan ID
        if (pesanan.id != null) {
          Get.toNamed(
            Routes.RINCIAN_PESANAN, 
            arguments: {'pesananId': pesanan.id}
          );
        } else {
          Get.snackbar(
            'Error',
            'ID Pesanan tidak tersedia',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      },
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: images.isNotEmpty
                        ? Image.network(
                            images,
                            width: 50,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 50,
                                height: 70,
                                color: Colors.grey[300],
                                child:
                                    const Icon(Icons.image, color: Colors.grey),
                              );
                            },
                          )
                        : Container(
                            width: 60,
                            height: 70,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, color: Colors.grey),
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              produk,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 8), // Tambahkan jarak antar teks
                            Text(
                              tanggalPesanan,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          total,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Stack(
                children: [
                  // Jumlah produk di pojok kiri bawah
                  if (jumlahProduk > 1)
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        '+${jumlahProduk - 1} produk lainnya',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),

                  // Status di pojok kanan bawah
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        color: _getStatusColor(status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Metode untuk menentukan warna status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return Colors.green;
      default:
        return Colors.black;
    }
  }
}

// Extension untuk membantu pemformatan
extension StringExtension on String {
  // Capitalize first letter
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
                        
