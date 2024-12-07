import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/detail_pesanan_controller.dart';

class DetailPesananView extends StatelessWidget {
  final String productId;

  const DetailPesananView({Key? key, required this.productId})
      : super(key: key);

  void _showProductList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Draggable Icon
              Container(
                width: 50,
                height: 5,
                margin: const EdgeInsets.only(top: 8.0),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 8.0),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Produk yang Tersedia",
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Expanded(
                child: Obx(() {
                  final detailController = Get.find<DetailPesananController>();
                  // Gunakan metode baru untuk mendapatkan produk yang tersedia
                  final products = detailController.getAvailableProducts();

                  if (products.isEmpty) {
                    return Center(
                      child: Text(
                        'Tidak ada produk tambahan yang tersedia',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 14.0, vertical: 8.0),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 237, 246, 255),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Gambar produk
                            Image.network(
                              product.images,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.image,
                                    size: 50, color: Colors.grey);
                              },
                            ),
                            const SizedBox(width: 16),
                            // Informasi produk
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.nama,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('Rp${product.harga},00'),
                                  const SizedBox(height: 4),
                                  Text('Stok: ${product.stok}'),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Tombol tambah pesanan
                            ElevatedButton(
                              onPressed: () {
                                detailController.tambahProduk(product);
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF0288D1),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 8.0,
                                ),
                                textStyle: const TextStyle(fontSize: 12),
                              ),
                              child: const Text(
                                'Tambah Pesanan',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final DetailPesananController controller =
        Get.put(DetailPesananController());
    controller.loadProductDetails(productId);
    controller.fetchAllProducts(); // Fetch all products when view is loaded

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
                // Reset tambah item sebelum kembali
                final controller = Get.find<DetailPesananController>();
                controller.resetTambahItem();
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

        final product = controller.selectedProduct.value;

        if (product == null) {
          return const Center(child: Text('Produk tidak ditemukan.'));
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Alamat Pengiriman
                Card(
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
                          'Biaya Ongkir: Rp${controller.ongkir.value}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'Pesanan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    // Product Info
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Image section
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                product.images,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.image,
                                      size: 50, color: Colors.grey);
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Product details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.nama,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  // const SizedBox(height: 4),
                                  Text(
                                    'Harga: Rp${product.harga}',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Quantity controls
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Tombol kurangi
                                  IconButton(
                                    icon:
                                        const Icon(Icons.remove_circle_outline),
                                    onPressed: () {
                                      controller.kurangiKuantitas(product);
                                    },
                                  ),
                                  // Tampilkan kuantitas
                                  Obx(() {
                                    final quantity = controller
                                            .productQuantities[product.id] ??
                                        1;
                                    return Text('$quantity');
                                  }),
                                  // Tombol tambah
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: () {
                                      controller.tambahKuantitas(product);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),

                    // Daftar Produk Tambahan
                    Obx(() {
                      if (controller.selectedProducts.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Di dalam DetailPesananView, di bagian produk tambahan
                          ...controller.selectedProducts.map((product) {
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 4),
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      8), // Membulatkan sudut gambar
                                  child: Image.network(
                                    product.images.isNotEmpty
                                        ? product.images
                                        : 'https://via.placeholder.com/50',
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.image,
                                          size: 50, color: Colors.grey);
                                    },
                                  ),
                                ),
                                title: Text(
                                  product.nama,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                subtitle: Text(
                                  'Rp${product.harga}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Tombol kurangi
                                    IconButton(
                                      icon: const Icon(
                                          Icons.remove_circle_outline),
                                      onPressed: () {
                                        controller.kurangiKuantitas(product);
                                      },
                                    ),
                                    // Tampilkan kuantitas
                                    Obx(() {
                                      final quantity = controller
                                              .productQuantities[product.id] ??
                                          1;
                                      return Text(
                                        '$quantity',
                                        style: const TextStyle(fontSize: 14.0),
                                      );
                                    }),
                                    // Tombol tambah
                                    IconButton(
                                      icon:
                                          const Icon(Icons.add_circle_outline),
                                      onPressed: () {
                                        controller.tambahKuantitas(product);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      );
                    }),
                  ],
                ),

                //icon tambah produk
                TextButton.icon(
                  onPressed: () => _showProductList(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0)),
                  ),
                  icon: Icon(
                    Icons.add_circle_outline,
                    color: Colors.blue[600],
                    size: 20,
                  ),
                  label: Text(
                    'Tambah item',
                    style: TextStyle(
                      color: Colors.blue[600],
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 3),

                // Metode Pembayaran
                const Card(
                  elevation: 2, // Memberikan bayangan
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Metode Pembayaran*',
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
                              'COD',
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
                ),
                const SizedBox(height: 14),

                // Rincian Pembayaran
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start, // Sesuaikan posisi teks
                      children: [
                        Text(
                          'Rincian Pembayaran',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(
                            height: 9), // Jarak opsional setelah judul
                        Column(
                          children: [
                            PaymentDetailRow(
                              label: 'Subtotal Produk Utama',
                              value: 'Rp${controller.subtotalProduk.value}',
                            ),
                            PaymentDetailRow(
                              label: 'Subtotal Pengiriman',
                              value: 'Rp${controller.ongkir.value}',
                            ),
                            const Divider(),
                            PaymentDetailRow(
                              label: 'Total',
                              value: 'Rp${controller.total.value}',
                              isBold: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: BottomAppBar(
        color: const Color.fromARGB(255, 237, 246, 255),
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Pembayaran',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  Obx(() => Text(
                        'Rp${controller.total.value}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      )),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0288D1),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: controller.buatPesanan,
                child: const Text(
                  'Buat Pesanan',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PaymentDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const PaymentDetailRow({
    Key? key,
    required this.label,
    required this.value,
    this.isBold = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
