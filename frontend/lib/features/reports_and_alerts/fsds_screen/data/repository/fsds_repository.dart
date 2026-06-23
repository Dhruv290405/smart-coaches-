import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_coach_new/core/network/api_constants.dart';
import '../models/fsds_model.dart';

class FsdsRepository {
  Future<List<FsdsAssetModel>> getFsdsData() async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      return [
        FsdsAssetModel(
          assetId: "7598556",
          assetName: "GS 255386 FSDS 100685",
          timestamp: "2026-04-23T10:18:19.209Z",
          lightValue: 1023,
          smokeLevel: 45,
          sensorId: "FSDS_TEST_001",
          locName: "VASP FSDS Train 8",
          locId: "be3c934f-28ed-4300-b278-aabfa8d1eca6",
        ),
      ];
    } catch (e) {
      throw Exception('Failed to fetch FSDS data: $e');
    }
  }

  Future<void> sendFsdsData(Map<String, dynamic> payload) async {
    final response = await http.post(
      Uri.parse(ApiConstants.fsdsReceiveDataApiEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to send FSDS data');
    }
  }
}
