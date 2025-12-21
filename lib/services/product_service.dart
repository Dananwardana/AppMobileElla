import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class ValidationException implements Exception {
  final Map<String, List<String>> errors;
  ValidationException(this.errors);
  @override
  String toString() => errors.values.expand((e) => e).join('\n');
}

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

  /// Create a new product using multipart/form-data.
  static Future<void> createProduct(
    Map<String, dynamic> fields, {
    XFile? image,
  }) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('User not authenticated.');
    }

    final uri = Uri.parse('$baseUrl/admin/products');
    final request = http.MultipartRequest('POST', uri);

    // Stop redirects to prevent token drop on 302 responses
    request.followRedirects = false;

    request.headers.addAll(_authHeaders(token));
    request.headers['Accept'] = 'application/json';

    // Parse fields and specs
    fields.forEach((key, value) {
      if (value == null) return;
      if (key == 'specs' && value is List) {
        for (var i = 0; i < value.length; i++) {
          final item = value[i];
          if (item is Map) {
            item.forEach((k, v) {
              request.fields['specs[$i][$k]'] = v?.toString() ?? '';
            });
          }
        }
      } else if (value is bool) {
        request.fields[key] = value ? '1' : '0';
      } else if (value is Map || value is List) {
        request.fields[key] = jsonEncode(value);
      } else {
        request.fields[key] = value.toString();
      }
    });

    if (image != null) {
      final bytes = await image.readAsBytes();
      final filename = image.name.isNotEmpty ? image.name : image.path.split(RegExp(r'[\\/]')).last;
      final multipart = http.MultipartFile.fromBytes('image', bytes, filename: filename);
      request.files.add(multipart);
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    // Accept 200, 201 (Created), or 302 (Found/Redirect success)
    if ((response.statusCode >= 200 && response.statusCode < 300) || response.statusCode == 302) {
      return;
    }

    final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;

    // Handle Validation Errors (422) - throw ValidationException with field map
    if (response.statusCode == 422 && body is Map<String, dynamic>) {
      final Map<String, List<String>> errorsMap = {};
      if (body['errors'] is Map<String, dynamic>) {
        (body['errors'] as Map<String, dynamic>).forEach((k, v) {
          if (v is List) {
            errorsMap[k] = v.map((e) => e.toString()).toList();
          } else {
            errorsMap[k] = [v.toString()];
          }
        });
      } else if (body['message'] is String) {
        errorsMap['message'] = [body['message'] as String];
      }
      throw ValidationException(errorsMap);
    }

    throw Exception('Failed to create product: ${response.statusCode}');
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

  /// Update a product using multipart/form-data.
  ///
  /// Sends a POST with `_method=PUT` (Laravel-style) and includes any provided
  /// fields. If `image` is supplied it will be attached as a file under the
  /// `image` field. `fields` may contain primitives, Maps, or Lists. If
  /// `fields['specs']` is a `List<Map>` it will be sent as indexed
  /// `specs[0][key]`/`specs[0][value]` form fields to match common backend
  /// expectations. Otherwise Maps/Lists are JSON-encoded.
/// Update a product using multipart/form-data with Method Spoofing.
  ///
  /// We ALWAYS use POST with `_method=PUT` because PHP/Laravel cannot parse
  /// multipart/form-data on a native PUT request.
  static Future<Map<String, dynamic>> updateProduct(
    int id,
    Map<String, dynamic> fields, {
    XFile? image,
  }) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('User not authenticated. Please login again.');
    }

    final uri = Uri.parse('$baseUrl/admin/products/$id');

    final request = http.MultipartRequest('POST', uri);

    // --- CRITICAL FIX: STOP REDIRECTS ---
    // This prevents the app from following a redirect (which drops the token)
    // and correctly accepts the initial response from the server.
    request.followRedirects = false; 
    
    request.headers.addAll(_authHeaders(token));
    request.headers['Accept'] = 'application/json';
    request.fields['_method'] = 'PUT';

    // ... (Loop through fields and add them as before) ...
    fields.forEach((key, value) {
      if (value == null) return;
      if (key == 'specs' && value is List) {
        for (var i = 0; i < value.length; i++) {
          final item = value[i];
          if (item is Map) {
            item.forEach((k, v) {
              request.fields['specs[$i][$k]'] = v?.toString() ?? '';
            });
          } else {
            request.fields['specs[$i]'] = item.toString();
          }
        }
      } else if (value is bool) {
        request.fields[key] = value ? '1' : '0'; 
      } else if (value is Map || value is List) {
        request.fields[key] = jsonEncode(value);
      } else {
        request.fields[key] = value.toString();
      }
    });

    if (image != null) {
      final bytes = await image.readAsBytes();
      final filename = image.name.isNotEmpty ? image.name : image.path.split(RegExp(r'[\\/]')).last;
      final multipart = http.MultipartFile.fromBytes('image', bytes, filename: filename);
      request.files.add(multipart);
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    // --- CRITICAL FIX: ACCEPT 302 REDIRECT AS SUCCESS ---
    // If the server redirects (302), it means the operation succeeded.
    if (response.statusCode >= 200 && response.statusCode < 300 || response.statusCode == 302) {
      // If it's a redirect, we might not get a body, so we return an empty success map.
      if (response.statusCode == 302) return {'status': 'success'};

      final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;
      if (body is Map<String, dynamic>) {
        if (body['data'] is Map<String, dynamic>) {
          return Map<String, dynamic>.from(body['data']);
        }
        return Map<String, dynamic>.from(body);
      }
      return {};
    }
    
    // ... (Rest of error handling remains the same) ...
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;
    
    if (response.statusCode == 422 && body is Map<String, dynamic>) {
      final Map<String, List<String>> errorsMap = {};
      if (body['errors'] is Map<String, dynamic>) {
        (body['errors'] as Map<String, dynamic>).forEach((k, v) {
          if (v is List) {
            errorsMap[k] = v.map((e) => e.toString()).toList();
          } else {
            errorsMap[k] = [v.toString()];
          }
        });
      } else if (body['message'] is String) {
        errorsMap['message'] = [body['message'] as String];
      }
      throw ValidationException(errorsMap);
    }

    final message = body is Map<String, dynamic> && body['message'] is String
        ? body['message'] as String
        : 'Failed to update product (code ${response.statusCode})';
    throw Exception(message);
  }

  // 1. Fetch Categories
  static Future<List<Map<String, dynamic>>> getCategories() async {
    final token = await _getToken();
    if (token == null) return [];
    
    // Using your existing endpoint
    final response = await http.get(
      Uri.parse('$baseUrl/admin/categories'), 
      headers: _authHeaders(token),
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return [];
  }

  // 2. Fetch All Subcategories
  static Future<List<Map<String, dynamic>>> getSubcategories() async {
    final token = await _getToken();
    if (token == null) return [];

    // Using your existing endpoint
    final response = await http.get(
      Uri.parse('$baseUrl/admin/subcategories'),
      headers: _authHeaders(token),
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return [];
  }
}
