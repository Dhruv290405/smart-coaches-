import 'dart:async';
import 'dart:collection';

import 'package:dio/dio.dart';
import 'package:smart_coach_new/core/utils/logger.dart';

class _PendingRequest {
  final Completer<Response> completer;
  _PendingRequest(this.completer);
}

class NetworkOptimizer {
  final Logger _log = Logger('NetworkOptimizer');
  final Dio _dio;

  final HashMap<String, _PendingRequest> _inFlight = HashMap();
  final List<Map<String, dynamic>> _requestQueue = [];
  bool _isProcessingQueue = false;
  bool _connectivityPaused = false;

  static const int _maxRetries = 3;

  NetworkOptimizer(this._dio);

  String _dedupKey(RequestOptions opts) {
    return '${opts.method}:${opts.path}?${opts.queryParameters}';
  }

  Future<Response> execute(RequestOptions opts) async {
    final dedupKey = _dedupKey(opts);

    final existing = _inFlight[dedupKey];
    if (existing != null) {
      _log.debug('Dedup: reusing in-flight for $dedupKey');
      return existing.completer.future;
    }

    final completer = Completer<Response>();
    _inFlight[dedupKey] = _PendingRequest(completer);

    try {
      final response = await _attemptWithRetry(opts);
      completer.complete(response);
      return response;
    } catch (e) {
      completer.completeError(e);
      rethrow;
    } finally {
      _inFlight.remove(dedupKey);
    }
  }

  Future<Response> _attemptWithRetry(RequestOptions opts) async {
    for (int attempt = 0; attempt <= _maxRetries; attempt++) {
      try {
        if (_connectivityPaused) {
          await Future.delayed(const Duration(seconds: 2));
        }

        if (attempt > 0) {
          final delay = Duration(milliseconds: 500 * (1 << attempt));
          _log.debug('Retry $attempt/$_maxRetries after ${delay.inMilliseconds}ms');
          await Future.delayed(delay);
        }

        return await _dio.fetch(opts);
      } on DioException catch (e) {
        if (_isRetryable(e) && attempt < _maxRetries) {
          _log.warn('Retryable error (${e.type}), attempt $attempt');
          continue;
        }
        if (_isConnectionError(e)) {
          _connectivityPaused = true;
          _queueRequest(opts);
        }
        rethrow;
      }
    }

    throw DioException(requestOptions: opts, message: 'Max retries exceeded');
  }

  bool _isRetryable(DioException e) {
    if (e.type == DioExceptionType.badResponse) {
      final code = e.response?.statusCode;
      return code != null && code >= 500;
    }
    return e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout;
  }

  bool _isConnectionError(DioException e) {
    return e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout;
  }

  void _queueRequest(RequestOptions opts) {
    _requestQueue.add({'opts': opts});
    _processQueue();
  }

  Future<void> _processQueue() async {
    if (_isProcessingQueue) return;
    _isProcessingQueue = true;

    try {
      while (_requestQueue.isNotEmpty) {
        await Future.delayed(const Duration(seconds: 3));

        try {
          await _dio.get('/health');
          _connectivityPaused = false;
          _log.info('Online, flushing ${_requestQueue.length} queued requests');

          final batch = List<Map<String, dynamic>>.from(_requestQueue);
          _requestQueue.clear();
          for (final item in batch) {
            _dio.fetch(item['opts'] as RequestOptions).catchError((_) {});
          }
          break;
        } catch (_) {
          _log.warn('Still offline, ${_requestQueue.length} queued');
        }
      }
    } finally {
      _isProcessingQueue = false;
    }
  }
}
