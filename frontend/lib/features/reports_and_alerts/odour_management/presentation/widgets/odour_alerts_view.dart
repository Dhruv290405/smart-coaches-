import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:smart_coach_new/core/utils/app_dimensions.dart';
import 'package:smart_coach_new/core/utils/app_text_styles.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/core/utils/logger.dart';
import 'package:smart_coach_new/features/reports_and_alerts/odour_management/data/models/odour_model.dart';
import 'package:smart_coach_new/supabase_config.dart';

final Logger _log = Logger('OdourAlerts');

class OdourAlertItem {
  final OdourCoachModel record;
  final String alertType;
  final String sensorName;
  final String currentReading;
  final String threshold;
  final String severity;
  final String id;

  OdourAlertItem({
    required this.record,
    required this.alertType,
    required this.sensorName,
    required this.currentReading,
    required this.threshold,
    required this.severity,
  }) : id = '${record.deviceId}-$alertType-${record.timestamp}';
}

class OdourAlertsView extends StatefulWidget {
  final List<OdourCoachModel> records;
  const OdourAlertsView({super.key, required this.records});

  @override
  State<OdourAlertsView> createState() => _OdourAlertsViewState();
}

class _OdourAlertsViewState extends State<OdourAlertsView> {
  final Set<String> _acknowledgedIds = {};
  final Set<String> _resolvedIds = {};

  List<OdourAlertItem> _generateAlerts() {
    final alerts = <OdourAlertItem>[];
    for (var r in widget.records) {
      if (r.voc >= r.vocThreshold) alerts.add(OdourAlertItem(record: r, alertType: 'Threshold Exceeded', sensorName: 'VOC', currentReading: '${r.voc.toStringAsFixed(2)} ppm', threshold: '${r.vocThreshold.toStringAsFixed(2)} ppm', severity: 'Critical'));
      if (r.h2s >= r.h2sThreshold) alerts.add(OdourAlertItem(record: r, alertType: 'Threshold Exceeded', sensorName: 'H₂S', currentReading: '${r.h2s.toStringAsFixed(2)} ppm', threshold: '${r.h2sThreshold.toStringAsFixed(2)} ppm', severity: 'Critical'));
      if (r.nh3 >= r.nh3Threshold) alerts.add(OdourAlertItem(record: r, alertType: 'Threshold Exceeded', sensorName: 'NH₃', currentReading: '${r.nh3.toStringAsFixed(2)} ppm', threshold: '${r.nh3Threshold.toStringAsFixed(2)} ppm', severity: 'Critical'));
      if (r.smoke >= r.smokeThreshold) alerts.add(OdourAlertItem(record: r, alertType: 'Threshold Exceeded', sensorName: 'Smoke', currentReading: '${r.smoke.toStringAsFixed(2)} ppm', threshold: '${r.smokeThreshold.toStringAsFixed(2)} ppm', severity: 'Critical'));
      if (r.hygieneScore < 50) alerts.add(OdourAlertItem(record: r, alertType: 'Hygiene Critical', sensorName: 'Hygiene Score', currentReading: '${r.hygieneScore.toStringAsFixed(0)}%', threshold: '50%', severity: 'Critical'));
      else if (r.hygieneScore < 70) alerts.add(OdourAlertItem(record: r, alertType: 'Hygiene Warning', sensorName: 'Hygiene Score', currentReading: '${r.hygieneScore.toStringAsFixed(0)}%', threshold: '70%', severity: 'Warning'));
      
      if (r.doorStatus.toLowerCase() == 'open') {
        alerts.add(OdourAlertItem(record: r, alertType: 'Door Open', sensorName: 'Limit Switch', currentReading: 'Open', threshold: 'Closed', severity: 'Warning'));
      }
    }
    return alerts;
  }

