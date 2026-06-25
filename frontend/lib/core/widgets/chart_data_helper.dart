// Helper to convert generic API data to FlSpot list for charts
import 'package:fl_chart/fl_chart.dart';

class ChartDataHelper {
  /// Expects a list of maps with 'timestamp' (DateTime) and 'value' (num)
  static List<FlSpot> fromTimestampValues(List<Map<String, dynamic>> data) {
    return data
        .map((e) => FlSpot(
            (e['timestamp'] as DateTime).millisecondsSinceEpoch.toDouble(),
            (e['value'] as num).toDouble()))
        .toList();
  }
}
