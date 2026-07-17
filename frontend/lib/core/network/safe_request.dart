import 'dart:io';

import 'package:dio/dio.dart';
import 'package:smart_coach_new/core/network/api_exception.dart';

Future<T> safeRequest<T>(Future<T> Function() request) async {
  try {
    return await request();
  } on DioException catch (e) {
    final data = e.response?.data;
    final statusCode = e.response?.statusCode;

    // Network-level errors (no server response)
    if (e.type == DioExceptionType.connectionError) {
      final msg = e.message ?? '';
      if (msg.contains('Host lookup') || msg.contains('Failed host')) {
        throw ApiException('Unable to reach server. Check your internet or switch to WiFi.\n(DNS: $msg)');
      }
      if (msg.contains('Connection refused') || msg.contains('No route')) {
        throw ApiException('Server is unreachable. Check your connection and try again.');
      }
      throw ApiException('Network error. Check your internet connection.\n($msg)');
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      throw ApiException('Request timed out. The server may be slow or unreachable on your network.');
    }

    // Server responded with an error
    if (data is Map && data['errors'] != null) {
      final errors =
          (data['errors'] as List).map((e) => e['msg'].toString()).toList();
      throw MultiFieldsValidationException(errors);
    }

    if (data is Map && data['message'] != null) {
      throw ApiException('[${statusCode ?? "?"}] ${data['message']}');
    }

    final debugMsg = '[${statusCode ?? e.type.name}] ${e.message ?? data?.toString() ?? "No response"}';
    throw ApiException(debugMsg);
  } on SocketException catch (e) {
    throw ApiException('No internet connection. Check your network and try again.\n(${e.message})');
  } on HttpException catch (e) {
    throw ApiException('HTTP error: ${e.message}');
  } catch (e, stack) {
    throw ApiException('Unexpected error: $e');
  }
}
