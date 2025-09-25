import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import '../models/user.dart';

class UserRepository {
  Future<Map<String, dynamic>?> me() async {
    final token = await _getToken();
    if (token == null) return null;

    final res = await http.get(
      Uri.parse('$API_BASE_URL/users/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (res.statusCode == 200) {
      final decoded = json.decode(res.body);
      if (decoded is Map<String, dynamic> && decoded['data'] != null) {
        return decoded['data'] as Map<String, dynamic>; 
      }
    }

    return null;
  }

  Future<bool> updateMe(Map<String, String> payload) async {
    final token = await _getToken();
    final res = await http.put(
      Uri.parse('$API_BASE_URL/users/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    debugPrint('updateMe response: ${res.statusCode} - ${res.body}');

    return res.statusCode == 200 || res.statusCode == 201;
  }

  Future<Map<String, dynamic>> fetchUsers({int page = 1, String? q}) async {
    final token = await _getToken();
    final search = q != null && q.isNotEmpty ? '&q=$q' : '';

    final res = await http.get(
      Uri.parse('$API_BASE_URL/users?page=$page$search'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (res.statusCode == 200) {
      final data = json.decode(res.body);

      final List<UserModel> users =
          (data['data'] as List).map((e) => UserModel.fromJson(e)).toList();

      final meta = data['meta'] ?? {};
      final int currentPage = meta['current_page'] ?? page;
      final int perPage = meta['per_page'] ?? users.length;
      final int total = meta['total'] ?? users.length;

      return {
        'users': users,
        'currentPage': currentPage,
        'perPage': perPage,
        'total': total,
      };
    } else {
      throw Exception('Failed to fetch users: ${res.body}');
    }
  }

  Future<UserModel?> fetchUserDetail(int id) async {
    final token = await _getToken();
    if (token == null) return null;

    final url = Uri.parse('$API_BASE_URL/users/$id');
    final res = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    if (res.statusCode == 200) {
      final decoded = json.decode(res.body);
      if (decoded is Map<String, dynamic> && decoded['data'] != null) {
        final userData = decoded['data'] as Map<String, dynamic>;
        return UserModel.fromJson(userData);
      }
    } else {
      debugPrint('fetchUserDetail failed: status ${res.statusCode}');
    }
    return null;
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
