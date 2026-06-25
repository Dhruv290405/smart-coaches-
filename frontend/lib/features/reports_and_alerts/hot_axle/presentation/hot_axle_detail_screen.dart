import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:smart_coach_new/core/utils/app_icons.dart';
import 'package:smart_coach_new/core/utils/app_text_styles.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/core/widgets/period_filter.dart';
import 'package:smart_coach_new/features/reports_and_alerts/hot_axle/data/models/hot_axle_model.dart';
import 'widgets/axle_detail_modal.dart';
import 'widgets/axle_list_card.dart';

class HotAxleDetailScreen extends StatefulWidget {
  final HotAxleCoachModel coach;
  const HotAxleDetailScreen({super.key, required this.coach});

  @override
  State<HotAxleDetailScreen> createState() => _HotAxleDetailScreenState();
}

class _HotAxleDetailScreenState extends State<HotAxleDetailScreen> {
  String selectedPeriod = '7 Days';
  DateTimeRange? customRange;

  List<AxleModel> get _alertAxles => widget.coach.axles.where((a) => a.status != 'Good').toList();

  Future<void> _pickCustomRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2026, 1, 1),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: ColorConstants.primary)),
        child: child!,
      ),
    );
    if (range != null) setState(() { customRange = range; selectedPeriod = 'Custom'; });
  }

  static Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'good':     return Colors.green;
      case 'warning':  return ColorConstants.statusCritical;
      case 'critical': return ColorConstants.statusWarning;
      default:         return ColorConstants.iconGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: ColorConstants.scaffoldBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 40,
        leading: IconButton(
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.arrow_back, color: ColorConstants.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 4,
        title: Text('${widget.coach.coachNumber} - Hot Axle', style: AppTextStyles.header1),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _trainInfoCard(),
            const SizedBox(height: 16),

            _coachSummaryStrip(),
            const SizedBox(height: 16),

            _card(child: _liveAxlesList()),
            const SizedBox(height: 16),

            _card(child: _historySection()),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: ColorConstants.white, borderRadius: BorderRadius.circular(12)),
    child: child,
  );

  Widget _trainInfoCard() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: ColorConstants.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        SvgPicture.asset(AppIcons.train, width: 18, height: 18, colorFilter: const ColorFilter.mode(ColorConstants.primary, BlendMode.srcIn)),
        const SizedBox(width: 8),
        Text('Train ${widget.coach.trainNo}', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: ColorConstants.primary)),
      ]),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: ColorConstants.cardBackground, borderRadius: BorderRadius.circular(8)),
        child: Text('Last Updated: ${_formatTimestamp(widget.coach.timestamp)}', style: AppTextStyles.bodySmall),
      ),
    ]),
  );

  Widget _coachSummaryStrip() {
    final statusColor = _statusColor(widget.coach.status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.coach.coachNumber, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: ColorConstants.primary)),
            Text('Max Temp: ${widget.coach.maxTemp}', style: GoogleFonts.poppins(fontSize: 12, color: statusColor, fontWeight: FontWeight.w600)),
          ]),
          Row(children: [
            _summaryPill('${widget.coach.axlesMonitored} Axles', ColorConstants.primary),
            const SizedBox(width: 8),
            if (widget.coach.axlesIssue > 0)
              _summaryPill('${widget.coach.axlesIssue} Issues', const Color(0xFFD32F2F)),
          ]),
        ],
      ),
    );
  }

  Widget _summaryPill(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
  );

  Widget _liveAxlesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${widget.coach.coachNumber} (${widget.coach.axlesMonitored} Axles)', style: AppTextStyles.header2),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.coach.axles.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final axle = widget.coach.axles[index];
            return AxleListCard(
              axle: axle,
              onEyeIconTap: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => AxleDetailModal(axle: axle),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _historySection() {
    final alertAxles = _alertAxles;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${widget.coach.coachNumber} (Current Axle Alerts)', style: AppTextStyles.header2),
        const SizedBox(height: 16),
        if (alertAxles.isEmpty)
          Center(child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(children: [
              const Icon(Icons.check_circle, size: 44, color: Colors.green),
              const SizedBox(height: 8),
              Text('All axles operating normally', style: AppTextStyles.bodyMedium.copyWith(color: ColorConstants.textTertiary)),
            ]),
          ))
        else
          ...alertAxles.map((e) => _buildAlertCard(e)),
      ],
    );
  }

  Widget _buildAlertCard(AxleModel e) {
    final statusColor = _statusColor(e.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
      ),
      child: Column(children: [
        _hRow('Axle Number', 'Axle ${e.axleNumber}'),
        const Divider(color: ColorConstants.divider),
        _hRow('Max Temperature', e.maxTemp, valueColor: statusColor),
        const Divider(color: ColorConstants.divider),
        _hRow('Current Temp', e.currentTemp),
        const Divider(color: ColorConstants.divider),
        _hRow('Status', e.status, valueColor: statusColor),
        const Divider(color: ColorConstants.divider),
        _hRow('Speed', e.speed),
        const Divider(color: ColorConstants.divider),
        _hRow('Detected At', e.detectedAt),
      ]),
    );
  }

  Widget _hRow(String label, String value, {Color? valueColor}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500, color: valueColor ?? ColorConstants.textPrimary)),
      ],
    ),
  );

  String _fmt(DateTime d) => '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';

  String _formatTimestamp(String raw) {
    if (raw.isEmpty) return 'N/A';
    try {
      return DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(raw).toLocal());
    } catch (_) {
      return raw;
    }
  }
}