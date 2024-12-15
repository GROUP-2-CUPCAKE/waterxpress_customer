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
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Produk yang Tersedia",
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0288D1),
                  ),
                ),
              ),
              Expanded(
                child: Obx(() {
                  final detailController = Get.find<DetailPesananController>();
                  // Gunakan metode baru untuk mendapatkan produk yang tersedia
                  final products = detailController.getAvailableProducts();

                  //produk tersedia kosong
                  if (products.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/image.png',
                            width: 150,
                            height: 150,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Semua produk sudah dipilih',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tidak ada produk tambahan yang tersedia',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 6.0, horizontal: 16),
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
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Gambar produk
                                  Image.network(
                                    product.images,
                                    width: 30,
                                    height: 70,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.nama,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text('Rp${product.harga}'),
                                        const SizedBox(height: 4),
                                        Text('Stok: ${product.stok}'),
                                      ],
                                    ),
                                  ),
                                  // Tombol tambah pesanan
                                  ElevatedButton(
                                    onPressed: product.stok > 0
                                        ? () {
                                            detailController
                                                .tambahProduk(product);
                                            Navigator.pop(context);
                                          }
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            product.stok > 0
                                                ? Color(0xFF40C4FF)
                                                : Colors.grey.shade300,
                                            product.stok > 0
                                                ? Color(0xFF0288D1)
                                                : Colors.grey.shade400,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      child: Text(
                                        product.stok > 0
                                            ? 'Tambah Pesanan'
                                            : 'Stok Habis',
                                        style: TextStyle(
                                          color: product.stok > 0
                                              ? Colors.white
                                              : Colors.grey.shade600,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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
    // Tambahkan refresh method
    controller.loadProductDetails(productId);
    controller.fetchAllProducts();
    controller.refreshUserLocation();

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
                // Reset tambah item sebelum kembali
                final controller = Get.find<DetailPesananController>();
                controller.resetTambahItem();
                Get.back();
              },
            ),
            title: const Text(
              'Detail Pesanan',
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            actions: [
              Obx(() => controller.isRefreshingLocation.value
                  ? Container(
                      width: 30,
                      height: 30,
                      padding: const EdgeInsets.only(right: 30),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        // method refresh lokasi
                        controller.refreshUserLocation();
                      },
                    )),
            ],
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
          return const Center(child: Text(''));
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card Alamat Pengiriman
                Padding(
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
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Alamat Pengiriman',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    // Navigasi ke halaman profil untuk mengatur alamat
                                    Get.toNamed('/profil');
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0288D1)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Atur Alamat',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0288D1),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Obx(() {
                              final alamat = controller.alamat.value;
                              final isAlamatValid = alamat.isNotEmpty &&
                                  alamat != 'Alamat belum diatur';

                              return Text(
                                isAlamatValid
                                    ? alamat
                                    : 'Masukkan alamat terlebih dahulu',
                                style: TextStyle(
                                  color: isAlamatValid
                                      ? Colors.black54
                                      : Colors.red,
                                  fontStyle: isAlamatValid
                                      ? FontStyle.normal
                                      : FontStyle.italic,
                                ),
                              );
                            }),
                            if (controller.alamat.value.isNotEmpty &&
                                controller.alamat.value !=
                                    'Alamat belum diatur') ...[
                              const SizedBox(height: 5),
                              Text(
                                'Biaya Ongkir: Rp${controller.ongkir.value}',
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
                                  Icon(Icons.info_outline,
                                      size: 16, color: Colors.grey),
                                  SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Biaya pengiriman Rp1000 setelah 1 km, berlaku kelipatan',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 10),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                //Produk saat ini
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(
                          top: 15, bottom: 5, left: 8, right: 8),
                      child: Text(
                        'Pesanan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    // Product Info
                    Padding(
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
                                      width: 30,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Icon(Icons.image,
                                            size: 50, color: Colors.grey);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Product details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                            color: Colors.black54,
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
                                          icon: const Icon(
                                              Icons.remove_circle_outline),
                                          onPressed: () {
                                            controller
                                                .kurangiKuantitas(product);
                                          },
                                        ),
                                        // Tampilkan kuantitas
                                        Obx(() {
                                          final quantity =
                                              controller.productQuantities[
                                                      product.id] ??
                                                  1;
                                          return Text('$quantity');
                                        }),
                                        // Tombol tambah
                                        IconButton(
                                          icon: const Icon(
                                              Icons.add_circle_outline),
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
                        )),
                    // const SizedBox(height: 2),

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
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom:
                                    controller.selectedProducts.last == product
                                        ? 0
                                        : 6, // Jarak antar card
                              ),
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
                                      color: const Color(0xFF0288D1)
                                          .withOpacity(0.5),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: ListTile(
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          8), // Membulatkan sudut gambar
                                      child: Image.network(
                                        product.images.isNotEmpty
                                            ? product.images
                                            : 'https://via.placeholder.com/50',
                                        width: 30,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
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
                                      'Harga: Rp${product.harga}',
                                      style: const TextStyle(
                                        color: Colors.black54,
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
                                            controller
                                                .kurangiKuantitas(product);
                                          },
                                        ),
                                        // Tampilkan kuantitas
                                        Obx(() {
                                          final quantity =
                                              controller.productQuantities[
                                                      product.id] ??
                                                  1;
                                          return Text(
                                            '$quantity',
                                            style:
                                                const TextStyle(fontSize: 14.0),
                                          );
                                        }),
                                        // Tombol tambah
                                        IconButton(
                                          icon: const Icon(
                                              Icons.add_circle_outline),
                                          onPressed: () {
                                            controller.tambahKuantitas(product);
                                          },
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
                    }),
                  ],
                ),

                //icon tambah produk
                TextButton.icon(
                  onPressed: () => _showProductList(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0)),
                  ),
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: Colors.black87,
                    size: 20,
                  ),
                  label: const Text(
                    'Tambah item',
                    style: TextStyle(
                      color: Colors.black87,
                      // color: Color(0xFF0288D1),
                      fontSize: 15,
                    ),
                  ),
                ),

                // Metode Pembayaran
                const CustomCard(
                  title: 'Metode Pembayaran*',
                  children: [
                    Row(
                      children: [
                        Icon(Icons.money, color: Colors.blue, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'COD (Cash On Delivery)',
                          style: TextStyle(
                            color: Colors.black54,

                            // fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // const SizedBox(height: 14),

                // Rincian Pembayaran
                CustomCard(
                  title: 'Rincian Pembayaran',
                  children: [
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
                        Divider(
                          thickness: 1,
                          color: const Color(0xFF0288D1).withOpacity(0.3),
                        ),
                        PaymentDetailRow(
                          label: 'Total',
                          value: 'Rp${controller.total.value}',
                          isBold: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        color: Colors.blue.withOpacity(0.1),
        child: Container(
          height: 100,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Pembayaran',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  Obx(() => Text(
                        'Rp${controller.total.value}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF0288D1),
                        ),
                      )),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: controller.buatPesanan,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      // colors: [Color(0xFF40C4FF), Color(0xFF0288D1)],
                      colors: [
                        controller.isAlamatValid
                            ? const Color(0xFF40C4FF)
                            : const Color(0xFF40C4FF),
                        controller.isAlamatValid
                            ? const Color(0xFF0288D1)
                            : const Color(0xFF0288D1)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: const Text(
                    'Buat Pesanan',
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

class CustomCard extends StatelessWidget {
  final String title;
  final Color titleColor;
  final List<Widget> children;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;

  const CustomCard({
    Key? key,
    required this.title,
    this.titleColor = Colors.black,
    required this.children,
    this.padding,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius ?? BorderRadius.circular(15),
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
            borderRadius: borderRadius ?? BorderRadius.circular(10),
            side: BorderSide(
              color: const Color(0xFF0288D1).withOpacity(0.5),
              width: 0.5,
            ),
          ),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 5),
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
