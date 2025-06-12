// lib/models/user.dart

/// Kullanıcı modelini temsil eder.
class User {
  final int id;
  final String name;
  final String email;

  User({
    required this.id,
    required this.name,
    required this.email,
  });

  /// JSON’dan User nesnesi oluşturur.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse('${json['id']}') ?? 0,
      name: json['name']?.toString() ?? 'Unknown',
      email: json['email']?.toString() ?? 'Unknown',
    );
  }
}
