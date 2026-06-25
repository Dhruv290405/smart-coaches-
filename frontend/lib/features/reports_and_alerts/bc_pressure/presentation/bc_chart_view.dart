import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_coach_new/core/utils/app_dimensions.dart';
import 'package:smart_coach_new/core/utils/app_text_styles.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/core/widgets/period_filter.dart';
import '../data/models/bc_pressure_model.dart';

class BCChartView extends StatefulWidget {
  final List<BCPressureModel> coaches;
  const BCChartView({super.key, required this.coaches});

  @override
  State<BCChartView> createState() => _BCChartViewState();
}

class _BCChartViewState extends State<BCChartView> {
  String selectedPeriod = 'Live';

  @override
  Widget build(BuildContext context) {
    final good = widget.coaches.where((c) => c.status == 'Good').length;
    final warning = widget.coaches.where((c) => c.status == 'Warning').length;
    final critical = widget.coaches.where((c) => c.status == 'Critical').length;
    final total = widget.coaches.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('BC Pressure Overview', style: AppTextStyles.header2),
        const SizedBox(height: 16),
        Row(
          children: [
            _statItem('Total', '$total', ColorConstants.primary, 'coaches'),
            const SizedBox(width: 8),
            _statItem('Good', '$good', Colors.green, 'coaches'),
            const SizedBox(width: 8),
            _statItem('Warning', '$warning', const Color(0xFFBE8B22), 'coaches'),
            const SizedBox(width: 8),
            _statItem('Critical', '$critical', const Color(0xFFD32F2F), 'coaches'),
          ],
        ),
        const SizedBox(height: 20),
        Text('Coach Summary', style: AppTextStyles.header2),
        const SizedBox(height: 12),
        _buildSummaryTable(),
      ],
    );
  }

  Widget _statItem(String label, String value, Color color, String unit) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(value, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
            Text(label, style: GoogleFonts.poppins(fontSize: 10, color: ColorConstants.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryTable() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorConstants.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: ColorConstants.divider),
      ),
      child: Column(
        children: [
          Row(children: [
            _headerCell('Coach', flex: 2),
            _headerCell('Pressure', flex: 2),
            _headerCell('Status', flex: 2),
          ]),
          const Divider(height: 16),
          ...widget.coaches.map((c) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(children: [
              Expanded(flex: 2, child: Text(c.coachNumber, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500))),
              Expanded(flex: 2, child: Text('${c.pressure.toStringAsFixed(1)} Kg/cm²', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 11))),
              Expanded(flex: 2, child: _statusChip(c.status)),
            ]),
          )),
        ],
      ),
    );
  }

  Widget _headerCell(String text, {int flex = 1}) {
    return Expanded(flex: flex, child: Text(text, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: ColorConstants.textSecondary)));
  }

  Widget _statusChip(String status) {
    final Color color;
    switch (status.toLowerCase()) {
      case 'good': color = Colors.green; break;
      case 'warning': color = const Color(0xFFBE8B22); break;
      case 'critical': color = const Color(0xFFD32F2F); break;
      default: color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(status, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    );
  }
}
