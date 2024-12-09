import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/app/data/Pesanan.dart';
import '/app/modules/pesanan/controllers/pesanan_controller.dart';
import 'package:waterxpress_customer/app/modules/rincian_pesanan/views/rincian_pesanan_view.dart';

class PesananView extends StatelessWidget {
  PesananView({Key? key}) : super(key: key);

  // Inisialisasi controller
  final PesananController controller = Get.put(PesananController());

  // get pesananId => null;

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
        // leading: IconButton(
        // icon: const Icon(Icons.arrow_back, color: Colors.white),
        // onPressed: () {
        // Navigator.pop(context);
        // },
        // ),
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
                stream: controller.getAllCompletedProducts(),
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
                        'Tidak ada pesanan yang diproses',
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
                        total: 'Rp${pesanan.total?.toString() ?? '0'}',
                        status: _getStatus(pesanan.produk),
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

  // Metode untuk mendapatkan gambar produk dari index 0
  String _getProdukImages(List<dynamic>? produkList) {
    if (produkList == null || produkList.isEmpty) {
      return '';
    }

    // Ambil gambar dari item pertama
    return produkList[0]['images'] ?? '';
  }

  // Metode untuk mendapatkan status dari produk
  String _getStatus(List<dynamic>? produkList) {
    if (produkList == null || produkList.isEmpty) {
      return 'Diproses';
    }

    // Ambil status dari item pertama
    return produkList[0]['status'] ?? 'Diproses';
  }

  Widget _buildPesananCard({
    required Pesanan pesanan,
    required String produk,
    required String subtitle,
    required String total,
    required String status,
    required String images,
    required int jumlahProduk,
  }) {
    return GestureDetector(
      onTap: () {
        // Periksa apakah userId tidak null
        if (pesanan.id != null) {
          // Navigasi ke halaman RincianPesanan dengan userId
          Get.to(
            () => RincianPesananView(
                // pesananId: pesanan.id!,
                ),
            arguments: {'userId': pesanan.userId},
          );
        } else {
          // Tampilkan pesan error jika userId null
          Get.snackbar(
            'Error',
            'ID Pengguna tidak tersedia',
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
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
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
}
