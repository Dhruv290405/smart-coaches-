import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/network/api_constants.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/core/utils/loader.dart';
import 'package:smart_coach_new/core/utils/prefs.dart';
import 'package:smart_coach_new/core/utils/toast_message_utils.dart';
import 'package:smart_coach_new/core/widgets/custom_button.dart';
import 'package:smart_coach_new/features/passenger_service/presentation/widgets/service_request_report_generator.dart';
import 'package:intl/intl.dart';

class ServiceRequestReportScreen extends StatefulWidget {
  const ServiceRequestReportScreen({super.key});

  @override
  State<ServiceRequestReportScreen> createState() => _ServiceRequestReportScreenState();
}

class _ServiceRequestReportScreenState extends State<ServiceRequestReportScreen> {
  DateTime? _dateFrom;
  DateTime? _dateTo;
  Map<String, dynamic>? _report;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchReport();
  }

  Future<void> _fetchReport() async {
    setState(() => _isLoading = true);
    Loader.show();

    try {
      String url = '${ApiConstants.devUrl}/service-requests/report';
      final params = <String, String>{};
      if (_dateFrom != null) {
        params['dateFrom'] = _dateFrom!.toUtc().toIso8601String();
      }
      if (_dateTo != null) {
        params['dateTo'] = _dateTo!.toUtc().add(const Duration(days: 1)).toIso8601String();
      }
      if (params.isNotEmpty) {
        url += '?${Uri(queryParameters: params).query}';
      }

      final response = await http.get(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        if (GetIt.I<Prefs>().token != null)
          'Authorization': 'Bearer ${GetIt.I<Prefs>().token}',
      });

      Loader.dismiss();
      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        setState(() => _report = body['data']);
      } else {
        ToastMessageUtils.showMessage(context, 'Failed to load report');
      }
    } catch (e) {
      Loader.dismiss();
      setState(() => _isLoading = false);
      ToastMessageUtils.showMessage(context, 'Network error');
    }
  }

  Future<void> _pickDate({bool isFrom = true}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom
          ? (_dateFrom ?? DateTime.now().subtract(const Duration(days: 30)))
          : (_dateTo ?? DateTime.now()),
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _dateFrom = picked;
        } else {
          _dateTo = picked;
        }
      });
      _fetchReport();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.screenBgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black87, size: 5.w),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Service Request Report",
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        centerTitle: true,
        actions: [
          if (_report != null && (_report!['requests'] as List).isNotEmpty)
            IconButton(
              icon: Icon(Icons.file_download, color: ColorConstants.primary, size: 6.w),
              onPressed: () {
                final requests = List<Map<String, dynamic>>.from(_report!['requests']);
                ServiceRequestReportGenerator.generate(context, requests);
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: ColorConstants.primary))
          : _report == null
              ? const Center(child: Text('No data'))
              : RefreshIndicator(
                  onRefresh: _fetchReport,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDateFilter(),
                        SizedBox(height: 2.h),
                        _buildSummaryCards(),
                        SizedBox(height: 2.h),
                        _buildServiceTypeBreakdown(),
                        SizedBox(height: 2.h),
                        _buildDayWiseChart(),
                        SizedBox(height: 2.h),
                        _buildResolutionTime(),
                        SizedBox(height: 2.h),
                        _buildRecentRequests(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildDateFilter() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Expanded(
            child: _dateButton(
              label: _dateFrom != null ? DateFormat('dd MMM yyyy').format(_dateFrom!) : 'From Date',
              onTap: () => _pickDate(isFrom: true),
            ),
          ),
          SizedBox(width: 3.w),
          Icon(Icons.arrow_forward, color: Colors.grey, size: 5.w),
          SizedBox(width: 3.w),
          Expanded(
            child: _dateButton(
              label: _dateTo != null ? DateFormat('dd MMM yyyy').format(_dateTo!) : 'To Date',
              onTap: () => _pickDate(isFrom: false),
            ),
          ),
          SizedBox(width: 3.w),
          GestureDetector(
            onTap: () {
              setState(() {
                _dateFrom = null;
                _dateTo = null;
              });
              _fetchReport();
            },
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2.w),
              ),
              child: Icon(Icons.clear, color: Colors.grey, size: 5.w),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateButton({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 3.w),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(2.w),
        ),
        child: Center(
          child: Text(label, style: TextStyle(fontSize: 11.sp, color: Colors.black54)),
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final total = _report!['totalCount'] ?? 0;
    final pending = _report!['pendingCount'] ?? 0;
    final inProgress = _report!['inProgressCount'] ?? 0;
    final resolved = _report!['resolvedCount'] ?? 0;

    return Row(
      children: [
        _statCard('Total', '$total', ColorConstants.primary),
        SizedBox(width: 2.w),
        _statCard('Pending', '$pending', ColorConstants.statusWarning),
        SizedBox(width: 2.w),
        _statCard('In Progress', '$inProgress', const Color(0xFF1A9DF8)),
        SizedBox(width: 2.w),
        _statCard('Resolved', '$resolved', const Color(0xFF2E7D32)),
      ],
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
        decoration: _cardDecoration(),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: color)),
            SizedBox(height: 0.5.h),
            Text(label, style: TextStyle(fontSize: 9.sp, color: ColorConstants.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceTypeBreakdown() {
    final byType = Map<String, dynamic>.from(_report!['byServiceType'] ?? {});
    if (byType.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Service Type Breakdown",
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700)),
          SizedBox(height: 2.h),
          ...byType.entries.map((e) {
            final total = _report!['totalCount'] ?? 1;
            final pct = ((e.value as int) / total * 100).round();
            return Padding(
              padding: EdgeInsets.only(bottom: 1.5.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatType(e.key), style: TextStyle(fontSize: 12.sp)),
                      Text("${e.value} ($pct%)",
                          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  SizedBox(height: 0.5.h),
                  LinearProgressIndicator(
                    value: (e.value as int) / total,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(ColorConstants.primary),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDayWiseChart() {
    final byDay = Map<String, dynamic>.from(_report!['byDay'] ?? {});
    if (byDay.isEmpty) return const SizedBox.shrink();

    final sortedDays = byDay.keys.toList()..sort();
    final last7 = sortedDays.length > 7 ? sortedDays.sublist(sortedDays.length - 7) : sortedDays;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Day-wise Trend",
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700)),
          SizedBox(height: 2.h),
          SizedBox(
            height: 12.h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: last7.map((day) {
                final data = Map<String, dynamic>.from(byDay[day]);
                final total = data['total'] ?? 0;
                final maxVal = last7.fold<int>(0, (max, d) {
                  final v = (byDay[d]['total'] ?? 0) as int;
                  return v > max ? v : max;
                });
                final height = maxVal > 0 ? (total / maxVal) * 10.h : 0.0;

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 1.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('$total', style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w600)),
                        SizedBox(height: 0.5.h),
                        Container(
                          height: height < 0.5.h ? 0.5.h : height,
                          decoration: BoxDecoration(
                            color: ColorConstants.primary,
                            borderRadius: BorderRadius.circular(1.w),
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(day.length > 5 ? day.substring(5) : day, style: TextStyle(fontSize: 7.sp, color: Colors.grey)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResolutionTime() {
    final avgHours = _report!['avgResolutionHours'];
    if (avgHours == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Icon(Icons.timer, color: ColorConstants.primary, size: 6.w),
          SizedBox(width: 3.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Avg. Resolution Time",
                  style: TextStyle(fontSize: 11.sp, color: ColorConstants.textSecondary)),
              Text("${avgHours.toStringAsFixed(1)} hours",
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: ColorConstants.primary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentRequests() {
    final requests = List<Map<String, dynamic>>.from(_report!['requests'] ?? []);
    if (requests.isEmpty) return const SizedBox.shrink();

    final recent = requests.take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Recent Requests", style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700)),
            Text("${requests.length} total", style: TextStyle(fontSize: 11.sp, color: Colors.grey)),
          ],
        ),
        SizedBox(height: 1.h),
        ...recent.map((r) => _requestTile(r)),
      ],
    );
  }

  Widget _requestTile(Map<String, dynamic> request) {
    final status = request['status'] ?? 'pending';
    final statusColor = status == 'resolved'
        ? const Color(0xFF2E7D32)
        : status == 'in_progress'
            ? const Color(0xFF1A9DF8)
            : ColorConstants.statusWarning;

    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      padding: EdgeInsets.all(3.w),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Train ${request['train_no'] ?? ''}  |  Coach ${request['coach_no'] ?? ''}",
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(1.w),
                ),
                child: Text(
                  _formatStatus(status),
                  style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w600, color: statusColor),
                ),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          Row(
            children: [
              Text("Seat: ${request['seat_berth'] ?? ''}",
                  style: TextStyle(fontSize: 10.sp, color: ColorConstants.textSecondary)),
              SizedBox(width: 3.w),
              Text(_formatType('${request['service_type'] ?? ''}'),
                  style: TextStyle(fontSize: 10.sp, color: ColorConstants.textSecondary)),
            ],
          ),
          if (request['description'] != null &&
              (request['description'] as String).isNotEmpty) ...[
            SizedBox(height: 0.5.h),
            Text(request['description'],
                style: TextStyle(fontSize: 10.sp, color: Colors.grey), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
          SizedBox(height: 0.5.h),
          Text(
            _fmtDateTime('${request['created_at'] ?? ''}'),
            style: TextStyle(fontSize: 9.sp, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(3.w),
    boxShadow: [
      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
    ],
  );

  String _formatType(String type) {
    switch (type) {
      case 'toilet_cleaning': return 'Toilet Cleaning';
      case 'linen_issue': return 'Linen Issue';
      case 'others': return 'Others';
      default: return type;
    }
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'pending': return 'Pending';
      case 'in_progress': return 'In Progress';
      case 'resolved': return 'Resolved';
      default: return status;
    }
  }

  String _fmtDateTime(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('dd MMM yyyy, HH:mm').format(dt);
    } catch (_) {
      return raw;
    }
  }
}
