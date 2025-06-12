// lib/services/user_repository.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

/// Kullanıcı verilerini belirtilen URL’den çeker ve ayrıştırır.
/// URL dinamik olarak HomeScreen’den gelecek.
class UserRepository {
  Future<List<User>> fetchUsers(String url) async {
    try {
      final uri = Uri.parse(url);
      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        // JSON dönen oturum listesi veya nesne listesi olarak bekleniyor.
        return data.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Sunucu hatası: ${response.statusCode}');
      }
    } on Exception catch (e) {
      // Hata detayını üst katmana iletir.
      throw Exception('Veri alınamadı: $e');
    }
  }
}
