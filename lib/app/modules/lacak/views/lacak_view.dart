
  import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:progress_tracker/progress_tracker.dart';
import 'package:waterxpress_customer/app/routes/app_pages.dart';
import 'package:waterxpress_customer/app/data/Pesanan.dart';
import '../controllers/lacak_controller.dart';

class LacakView extends StatefulWidget {
  const LacakView({Key? key}) : super(key: key);

  @override
  _LacakViewState createState() => _LacakViewState();
}

// Fungsi helper untuk memformat list produk
String _formatProdukList(List<dynamic>? produk) {
  if (produk == null || produk.isEmpty) {
    return 'Tidak ada produk';
  }

  // Map untuk menyimpan jumlah setiap produk
  Map<String, int> produkCount = {};

  // Hitung jumlah setiap produk
  for (var item in produk) {
    if (item is Map<String, dynamic>) {
      String namaProduk = item['nama'] ?? 'Produk Tidak Dikenal';
      int kuantitas = item['kuantitas'] ?? 0;

      produkCount[namaProduk] = (produkCount[namaProduk] ?? 0) + kuantitas;
    }
  }

  // Buat string dengan format "namaProduk(kuantitas)"
  return produkCount.entries
      .map((entry) => '${entry.value} ${entry.key}')
      .join(', ');
}

class _LacakViewState extends State<LacakView> {
  late Future<Pesanan?> pesananDetail;
  final LacakController controller = Get.find();

  @override
  void initState() {
    super.initState();
    // Ambil orderId dari argumen yang dikirim
    final String orderId = Get.arguments as String;
    pesananDetail = controller.getPesananById(orderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Status Pesanan'),
      automaticallyImplyLeading: true,
      centerTitle: true,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF40C4FF), Color(0xFF0288D1)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return FutureBuilder<Pesanan?>(
      future: pesananDetail,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('Pesanan tidak ditemukan'));
        }

        final pesanan = snapshot.data!;
        return _buildPesananDetail(pesanan);
      },
    );
  }

  Widget _buildPesananDetail(Pesanan pesanan) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Card(
            color: const Color.fromARGB(255, 237, 246, 255),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPesananInfo(pesanan),
                  const Divider(color: Colors.grey, thickness: 1),
                  _buildStatusTracker(),
                  _buildNextButton(pesanan),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPesananInfo(Pesanan pesanan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ID: ${pesanan.id}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Pembeli : ',
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: pesanan.email ?? 'Email tidak tersedia',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Pesanan: ',
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: _formatProdukList(pesanan.produk),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Alamat   : ',
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: pesanan.alamat ?? 'Alamat tidak tersedia',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Ongkir: ',
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: 'Rp${pesanan.ongkir}',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Total   : ',
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: 'Rp${pesanan.total}',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusTracker() {
    return Column(
      children: [
        const Text('KONFIRMASI PEMESANAN',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Obx(
          () => ProgressTracker(
            currentIndex: controller.index.value,
            statusList: controller.statusList,
            activeColor: Colors.green,
            inActiveColor: Colors.grey,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildNextButton(Pesanan pesanan) {
    return SizedBox(
      height: 40,
      width: 100,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF40C4FF), Color(0xFF0288D1)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
          borderRadius: BorderRadius.circular(30),
        ),
        child: Obx(
          () => ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed:
                // Tambahkan null check untuk pesanan.id
                pesanan.id != null &&
                        controller.index.value !=
                            controller.statusList.length - 1
                    ? () {
                        print(pesanan.id);
                        controller.nextButton(pesanan.id!);
                      }
                    : null,
            // onPressed: controller.index.value != controller.statusList.length - 1
            // ? () {
            // print(pesanan.id);
            // controller.nextButton(pesanan.id);
            // controller.updateStatusPesanan(
            // pesanan.id,
            // controller.statusList[controller.index.value].name
            // );
            // }
            // : null,
            child: const Text(
              'Next',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
