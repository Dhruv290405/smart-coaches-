import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/core/network/api_exception.dart';
import 'package:smart_coach_new/core/utils/prefs.dart';

import 'api_constants.dart';

@lazySingleton
class ApiClient {
  final Prefs prefs;

  ApiClient(this.prefs);

  static const String baseUrl = ApiConstants.devUrl;

  Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (includeAuth) {
      final token = prefs.token;
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParams, String? baseOverride]) {
    final base = baseOverride ?? baseUrl;
    return Uri.parse('$base$endpoint').replace(
      queryParameters: queryParams?.map((k, v) => MapEntry(k, v.toString())),
    );
  }

  Future<dynamic> get(String endpoint,
      {Map<String, dynamic>? queryParams,
      bool includeAuthHeaders = true,
      String? baseUrlOverride}) async {
    final uri = _buildUri(endpoint, queryParams, baseUrlOverride);
    final response = await http.get(uri,
        headers: await _getHeaders(includeAuth: includeAuthHeaders));
    return _processResponse(response);
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data,
      {bool includeAuthHeaders = true, String? baseUrlOverride}) async {
    final base = baseUrlOverride ?? baseUrl;
    final uri = Uri.parse('$base$endpoint');
    final response = await http.post(uri,
        headers: await _getHeaders(includeAuth: includeAuthHeaders),
        body: jsonEncode(data));
    return _processResponse(response);
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> data,
      {Map<String, dynamic>? queryParams,
      bool includeAuthHeaders = true}) async {
    final uri = _buildUri(endpoint, queryParams);
    final response = await http.put(uri,
        headers: await _getHeaders(includeAuth: includeAuthHeaders),
        body: jsonEncode(data));
    return _processResponse(response);
  }

  Future<dynamic> delete(String endpoint,
      {Map<String, dynamic>? queryParams,
      bool includeAuthHeaders = true}) async {
    final uri = _buildUri(endpoint, queryParams);
    final response = await http.delete(uri,
        headers: await _getHeaders(includeAuth: includeAuthHeaders));
    return _processResponse(response);
  }

  dynamic _processResponse(http.Response response) {
    final decoded = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    } else {
      if (decoded['errors'] != null) {
        final errors = (decoded['errors'] as List)
            .map((e) => e['msg'].toString())
            .toList();
        throw MultiFieldsValidationException(errors);
      } else {
        throw ApiException(decoded['message'] ?? 'Something went wrong');
      }
    }
  }
}
