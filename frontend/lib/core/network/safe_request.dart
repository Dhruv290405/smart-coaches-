import 'package:dio/dio.dart';
import 'package:smart_coach_new/core/network/api_exception.dart';

Future<T> safeRequest<T>(Future<T> Function() request) async {
  try {
    return await request();
  } on DioException catch (e) {
    final data = e.response?.data;
    final statusCode = e.response?.statusCode;

    print('❌ DIO ERROR: type=${e.type}, status=$statusCode, data=$data, msg=${e.message}');

    if (data is Map && data['errors'] != null) {
      final errors =
          (data['errors'] as List).map((e) => e['msg'].toString()).toList();
      throw MultiFieldsValidationException(errors);
    }

    if (data is Map && data['message'] != null) {
      throw ApiException('[${statusCode ?? "?"}] ${data['message']}');
    }

    // Show real technical details so user can screenshot and share
    final debugMsg = '[${statusCode ?? e.type.name}] ${e.message ?? data?.toString() ?? "No response"}';
    throw ApiException(debugMsg);
  } catch (e, stack) {
    print('❌ SAFE_REQUEST REAL ERROR: $e');
    print('❌ SAFE_REQUEST REAL STACK: $stack');
    throw ApiException('Unexpected error: $e');
  }
}
