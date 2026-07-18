import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:smart_coach_new/core/network/api_cache.dart';
import 'package:smart_coach_new/core/network/api_exception.dart';

Future<T> safeRequest<T>(
  Future<T> Function() request, {
  String? cacheKey,
  Duration? cacheTtl,
  T Function()? fallback,
}) async {
  try {
    if (cacheKey != null) {
      final cache = GetIt.I<ApiCache>();
      final cached = cache.get(cacheKey);
      if (cached != null) {
        return cached as T;
      }
    }

    final result = await request();

    if (cacheKey != null) {
      final cache = GetIt.I<ApiCache>();
      cache.set(cacheKey, result, ttl: cacheTtl);
    }

    return result;
  } on DioException catch (e) {
    final data = e.response?.data;
    final statusCode = e.response?.statusCode;

    if (e.type == DioExceptionType.connectionError) {
      final msg = e.message ?? '';
      if (msg.contains('Host lookup') || msg.contains('Failed host')) {
        throw ApiException('Unable to reach server. Check your internet or switch to WiFi.\n(DNS: $msg)');
      }
      if (msg.contains('Connection refused') || msg.contains('No route')) {
        throw ApiException('Server is unreachable. Check your connection and try again.');
      }

      if (fallback != null) return fallback();
      throw ApiException('Network error. Check your internet connection.\n($msg)');
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      if (fallback != null) return fallback();
      throw ApiException('Request timed out. The server may be slow or unreachable on your network.');
    }

    if (data is Map && data['errors'] != null) {
      final errors = (data['errors'] as List).map((e) => e['msg'].toString()).toList();
      throw MultiFieldsValidationException(errors);
    }

    if (data is Map && data['message'] != null) {
      throw ApiException('[${statusCode ?? "?"}] ${data['message']}');
    }

    final debugMsg = '[${statusCode ?? e.type.name}] ${e.message ?? data?.toString() ?? "No response"}';
    throw ApiException(debugMsg);
  } on SocketException catch (e) {
    if (fallback != null) return fallback();
    throw ApiException('No internet connection. Check your network and try again.\n(${e.message})');
  } on HttpException catch (e) {
    throw ApiException('HTTP error: ${e.message}');
  } catch (e, stack) {
    throw ApiException('Unexpected error: $e');
  }
}
