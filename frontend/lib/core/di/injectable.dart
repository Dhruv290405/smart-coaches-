import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/dio.dart' show InterceptorsWrapper, DioException, Response;
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_coach_new/core/network/api_cache.dart';
import 'package:smart_coach_new/core/network/api_constants.dart';
import 'package:smart_coach_new/core/network/api_exception.dart';
import 'package:smart_coach_new/core/network/network_optimizer.dart';
import 'package:smart_coach_new/core/network/rest_client.dart';
import 'package:smart_coach_new/core/utils/logger.dart';
import 'package:smart_coach_new/core/utils/prefs.dart';

String _apiHost = '';
String _resolvedIp = '';
final Logger _log = Logger('DioSetup');

Future<String> _resolveHostname(String host) async {
  final resolvers = [
    _resolveSystemDns,
    _resolveCloudflareDoh,
    _resolveGoogleDoh,
    _resolveQuad9Doh,
  ];

  for (final resolver in resolvers) {
    try {
      final ip = await resolver(host);
      if (ip != null && ip.isNotEmpty) {
        _log.info('DNS resolved $host -> $ip via ${resolver.toString().split('.').last}');
        return ip;
      }
    } catch (_) {}
  }

  _log.warn('All DNS resolvers failed for $host, falling back to hostname');
  return host;
}

Future<String?> _resolveSystemDns(String host) async {
  final results = await InternetAddress.lookup(host);
  if (results.isNotEmpty) return host;
  return null;
}

Future<String?> _resolveCloudflareDoh(String host) async {
  final response = await http.get(
    Uri.parse('https://1.1.1.1/dns-query?name=$host&type=A'),
    headers: {'accept': 'application/dns-json'},
  );
  if (response.statusCode != 200) return null;
  final data = json.decode(response.body) as Map;
  final answers = data['Answer'] as List? ?? [];
  for (final a in answers) {
    if ((a as Map)['type'] == 1) return a['data'] as String;
  }
  return null;
}

Future<String?> _resolveGoogleDoh(String host) async {
  final response = await http.get(
    Uri.parse('https://dns.google/resolve?name=$host&type=A'),
  );
  if (response.statusCode != 200) return null;
  final data = json.decode(response.body) as Map;
  final answers = data['Answer'] as List? ?? [];
  for (final a in answers) {
    if ((a as Map)['type'] == 1) return a['data'] as String;
  }
  return null;
}

Future<String?> _resolveQuad9Doh(String host) async {
  final response = await http.get(
    Uri.parse('https://dns.quad9.net/dns-query?name=$host&type=A'),
    headers: {'accept': 'application/dns-json'},
  );
  if (response.statusCode != 200) return null;
  final data = json.decode(response.body) as Map;
  final answers = data['Answer'] as List? ?? [];
  for (final a in answers) {
    if ((a as Map)['type'] == 1) return a['data'] as String;
  }
  return null;
}

@module
abstract class RegisterModule {
  @preResolve
  Future<SharedPreferences> get prefs {
    _resolveHostname(Uri.parse(ApiConstants.devUrl).host).then((ip) {
      _resolvedIp = ip;
    });
    return SharedPreferences.getInstance();
  }

  @lazySingleton
  ApiCache get apiCache => ApiCache();

  @lazySingleton
  Dio provideDio(Prefs prefs) {
    _apiHost = Uri.parse(ApiConstants.devUrl).host;

    String baseUrl = ApiConstants.devUrl;
    final headers = <String, dynamic>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Connection': 'keep-alive',
      'Accept-Encoding': 'gzip',
      'x-clientId': 'E9B636CB-4F5D-470F-8DFF-025858E3F4EE',
    };

    if (_resolvedIp.isNotEmpty && _resolvedIp != _apiHost) {
      baseUrl = ApiConstants.devUrl.replaceFirst(_apiHost, _resolvedIp);
      headers['Host'] = _apiHost;
    }

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: headers,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        followRedirects: true,
        maxRedirects: 3,
        validateStatus: (status) => status != null && status < 500,
        contentType: 'application/json',
        responseType: ResponseType.json,
      ),
    );

    bool _dnsChecked = false;

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (!_dnsChecked) {
            _dnsChecked = true;
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

          final requiresAuth = options.extra['requiresAuth'] ?? true;
          if (requiresAuth) {
            final token = prefs.token;
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }

          handler.next(options);
        },
        onError: (e, handler) async {
          final retryable = [
            DioExceptionType.connectionTimeout,
            DioExceptionType.sendTimeout,
            DioExceptionType.receiveTimeout,
            DioExceptionType.connectionError,
          ].contains(e.type) ||
              (e.type == DioExceptionType.badResponse &&
                  e.response?.statusCode != null &&
                  e.response!.statusCode! >= 500);

          if (retryable) {
            final retryCount = e.requestOptions.extra['_retryCount'] as int? ?? 0;
            if (retryCount < 2) {
              e.requestOptions.extra['_retryCount'] = retryCount + 1;
              final delay = Duration(milliseconds: 500 * (1 << (retryCount + 1)));
              await Future.delayed(delay);

              try {
                final clone = Dio(
                  BaseOptions(
                    baseUrl: e.requestOptions.baseUrl,
                    headers: e.requestOptions.headers,
                    connectTimeout: const Duration(seconds: 30),
                    receiveTimeout: const Duration(seconds: 30),
                    sendTimeout: const Duration(seconds: 30),
                    followRedirects: true,
                    maxRedirects: 3,
                    validateStatus: (status) => status != null && status < 500,
                  ),
                );
                final response = await clone.fetch(e.requestOptions);
                return handler.resolve(response);
              } catch (_) {
                return handler.next(e);
              }
            }
          }

          final data = e.response?.data;
          if (data is Map && data.containsKey('errors')) {
            final errors = (data['errors'] as List).map((e) => e['msg'].toString()).toList();
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
        },
        onResponse: (Response response, ResponseInterceptorHandler handler) {
          handler.next(response);
        },
      ),
    );

    return dio;
  }

  @lazySingleton
  NetworkOptimizer provideNetworkOptimizer(Dio dio) => NetworkOptimizer(dio);

  @lazySingleton
  RestClient provideRestClient(Dio dio) => RestClient(dio, baseUrl: ApiConstants.devUrl);
}
