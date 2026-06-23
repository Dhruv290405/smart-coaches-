import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_coach_new/core/network/api_exception.dart';
import 'package:smart_coach_new/core/network/rest_client.dart';
import 'package:smart_coach_new/core/utils/prefs.dart';

@module
abstract class RegisterModule {
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  // @lazySingleton
  // Dio get dio => provideDio(prefs);

  @lazySingleton
  Dio provideDio(Prefs prefs) {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
        followRedirects: true,
        maxRedirects: 5,
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(onRequest: (options, handler) async {
        log("🚀 [REQUEST] ${options.method} => ${options.uri}");
        if (options.data != null) {
          try {
            const encoder = JsonEncoder.withIndent('  ');
            log("📦 [PAYLOAD]\n${encoder.convert(options.data)}");
          } catch (_) {
            log("📦 [PAYLOAD] ${options.data}");
          }
        }

        options.headers["Content-Type"] = "application/json";
        options.headers["Accept"] = "application/json";
        options.headers["Connection"] = "keep-alive";
        options.headers["x-clientId"] = "E9B636CB-4F5D-470F-8DFF-025858E3F4EE";

        final requiresAuth = options.extra['requiresAuth'] ?? true;
        if (requiresAuth) {
          final token = prefs.token;
          if (token != null && token.isNotEmpty) {
            options.headers["Authorization"] = "Bearer $token";
          }
        }

        handler.next(options);
      }, onError: (DioException e, handler) {
        log('❌ [ERROR] ${e.response?.statusCode} => ${e.requestOptions.uri}');
        log('📄 [BODY] ${e.response?.data}');
        final data = e.response?.data;
        if (data is Map && data.containsKey('errors')) {
          final errors =
          (data['errors'] as List).map((e) => e['msg'].toString()).toList();
          handler.reject(
            DioException(
              requestOptions: e.requestOptions,
              type: DioExceptionType.badResponse,
              response: e.response,
              error: MultiFieldsValidationException(errors),
            ),
          );
        } else {
          handler.reject(
            DioException(
              requestOptions: e.requestOptions,
              type: DioExceptionType.badResponse,
              response: e.response,
              error: ApiException(data?['message'] ?? 'Something went wrong'),
            ),
          );
        }
      }, onResponse: (Response response, ResponseInterceptorHandler handler) {
        log("✅ [RESPONSE] ${response.statusCode} <= ${response.requestOptions.uri}");
        try {
          const encoder = JsonEncoder.withIndent('  ');
          log("✨ [DATA]\n${encoder.convert(response.data)}");
        } catch (_) {
          log("✨ [DATA] ${response.data}");
        }
        handler.next(response);
      }),
    );

    return dio;
  }

  @lazySingleton
  RestClient provideRestClient(Dio dio) => RestClient(dio);
}