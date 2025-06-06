class User {
  final String username;
  final String password;
  final String name;
  final String phone;
  final String role;
  double balance;

  User({
    required this.username,
    required this.password,
    required this.name,
    required this.phone,
    required this.role,
    this.balance = 0,
  });

  factory User.fromString(String data) {
    final parts = data.split('|');
    return User(
      username: parts[0],
      password: parts[1],
      name: parts[2],
      phone: parts[3],
      role: parts[4],
      balance: parts.length > 5 ? double.tryParse(parts[5]) ?? 0 : 0,
    );
  }

  String toStorageString() {
    return [username, password, name, phone, role, balance.toString()].join('|');
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? '',
      balance: (map['balance'] is int)
          ? (map['balance'] as int).toDouble()
          : (map['balance'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
      'name': name,
      'phone': phone,
      'role': role,
      'balance': balance,
    };
  }
}