  @override
  Widget build(BuildContext context) {
    final allAlerts = _generateAlerts().where((a) => !_resolvedIds.contains(a.id)).toList();
    final critical = allAlerts.where((a) => a.severity == 'Critical').toList();
    final warning = allAlerts.where((a) => a.severity == 'Warning').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Automatic Alerts", style: AppTextStyles.header2),
            Row(children: [
              if (critical.isNotEmpty) _badge('${critical.length} Critical', const Color(0xFFD32F2F)),
              if (warning.isNotEmpty) ...[const SizedBox(width: 6), _badge('${warning.length} Warning', const Color(0xFFBE8B22))],
            ]),
          ],
        ),
        const SizedBox(height: 16),
        if (allAlerts.isEmpty)
          const Center(child: Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Text('No active alerts', style: TextStyle(color: Colors.grey)),
          )),
        ...critical.map((a) => _buildAlertCard(a)),
        ...warning.map((a) => _buildAlertCard(a)),
      ],
    );
  }

  String _fmt(String ts) {
    try { return DateFormat('dd MMM, HH:mm:ss').format(DateTime.parse(ts).toLocal()); }
    catch (_) { return ts; }
  }

  Widget _badge(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
    child: Text(label, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
  );

  Widget _buildAlertCard(OdourAlertItem alert) {
    final isAck = _acknowledgedIds.contains(alert.id);
    final color = alert.severity == 'Critical' ? const Color(0xFFD32F2F) : const Color(0xFFBE8B22);
    final bg = alert.severity == 'Critical' ? const Color(0xFFFFEBEE) : const Color(0xFFFFF8E1);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: isAck ? ColorConstants.cardBackground : bg, borderRadius: BorderRadius.circular(AppDimensions.radiusLarge), border: Border.all(color: isAck ? ColorConstants.divider : color.withValues(alpha: 0.3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(alert.severity == 'Critical' ? Icons.error : Icons.warning_amber_rounded, color: isAck ? Colors.grey : color, size: 20),
              const SizedBox(width: 8),
              Text(alert.alertType, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: isAck ? Colors.grey : color)),
              const Spacer(),
              if (isAck) _badge('Acknowledged', Colors.blue)
              else _badge('Open', color),
            ],
          ),
          const SizedBox(height: 12),
          _infoRow('Coach / Device', '${alert.record.coachNumber} (${alert.record.toiletPosition}) | ${alert.record.deviceId}'),
          _infoRow('Triggered Sensor', alert.sensorName),
          _infoRow('Actual Value', alert.currentReading, valueColor: color),
          _infoRow('Triggered Threshold', alert.threshold),
          _infoRow('Timestamp', _fmt(alert.record.timestamp)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!isAck)
                TextButton(
                  onPressed: () => setState(() => _acknowledgedIds.add(alert.id)),
                  child: Text('Acknowledge', style: GoogleFonts.poppins(color: Colors.blue, fontWeight: FontWeight.w600)),
                ),
              const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, elevation: 0),
                  onPressed: () async {
                    setState(() => _resolvedIds.add(alert.id));
                    try {
                      final client = alert.record.section == 'Section 2'
                          ? SupabaseConfig.odour2Client
                          : SupabaseConfig.acpClient;
                      final table = alert.record.section == 'Section 2'
                          ? 'odour_management_live'
                          : 'iot_bad_odour';
                      await client
                          .from(table)
                          .update({'pending_action': 'RESOLVE'})
                          .eq('sensor_id', alert.record.sensorId);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Resolve command sent to hardware!')),
                        );
                      }
                    } catch (e) {
                      _log.error('Error sending resolve command', e);
                    }
                  },
                  child: Text('Resolve', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ),
            ],
          )
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: AppTextStyles.bodySmall.copyWith(color: ColorConstants.textSecondary))),
          Expanded(child: Text(value, style: AppTextStyles.bodyMedium.copyWith(color: valueColor ?? ColorConstants.textPrimary, fontWeight: valueColor != null ? FontWeight.w600 : FontWeight.w500))),
        ],
      ),
    );
  }
}
