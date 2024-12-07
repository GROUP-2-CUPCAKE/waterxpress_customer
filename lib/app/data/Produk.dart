class Produk {
  String id;
  final String nama;
  final int harga;
  final int stok;
  final String images;
  // int jumlah; // Jumlah item (default: 1)

  Produk({
    this.id = "",
    required this.nama,
    required this.harga,
    required this.stok,
    required this.images,
    // this.jumlah = 1,
  });

  factory Produk.fromJson(Map<String, dynamic> json) {
    return Produk(
      id: json['id'] as String,
      nama: json['nama'] as String,
      harga: json['harga'] as int,
      stok: json['stok'] as int,
      images: json['images'] as String,
      // jumlah: json['jumlah'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'harga': harga,
      'stok': stok,
      'images': images,
      // 'jumlah': jumlah,
    };
  }
}
