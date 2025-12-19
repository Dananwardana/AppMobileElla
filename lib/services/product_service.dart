import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProductService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Map<String, String> _authHeaders(String token) {
    return {'Accept': 'application/json', 'Authorization': 'Bearer $token'};
  }

  static Future<List<Map<String, dynamic>>> getAdminProducts() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('User not authenticated. Please login again.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/admin/products'),
      headers: _authHeaders(token),
    );

    final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;

    if (response.statusCode == 200) {
      dynamic items;
      if (body is List) {
        items = body;
      } else if (body is Map<String, dynamic>) {
        items = body['data'] ?? body['products'] ?? body['items'];
      }

      if (items is List) {
        return items
            .whereType<Map<String, dynamic>>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }

      return [];
    }

    final message = body is Map<String, dynamic> && body['message'] is String
        ? body['message'] as String
        : 'Failed to load products (code ${response.statusCode})';
    throw Exception(message);
  }

  static Future<void> deleteProduct(int productId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('User not authenticated. Please login again.');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/admin/products/$productId'),
      headers: _authHeaders(token),
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    }

    final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;
    final message = body is Map<String, dynamic> && body['message'] is String
        ? body['message'] as String
        : 'Failed to delete product (code ${response.statusCode})';
    throw Exception(message);
  }
}
