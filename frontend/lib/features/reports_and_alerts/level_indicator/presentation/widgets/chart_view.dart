import 'dart:convert';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/network/api_constants.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/core/utils/enums.dart';

class ChartView extends StatefulWidget {
  final int? coachId;

  const ChartView({super.key, this.coachId});

  @override
  State<ChartView> createState() => _ChartViewState();
}

class _ChartViewState extends State<ChartView> {
  final List<ChartViewType> filters = [
    ChartViewType.hour,
    ChartViewType.day,
    ChartViewType.week,
    ChartViewType.month,
  ];

  int touchedIndex = -1;

  ChartViewType selectedViewType = ChartViewType.hour;
  List<ChartData> allApiData = [];
  List<LineChartDataModel> lineData = []; // <-- dynamic now
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadApiData(widget.coachId ?? 0);

  }

  Future<void> _loadApiData(int coachId) async {
    try {
      final data = await fetchSensorData(coachId);

      final sensorIds = data.map((d) => d.category).toSet().toList();

      // assign each sensor a random color
      final random = Random();
      final generatedLineData = sensorIds.map((id) {
        return LineChartDataModel(
          name: id, // sensor_id shown as legend
          color: Color.fromARGB(
            255,
            random.nextInt(256),
            random.nextInt(256),
            random.nextInt(256),
          ),
        );
      }).toList();


      if (mounted) {
        setState(() {
          allApiData = data;
          lineData = generatedLineData;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching chart data: $e");
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredData = getFilteredData(allApiData, selectedViewType);


    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Water level Trend',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
            ),
            SizedBox(width: 1.w),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: filters.map((f) => _buildFilterButton(f)).toList(),
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 12,
          children: lineData.map((e) => _buildLegend(e)).toList(),
        ),
        const SizedBox(height: 20),
        buildChart(filteredData, selectedViewType), // 👈 filtered instead of all
      ],
    );
  }

  Widget buildChart(List<ChartData> data, ChartViewType viewType) {
    if (data.isEmpty) {
      return const Center(child: Text("No data available"));
    }

    final grouped = <String, List<ChartData>>{};
    for (var item in data) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }

    final rawMinX = data
        .map((d) => d.timestamp.millisecondsSinceEpoch.toDouble())
        .reduce(min);
    final rawMaxX = data
        .map((d) => d.timestamp.millisecondsSinceEpoch.toDouble())
        .reduce(max);

    final padding = (rawMaxX - rawMinX) * 0.02; // 2% padding

    final minX = rawMinX - padding;
    final maxX = rawMaxX + padding;

    final xRange = maxX - minX;
    final calculatedInterval = xRange / 4;
    final interval = calculatedInterval > 0 ? calculatedInterval : 1.0;

    return SizedBox(
      height: 30.h,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          minX: minX,
          maxX: maxX,
          lineBarsData: grouped.entries.map((entry) {
            final color = getColorForCategory(entry.key);
            final spots =
                entry.value
                    .map(
                      (e) => FlSpot(
                        e.timestamp.millisecondsSinceEpoch.toDouble(),
                        e.value,
                      ),
                    )
                    .toList()
                  ..sort((a, b) => a.x.compareTo(b.x));

            return LineChartBarData(
              spots: spots,
              color: color,
              isCurved: true,
              barWidth: 2,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(show: false),
            );
          }).toList(),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: interval,
                getTitlesWidget: (value, meta) {
                  final date = DateTime.fromMillisecondsSinceEpoch(
                    value.toInt(),
                  );
                  return Text(
                    _formatDate(date, viewType),
                    style: TextStyle(fontSize: 10.sp),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, _) => Text(
                  '${value.toInt()}%',
                  style: TextStyle(fontSize: 11.sp),
                ),
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.symmetric(
              horizontal: BorderSide(width: 0.5, color: Colors.grey.shade300),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              // tooltipBgColor: Colors.black87,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final category = lineData
                      .firstWhere(
                        (line) => line.color == spot.bar.color,
                        orElse: () => LineChartDataModel(
                          name: 'Unknown',
                          color: Colors.grey,
                        ),
                      )
                      .name;

                  final xValue = getXLabel(viewType, spot.x.toInt());
                  final yValue = "${spot.y.toStringAsFixed(1)}%";

                  return LineTooltipItem(
                    "$category -- $xValue -- $yValue",
                    TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      // fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  String getXLabel(ChartViewType viewType, int x) {
    final dt = DateTime.fromMillisecondsSinceEpoch(x);

    switch (viewType) {
      case ChartViewType.hour:
        return DateFormat('HH:mm').format(dt); // e.g., 14:30
      case ChartViewType.day:
        return DateFormat('HH:mm').format(dt); // e.g., 14:30
      case ChartViewType.week:
        return DateFormat('dd MMM').format(dt); // e.g., 14 Jul
      case ChartViewType.month:
        return DateFormat('dd MMM').format(dt); // e.g., 14 Jul
    }
  }

  DateTime getWeekStart(DateTime date) {
    // Assuming Monday as start of the week
    return date.subtract(Duration(days: date.weekday - 1));
  }

  String _formatDate(DateTime date, ChartViewType type) {
    switch (type) {
      case ChartViewType.hour:
        return "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
      case ChartViewType.day:
        return "${date.hour}:00";
      case ChartViewType.week:
      case ChartViewType.month:
        return "${date.day}/${date.month}";
    }
  }

  Color getColorForCategory(String category) {
    final found = lineData.firstWhere(
          (line) => line.name == category,
      orElse: () => LineChartDataModel(name: 'Unknown', color: Colors.grey),
    );
    return found.color;
  }


  Widget _buildFilterButton(ChartViewType chartViewType) {
    final selected = chartViewType == selectedViewType;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (selected) return;
          setState(() {
            selectedViewType = chartViewType;
          });
        },
        child: Container(
          height: 3.3.h,
          margin: EdgeInsets.symmetric(horizontal: 1.w),
          decoration: BoxDecoration(
            color: selected ? ColorConstants.primary : const Color(0xFFF0F1F4),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              chartViewType.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black,
                fontSize: 9.sp,
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildLegend(LineChartDataModel model) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(radius: 5, backgroundColor: model.color),
        const SizedBox(width: 4),
        Text(model.name, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  List<ChartData> getFilteredData(
      List<ChartData> originalData,
      ChartViewType selectedViewType,
      ) {
    final now = DateTime.now();
    DateTime cutoff;

    switch (selectedViewType) {
      case ChartViewType.hour:
        cutoff = now.subtract(const Duration(hours: 1));
        break;
      case ChartViewType.day:
        cutoff = now.subtract(const Duration(days: 1));
        break;
      case ChartViewType.week:
        cutoff = now.subtract(const Duration(days: 7));
        break;
      case ChartViewType.month:
        cutoff = now.subtract(const Duration(days: 30));
        break;
    }

    final filtered = originalData.where((d) => d.timestamp.isAfter(cutoff)).toList();

    // ⬇️ Now group differently based on view type
    switch (selectedViewType) {
      case ChartViewType.hour:
      // raw values (5-min readings assumed)
        return filtered;

      case ChartViewType.day:
      // group by hour
        return _aggregateData(filtered, (dt) =>
            DateTime(dt.year, dt.month, dt.day, dt.hour));

      case ChartViewType.week:
      // group by day
        return _aggregateData(filtered, (dt) =>
            DateTime(dt.year, dt.month, dt.day));

      case ChartViewType.month:
      // group by day (or could group by week if you prefer)
        return _aggregateData(filtered, (dt) =>
            DateTime(dt.year, dt.month, dt.day));
    }
  }

  /// Groups data points by a "bucket" (hour/day) and averages their values
  List<ChartData> _aggregateData(
      List<ChartData> data,
      DateTime Function(DateTime) bucketMapper,
      ) {
    final Map<String, List<ChartData>> grouped = {};

    for (var d in data) {
      final bucket = bucketMapper(d.timestamp);
      final key = "${d.category}_${bucket.toIso8601String()}";

      grouped.putIfAbsent(key, () => []).add(d);
    }

    return grouped.entries.map((entry) {
      final items = entry.value;
      final avg = items.map((e) => e.value).reduce((a, b) => a + b) / items.length;

      return ChartData(
        timestamp: bucketMapper(items.first.timestamp),
        value: avg,
        category: items.first.category,
      );
    }).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }
}

class LineChartDataModel {
  final String name;
  final Color color;

  LineChartDataModel({required this.name, required this.color});
}

class ChartData {
  final DateTime timestamp;
  final double value;
  final String category; // Here we’ll use sensor_id

  ChartData({
    required this.timestamp,
    required this.value,
    required this.category,
  });

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      timestamp: DateTime.parse(json['timestamp']).toLocal(),
      value: double.tryParse(json['water_level'].toString()) ?? 0.0,
      category: json['sensor_id'],
    );
  }
}

const String apiUrl = "${ApiConstants.devUrl}/iot_water_level/get_data_for_coach";

Future<List<ChartData>> fetchSensorData(int coachId) async {
  final response = await http.get(Uri.parse("$apiUrl?coach_id=$coachId"));

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    final List<dynamic> data = jsonResponse['data']; // depends on your API shape

    return data.map((item) => ChartData.fromJson(item)).toList();
  } else {
    throw Exception("Failed to load sensor data $e");
  }
}
