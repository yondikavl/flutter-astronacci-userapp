import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';

class AuthRepository {
  Future<String?> login(String email, String password) async {
    final res = await http.post(Uri.parse('$API_BASE_URL/auth/login'), body: {
      'email': email,
      'password': password,
    });
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      final token = data['access_token'] ?? data['token'];
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        return token;
      }
    }
    return null;
  }

  Future<bool> register(String name, String email, String password) async {
    final res =
        await http.post(Uri.parse('$API_BASE_URL/auth/register'), body: {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': password,
    });
    return res.statusCode == 201 || res.statusCode == 200;
  }

  Future<bool> forgot(String email) async {
    final res = await http
        .post(Uri.parse('$API_BASE_URL/auth/forgot'), body: {'email': email});
    return res.statusCode == 200 || res.statusCode == 201;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      await http.post(Uri.parse('$API_BASE_URL/auth/logout'), headers: {
        'Authorization': 'Bearer \$token',
      });
    }
    await prefs.remove('token');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
