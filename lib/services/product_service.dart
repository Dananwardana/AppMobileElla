import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'api_service.dart';

class ValidationException implements Exception {
  final Map<String, List<String>> errors;
  ValidationException(this.errors);
  @override
  String toString() => errors.values.expand((e) => e).join('\n');
}

class ProductService {
  // Delegate base URL and auth/token handling to ApiService

  static Future<List<Map<String, dynamic>>> getAdminProducts() async {
    final token = await ApiService.getToken();
    if (token == null) {
      throw Exception('User not authenticated. Please login again.');
    }

    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/admin/products'),
      headers: ApiService.authHeaders(token),
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
    final token = await ApiService.getToken();
    if (token == null) {
      throw Exception('User not authenticated.');
    }

    final uri = Uri.parse('${ApiService.baseUrl}/admin/products');
    final request = http.MultipartRequest('POST', uri);

    // Stop redirects to prevent token drop on 302 responses
    request.followRedirects = false;

    request.headers.addAll(ApiService.authHeaders(token));
    request.headers['Accept'] = 'application/json';

    _addFieldsToRequest(request, fields);

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

    if (response.statusCode == 422 && body is Map<String, dynamic>) {
      throw ValidationException(_parseValidationErrors(body));
    }

    throw Exception('Failed to create product: ${response.statusCode}');
  }

  static Future<void> deleteProduct(int productId) async {
    final token = await ApiService.getToken();
    if (token == null) {
      throw Exception('User not authenticated. Please login again.');
    }

    final response = await http.delete(
      Uri.parse('${ApiService.baseUrl}/admin/products/$productId'),
      headers: ApiService.authHeaders(token),
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

  /// Update a product using multipart/form-data with Method Spoofing.
  static Future<Map<String, dynamic>> updateProduct(
    int id,
    Map<String, dynamic> fields, {
    XFile? image,
  }) async {
    final token = await ApiService.getToken();
    if (token == null) {
      throw Exception('User not authenticated. Please login again.');
    }

    final uri = Uri.parse('${ApiService.baseUrl}/admin/products/$id');

    final request = http.MultipartRequest('POST', uri);

    // Prevent following redirects (server may respond with 302)
    request.followRedirects = false;
    request.headers.addAll(ApiService.authHeaders(token));
    request.headers['Accept'] = 'application/json';
    request.fields['_method'] = 'PUT';

    _addFieldsToRequest(request, fields);

    if (image != null) {
      final bytes = await image.readAsBytes();
      final filename = image.name.isNotEmpty ? image.name : image.path.split(RegExp(r'[\\/]')).last;
      final multipart = http.MultipartFile.fromBytes('image', bytes, filename: filename);
      request.files.add(multipart);
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if ((response.statusCode >= 200 && response.statusCode < 300) || response.statusCode == 302) {
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
    
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;
    if (response.statusCode == 422 && body is Map<String, dynamic>) {
      throw ValidationException(_parseValidationErrors(body));
    }

    final message = body is Map<String, dynamic> && body['message'] is String
        ? body['message'] as String
        : 'Failed to update product (code ${response.statusCode})';
    throw Exception(message);
  }

  // 1. Fetch Categories
  static Future<List<Map<String, dynamic>>> getCategories() async {
    final token = await ApiService.getToken();
    if (token == null) return [];
    
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/admin/categories'), 
      headers: ApiService.authHeaders(token),
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return [];
  }

  // 2. Fetch All Subcategories
  static Future<List<Map<String, dynamic>>> getSubcategories() async {
    final token = await ApiService.getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/admin/subcategories'),
      headers: ApiService.authHeaders(token),
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return [];
  }

  // Helper: add fields to a MultipartRequest in a consistent way
  static void _addFieldsToRequest(http.MultipartRequest request, Map<String, dynamic> fields) {
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
  }

  // Helper: parse validation error payloads into a Map<String, List<String>>
  static Map<String, List<String>> _parseValidationErrors(Map<String, dynamic> body) {
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
    return errorsMap;
  }
}
