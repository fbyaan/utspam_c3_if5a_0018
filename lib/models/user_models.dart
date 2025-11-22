class User {
  final String fullName;
  final String nik;
  final String email;
  final String phone;
  final String address;
  final String username;
  final String password;

  User({
    required this.fullName,
    required this.nik,
    required this.email,
    required this.phone,
    required this.address,
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'nik': nik,
      'email': email,
      'phone': phone,
      'address': address,
      'username': username,
      'password': password,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      fullName: map['fullName'],
      nik: map['nik'],
      email: map['email'],
      phone: map['phone'],
      address: map['address'],
      username: map['username'],
      password: map['password'],
    );
  }
}