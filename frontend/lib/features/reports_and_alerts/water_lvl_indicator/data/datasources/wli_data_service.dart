import 'dart:convert';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:smart_coach_new/core/network/api_constants.dart';
import 'package:smart_coach_new/core/utils/prefs.dart';
import '../models/water_tank_model.dart';

class WliDataService {
  final String baseUrl;

  WliDataService({required this.baseUrl});

  Future<List<WaterTankModel>> fetchWliCoaches() async {
    final uri = Uri.parse('$baseUrl${ApiConstants.wliCoachesApiEndpoint}');
    final token = GetIt.I<Prefs>().token;
    final response = await http.get(uri, headers: {
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      if (body['success'] == true && body['data'] != null) {
        final List<dynamic> dataList = body['data'] is List ? body['data'] : [];
        final models = dataList.map((e) => WaterTankModel.fromFlatJson(e as Map<String, dynamic>)).toList();
        return _mergeByDevice(models);
      }
      return [];
    }
    throw Exception('Failed to load WLI data: ${response.statusCode}');
  }

  /// Fetch historical readings for a device within the last [days] days.
  /// Returns rows normalised to `{ timestamp, percentFull, levelCm, volumeLiters, rawValue }`.
  Future<List<Map<String, dynamic>>> fetchHistory({
    required String deviceId,
    String? coachId,
    required int days,
    String? token,
  }) async {
    final query = <String, String>{
      if (deviceId.isNotEmpty) 'deviceId': deviceId,
      if (deviceId.isEmpty && (coachId ?? '').isNotEmpty) 'coachId': coachId!,
      'days': '$days',
    };
    final uri = Uri.parse('$baseUrl${ApiConstants.wliHistoryApiEndpoint}')
        .replace(queryParameters: query);

    final response = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    });

    if (response.statusCode != 200) return [];
    final body = json.decode(response.body);
    if (body['success'] != true || body['data'] is! List) return [];

    return (body['data'] as List).map<Map<String, dynamic>>((raw) {
      final row = raw as Map<String, dynamic>;
      final rawPercent = row['percent_full'] is num
          ? (row['percent_full'] as num).toDouble()
          : double.tryParse(row['percent_full']?.toString() ?? '') ?? 0.0;
      final percentFull = rawPercent <= 1.0 ? rawPercent * 100 : rawPercent;
      final levelCm = row['level_cm'] is num
          ? (row['level_cm'] as num).toDouble()
          : double.tryParse(row['level_cm']?.toString() ?? '') ?? 0.0;
      final volumeLiters = row['volume_liters'] is num
          ? (row['volume_liters'] as num).toDouble()
          : double.tryParse(row['volume_liters']?.toString() ?? '') ?? 0.0;
      final rawValue = row['raw_value'] is num
          ? (row['raw_value'] as num).toInt()
          : int.tryParse(row['raw_value']?.toString() ?? '') ?? 0;

      return <String, dynamic>{
        'timestamp': row['timestamp']?.toString() ?? '',
        'percentFull': percentFull,
        'levelCm': levelCm,
        'volumeLiters': volumeLiters,
        'rawValue': rawValue,
      };
    }).toList();
  }

  /// Groups rows by device_id so overhead coaches with two sensors
  /// (front + rear) become one card with multiple assets.
  List<WaterTankModel> _mergeByDevice(List<WaterTankModel> models) {
    final Map<String, List<WaterTankModel>> grouped = {};
    for (final m in models) {
      grouped.putIfAbsent(m.source.deviceId, () => []).add(m);
    }

    final result = <WaterTankModel>[];
    for (final entry in grouped.entries) {
      final rows = entry.value;
      if (rows.length == 1) {
        result.add(rows.first);
        continue;
      }
      // Merge multiple sensors of the same device into one coach
      final base = rows.first;
      final assets = <WliAsset>[];
      final seen = <String>{};
      String latestTimestamp = base.timestamp;
      for (final row in rows) {
        for (final asset in row.assets) {
          if (seen.add(asset.assetName)) assets.add(asset);
        }
        if (row.timestamp.compareTo(latestTimestamp) > 0) latestTimestamp = row.timestamp;
      }
      result.add(WaterTankModel(
        source: base.source,
        location: base.location,
        messageType: base.messageType,
        timestamp: latestTimestamp,
        placement: base.placement,
        assets: assets,
        coachType: base.coachType,
        trainNo: base.trainNo,
      ));
    }
    return result;
  }
}
