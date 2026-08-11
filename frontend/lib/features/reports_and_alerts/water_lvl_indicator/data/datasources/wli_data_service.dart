import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_coach_new/core/network/api_constants.dart';
import '../models/water_tank_model.dart';

class WliDataService {
  final String baseUrl;

  WliDataService({required this.baseUrl});

  Future<List<WaterTankModel>> fetchWliCoaches() async {
    final uri = Uri.parse('$baseUrl${ApiConstants.wliCoachesApiEndpoint}');
    final response = await http.get(uri);

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
