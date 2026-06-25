import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_dimensions.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/utils/color_constants.dart';
import '../../../../core/widgets/period_filter.dart';
import '../data/models/hot_axle_model.dart';

class HotAxleChartView extends StatefulWidget {
  final List<HotAxleCoachModel> coaches;
  const HotAxleChartView({super.key, required this.coaches});

  @override
  State<HotAxleChartView> createState() => _HotAxleChartViewState();
}

class _HotAxleChartViewState extends State<HotAxleChartView> {
  String selectedPeriod = '7 Days';

  @override
  Widget build(BuildContext context) {
    final good = widget.coaches.where((c) => c.status == 'Good').length;
    final warning = widget.coaches.where((c) => c.status == 'Warning').length;
    final critical = widget.coaches.where((c) => c.status == 'Critical').length;
    final total = widget.coaches.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Axle Temperature Overview', style: AppTextStyles.header2),
        const SizedBox(height: 16),
        _buildStatsGrid(good, warning, critical, total),
        const SizedBox(height: 16),
        _buildSummaryTable(),
      ],
    );
  }

  Widget _buildStatsGrid(int good, int warning, int critical, int total) {
    return Row(
      children: [
        _statCard('Total', '$total', ColorConstants.primary),
        const SizedBox(width: 8),
        _statCard('Good', '$good', Colors.green),
        const SizedBox(width: 8),
        _statCard('Warning', '$warning', const Color(0xFFBE8B22)),
        const SizedBox(width: 8),
        _statCard('Critical', '$critical', const Color(0xFFD32F2F)),
      ],
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(value, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.poppins(fontSize: 11, color: ColorConstants.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryTable() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorConstants.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: ColorConstants.divider),
      ),
      child: Column(
        children: [
          _summaryRow('Coach', 'Max Temp', 'Status'),
          const Divider(height: 20),
          ...widget.coaches.map((c) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: _summaryRow(
              c.coachNumber,
              '${c.maxTemp.toStringAsFixed(1)}°C',
              c.status,
              statusColor: c.status == 'Critical' ? const Color(0xFFD32F2F) : (c.status == 'Warning' ? const Color(0xFFBE8B22) : Colors.green),
              deviceId: c.deviceId,
              trainNo: c.trainNo,
            ),
          )),
        ],
      ),
    );
  }

  Widget _summaryRow(String coach, String temp, String status, {Color? statusColor, String? deviceId, String? trainNo}) {
    return Row(
      children: [
        Expanded(flex: 2, child: Text(coach, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500))),
        Expanded(flex: 1, child: Text(temp, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 11)),
        ),
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: (statusColor ?? Colors.grey).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(status, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor ?? Colors.grey)),
          ),
        ),
      ],
    );
  }
}
