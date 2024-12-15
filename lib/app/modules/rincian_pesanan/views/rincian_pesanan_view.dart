import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../detail_pesanan/views/detail_pesanan_view.dart';
import '/app/routes/app_pages.dart';
import '../controllers/rincian_pesanan_controller.dart';

class RincianPesananView extends StatelessWidget {
  RincianPesananView({Key? key}) : super(key: key);

  final RincianPesananController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    final String? pesananId = Get.arguments?['pesananId'];

    if (pesananId != null && pesananId.isNotEmpty) {
      controller.fetchPesananDetail(pesananId);
    } else {
      Get.snackbar(
        'Error',
        'Pesanan ID tidak valid',
        margin: const EdgeInsets.all(12),
        backgroundColor: Colors.white,
        colorText: const Color(0xFFFF5252),
      );
      return Container();
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF40C4FF), Color(0xFF0288D1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Get.back();
              },
            ),
            title: const Text(
              'Rincian Pesanan',
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final pesanan = controller.pesanan.value;

        if (pesanan == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Pesanan tidak ditemukan.'),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Kembali'),
                )
              ],
            ),
          );
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Alamat Pengiriman
                _buildAlamatPengirimanCard(controller),
                const SizedBox(height: 5),

                // Daftar Produk
                _buildProdukList(controller),
                const SizedBox(height: 5),

                // Metode Pembayaran
                _buildMetodePembayaranCard(),
                const SizedBox(height: 5),

                // Rincian Pembayaran
                _buildRincianPembayaranCard(controller),
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: _buildBottomNavigationBar(controller),
    );
  }

  // Widget Alamat Pengiriman
  Widget _buildAlamatPengirimanCard(RincianPesananController controller) {
    return CustomCard(
      title: 'Alamat Pengiriman',
      children: [
        Text(
          controller.alamat.value,
          style: const TextStyle(
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Biaya Ongkir: Rp${controller.ongkir.value.toStringAsFixed(0)}',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Divider(
          thickness: 1,
          color: const Color(0xFF0288D1).withOpacity(0.3),
        ),
        const Row(
          children: [
            Icon(Icons.info_outline, size: 16, color: Colors.grey),
            SizedBox(width: 4),
            Expanded(
              child: Text(
                'Biaya pengiriman Rp1000 setelah 1 km, berlaku kelipatan',
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Widget Daftar Produk
  Widget _buildProdukList(RincianPesananController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 10, bottom: 5, left: 8, right: 8),
          child: Text(
            'Daftar Produk',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        ...controller.produkList.map((produk) {
          return Padding(
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
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: const Color(0xFF0288D1).withOpacity(0.5),
                    width: 0.5,
                  ),
                ),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Image section
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: produk['images'] != null
                            ? Image.network(
                                produk['images'],
                                width: 40,
                                height: 70,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.image,
                                      size: 50, color: Colors.grey);
                                },
                              )
                            : const Icon(Icons.image,
                                size: 50, color: Colors.grey),
                      ),
                      const SizedBox(width: 12),
                      // Product details
                      Expanded(
                        // Expanded langsung di dalam Row
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              produk['nama'] ?? 'Nama Produk Tidak Tersedia',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Harga: Rp${(produk['harga'] ?? 0).toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Jumlah produk: ${produk['kuantitas']}',
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  // Widget Metode Pembayaran
  Widget _buildMetodePembayaranCard() {
    return const CustomCard(
      title: 'Metode Pembayaran*',
      children: [
        Row(
          children: [
            Icon(Icons.money, color: Colors.blue, size: 24),
            SizedBox(width: 8),
            Text(
              'COD (Cash On Delivery)',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ],
    );
  }

// Widget Rincian Pembayaran
  Widget _buildRincianPembayaranCard(RincianPesananController controller) {
    return CustomCard(
      title: 'Rincian Pembayaran',
      children: [
        _buildPaymentRow(
          'Subtotal Produk',
          'Rp${controller.subtotalProduk.value.toStringAsFixed(0)}',
        ),
        _buildPaymentRow(
          'Biaya Pengiriman',
          'Rp${controller.ongkir.value.toStringAsFixed(0)}',
        ),
        Divider(
          thickness: 1,
          color: const Color(0xFF0288D1).withOpacity(0.3),
        ),
        _buildPaymentRow(
          'Total',
          'Rp${controller.total.value.toStringAsFixed(0)}',
          isBold: true,
        ),
      ],
    );
  }

  // Metode _buildPaymentRow dimodifikasi untuk lebih sesuai
  Widget _buildPaymentRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
              color: isBold ? const Color(0xFF0288D1) : Colors.black,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
              color: isBold ? Colors.blue : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // Widget Bottom Navigation Bawah
  Widget _buildBottomNavigationBar(RincianPesananController controller) {
    return BottomAppBar(
      elevation: 0,
      color: Colors.blue.withOpacity(0.1),
      child: Container(
        height: 100,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Tombol Batalkan Pesanan
            Obx(() {
              if (controller.pesanan.value?.status?.toLowerCase() == 'selesai' ||
                  controller.pesanan.value?.status?.toLowerCase() ==
                      'dikirim' ||
                  controller.pesanan.value?.status?.toLowerCase() ==
                      'dikemas') {
                return const SizedBox.shrink();
              }

              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  // Tampilkan konfirmasi pembatalan
                  _showBatalkanPesananDialog(controller);
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.redAccent, Colors.red],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: const Text(
                    'Batalkan Pesanan',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }),

            // Tombol Lacak Pesanan
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () {
                final pesananId = controller.pesanan.value?.id;
                if (pesananId != null) {
                  print('ID Pesanan: $pesananId');
                  Get.toNamed(Routes.LACAK,
                      arguments: {'pesananId': pesananId});
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
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF40C4FF), Color(0xFF0288D1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                child: const Text(
                  'Lacak Pesanan',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog Konfirmasi Pembatalan Pesanan
  void _showBatalkanPesananDialog(RincianPesananController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Batalkan Pesanan'),
        content: const Text('Kamu yakin ingin membatalkan pesanan ini? '
            'Pesanan yang sudah dibatalkan tidak dapat dikembalikan yaa.'),
        actions: [
          // Tombol Batal
          TextButton(
            onPressed: () => Get.back(), // Tutup dialog
            child: const Text('Tidak', style: TextStyle(color: Colors.grey)),
          ),

          // Tombol Konfirmasi
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              // Panggil metode pembatalan pesanan
              controller.batalkanPesanan();
              Get.back();
              Get.back();
            },
            child: const Text('Ya, Batalkan',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
