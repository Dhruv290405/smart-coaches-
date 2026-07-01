import 'dart:developer';
import 'package:smart_coach_new/core/network/api_client.dart';
import 'package:smart_coach_new/core/network/api_constants.dart';
import '../models/fsds_model.dart';

class FsdsRepository {
  final ApiClient apiClient;

  FsdsRepository(this.apiClient);

  Future<List<FsdsBypassModel>> getFsdsData({String? trainNo, String? locName, int limit = 100}) async {
    try {
      final params = <String, dynamic>{
        'limit': limit.toString(),
        'offset': '0',
      };
      if (trainNo != null && trainNo.isNotEmpty) params['trainNo'] = trainNo;
      if (locName != null && locName.isNotEmpty) params['locName'] = locName;

      final response = await apiClient.get(
        ApiConstants.fsdsGetDataApiEndpoint,
        queryParams: params,
        baseUrlOverride: ApiConstants.fsdsBaseUrl,
      );

      if (response['success'] == true && response['data'] is List) {
        return (response['data'] as List).map((e) => FsdsBypassModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      log('FSDS get-data: unexpected response format: $response');
      return [];
    } catch (e) {
      log('FSDS get-data error: $e');
      return [];
    }
  }

  Future<void> sendFsdsData(Map<String, dynamic> payload) async {
    await apiClient.post(ApiConstants.fsdsReceiveDataApiEndpoint, payload);
  }
}
