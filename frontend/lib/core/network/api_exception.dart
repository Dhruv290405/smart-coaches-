import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String? message;

  ApiException(this.message);

  @override
  String toString() => message ?? '';
}

class MultiFieldsValidationException implements Exception {
  final List<String> errors;

  MultiFieldsValidationException(this.errors);
}

class SimpleDioException extends DioException {
  final String readableMessage;

  SimpleDioException({
    required super.requestOptions,
    required this.readableMessage,
    super.response,
    super.type = DioExceptionType.badResponse,
  });

  @override
  String toString() => readableMessage;
}