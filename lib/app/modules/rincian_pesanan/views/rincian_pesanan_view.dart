import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../lacak_pesanan/views/lacak_pesanan_view.dart';
import '../controllers/rincian_pesanan_controller.dart';

class RincianPesananView extends StatelessWidget {
  // final String pesananId;

  // const RincianlPesananView({super.key, required this.pesananId});
  // RincianPesananView({Key? key, required this.pesananId}) : super(key: key);
  final RincianPesananController controller =
      Get.put(RincianPesananController());

  @override
  Widget build(BuildContext context) {
    // final RincianPesananController controller = Get.find();
    // Inisialisasi controller dengan pesananId
    final RincianPesananController controller =
        Get.put(RincianPesananController(), permanent: true);

    // Panggil method fetch pesanan dengan pesananId yang diterima
    // controller.fetchPesananDetail(pesananId);

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
          return const Center(child: Text('Pesanan tidak ditemukan.'));
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
              'Biaya Ongkir: ${(controller.ongkir.value)}',
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
                        Text('Harga: ${(produk['harga'] ?? 0)}'),
                        Text('kuantitas: ${produk['kuantitas'] ?? 1}'),
                      ],
                    ),
                    trailing: Text(
                      // ((produk['harga'] ?? 0) * (produk['kuantitas'] ?? 1)),
                      'Rp${((produk['harga'] ?? 0) * (produk['jumlah'] ?? 1))}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
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
              'Rp${controller.subtotalProduk.value}',
            ),
            _buildPaymentRow(
                'Biaya Pengiriman', 'Rp${(controller.ongkir.value)}'),
            const Divider(),
            _buildPaymentRow('Total', 'Rp${(controller.total.value)}',
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
            ElevatedButton(
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
            ),

            // Tombol Lacak Pesanan
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0288D1),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              // onPressed: controller.lacakPesanan,
              onPressed: () {
                // Pastikan ID pesanan tersedia sebelum navigasi
                if (controller.pesanan.value?.id != null) {
                  Get.to(
                    () => LacakPesananView(),
                    arguments: {'pesananId': controller.pesanan.value!.id},
                  );
                } else {
                  // Tampilkan pesan jika ID tidak tersedia
                  Get.snackbar(
                    'Error',
                    'ID Pesanan tidak ditemukan',
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
              Get.back(); // Tutup dialog
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
