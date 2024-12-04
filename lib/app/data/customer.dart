class customer {
  String id;
  final String username;
  final int nohp;
  final String email;
  final String alamat;

  customer({
    this.id = "",
    required this.username,
    required this.nohp,
    required this.email,
    required this.alamat,
  });

  factory customer.fromJson(Map<String, dynamic> json) {
    return customer(
      id: json['id'] as String,
      username: json['username'] as String,
      nohp: json['nohp'] as int,
      email: json['email'] as String,
      alamat: json['alamat'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'nohp': nohp,
      'email': email,
      'alamat': alamat,
    };
  }
}
