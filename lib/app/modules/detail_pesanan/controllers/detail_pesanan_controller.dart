import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '/app/data/Produk.dart';

class DetailPesananController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observables for customer data
  var alamat = ''.obs;
  var ongkir = 0.obs;

  // Observable list for productsH
  var produkList = <Produk>[].obs;
  RxList<Produk> selectedProducts = <Produk>[].obs;
  RxList<Produk> allProducts = <Produk>[].obs;

  // Kuantitas produk
  RxMap<String, int> productQuantities = <String, int>{}.obs;

  // Payment details
  var subtotalProduk = 0.obs;
  var total = 0.obs;

  var isLoading = false.obs; // Indikator loading
  var selectedProduct = Rxn<Produk>();

  // Initialize data
  @override
  void onInit() {
    super.onInit();
    fetchCustomerData();
    fetchProdukData();
    fetchAllProducts();
  }

  // Fetch customer data based on the logged-in user's email
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

        // Handle berbagai tipe data
        alamat.value = data['alamat'] ?? '';

        // Konversi ongkir ke int
        ongkir.value = (data['ongkir'] ?? 0).toInt();

        _updateTotal();
      }
    } catch (e) {
      print('Error fetching customer data: $e');
    }
  }

  // Fetch product data from the 'Produk' collection
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

  // ---
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

      // Ambil data produk dari koleksi 'Produk' di Firestore
      DocumentSnapshot productSnapshot =
          await _firestore.collection('Produk').doc(productId).get();

      if (productSnapshot.exists) {
        // Parse data produk
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
        Get.snackbar('Error', 'Produk tidak ditemukan di database.');
      }
    } catch (e) {
      print('Error loading product details: $e');
      Get.snackbar('Error', 'Gagal memuat data produk.');
    } finally {
      isLoading.value = false;
    }
  }

  // Metode untuk menambah kuantitas produk
  void tambahKuantitas(Produk product) {
    // Cek apakah produk adalah produk utama
    bool isProdukUtama = selectedProduct.value?.id == product.id;

    // Cek stok sebelum menambah kuantitas
    int currentQuantity = productQuantities[product.id] ?? 0;
    if (currentQuantity + 1 > product.stok) {
      Get.snackbar('Stok Terbatas', 'Stok ${product.nama} tidak mencukupi');
      return;
    }

    // Jika produk utama, naikkan kuantitas
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

  void tambahProduk(Produk product) {
    // Cek apakah produk adalah produk utama
    bool isProdukUtama = selectedProduct.value?.id == product.id;

    // Cek apakah produk sudah ada di selectedProducts
    bool isProdukTambahan = selectedProducts.any((p) => p.id == product.id);

    // Cek stok sebelum menambah
    int currentQuantity = productQuantities[product.id] ?? 0;
    if (currentQuantity + 1 > product.stok) {
      Get.snackbar('Stok Terbatas', 'Stok ${product.nama} tidak mencukupi');
      return;
    }

    if (isProdukUtama || isProdukTambahan) {
      // Jika produk sudah ada, naikkan kuantitasnya
      tambahKuantitas(product);
    } else {
      // Jika produk belum ada sama sekali, tambahkan ke selectedProducts
      selectedProducts.add(product);
      // Set default kuantitas
      productQuantities[product.id] = 1;
      _updateTotal();
    }
  }

  // Metode untuk mengurangi kuantitas produk
  void kurangiKuantitas(Produk product) {
    // Cek apakah produk adalah produk utama
    bool isProdukUtama = selectedProduct.value?.id == product.id;

    if (productQuantities.containsKey(product.id)) {
      if ((productQuantities[product.id] ?? 0) > 1) {
        // Kurangi kuantitas
        productQuantities[product.id] =
            (productQuantities[product.id] ?? 0) - 1;
      } else {
        // Jika kuantitas 1, hapus produk
        productQuantities.remove(product.id);

        if (isProdukUtama) {
          // Untuk produk utama, tidak bisa dihapus sepenuhnya
          productQuantities[product.id] = 1;
        } else {
          // Untuk produk tambahan, hapus dari daftar
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

  // Update total dengan perhitungan detail
  void _updateTotal() {
    // Hitung subtotal untuk semua produk (produk utama + produk tambahan)
    double subtotalKeseluruhan = 0;

    if (selectedProduct.value != null) {
      // Gunakan kuantitas dari productQuantities jika ada, jika tidak gunakan 1
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

    // Set subtotal produk
    subtotalProduk.value = subtotalKeseluruhan.toInt();

    int totalKeseluruhan = subtotalKeseluruhan.toInt() + ongkir.value;

    // Update total
    total.value = totalKeseluruhan;
  }

  // Save order to the 'Pesanan' collection in Firebase
  Future<void> buatPesanan() async {
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
        // produkUtamaData['kuantitas'] = 1; // Default kuantitas 1
        // Gunakan kuantitas aktual dari productQuantities
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

      // Update stok produk
      await _kurangiStokProduk(semuaProduk);

      print('Pesanan berhasil disimpan dengan ID: ${pesananRef.id}');

      // Reset data setelah pesanan dibuat
      _resetPesanan();

      Get.snackbar('Sukses', 'Pesanan berhasil dibuat');
      // Reset data tambahan
      resetTambahItem();
    } catch (e) {
      print('Error saving order: $e');
      Get.snackbar('Error', 'Gagal membuat pesanan');
    }
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

      // Hanya bisa membatalkan pesanan dengan status tertentu
      if (status == 'Menunggu Konfirmasi') {
        await _firestore.collection('Pesanan').doc(pesananId).update({
          'status': 'Dibatalkan',
          'tanggalPembatalan': FieldValue.serverTimestamp()
        });

        // Kembalikan stok produk
        await _kembalikanStokProduk(pesananDoc);

        return true;
      } else {
        Get.snackbar('Gagal', 'Pesanan tidak dapat dibatalkan');
        return false;
      }
    } catch (e) {
      print('Error membatalkan pesanan: $e');
      Get.snackbar('Error', 'Gagal membatalkan pesanan');
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
        Get.snackbar('Stok Habis',
            'Stok ${selectedProduct.value!.nama} tidak mencukupi. Tersedia: ${selectedProduct.value!.stok}');
        return false;
      }
    }

    // Cek stok produk tambahan
    for (var product in selectedProducts) {
      int kuantitas = productQuantities[product.id] ?? 1;
      if (product.stok < kuantitas) {
        Get.snackbar('Stok Terbatas',
            'Stok ${product.nama} tidak mencukupi. Tersedia: ${product.stok}');
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

// Override method dispose untuk membersihkan data
  @override
  void onClose() {
    // Reset semua data tambahan saat controller ditutup
    resetTambahItem();
    super.onClose();
  }
}
