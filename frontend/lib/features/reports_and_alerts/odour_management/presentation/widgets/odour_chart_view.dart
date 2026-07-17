import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_coach_new/core/utils/app_dimensions.dart';
import 'package:smart_coach_new/core/utils/app_text_styles.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import '../../data/models/odour_model.dart';

class OdourChartView extends StatelessWidget {
  final List<OdourCoachModel> records;
  final List<CoachToiletGroup> groups;

  const OdourChartView({super.key, required this.records, required this.groups});

  int get alertCount => records.where((r) => r.hasAlert).length;
  int get activeCount => records.where((r) => r.isActive).length;

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty || groups.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("No analytics data available.")));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTopSummaryCards(context),
        const SizedBox(height: 24),

        _sectionTitle('Washroom Status Distribution', 'Overall train hygiene health'),
        _buildStatusDistributionDonut(context),
        const SizedBox(height: 24),

        _sectionTitle('Critical Attention Required', 'Top 3 worst performing washrooms'),
        _buildTop3CriticalList(context),
        const SizedBox(height: 24),
        
        _sectionTitle('Hygiene Score Comparison', 'Average hygiene score by coach'),
        _buildHygieneBarChart(context),
        const SizedBox(height: 24),
        
        _sectionTitle('Fleet Sensor Averages', 'Train-wide average readings vs thresholds'),
        _buildFleetSensorAverages(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.header2),
        const SizedBox(height: 4),
        Text(subtitle, style: AppTextStyles.bodyMedium.copyWith(color: ColorConstants.textSecondary)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTopSummaryCards(BuildContext context) {
    int doorEvents = 0;
    for (var r in records) {
      doorEvents += r.doorOpenEventsToday;
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _summaryMetricCard(context, 'Total Alerts', '$alertCount', Icons.notification_important, const Color(0xFFD32F2F)),
        _summaryMetricCard(context, 'Door Events', '$doorEvents', Icons.door_front_door, Colors.blueAccent),
        _summaryMetricCard(context, 'Active Devices', '$activeCount', Icons.sensors, const Color(0xFF34C700)),
      ],
    );
  }

  Widget _summaryMetricCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      width: (MediaQuery.of(context).size.width - 44) / 2,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorConstants.white, 
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium), 
        border: Border.all(color: ColorConstants.divider),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
        ]
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.05)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodySmall.copyWith(color: ColorConstants.textSecondary)),
                const SizedBox(height: 4),
                Text(value, style: AppTextStyles.header2.copyWith(fontSize: 16)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatusDistributionDonut(BuildContext context) {
    int good = 0;
    int warning = 0;
    int critical = 0;
    for (var r in records) {
      if (r.hygieneScore >= 70) good++;
      else if (r.hygieneScore >= 50) warning++;
      else critical++;
    }
    
    final total = records.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorConstants.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: ColorConstants.divider)
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120, height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(PieChartData(
                  sectionsSpace: 4,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(value: good.toDouble(), color: const Color(0xFF34C700), radius: 16, showTitle: false),
                    PieChartSectionData(value: warning.toDouble(), color: const Color(0xFFBE8B22), radius: 16, showTitle: false),
                    PieChartSectionData(value: critical.toDouble(), color: const Color(0xFFD32F2F), radius: 16, showTitle: false),
                  ]
                )),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$total', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700)),
                    Text('Total', style: GoogleFonts.poppins(fontSize: 10, color: ColorConstants.textSecondary)),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _donutLegendRow('Good', good, total, const Color(0xFF34C700)),
                const SizedBox(height: 12),
                _donutLegendRow('Warning', warning, total, const Color(0xFFBE8B22)),
                const SizedBox(height: 12),
                _donutLegendRow('Critical', critical, total, const Color(0xFFD32F2F)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _donutLegendRow(String label, int count, int total, Color color) {
    final pct = total > 0 ? (count / total * 100).toStringAsFixed(2) : '0';
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500))),
        Text('$count ($pct%)', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }

  Widget _buildTop3CriticalList(BuildContext context) {
    final sorted = List<OdourCoachModel>.from(records);
    sorted.sort((a, b) => a.hygieneScore.compareTo(b.hygieneScore));
    
    final worst3 = sorted.take(3).toList();
    if (worst3.isEmpty) return const SizedBox.shrink();

    return Column(
      children: worst3.map((r) {
        final score = r.hygieneScore;
        final color = score >= 70 ? const Color(0xFF34C700) : score >= 50 ? const Color(0xFFBE8B22) : const Color(0xFFD32F2F);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.2))
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
                child: Text('${score.toStringAsFixed(2)}%', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Coach C-${r.coachNumber}', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: ColorConstants.textPrimary)),
                    Text(r.toiletPosition, style: GoogleFonts.poppins(fontSize: 12, color: ColorConstants.textSecondary)),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.cleaning_services, size: 14, color: Colors.white),
                label: Text('Clean', style: GoogleFonts.poppins(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  minimumSize: const Size(0, 32),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                ),
              )
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHygieneBarChart(BuildContext context) {
    List<FlSpot> spots = [];
    List<String> labels = [];
    
    for (int i = 0; i < groups.length; i++) {
      final g = groups[i];
      if (g.toilets.isEmpty) continue;
      double sum = 0;
      for (var t in g.toilets) {
        sum += t.hygieneScore;
      }
      double avg = sum / g.toilets.length;
      spots.add(FlSpot(i.toDouble(), avg));
      labels.add('C-${g.coachNumber}');
    }

    if (spots.isEmpty) return const SizedBox.shrink();

    final chartWidth = labels.length * 50.0 > MediaQuery.of(context).size.width - 32
        ? labels.length * 50.0
        : MediaQuery.of(context).size.width - 32;

    return Container(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      decoration: BoxDecoration(color: ColorConstants.cardBackground, borderRadius: BorderRadius.circular(AppDimensions.radiusLarge), border: Border.all(color: ColorConstants.divider)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          width: chartWidth,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            height: 220,
            child: BarChart(BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 100,
              gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 20,
                getDrawingHorizontalLine: (v) => FlLine(color: ColorConstants.divider, strokeWidth: 1, dashArray: [4, 4])),
              titlesData: FlTitlesData(
                show: true, rightTitles: const AxisTitles(), topTitles: const AxisTitles(),
                bottomTitles: AxisTitles(sideTitles: SideTitles(
                  showTitles: true, reservedSize: 42,
                  getTitlesWidget: (v, m) {
                    final idx = v.toInt();
                    if (idx >= 0 && idx < labels.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(labels[idx], style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: ColorConstants.textSecondary), textAlign: TextAlign.center),
                      );
                    }
                    return const SizedBox.shrink();
                  })),
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30,
                  getTitlesWidget: (v, m) => Text(v.toInt().toString(), style: GoogleFonts.poppins(fontSize: 10, color: ColorConstants.textSecondary)))),
              ),
              borderData: FlBorderData(show: false),
              extraLinesData: ExtraLinesData(horizontalLines: [
                HorizontalLine(y: 70, color: Colors.green.withValues(alpha: 0.5), strokeWidth: 1.5, dashArray: [5, 5], label: HorizontalLineLabel(show: true, alignment: Alignment.topRight, style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold), labelResolver: (line) => 'Good')),
                HorizontalLine(y: 50, color: Colors.redAccent.withValues(alpha: 0.5), strokeWidth: 1.5, dashArray: [5, 5], label: HorizontalLineLabel(show: true, alignment: Alignment.bottomRight, style: const TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold), labelResolver: (line) => 'Critical')),
              ]),
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => Colors.black87,
                  tooltipPadding: const EdgeInsets.all(8),
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${labels[group.x.toInt()]}\n',
                      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      children: [
                        TextSpan(text: '${rod.toY.toStringAsFixed(2)} Score', style: const TextStyle(color: Colors.yellowAccent, fontSize: 11, fontWeight: FontWeight.w500))
                      ]
                    );
                  }
                )
              ),
              barGroups: spots.asMap().entries.map((e) {
                final score = e.value.y;
                final baseColor = score >= 70 ? const Color(0xFF34C700) : score >= 50 ? const Color(0xFFBE8B22) : const Color(0xFFD32F2F);
                return BarChartGroupData(x: e.key, barRods: [
                  BarChartRodData(
                    toY: score, 
                    width: 26,
                    gradient: LinearGradient(colors: [baseColor, baseColor.withValues(alpha: 0.6)], begin: Alignment.bottomCenter, end: Alignment.topCenter),
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6))
                  )
                ]);
              }).toList(),
            )),
          ),
        ),
      ),
    );
  }

  Widget _buildFleetSensorAverages() {
    double avgVoc = 0, avgNh3 = 0, avgH2s = 0, avgSmoke = 0, avgTemp = 0, avgHum = 0;
    final wm = records.isNotEmpty ? records.first : null;
    
    for (var r in records) {
      avgVoc += r.voc;
      avgNh3 += r.nh3;
      avgH2s += r.h2s;
      avgSmoke += r.smoke;
      avgTemp += r.temperature;
      avgHum += r.humidity;
    }
    
    int count = records.isEmpty ? 1 : records.length;
    avgVoc /= count;
    avgNh3 /= count;
    avgH2s /= count;
    avgSmoke /= count;
    avgTemp /= count;
    avgHum /= count;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: [
        _avgSensorTile('Avg VOC', avgVoc, 'ppm', const Color(0xFF4285F4), wm?.vocThreshold ?? 500.0),
        _avgSensorTile('Avg NH₃', avgNh3, 'ppm', const Color(0xFFFBBC05), wm?.nh3Threshold ?? 1.0),
        _avgSensorTile('Avg H₂S', avgH2s, 'ppm', const Color(0xFFEA4335), wm?.h2sThreshold ?? 0.1),
        _avgSensorTile('Avg Smoke', avgSmoke, 'ppm', Colors.grey.shade700, wm?.smokeThreshold ?? 10.0),
        _avgSensorTile('Avg Temp', avgTemp, '°C', const Color(0xFFFA7B17), 50.0),
        _avgSensorTile('Avg Humidity', avgHum, '% RH', const Color(0xFF34A853), 100.0),
      ],
    );
  }

  Widget _avgSensorTile(String label, double value, String unit, Color color, double threshold) {
    double percent = value / threshold;
    if (percent > 1.0) percent = 1.0;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_outlined, size: 14, color: color),
              const SizedBox(width: 4),
              Expanded(child: Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: ColorConstants.textSecondary), overflow: TextOverflow.ellipsis)),
            ],
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value.toStringAsFixed(2), style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
              const SizedBox(width: 4),
              Text(unit, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: color)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: color.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0', style: GoogleFonts.poppins(fontSize: 9, color: ColorConstants.textSecondary)),
              Text('Max: ${threshold.toStringAsFixed(2)}', style: GoogleFonts.poppins(fontSize: 9, color: ColorConstants.textSecondary)),
            ],
          )
        ],
      ),
    );
  }
}
