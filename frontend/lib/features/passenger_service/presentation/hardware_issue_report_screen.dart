import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/network/api_constants.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/core/utils/loader.dart';
import 'package:smart_coach_new/core/utils/prefs.dart';
import 'package:smart_coach_new/core/utils/toast_message_utils.dart';
import 'package:smart_coach_new/features/passenger_service/presentation/widgets/hardware_issue_report_generator.dart';

class HardwareIssueReportScreen extends StatefulWidget {
  const HardwareIssueReportScreen({super.key});

  @override
  State<HardwareIssueReportScreen> createState() => _HardwareIssueReportScreenState();
}

class _HardwareIssueReportScreenState extends State<HardwareIssueReportScreen> {
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
      String url = '${ApiConstants.devUrl}/hardware-issues/report';
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
          ? (_dateFrom ?? DateTime.now().subtract(const Duration(days: 7)))
          : (_dateTo ?? DateTime.now()),
      firstDate: DateTime(2025),
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

  String _fmtResponse(int? seconds) {
    if (seconds == null) return '-';
    if (seconds < 60) return '$seconds sec';
    if (seconds < 3600) return '${(seconds / 60).toStringAsFixed(1)} min';
    return '${(seconds / 3600).toStringAsFixed(2)} hr';
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
          "Hardware Issue Report",
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        centerTitle: true,
        actions: [
          if (_report != null && ((_report!['requests'] as List?)?.isNotEmpty ?? false))
            IconButton(
              icon: Icon(Icons.file_download, color: ColorConstants.primary, size: 6.w),
              onPressed: () {
                final requests = List<Map<String, dynamic>>.from(_report!['requests']);
                HardwareIssueReportGenerator.generate(context, requests, report: _report);
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
                        _buildKpiCards(),
                        SizedBox(height: 2.h),
                        _buildIssueByDayBarChart(),
                        SizedBox(height: 2.h),
                        _buildTypePieChart(),
                        SizedBox(height: 2.h),
                        _buildPeakTimeChart(),
                        SizedBox(height: 2.h),
                        _buildResponseTimeCard(),
                        SizedBox(height: 2.h),
                        _buildIssuesTable(),
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

  Widget _buildKpiCards() {
    final r = _report!;
    return Column(
      children: [
        Row(
          children: [
            _statCard('Total', '${r['totalCount'] ?? 0}', ColorConstants.primary),
            SizedBox(width: 2.w),
            _statCard('Open', '${r['openCount'] ?? 0}', const Color(0xFFDE980A)),
            SizedBox(width: 2.w),
            _statCard('Cleaning', '${r['cleaningCount'] ?? 0}', const Color(0xFF1A9DF8)),
          ],
        ),
        SizedBox(height: 2.w),
        Row(
          children: [
            _statCard('Closed', '${r['closedCount'] ?? 0}', const Color(0xFF2E7D32)),
            SizedBox(width: 2.w),
            _statCard('Linen', '${r['linenCount'] ?? 0}', const Color(0xFF7B1FA2)),
            SizedBox(width: 2.w),
            _statCard('Avg. Response', _fmtResponse(r['avgResponseSeconds'] as int?),
                const Color(0xFFE64A19)),
          ],
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 1.w),
        decoration: _cardDecoration(),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: color)),
            SizedBox(height: 0.5.h),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 8.5.sp, color: ColorConstants.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildIssueByDayBarChart() {
    final byDay = List<Map<String, dynamic>>.from(_report!['byDay'] ?? []);
    if (byDay.isEmpty) return const SizedBox.shrink();

    final maxVal = byDay.fold<int>(0, (m, d) {
      final t = (d['total'] ?? 0) as int;
      return t > m ? t : m;
    });

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Issues Per Day",
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700)),
          SizedBox(height: 2.h),
          SizedBox(
            height: 18.h,
            child: BarChart(
              BarChartData(
                maxY: (maxVal + 1).toDouble(),
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 24),
                  ),
                  rightTitles: const AxisTitles(),
                  topTitles: const AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= byDay.length) return const SizedBox.shrink();
                        final day = '${byDay[idx]['date'] ?? ''}';
                        return Padding(
                          padding: EdgeInsets.only(top: 1.h),
                          child: Text(
                            day.length > 5 ? day.substring(5) : day,
                            style: TextStyle(fontSize: 7.sp, color: Colors.grey),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (v) =>
                      FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                barGroups: byDay.asMap().entries.map((e) {
                  final idx = e.key;
                  final d = e.value;
                  return BarChartGroupData(
                    x: idx,
                    barRods: [
                      BarChartRodData(
                        toY: ((d['cleaning'] ?? 0) as int).toDouble(),
                        color: const Color(0xFF1A9DF8),
                        width: 6,
                      ),
                      BarChartRodData(
                        toY: ((d['linen'] ?? 0) as int).toDouble(),
                        color: const Color(0xFF7B1FA2),
                        width: 6,
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendDot(const Color(0xFF1A9DF8), 'Cleaning'),
              SizedBox(width: 4.w),
              _legendDot(const Color(0xFF7B1FA2), 'Linen'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypePieChart() {
    final share = Map<String, dynamic>.from(_report!['shareByType'] ?? {});
    final total = (_report!['totalCount'] ?? 0) as int;
    if (total == 0) return const SizedBox.shrink();

    final cleaning = (share['cleaning'] ?? 0) as num;
    final linen = (share['linen'] ?? 0) as num;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Issue Type Distribution",
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700)),
          SizedBox(height: 2.h),
          SizedBox(
            height: 18.h,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: cleaning.toDouble(),
                          color: const Color(0xFF1A9DF8),
                          radius: 32,
                          title: '$cleaning%',
                          titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                        if (linen > 0)
                          PieChartSectionData(
                            value: linen.toDouble(),
                            color: const Color(0xFF7B1FA2),
                            radius: 32,
                            title: '$linen%',
                            titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                      ],
                      sectionsSpace: 2,
                      centerSpaceRadius: 18,
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _legendRow(const Color(0xFF1A9DF8), 'Cleaning', cleaning.toInt()),
                      SizedBox(height: 1.5.h),
                      _legendRow(const Color(0xFF7B1FA2), 'Linen', linen.toInt()),
                      SizedBox(height: 1.5.h),
                      Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: ColorConstants.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(2.w),
                        ),
                        child: Text('Total: $total',
                            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: ColorConstants.primary)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeakTimeChart() {
    final peak = List<Map<String, dynamic>>.from(_report!['peakHours'] ?? []);
    if (peak.isEmpty) return const SizedBox.shrink();

    final maxVal = peak.fold<int>(0, (m, p) {
      final c = (p['count'] ?? 0) as int;
      return c > m ? c : m;
    });
    if (maxVal == 0) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Peak Call Time (per hour)",
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700)),
          SizedBox(height: 2.h),
          SizedBox(
            height: 18.h,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: 23,
                minY: 0,
                maxY: (maxVal + 1).toDouble(),
                lineBarsData: [
                  LineChartBarData(
                    spots: peak.where((p) => (p['count'] ?? 0) > 0).map((p) {
                      return FlSpot((p['hour'] as num).toDouble(), (p['count'] ?? 0).toDouble());
                    }).toList(),
                    isCurved: true,
                    color: ColorConstants.primary,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: ColorConstants.primary.withValues(alpha: 0.1),
                    ),
                  ),
                ],
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                        showTitles: true, reservedSize: 28, getTitlesWidget: (v, m) {
                      return Text('${v.toInt()}',
                          style: TextStyle(fontSize: 8.sp, color: Colors.grey));
                    }),
                  ),
                  rightTitles: const AxisTitles(),
                  topTitles: const AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 3,
                      getTitlesWidget: (v, m) {
                        final h = v.toInt();
                        return Padding(
                          padding: EdgeInsets.only(top: 1.h),
                          child: Text(h == 0 ? '12 AM' : h == 12 ? '12 PM' : '$h',
                              style: TextStyle(fontSize: 8.sp, color: Colors.grey)),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  drawVerticalLine: true,
                  drawHorizontalLine: true,
                  getDrawingVerticalLine: (v) =>
                      FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                  getDrawingHorizontalLine: (v) =>
                      FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: const LineTouchData(enabled: true),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseTimeCard() {
    final avg = _report!['avgResponseSeconds'] as int?;
    if (avg == null) return const SizedBox.shrink();

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
              Text("Average Response Time",
                  style: TextStyle(fontSize: 11.sp, color: ColorConstants.textSecondary)),
              Text("${_fmtResponse(avg)}",
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: ColorConstants.primary)),
            ],
          ),
          const Spacer(),
          Text("Open compartments: ${_report!['openCount'] ?? 0}",
              style: TextStyle(fontSize: 10.sp, color: ColorConstants.statusWarning)),
        ],
      ),
    );
  }

  Widget _buildIssuesTable() {
    final requests = List<Map<String, dynamic>>.from(_report!['requests'] ?? []);
    if (requests.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(4.w),
        decoration: _cardDecoration(),
        child: Text("No issues found in this period",
            style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Issue Details",
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700)),
            Text("${requests.length} shown",
                style: TextStyle(fontSize: 11.sp, color: Colors.grey)),
          ],
        ),
        SizedBox(height: 1.h),
        Container(
          decoration: _cardDecoration(),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStatePropertyAll(ColorConstants.primary.withValues(alpha: 0.08)),
              dataRowMinHeight: 4.5.h,
              dataRowMaxHeight: 6.h,
              columns: const [
                DataColumn(label: Text('Coach', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11))),
                DataColumn(label: Text('Comp.', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11))),
                DataColumn(label: Text('Type', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11))),
                DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11))),
                DataColumn(label: Text('Start', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11))),
                DataColumn(label: Text('Closed', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11))),
                DataColumn(label: Text('Response', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11))),
              ],
              rows: requests.take(50).map((r) {
                final status = '${r['status'] ?? ''}';
                final statusColor = status == 'closed'
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFFDE980A);
                return DataRow(cells: [
                  DataCell(Text('${r['coach_no'] ?? ''}', style: TextStyle(fontSize: 11.sp))),
                  DataCell(Text('${r['compartment_no'] ?? ''}', style: TextStyle(fontSize: 11.sp))),
                  DataCell(Text(_formatType('${r['issue_type'] ?? ''}'), style: TextStyle(fontSize: 11.sp))),
                  DataCell(Container(
                    padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.3.h),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(1.w),
                    ),
                    child: Text(
                      status == 'closed' ? 'Closed' : 'Open',
                      style: TextStyle(
                          fontSize: 9.sp, fontWeight: FontWeight.w600, color: statusColor),
                    ),
                  )),
                  DataCell(Text(_fmtDateTime('${r['opened_at'] ?? ''}'), style: TextStyle(fontSize: 10.sp))),
                  DataCell(Text(_fmtDateTime('${r['closed_at'] ?? ''}'), style: TextStyle(fontSize: 10.sp))),
                  DataCell(Text(_fmtResponse(r['response_seconds'] as int?),
                      style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: ColorConstants.primary))),
                ]);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(3.w),
    boxShadow: [
      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
    ],
  );

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(width: 2.5.w, height: 2.5.w, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        SizedBox(width: 1.w),
        Text(label, style: TextStyle(fontSize: 10.sp, color: Colors.grey)),
      ],
    );
  }

  Widget _legendRow(Color color, String label, int value) {
    return Row(
      children: [
        Container(width: 2.5.w, height: 2.5.w, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        SizedBox(width: 2.w),
        Expanded(
          child: Text(label,
              style: TextStyle(fontSize: 11.sp, color: Colors.black87)),
        ),
        Text('$value%', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700)),
      ],
    );
  }

  String _formatType(String type) {
    switch (type) {
      case 'linen': return 'Linen';
      case 'cleaning': return 'Cleaning';
      default: return type;
    }
  }

  String _fmtDateTime(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('dd MMM, HH:mm').format(dt);
    } catch (_) {
      return raw.isNotEmpty ? raw : '-';
    }
  }
}