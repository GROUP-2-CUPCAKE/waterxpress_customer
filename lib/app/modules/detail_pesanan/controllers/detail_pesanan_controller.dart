import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/app/data/Produk.dart';
import 'package:waterxpress_customer/app/routes/app_pages.dart';

class DetailPesananController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var alamat = ''.obs;
  var ongkir = 0.obs;
  var produkList = <Produk>[].obs;
  RxList<Produk> selectedProducts = <Produk>[].obs;
  RxList<Produk> allProducts = <Produk>[].obs;

  // Kuantitas produk
  RxMap<String, int> productQuantities = <String, int>{}.obs;

  // Payment details
  var subtotalProduk = 0.obs;
  var total = 0.obs;

  var isLoading = false.obs;
  var selectedProduct = Rxn<Produk>();

  // Initialize data
  @override
  void onInit() {
    super.onInit();
    fetchCustomerData();
    fetchProdukData();
    fetchAllProducts();
  }

  // Tambahkan getter untuk validasi alamat
  bool get isAlamatValid {
    return alamat.value.isNotEmpty && alamat.value != 'Alamat belum diatur';
  }

  // Ganti method buatPesanan() yang sudah ada dengan versi baru
  Future<void> buatPesanan() async {
    // Periksa validitas alamat
    if (!isAlamatValid) {
      _showAlamatDialog();
      return;
    }

    // Lanjutkan proses pembuatan pesanan yang sudah ada
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('User not logged in');
        return;
      }

      // Gabungkan produk utama dan produk tambahan dengan kuantitasnya
      List<dynamic> semuaProduk = [];

      // Tambahkan produk utama
      if (selectedProduct.value != null) {
        var produkUtamaData = selectedProduct.value!.toJson();
        produkUtamaData['kuantitas'] =
            productQuantities[selectedProduct.value!.id] ?? 1;
        semuaProduk.add(produkUtamaData);
      }

      if (!cekKetersediaanStok()) {
        return;
      }

      // Tambahkan produk tambahan dengan kuantitasnya
      selectedProducts.forEach((product) {
        var produkData = product.toJson();
        produkData['kuantitas'] = productQuantities[product.id] ?? 1;
        semuaProduk.add(produkData);
      });

      final orderData = {
        'userId': user.uid,
        'email': user.email,
        'alamat': alamat.value,
        'ongkir': ongkir.value,
        'subtotalProduk': subtotalProduk.value,
        'total': total.value,
        'produk': semuaProduk,
        'tanggalPesanan': FieldValue.serverTimestamp(),
        'status': 'Diproses', // Status default pesanan
      };

      // Simpan pesanan ke Firestore
      DocumentReference pesananRef =
          await _firestore.collection('Pesanan').add(orderData);
      await _kurangiStokProduk(semuaProduk);
      print('Pesanan berhasil disimpan dengan ID: ${pesananRef.id}');
      _resetPesanan();
      Get.snackbar(
        'Sukses',
        'Pesanan berhasil dibuat',
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(12),
        backgroundColor: Colors.white,
        colorText: const Color(0xFF0288D1),
      );
      Get.offNamed(Routes.HOME);
      // Reset data tambahan
      resetTambahItem();
    } catch (e) {
      print('Error saving order: $e');
      Get.snackbar(
        'Error',
        'Gagal membuat pesanan: $e',
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(12),
        backgroundColor: Colors.white,
        colorText: const Color(0xFFFF5252),
      );
    }
  }

  // status refresh
  var isRefreshingLocation = false.obs;

  void refreshUserLocation() async {
    try {
      isRefreshingLocation.value = true;

      // Ambil user saat ini
      final user = FirebaseAuth.instance.currentUser;

      // Cek apakah user ada
      if (user != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('customer')
            .doc(user.uid)
            .get();

        // Update alamat jika dokumen ada
        if (snapshot.exists) {
          alamat.value = snapshot['alamat'] ?? '';
          ongkir.value = (snapshot['ongkir'] as num?)?.toInt() ?? 0;
        }
      }
    } catch (e) {
      print('Gagal refresh alamat: $e');
      Get.snackbar(
        'Error',
        'Gagal memperbarui alamat',
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(12),
        backgroundColor: Colors.white,
        colorText: const Color(0xFFFF5252),
      );
    } finally {
      isRefreshingLocation.value = false;
    }
  }

  // Method untuk menampilkan dialog pesanan gagal
  void _showPesananGagalDialog(String errorMessage) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text(
          'Gagal Membuat Pesanan',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Terjadi kesalahan: $errorMessage',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  // Method untuk menampilkan dialog alamat belum diatur
  void _showAlamatDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text(
          'Alamat Belum Diatur',
          style: TextStyle(
            color: Color(0xFF0288D1),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Silakan mengatur alamat terlebih dahulu sebelum membuat pesanan.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
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
            onPressed: () {
              Get.back(); // Tutup dialog

              // Navigasi ke halaman profil
              Get.toNamed(Routes.PROFIL);
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
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              child: const Text(
                'Atur Alamat',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Ambil data pelanggan berdasarkan email pengguna yang login
  Future<void> fetchCustomerData() async {
    try {
      final email = _auth.currentUser?.email;
      if (email == null) return;

      final snapshot = await _firestore
          .collection('customer')
          .where('email', isEqualTo: email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        alamat.value = data['alamat'] ?? '';
        ongkir.value = (data['ongkir'] ?? 0).toInt();

        _updateTotal();
      }
    } catch (e) {
      print('Error fetching customer data: $e');
    }
  }

  // Ambil data produk dari koleksi 'Produk'
  Future<void> fetchProdukData() async {
    try {
      final snapshot = await _firestore.collection('Produk').get();
      produkList.value = snapshot.docs
          .map((doc) => Produk.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching product data: $e');
    }
  }

  List<Produk> getAvailableProducts() {
    // Filter produk yang belum dipilih
    return allProducts
        .where((product) =>
            product.id != selectedProduct.value?.id &&
            !selectedProducts
                .any((selectedProduct) => selectedProduct.id == product.id))
        .toList();
  }

  Future<void> loadProductDetails(String productId) async {
    try {
      isLoading.value = true;

      // Ambil data produk dari  Firestore
      DocumentSnapshot productSnapshot =
          await _firestore.collection('Produk').doc(productId).get();

      if (productSnapshot.exists) {
        Map<String, dynamic> data =
            productSnapshot.data() as Map<String, dynamic>;
        selectedProduct.value = Produk(
          id: productId,
          nama: data['nama'] ?? 'Produk Tidak Ditemukan',
          harga: data['harga'] ?? 0,
          stok: data['stok'] ?? 0,
          images: data['images'] ?? 'https://via.placeholder.com/150',
        );

        // Tambahkan produk ke daftar produk
        produkList.add(selectedProduct.value!);

        // Inisialisasi kuantitas produk utama
        productQuantities[productId] = 1;
        _updateTotal();
      } else {
        Get.snackbar(
          'Error',
          'Produk tidak ditemukan di database.',
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(12),
          backgroundColor: Colors.white,
          colorText: const Color(0xFFFF5252),
        );
      }
    } catch (e) {
      print('Error loading product details: $e');
      Get.snackbar(
        'Error',
        'Gagal memuat data produk.',
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(12),
        backgroundColor: Colors.white,
        colorText: const Color(0xFFFF5252),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Metode untuk menambah kuantitas produk
  void tambahKuantitas(Produk product) {
    bool isProdukUtama = selectedProduct.value?.id == product.id;

    // Cek stok sebelum menambah kuantitas
    int currentQuantity = productQuantities[product.id] ?? 0;
    if (currentQuantity + 1 > product.stok) {
      Get.snackbar(
        'Stok Terbatas',
        'Stok ${product.nama} tidak mencukupi',
        backgroundColor: Colors.white,
        colorText: const Color(0xFFFF5252),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    // naikkan kuantitas
    if (isProdukUtama) {
      productQuantities[product.id] = (productQuantities[product.id] ?? 0) + 1;
      _updateTotal();
      return;
    }

    // Tambahkan produk tambahan jika belum ada
    if (!selectedProducts.any((p) => p.id == product.id)) {
      selectedProducts.add(product);
    }

    // Update kuantitas produk tambahan
    productQuantities[product.id] = (productQuantities[product.id] ?? 0) + 1;
    _updateTotal();
  }

  // tambah produk
  void tambahProduk(Produk product) {
    bool isProdukUtama = selectedProduct.value?.id == product.id;
    bool isProdukTambahan = selectedProducts.any((p) => p.id == product.id);
    int currentQuantity = productQuantities[product.id] ?? 0;
    if (currentQuantity + 1 > product.stok) {
      Get.snackbar(
        'Stok Terbatas',
        'Stok ${product.nama} tidak mencukupi',
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(12),
        backgroundColor: Colors.white,
        colorText: const Color(0xFFFF5252),
      );
      return;
    }

    if (isProdukUtama || isProdukTambahan) {
      tambahKuantitas(product);
    } else {
      selectedProducts.add(product);
      productQuantities[product.id] = 1;
      _updateTotal();
    }
  }

  // kurang kuantitas
  void kurangiKuantitas(Produk product) {
    bool isProdukUtama = selectedProduct.value?.id == product.id;
    if (productQuantities.containsKey(product.id)) {
      if ((productQuantities[product.id] ?? 0) > 1) {
        productQuantities[product.id] =
            (productQuantities[product.id] ?? 0) - 1;
      } else {
        productQuantities.remove(product.id);
        if (isProdukUtama) {
          productQuantities[product.id] = 1;
        } else {
          selectedProducts.removeWhere((p) => p.id == product.id);
        }
      }

      _updateTotal();
    }
  }

  // Metode untuk menghapus produk
  void hapusProduk(Produk product) {
    selectedProducts.removeWhere((p) => p.id == product.id);
    productQuantities.remove(product.id);
    _updateTotal();
  }

  // Fetch semua produk untuk bottom sheet
  Future<void> fetchAllProducts() async {
    try {
      final snapshot = await _firestore.collection('Produk').get();
      allProducts.value = snapshot.docs
          .map((doc) => Produk.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching all products: $e');
    }
  }

  // Update total
  void _updateTotal() {
    double subtotalKeseluruhan = 0;
    if (selectedProduct.value != null) {
      int kuantitasProdukUtama =
          productQuantities[selectedProduct.value!.id] ?? 1;
      subtotalKeseluruhan +=
          selectedProduct.value!.harga * kuantitasProdukUtama;
    }

    // Tambahkan produk tambahan dengan kuantitasnya
    selectedProducts.forEach((product) {
      int quantity = productQuantities[product.id] ?? 1;
      subtotalKeseluruhan += product.harga * quantity;
    });
    subtotalProduk.value = subtotalKeseluruhan.toInt();
    int totalKeseluruhan = subtotalKeseluruhan.toInt() + ongkir.value;
    total.value = totalKeseluruhan;
  }

  // Metode untuk mengurangi stok produk setelah pesanan
  Future<void> _kurangiStokProduk(List<dynamic> produk) async {
    WriteBatch batch = _firestore.batch();

    for (var item in produk) {
      if (item['id'] != null) {
        DocumentReference produkRef =
            _firestore.collection('Produk').doc(item['id']);
        int kuantitas = item['kuantitas'] ?? 1;
        batch.update(produkRef, {'stok': FieldValue.increment(-kuantitas)});
      }
    }

    await batch.commit();
  }

  // Reset data pesanan setelah berhasil dibuat
  void _resetPesanan() {
    selectedProducts.clear();
    productQuantities.clear();
    selectedProduct.value = null;
    subtotalProduk.value = 0;
    total.value = 0;
  }

  // Metode untuk mendapatkan riwayat pesanan pengguna
  Future<List<Map<String, dynamic>>> getRiwayatPesanan() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      QuerySnapshot pesananSnapshot = await _firestore
          .collection('Pesanan')
          .where('userId', isEqualTo: user.uid)
          .orderBy('tanggalPesanan', descending: true)
          .get();

      return pesananSnapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();
    } catch (e) {
      print('Error mengambil riwayat pesanan: $e');
      return [];
    }
  }

  // Metode untuk membatalkan pesanan yang belum diproses
  Future<bool> batalkanPesanan(String pesananId) async {
    try {
      // Cek status pesanan sebelum membatalkan
      DocumentSnapshot pesananDoc =
          await _firestore.collection('Pesanan').doc(pesananId).get();
      String status = pesananDoc.get('status') ?? '';
      if (status == 'Diproses') {
        await _firestore.collection('Pesanan').doc(pesananId).update({
          'status': 'Dibatalkan',
          'tanggalPembatalan': FieldValue.serverTimestamp()
        });

        // Kembalikan stok produk
        await _kembalikanStokProduk(pesananDoc);

        return true;
      } else {
        Get.snackbar(
          'Gagal',
          'Pesanan tidak dapat dibatalkan',
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(12),
          backgroundColor: Colors.white,
          colorText: const Color(0xFFFF5252),
        );
        return false;
      }
    } catch (e) {
      print('Error membatalkan pesanan: $e');
      Get.snackbar(
        'Error',
        'Gagal membatalkan pesanan',
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(12),
        backgroundColor: Colors.white,
        colorText: const Color(0xFFFF5252),
      );
      return false;
    }
  }

  // Metode untuk mengembalikan stok produk yang dibatalkan
  Future<void> _kembalikanStokProduk(DocumentSnapshot pesananDoc) async {
    WriteBatch batch = _firestore.batch();
    List<dynamic> produk = pesananDoc.get('produk') ?? [];

    for (var item in produk) {
      if (item['id'] != null) {
        DocumentReference produkRef =
            _firestore.collection('Produk').doc(item['id']);
        int kuantitas = item['kuantitas'] ?? 1;
        batch.update(produkRef, {'stok': FieldValue.increment(kuantitas)});
      }
    }

    await batch.commit();
  }

  // Metode untuk mengecek ketersediaan stok sebelum membuat pesanan
  bool cekKetersediaanStok() {
    // Cek stok produk utama
    if (selectedProduct.value != null) {
      int kuantitasProdukUtama =
          productQuantities[selectedProduct.value!.id] ?? 1;
      if (selectedProduct.value!.stok < kuantitasProdukUtama) {
        Get.snackbar(
          'Stok Habis',
          'Stok ${selectedProduct.value!.nama} tidak mencukupi. Tersedia: ${selectedProduct.value!.stok}',
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(12),
          backgroundColor: Colors.white,
          colorText: const Color(0xFFFF5252),
        );
        return false;
      }
    }

    // Cek stok produk tambahan
    for (var product in selectedProducts) {
      int kuantitas = productQuantities[product.id] ?? 1;
      if (product.stok < kuantitas) {
        Get.snackbar(
          'Stok Terbatas',
          'Stok ${product.nama} tidak mencukupi. Tersedia: ${product.stok}',
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(12),
          backgroundColor: Colors.white,
          colorText: const Color(0xFFFF5252),
        );
        return false;
      }
    }
    return true;
  }

  // Method untuk mereset semua data tambahan
  void resetTambahItem() {
    // Hapus semua produk tambahan
    selectedProducts.clear();

    // Reset kuantitas produk tambahan
    productQuantities
        .removeWhere((key, value) => key != selectedProduct.value?.id);

    // Update total
    _updateTotal();
  }

  // Reset semua data tambahan saat controller ditutup
  @override
  void onClose() {
    resetTambahItem();
    super.onClose();
  }
}
