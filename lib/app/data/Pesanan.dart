import 'package:cloud_firestore/cloud_firestore.dart';

class Pesanan {
  String? id;
  String? alamat;
  String? email;
  int? ongkir;
  List<dynamic>? produk;
  int? subtotalProduk;
  Timestamp? tanggalPesanan;
  int? total;
  String? userId;
  String? status;

  Pesanan({
    this.id,
    this.alamat,
    this.email,
    this.ongkir,
    this.produk,
    this.subtotalProduk,
    this.tanggalPesanan,
    this.total,
    this.userId,
    this.status,
  });

  // Konstruktor dari JSON
  factory Pesanan.fromJson(Map<String, dynamic> json, {String? documentId}) {
    return Pesanan(
      id: documentId ?? json['id'],
      alamat: json['alamat'],
      email: json['email'],
      ongkir: _parseIntSafely(json['ongkir']),
      produk: json['produk'],
      subtotalProduk: _parseIntSafely(json['subtotalProduk']),
      tanggalPesanan: json['tanggalPesanan'],
      total: _parseIntSafely(json['total']),
      userId: json['userId'],
      status: json['status'],
    );
  }

  // Metode pembantu untuk parsing integer dengan aman
  static int? _parseIntSafely(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  // Metode untuk konversi ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'alamat': alamat,
      'email': email,
      'ongkir': ongkir,
      'produk': produk,
      'subtotalProduk': subtotalProduk,
      'tanggalPesanan': tanggalPesanan,
      'total': total,
      'userId': userId,
      'status': status,
    };
  }

  // Metode untuk mendapatkan nama produk pertama
  String getProdukNama() {
    if (produk != null && produk!.isNotEmpty) {
      return produk![0]['nama'] ?? 'Produk Tidak Diketahui';
    }
    return 'Produk Tidak Diketahui';
  }

  // Metode untuk mendapatkan gambar produk pertama
  String getProdukImage() {
    if (produk != null && produk!.isNotEmpty) {
      return produk![0]['images'] ?? '';
    }
    return '';
  }

  // Metode untuk mendapatkan status produk pertama
  String getProdukStatus() {
    if (produk != null && produk!.isNotEmpty) {
      return produk![0]['status'] ?? 'Diproses';
    }
    return 'Diproses';
  }
}
