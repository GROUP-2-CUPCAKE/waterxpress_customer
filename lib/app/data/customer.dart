// class customer {
//   String id;
//   final String username;
//   final int nohp;
//   final String email;
//   final String alamat;
//   final String shippingCost;

//   customer({
//     this.id = "",
//     required this.username,
//     required this.nohp,
//     required this.email,
//     required this.alamat,
//     required this.shippingCost,
//   });

//   factory customer.fromJson(Map<String, dynamic> json) {
//     return customer(
//       id: json['id'] as String,
//       username: json['username'] as String,
//       nohp: json['nohp'] as int,
//       email: json['email'] as String,
//       alamat: json['alamat'] as String,
//       shippingCost: json['ongkir'] as String,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'username': username,
//       'nohp': nohp,
//       'email': email,
//       'alamat': alamat,
//       'ongkir': shippingCost,
//     };
//   }
// }
class customer {
  String id;
  final String username;
  final int nohp;
  final String email;
  final String alamat;
  final double ongkir;

  customer({
    this.id = "",
    required this.username,
    required this.nohp,
    required this.email,
    required this.alamat,
    required this.ongkir,
  });

  factory customer.fromJson(Map<String, dynamic> json) {
    return customer(
      id: json['id'] as String,
      username: json['username'] as String,
      nohp: json['nohp'] as int,
      email: json['email'] as String,
      alamat: json['alamat'] as String,
      ongkir: json['ongkir'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'nohp': nohp,
      'email': email,
      'alamat': alamat,
      'ongkir': ongkir,
    };
  }
}
