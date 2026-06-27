import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_coach_new/core/network/api_constants.dart';
import 'package:smart_coach_new/core/network/api_exception.dart';
import 'package:smart_coach_new/core/network/rest_client.dart';
import 'package:smart_coach_new/core/utils/prefs.dart';

String _apiHost = '';
String _resolvedIp = '';

Future<String> _resolveHostname(String host) async {
  // Try system DNS first
  try {
    final results = await InternetAddress.lookup(host);
    if (results.isNotEmpty) return host;
  } catch (_) {
    log('⚠️ System DNS failed for $host, trying DoH...');
  }

  // Fallback: Cloudflare DoH via hardcoded IP (no DNS needed for 1.1.1.1)
  try {
    final response = await http.get(
      Uri.parse('https://1.1.1.1/dns-query?name=$host&type=A'),
      headers: {'accept': 'application/dns-json'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map;
      final answers = data['Answer'] as List? ?? [];
      for (final a in answers) {
        final answer = a as Map;
        if (answer['type'] == 1) {
          final ip = answer['data'] as String;
          log('✅ DoH resolved $host → $ip');
          return ip;
        }
      }
    }
  } catch (e) {
    log('❌ DoH fallback also failed: $e');
  }

  return host;
}

@module
abstract class RegisterModule {
  @preResolve
  Future<SharedPreferences> get prefs {
    _resolveHostname(Uri.parse(ApiConstants.devUrl).host).then((ip) {
      _resolvedIp = ip;
      log('🔍 DNS resolved $ip for ${ApiConstants.devUrl}');
    });
    return SharedPreferences.getInstance();
  }

  @lazySingleton
  Dio provideDio(Prefs prefs) {
    _apiHost = Uri.parse(ApiConstants.devUrl).host;

    String baseUrl = ApiConstants.devUrl;
    final headers = <String, dynamic>{};

    if (_resolvedIp.isNotEmpty && _resolvedIp != _apiHost) {
      baseUrl = ApiConstants.devUrl.replaceFirst(_apiHost, _resolvedIp);
      headers['Host'] = _apiHost;
    }

    headers.addAll({
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Connection': 'keep-alive',
      'x-clientId': 'E9B636CB-4F5D-470F-8DFF-025858E3F4EE',
    });

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: headers,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
        followRedirects: false,
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    // Lazy DNS resolution interceptor (runs once to check if DoH is needed)
    bool _dnsChecked = false;
    dio.interceptors.add(
      InterceptorsWrapper(onRequest: (options, handler) async {
        if (!_dnsChecked) {
          _dnsChecked = true;
          // If DNS wasn't resolved during startup, try now
          if (_resolvedIp.isEmpty) {
            final ip = await _resolveHostname(_apiHost);
            _resolvedIp = ip;
          }
          if (_resolvedIp.isNotEmpty && _resolvedIp != _apiHost) {
            options.baseUrl = options.baseUrl.replaceFirst(_apiHost, _resolvedIp);
          }
        }

        if (_resolvedIp.isNotEmpty && _resolvedIp != _apiHost) {
          options.headers['Host'] = _apiHost;
        }

        log("🚀 [REQUEST] ${options.method} => ${options.uri}");
        if (options.data != null) {
          try {
            const encoder = JsonEncoder.withIndent('  ');
            log("📦 [PAYLOAD]\n${encoder.convert(options.data)}");
          } catch (_) {
            log("📦 [PAYLOAD] ${options.data}");
          }
        }

        final requiresAuth = options.extra['requiresAuth'] ?? true;
        if (requiresAuth) {
          final token = prefs.token;
          if (token != null && token.isNotEmpty) {
            options.headers["Authorization"] = "Bearer $token";
          }
        }

        handler.next(options);
      }, onError: (DioException e, handler) async {
        final retryable = [
          DioExceptionType.connectionTimeout,
          DioExceptionType.sendTimeout,
          DioExceptionType.receiveTimeout,
          DioExceptionType.connectionError,
        ].contains(e.type);

        if (retryable) {
          final retryCount = e.requestOptions.extra['_retryCount'] as int? ?? 0;
          if (retryCount < 2) {
            log('🔁 [RETRY ${retryCount + 1}/3] ${e.requestOptions.uri}');
            e.requestOptions.extra['_retryCount'] = retryCount + 1;
            await Future.delayed(Duration(seconds: retryCount + 1));
            try {
              final clone = Dio(
                BaseOptions(baseUrl: e.requestOptions.baseUrl, headers: e.requestOptions.headers),
              );
              final response = await clone.fetch(e.requestOptions);
              return handler.resolve(response);
            } catch (_) {
              return handler.next(e);
            }
          }
        }

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