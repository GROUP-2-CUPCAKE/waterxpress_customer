import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/app/data/Pesanan.dart';
import 'package:waterxpress_customer/app/modules/riwayat_pesanan/controllers/riwayat_pesanan_controller.dart';
import '/app/routes/app_pages.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RiwayatPesananView extends StatelessWidget {
  RiwayatPesananView({Key? key}) : super(key: key);
  final RiwayatPesananController controller =
      Get.put(RiwayatPesananController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Riwayat Pesanan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        foregroundColor: Colors.white,
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
                'Pesanan yang sudah selesai',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0288D1),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Pesanan>>(
                stream: controller
                    .getCurrentUserPesanan(includeStatuses: ['Selesai']),
                builder: (context, snapshot) {
                  // Tampilkan loading indicator saat data sedang dimuat
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  //pesanan kosong
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Gambar
                          Image.asset(
                            'assets/images/image.png',
                            width: 200,
                            height: 200,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Tidak ada riwayat pesanan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Kamu belum memiliki riwayat apapun',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black45,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 30),
                        ],
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
          Get.toNamed(Routes.RINCIAN_PESANAN,
              arguments: {'pesananId': pesanan.id});
        } else {
          Get.snackbar(
            'Error',
            'ID Pesanan tidak tersedia',
            margin: const EdgeInsets.all(12),
            backgroundColor: Colors.white,
            colorText: const Color(0xFFFF5252),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [
                Colors.blue.withOpacity(0.1),
                Colors.blue.withOpacity(0.02),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.05),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Card(
            elevation: 0,
            color: Colors.transparent,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(
                color: const Color(0xFF0288D1).withOpacity(0.5),
                width: 0.5,
              ),
            ),
            child: Container(
              // Dekorasi border bawah
              decoration: BoxDecoration(
                border: const Border(
                  bottom: BorderSide(
                    color: Color(0xFF0288D1),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 50,
                                    height: 70,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.image,
                                        color: Colors.grey),
                                  );
                                },
                              )
                            : Container(
                                width: 60,
                                height: 70,
                                color: Colors.grey[300],
                                child:
                                    const Icon(Icons.image, color: Colors.grey),
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              produk,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
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
                                fontWeight: FontWeight.w900,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        pesanan.tanggalPesanan != null
                            ? _formatTanggal(pesanan.tanggalPesanan!)
                            : 'Tanggal tidak tersedia',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    thickness: 1,
                    color: const Color(0xFF0288D1).withOpacity(0.3),
                    height: 20,
                  ),
                  Stack(
                    children: [
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
