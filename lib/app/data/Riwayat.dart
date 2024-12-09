import 'package:cloud_firestore/cloud_firestore.dart';

class Riwayat {
  String id;
  final String nama;
  final String pesanan;
  final String status;
  final int total_harga;
  final DateTime tanggal; // Ubah ke DateTime

  Riwayat({
    this.id = "",
    required this.nama,
    required this.pesanan,
    required this.status,
    required this.total_harga,
    required this.tanggal,
  });

  factory Riwayat.fromJson(Map<String, dynamic> json) {
    return Riwayat(
      id: (json['id'] ?? "").toString(),
      nama: (json['nama'] ?? "").toString(),
      pesanan: (json['pesanan'] ?? "").toString(),
      status: (json['status'] ?? "").toString(),
      total_harga: json['total_harga'] is int
          ? json['total_harga']
          : int.tryParse(json['total_harga']?.toString() ?? "0") ?? 0,
      tanggal: json['tanggal'] is Timestamp
          ? (json['tanggal'] as Timestamp)
              .toDate() // Konversi Timestamp ke DateTime
          : DateTime.now(), // Fallback ke tanggal sekarang jika null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'pesanan': pesanan,
      'status': status,
      'total_harga': total_harga,
      'tanggal':
          tanggal, // Firestore akan otomatis mengonversi DateTime ke Timestamp
    };
  }
}
