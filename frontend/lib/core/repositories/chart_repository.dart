import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:smart_coach_new/core/network/rest_client.dart';
import 'package:smart_coach_new/core/widgets/chart_data_helper.dart';

class ChartRepository {
  static RestClient _client() => RestClient(Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 60),
    sendTimeout: const Duration(seconds: 60),
    followRedirects: true,
    maxRedirects: 5,
    validateStatus: (status) => status != null && status < 500,
  )));

  static Future<List<Map<String, dynamic>>> getAcpData() async {
    final client = _client();
    final response = await client.getAcpLogs();
    final logs = response?.data ?? [];
    return logs.map((log) {
      final timestamp = log.lastHeartbeat != null
          ? DateFormat('yyyy-MM-dd HH:mm:ss').tryParse(log.lastHeartbeat!)
          : null;
      return {
        'timestamp': timestamp ?? DateTime.now(),
        'value': log.todayCount ?? 0,
      };
    }).toList();
  }
}
