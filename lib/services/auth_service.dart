import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
class AuthService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('token', data['token']);
    await prefs.setString('role', data['user']['role']);

    return {
      'success': true,
      'token': data['token'],
      'role': data['user']['role'],
      'user': data['user'],
    };
  }

    return {
      'success': false,
      'message': data['message'] ?? 'Login gagal',
    };
  }
}
