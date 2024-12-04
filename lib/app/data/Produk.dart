class Produk {
  String id;
  final String nama;
  final int harga;
  final int stok;
  final String images;

  Produk({
    this.id = "",
    required this.nama,
    required this.harga,
    required this.stok,
    required this.images,
  });

  factory Produk.fromJson(Map<String, dynamic> json) {
    return Produk(
      id: json['id'] as String,
      nama: json['nama'] as String,
      harga: json['harga'] as int,
      stok: json['stok'] as int,
      images: json['images'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'harga': harga,
      'stok': stok,
      'images': images,
    };
  }
}
