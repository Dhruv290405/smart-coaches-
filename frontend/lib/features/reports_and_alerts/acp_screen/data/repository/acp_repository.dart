import 'package:injectable/injectable.dart';
import 'package:smart_coach_new/features/reports_and_alerts/acp_screen/data/datasource/acp_remote_data_source.dart';
import 'package:smart_coach_new/features/reports_and_alerts/acp_screen/data/models/acp_log_response.dart';
import 'package:smart_coach_new/features/reports_and_alerts/acp_screen/data/models/acp_coach_history_response.dart';
import 'package:smart_coach_new/features/reports_and_alerts/acp_screen/data/models/acp_filters_response.dart';

abstract class AcpRepository {
  Future<List<AcpLogData>> getAcpLogs();
  Future<List<AcpLogData>> getAcpSummary();
  Future<AcpLogResponse> getAcpSummaryResponse();

  Future<AcpFiltersResponse> getAcpFilters({
    String? trainNo,
    String? coachType,
  });

  Future<List<AcpLogData>> getAcpFilteredLogs({
    String? trainNo,
    String? techCoachNo,  
  });

  Future<List<AcpCoachHistoryEntry>> getAcpCoachHistory({
    required String coachId,
    String? fromDate,
    String? toDate,
  });
}

@Injectable(as: AcpRepository)
class AcpRepositoryImpl implements AcpRepository {
  final AcpRemoteDataSource remoteDataSource;

  AcpRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<AcpLogData>> getAcpLogs() async {
    final response = await remoteDataSource.getAcpLogs();
    return response.data ?? [];
  }

  @override
  Future<List<AcpLogData>> getAcpSummary() async {
    final response = await remoteDataSource.getAcpSummary();
    return response.data ?? [];
  }

  @override
  Future<AcpLogResponse> getAcpSummaryResponse() async {
    return await remoteDataSource.getAcpSummary();
  }

  @override
  Future<AcpFiltersResponse> getAcpFilters({
    String? trainNo,
    String? coachType,
  }) async {
    return await remoteDataSource.getAcpFilters(
      trainNo: trainNo,
      coachType: coachType,
    );
  }

  @override
  Future<List<AcpLogData>> getAcpFilteredLogs({
    String? trainNo,
    String? techCoachNo,
  }) async {
    final response = await remoteDataSource.getAcpFilteredLogs(
      trainNo: trainNo,
      techCoachNo: techCoachNo,
    );
    return response.data ?? [];
  }

  @override
  Future<List<AcpCoachHistoryEntry>> getAcpCoachHistory({
    required String coachId,
    String? fromDate,
    String? toDate,
  }) async {
    final response = await remoteDataSource.getAcpCoachHistory(
      coachId: coachId,
      fromDate: fromDate,
      toDate: toDate,
    );
    return response.data ?? [];
  }
}
