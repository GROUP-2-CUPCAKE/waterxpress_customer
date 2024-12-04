import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/detail_pesanan_controller.dart';
// import 'produk.dart';

class DetailPesananView extends StatelessWidget {
  final DetailPesananController controller = Get.put(DetailPesananController());

  @override
  Widget build(BuildContext context) {
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
                Navigator.pop(context);
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Alamat Pengiriman
              Obx(() => Card(
                    elevation: 4,
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
                  )),
              const SizedBox(height: 16),

              // Pesanan
              const Text(
                'Pesanan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Obx(() {
                if (controller.produkList.isEmpty) {
                  return const Text('Tidak ada produk tersedia.');
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.produkList.length,
                  itemBuilder: (context, index) {
                    final produk = controller.produkList[index];
                    return OrderItemWidget(
                      imageUrl: produk.images,
                      title: produk.nama,
                      price: 'Rp${produk.harga}',
                    );
                  },
                );
              }),
              const SizedBox(height: 16),

              // Rincian Pembayaran
              const Text(
                'Rincian Pembayaran',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      PaymentDetailRow(
                          label: 'Subtotal produk',
                          value: 'Rp${controller.subtotalProduk.value}'),
                      PaymentDetailRow(
                          label: 'Subtotal Pengiriman',
                          value: 'Rp${controller.ongkir.value}'),
                      const Divider(),
                      PaymentDetailRow(
                          label: 'Total',
                          value: 'Rp${controller.total.value}',
                          isBold: true),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
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
                            fontWeight: FontWeight.bold, fontSize: 18),
                      )),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: controller.buatPesanan,
                child: const Text('Buat Pesanan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderItemWidget extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String price;

  const OrderItemWidget({
    required this.imageUrl,
    required this.title,
    required this.price,
  });

  @override
  _OrderItemWidgetState createState() => _OrderItemWidgetState();
}

class _OrderItemWidgetState extends State<OrderItemWidget> {
  int quantity = 1;

  void _increaseQuantity() {
    setState(() {
      quantity++;
    });
  }

  void _decreaseQuantity() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(widget.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(widget.price,
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: _decreaseQuantity,
                ),
                Text(quantity.toString()),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: _increaseQuantity,
                ),
              ],
            ),
          ],
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
    required this.label,
    required this.value,
    this.isBold = false,
  });

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
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
          ),
          Text(
            value,
            style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
          ),
        ],
      ),
    );
  }
}
