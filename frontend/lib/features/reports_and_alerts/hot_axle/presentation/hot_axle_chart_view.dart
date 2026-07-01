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
        _buildTemperatureTrends(),
        const SizedBox(height: 16),
        _buildSummaryTable(),
      ],
    );
  }

  Widget _buildTemperatureTrends() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Temperature Trends', style: AppTextStyles.header2),
        const SizedBox(height: 8),
        PeriodFilter(
          selected: selectedPeriod,
          periods: const ['7 Days', '15 Days', '30 Days'],
          onChanged: (val) => setState(() => selectedPeriod = val),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ColorConstants.cardBackground,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            border: Border.all(color: ColorConstants.divider),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Period: $selectedPeriod', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: ColorConstants.textSecondary)),
                  Text('${widget.coaches.length} coaches tracked', style: GoogleFonts.poppins(fontSize: 11, color: ColorConstants.textTertiary)),
                ],
              ),
              const SizedBox(height: 12),
              ...widget.coaches.take(5).map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(flex: 2, child: Text(c.coachNumber, style: GoogleFonts.poppins(fontSize: 10, color: ColorConstants.textPrimary))),
                    Expanded(
                      flex: 3,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (c.maxTemp / 100).clamp(0.0, 1.0),
                          backgroundColor: Colors.grey[200],
                          color: c.maxTemp > 80 ? const Color(0xFFD32F2F) : (c.maxTemp > 60 ? const Color(0xFFBE8B22) : Colors.green),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 50,
                      child: Text('${c.maxTemp.toStringAsFixed(1)}°C', textAlign: TextAlign.right, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: c.maxTemp > 60 ? const Color(0xFFD32F2F) : ColorConstants.textSecondary)),
                    ),
                  ],
                ),
              )),
              if (widget.coaches.length > 5)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('+ ${widget.coaches.length - 5} more', style: GoogleFonts.poppins(fontSize: 10, color: ColorConstants.textTertiary)),
                ),
            ],
          ),
        ),
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
          _summaryRow('Coach', 'Max Temp', 'Status', isHeader: true),
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

  Widget _summaryRow(String coach, String temp, String status, {Color? statusColor, String? deviceId, String? trainNo, bool isHeader = false}) {
    if (isHeader) {
      return Row(
        children: [
          Expanded(flex: 2, child: Text('Coach / Device', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: ColorConstants.textSecondary))),
          Expanded(flex: 1, child: Text('Train', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: ColorConstants.textSecondary))),
          Expanded(flex: 1, child: Text('Max Temp', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: ColorConstants.textSecondary))),
          Expanded(flex: 1, child: Text('Status', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: ColorConstants.textSecondary))),
        ],
      );
    }
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(coach, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500)),
              if (deviceId != null && deviceId != 'Unknown')
                Text(deviceId, style: GoogleFonts.poppins(fontSize: 8, color: ColorConstants.textTertiary)),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            (trainNo != null && trainNo.isNotEmpty) ? trainNo : '-',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 10, color: ColorConstants.textSecondary),
          ),
        ),
        Expanded(flex: 1, child: Text(temp, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 11))),
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: (statusColor ?? Colors.grey).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(status, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w600, color: statusColor ?? Colors.grey)),
          ),
        ),
      ],
    );
  }
}
