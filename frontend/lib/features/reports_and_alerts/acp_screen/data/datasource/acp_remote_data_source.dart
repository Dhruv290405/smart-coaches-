import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/core/network/rest_client.dart';
import 'package:smart_coach_new/core/network/safe_request.dart';
import 'package:smart_coach_new/features/reports_and_alerts/acp_screen/data/models/acp_filters_response.dart';
import 'package:smart_coach_new/features/reports_and_alerts/acp_screen/data/models/acp_log_response.dart';
import 'package:smart_coach_new/features/reports_and_alerts/acp_screen/data/models/acp_coach_history_response.dart';

abstract class AcpRemoteDataSource {
  Future<AcpLogResponse> getAcpLogs();
  Future<AcpLogResponse> getAcpSummary();

  Future<AcpFiltersResponse> getAcpFilters({
    String? trainNo,
    String? coachType,
  });

  Future<AcpLogResponse> getAcpFilteredLogs({
    String? trainNo,
    String? techCoachNo,
  });

  Future<AcpCoachHistoryResponse> getAcpCoachHistory({
    required String coachId,
    String? fromDate,
    String? toDate,
  });
}

@Injectable(as: AcpRemoteDataSource)
class AcpRemoteDataSourceImpl implements AcpRemoteDataSource {
  final RestClient restClient;

  AcpRemoteDataSourceImpl(this.restClient);

  @override
  Future<AcpLogResponse> getAcpLogs() async {
    return safeRequest(() async {
      return await restClient.getAcpLogs();
    });
  }

  @override
  Future<AcpLogResponse> getAcpSummary() async {
    return safeRequest(() async {
      return await restClient.getAcpSummary();
    });
  }

  @override
  Future<AcpFiltersResponse> getAcpFilters({
    String? trainNo,
    String? coachType,
  }) async {
    return safeRequest(() async {
      return await restClient.getAcpFilters(trainNo, coachType);
    });
  }

  @override
  Future<AcpLogResponse> getAcpFilteredLogs({
    String? trainNo,
    String? techCoachNo,
  }) async {
    return safeRequest(() async {
      return await restClient.getAcpFilteredLogs(trainNo, techCoachNo);
    });
  }

  @override
  Future<AcpCoachHistoryResponse> getAcpCoachHistory({
    required String coachId,
    String? fromDate,
    String? toDate,
  }) async {
    return safeRequest(() async {
      return await restClient.getAcpCoachHistory(coachId, fromDate, toDate);
    });
  }
}
