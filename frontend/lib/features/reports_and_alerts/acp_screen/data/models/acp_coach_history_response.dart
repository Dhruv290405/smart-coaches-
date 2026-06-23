class AcpCoachHistoryResponse {
  final bool? success;
  final String? message;
  final int? count;
  final List<AcpCoachHistoryEntry>? data;

  AcpCoachHistoryResponse({this.success, this.message, this.count, this.data});

  factory AcpCoachHistoryResponse.fromJson(Map<String, dynamic> json) {
    return AcpCoachHistoryResponse(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      count: json['count'] as int?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => AcpCoachHistoryEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AcpCoachHistoryEntry {
  final int? logId;
  final String? eventTime;
  final String? acpStatus;
  final int? historySequenceNo;
  final int? dailyEventNo;
  final String? dbTotalCount;
  final String? trainLocation;
  final String? rawAssetName;
  final int? todayPullsCount;
  final int? totalLifetimePulls;

  AcpCoachHistoryEntry({
    this.logId,
    this.eventTime,
    this.acpStatus,
    this.historySequenceNo,
    this.dailyEventNo,
    this.dbTotalCount,
    this.trainLocation,
    this.rawAssetName,
    this.todayPullsCount,
    this.totalLifetimePulls,
  });

  factory AcpCoachHistoryEntry.fromJson(Map<String, dynamic> json) {
    return AcpCoachHistoryEntry(
      logId: json['log_id'] as int?,
      eventTime: json['event_time'] as String?,
      acpStatus: json['acp_status']?.toString(),
      historySequenceNo: json['history_sequence_no'] as int?,
      dailyEventNo: json['daily_event_no'] as int?,
      dbTotalCount: json['db_total_count']?.toString(),
      trainLocation: json['train_location'] as String?,
      rawAssetName: json['raw_asset_name'] as String?,
      todayPullsCount: (json['today_pulls_count'] as num?)?.toInt(),
      totalLifetimePulls: (json['total_lifetime_pulls'] as num?)?.toInt(),
    );
  }

  DateTime get eventDate {
    if (eventTime == null) return DateTime(0);
    return DateTime.tryParse(eventTime!) ?? DateTime(0);
  }
}
