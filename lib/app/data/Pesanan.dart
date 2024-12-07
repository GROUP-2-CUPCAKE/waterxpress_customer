import 'package:cloud_firestore/cloud_firestore.dart';

class Pesanan {
  String id;
  final String alamat;
  final String email;
  final num ongkir;
  final List<ProdukPesanan> produk;
  final String status;
  final Timestamp tanggalPesanan;
  final num total;
  final String userId;

  Pesanan({
    this.id = "",
    required this.alamat,
    required this.email,
    required this.ongkir,
    required this.produk,
    required this.status,
    required this.tanggalPesanan,
    required this.total,
    required this.userId,
  });

  // Factory constructor untuk membuat objek Pesanan dari JSON
  factory Pesanan.fromJson(Map<String, dynamic> json) {
    return Pesanan(
      id: json['id'] as String? ?? '',
      alamat: json['alamat'] as String,
      email: json['email'] as String,
      ongkir: json['ongkir'] as num,
      produk: (json['produk'] as List<dynamic>?)
              ?.map((produkData) => ProdukPesanan.fromJson(produkData))
              .toList() ??
          [],
      status: json['status'] as String,
      tanggalPesanan: json['tanggalPesanan'] as Timestamp,
      total: json['total'] as num,
      userId: json['userId'] as String,
    );
  }

  // Factory constructor untuk membuat objek Pesanan dari Firestore DocumentSnapshot
  factory Pesanan.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id; // Tambahkan ID dari dokumen
    return Pesanan.fromJson(data);
  }

  // Metode untuk mengkonversi objek Pesanan ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'alamat': alamat,
      'email': email,
      'ongkir': ongkir,
      'produk': produk.map((p) => p.toJson()).toList(),
      'status': status,
      'tanggalPesanan': tanggalPesanan,
      'total': total,
      'userId': userId,
    };
  }
}

// Class untuk detail produk dalam pesanan
class ProdukPesanan {
  String id;
  final num harga;
  final String images;
  final num kuantitas;
  final String nama;
  final num stok;
  final num subtotalProduk;

  ProdukPesanan({
    this.id = "",
    required this.harga,
    required this.images,
    required this.kuantitas,
    required this.nama,
    required this.stok,
    required this.subtotalProduk,
  });

  // Factory constructor untuk membuat objek ProdukPesanan dari JSON
  factory ProdukPesanan.fromJson(Map<String, dynamic> json) {
    return ProdukPesanan(
      id: json['id'] as String? ?? '',
      harga: json['harga'] as num,
      images: json['images'] as String,
      kuantitas: json['kuantitas'] as num,
      nama: json['nama'] as String,
      stok: json['stok'] as num,
      subtotalProduk: json['subtotalProduk'] as num,
    );
  }

  // Metode untuk mengkonversi objek ProdukPesanan ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'harga': harga,
      'images': images,
      'kuantitas': kuantitas,
      'nama': nama,
      'stok': stok,
      'subtotalProduk': subtotalProduk,
    };
  }
}
