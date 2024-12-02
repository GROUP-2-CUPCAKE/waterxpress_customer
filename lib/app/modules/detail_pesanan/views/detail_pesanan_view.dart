import 'package:flutter/material.dart';

final List<Map<String, dynamic>> _availableProducts = [
  {
    "title": "Air Mineral Bioglass",
    "price": "Rp10.000",
    "stock": 100,
    "image": "assets/images/image.png",  
  },
  {
    "title": "Air Mineral Hexagonal",
    "price": "Rp5.000",
    "stock": 50,
    "image": "assets/images/image.png",  
  },
];

class DetailPesananView extends StatefulWidget {
  @override
  _DetailPesananViewState createState() => _DetailPesananViewState();
}

class _DetailPesananViewState extends State<DetailPesananView> {
  List<Map<String, dynamic>> _orderItems = [];

  void _addProductToOrder(Map<String, dynamic> product) {
    setState(() {
      _orderItems.add({
        "title": product["title"],
        "price": product["price"],
        "quantity": 1,
        "image": product["image"],
      });
    });
  }

  void _showAvailableProducts() {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Produk yang tersedia",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0288D1),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: _availableProducts.map((product) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  product["image"],
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product["title"],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      product["price"],
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Stok: ${product["stock"]}",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () => _addProductToOrder(product),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0288D1),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  "Tambah",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      );
    },
  );
}

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
              const Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alamat Pengiriman',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'BTN Palupi Permai Blok O5 No 14, Kota Palu, Sulawesi Tengah',
                      ),
                      Divider(thickness: 1, color: Colors.grey),
                      Row(
                        children: [
                          Icon(Icons.info_outline, size: 16, color: Colors.grey),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Biaya pengiriman Rp1,000/km setelah 1 km, berlaku kelipatan',
                              style: TextStyle(color: Colors.grey, fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
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

              // Daftar OrderItemWidget
              Column(
                children: [
                  OrderItemWidget(
                    imageUrl: 'assets/images/image.png',
                    title: 'Air Mineral Bioglass',
                    price: 'Rp10.000',
                    initialQuantity: 1,
                    onAdd: () {},
                    onRemove: () {},
                    onDelete: () {},
                  ),
                  OrderItemWidget(
                    imageUrl: 'assets/images/image.png',
                    title: 'Air Mineral Hexagonal',
                    price: 'Rp5.000',
                    initialQuantity: 1,
                    onAdd: () {},
                    onRemove: () {},
                    onDelete: () {},
                  ),
                  ..._orderItems.map((item) {
                    return OrderItemWidget(
                      imageUrl: item["image"],
                      title: item["title"],
                      price: item["price"],
                      initialQuantity: item["quantity"],
                      onAdd: () {
                        setState(() {
                          item["quantity"]++;
                        });
                      },
                      onRemove: () {
                        setState(() {
                          if (item["quantity"] > 1) {
                            item["quantity"]--;
                          }
                        });
                      },
                      onDelete: () {
                        setState(() {
                          _orderItems.remove(item);
                        });
                      },
                    );
                  }).toList(),
                ],
              ),
              TextButton.icon(
                onPressed: _showAvailableProducts,  
                icon: const Icon(Icons.add, color: Colors.blue),
                label: const Text(
                  'Tambah item',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              const SizedBox(height: 16),

              // Metode Pembayaran
              const Text(
                'Metode pembayaran*',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              const Row(
                children: [
                  Icon(Icons.money, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('COD', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),

              // Rincian Pembayaran
              const Text(
                'Rincian pembayaran',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              const Card(
                color: Color(0xFFF5F5F5),
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      PaymentDetailRow(
                          label: 'Subtotal Produk (3)', value: 'Rp20.000'),
                      PaymentDetailRow(
                          label: 'Subtotal Pengiriman', value: 'Rp4.000'),
                      Divider(color: Colors.black54),
                      PaymentDetailRow(
                          label: 'Total', value: 'Rp24.000', isBold: true),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Bagian Total Pembayaran dan Buat Pesanan
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF40C4FF), Color(0xFF0288D1)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                      'Total Pembayaran',
                            style: TextStyle(fontSize: 14, color: Colors.white70),
                          ),
                          Text(
                      'Rp24.000',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                       ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                        // Aksi buat pesanan
                        },
                        child: const Text(
                    'Buat Pesanan',
                          style: TextStyle(color: Color(0xFF0288D1)),
                        ),
                      ),
                    ],
                  ),
                ),
              )
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
  final int initialQuantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onDelete;

  const OrderItemWidget({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.initialQuantity,
    required this.onAdd,
    required this.onRemove,
    required this.onDelete,
  }) : super(key: key);

  @override
  _OrderItemWidgetState createState() => _OrderItemWidgetState();
}

class _OrderItemWidgetState extends State<OrderItemWidget> {
  late int _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity;
  }

  void _increaseQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decreaseQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                widget.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.price,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround, 
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline,
                  color: Colors.blueGrey, size: 20),
                  onPressed: _decreaseQuantity,
                ),
                Text(
                  _quantity.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline,
                  color: Colors.blueGrey, size: 20),
                  onPressed: _increaseQuantity,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.blue, size: 20),
                  onPressed: widget.onDelete,
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
    Key? key,
    required this.label,
    required this.value,
    this.isBold = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}
