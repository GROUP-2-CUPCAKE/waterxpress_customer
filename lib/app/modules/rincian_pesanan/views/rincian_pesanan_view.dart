import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/app/routes/app_pages.dart'; // Pastikan import routes
import '../controllers/rincian_pesanan_controller.dart';

class RincianPesananView extends StatelessWidget {
  RincianPesananView({Key? key}) : super(key: key);

  final RincianPesananController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    // Ambil pesananId dari argumen
    final String? pesananId = Get.arguments?['pesananId'];

    // Panggil method untuk mengambil detail pesanan
    if (pesananId != null) {
      controller.fetchPesananDetail(pesananId);
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0288D1), Color(0xFF81D4FA)],
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
              'Detail Pemesanan',
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
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Alamat Pengiriman',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 5),
            Text(controller.alamat.value),
            const SizedBox(height: 5),
            Text(
              'Biaya Ongkir: Rp${controller.ongkir.value.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Daftar Produk
  Widget _buildProdukList(RincianPesananController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
          child: Text(
            'Daftar Produk',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        ...controller.produkList
            .map((produk) => Card(
                  elevation: 2,
                  margin:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 5),
                  child: ListTile(
                    leading: produk['images'] != null
                        ? Image.network(
                            produk['images'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.image, size: 50);
                            },
                          )
                        : const Icon(Icons.image, size: 50),
                    title: Text(produk['nama'] ?? 'Nama Produk Tidak Tersedia'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Harga: Rp${(produk['harga'] ?? 0).toStringAsFixed(0)}'),
                        Text('Kuantitas: ${produk['jumlah'] ?? 1}'),
                      ],
                    ),
                    // trailing: Text(
                    //   'Rp${((produk['harga'] ?? 0) * (produk['jumlah'] ?? 1)).toStringAsFixed(0)}',
                    //   style: const TextStyle(fontWeight: FontWeight.bold),
                    // ),
                  ),
                ))
            .toList(),
      ],
    );
  }

  // Widget Metode Pembayaran
  Widget _buildMetodePembayaranCard() {
    return const Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Metode Pembayaran',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.money, color: Colors.blue, size: 24),
                SizedBox(width: 8),
                Text(
                  'COD (Cash On Delivery)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget Rincian Pembayaran
  Widget _buildRincianPembayaranCard(RincianPesananController controller) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rincian Pembayaran',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            _buildPaymentRow(
              'Subtotal Produk',
              'Rp${controller.subtotalProduk.value.toStringAsFixed(0)}',
            ),
                        _buildPaymentRow(
                'Biaya Pengiriman', 'Rp${controller.ongkir.value.toStringAsFixed(0)}'),
            const Divider(),
            _buildPaymentRow('Total', 'Rp${controller.total.value.toStringAsFixed(0)}',
                isBold: true),
          ],
        ),
      ),
    );
  }

  // Lanjutan metode _buildPaymentRow
  Widget _buildPaymentRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
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

  // Widget Bottom Navigation Bar
  Widget _buildBottomNavigationBar(RincianPesananController controller) {
    return BottomAppBar(
      color: const Color.fromARGB(255, 237, 246, 255),
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Tombol Batalkan Pesanan
            Obx(() {
              // Sembunyikan tombol batalkan jika pesanan sudah selesai atau dibatalkan
              if (controller.pesanan.value?.status?.toLowerCase() == 'selesai' ||
                  controller.pesanan.value?.status?.toLowerCase() == 'dikirim' ||
                  controller.pesanan.value?.status?.toLowerCase() == 'dikemas') {
                return const SizedBox.shrink();
              }

              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () {
                  // Tampilkan konfirmasi pembatalan
                  _showBatalkanPesananDialog(controller);
                },
                child: const Text(
                  'Batalkan Pesanan',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }),

            // Tombol Lacak Pesanan
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0288D1),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () {
                final pesananId = controller.pesanan.value?.id;
                if (pesananId != null) {
                  print('ID Pesanan: $pesananId');
                  Get.toNamed(
                    Routes.LACAK, 
                    arguments: {'pesananId': pesananId}
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
              child: const Text(
                'Lacak Pesanan',
                style: TextStyle(color: Colors.white),
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
        content: const Text('Apakah Anda yakin ingin membatalkan pesanan ini? '
            'Pesanan yang sudah dibatalkan tidak dapat dikembalikan.'),
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
      barrierDismissible:
          false, // Tidak bisa ditutup dengan mengetuk di luar dialog
    );
  }
}

// Extension untuk membantu pemformatan
extension FormatExtension on num {
  String toRupiah() {
    return 'Rp${toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}';
  }
}

// Tambahan styling dan utilitas
class RincianPesananStyles {
  static const TextStyle titleStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 14,
    color: Colors.grey,
  );

  static BoxDecoration gradientDecoration = BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFF0288D1), Color(0xFF81D4FA)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );
}