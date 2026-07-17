import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HamsDataModel {
  final int id;
  final String deviceId;
  final String masterId;
  final double temperature;
  final String status;
  final String tempState;
  final String receivedTimestamp;
  final String batteryStatus;
  final double batteryVoltage;

  HamsDataModel({
    required this.id,
    required this.deviceId,
    required this.masterId,
    required this.temperature,
    required this.status,
    required this.tempState,
    required this.receivedTimestamp,
    required this.batteryStatus,
    required this.batteryVoltage,
  });

  factory HamsDataModel.fromJson(Map<String, dynamic> json) {
    return HamsDataModel(
      id: json['id'] ?? 0,
      deviceId: json['device_id']?.toString() ?? '',
      masterId: json['master_id']?.toString() ?? '',
      temperature: (json['temperature'] ?? 0.0).toDouble(),
      status: json['status']?.toString() ?? 'Low',
      tempState: json['temp_state']?.toString() ?? 'Normal',
      receivedTimestamp: json['received_timestamp']?.toString() ?? '',
      batteryStatus: json['battery_status']?.toString() ?? 'Low',
      batteryVoltage: (json['battery_voltage'] ?? 0.0).toDouble(),
    );
  }
}

class HamsDeviceCard extends StatelessWidget {
  final HamsDataModel data;
  final int sequenceNumber;
  final VoidCallback? onTap;

  const HamsDeviceCard({
    super.key,
    required this.data,
    required this.sequenceNumber,
    this.onTap,
  });

  Color _tempColor(double temp) {
    if (temp > 80) return const Color(0xFFE53935);
    if (temp > 60) return const Color(0xFFFF9800);
    return const Color(0xFF4CAF50);
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'high': return const Color(0xFFE53935);
      case 'moderate': return const Color(0xFFFF9800);
      default: return const Color(0xFF4CAF50);
    }
  }

  Color _batColor(String bat) {
    switch (bat.toLowerCase()) {
      case 'low': return const Color(0xFFE53935);
      case 'moderate': return const Color(0xFFFF9800);
      default: return const Color(0xFF4CAF50);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tempC = _tempColor(data.temperature);
    final tColor = _statusColor(data.tempState);
    final bColor = _batColor(data.batteryStatus);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8ECF0), width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(color: tempC.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  alignment: Alignment.center,
                  child: Text('$sequenceNumber', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: tempC)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Device: ${data.deviceId}', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF1A1D21)), overflow: TextOverflow.ellipsis, maxLines: 1),
                      Text('Master: ${data.masterId}', style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF6B7280)), overflow: TextOverflow.ellipsis, maxLines: 1),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: tempC.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                  child: Text(data.status.toUpperCase(), style: GoogleFonts.poppins(fontSize: 8, fontWeight: FontWeight.w700, color: tempC, letterSpacing: 0.5)),
                ),
              ],
            ),
            const Spacer(),
            Center(
              child: Text('${data.temperature.toStringAsFixed(1)}°C', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: tempC)),
            ),
            const SizedBox(height: 2),
            Center(
              child: Text('Temperature', style: GoogleFonts.poppins(fontSize: 9, color: const Color(0xFF9CA3AF))),
            ),
            const Spacer(),
            _infoRow(Icons.thermostat, 'State', data.tempState, tColor),
            const SizedBox(height: 3),
            _infoRow(Icons.battery_std, 'Battery', '${data.batteryStatus} (${data.batteryVoltage.toStringAsFixed(2)}V)', bColor),
            const SizedBox(height: 3),
            _infoRow(Icons.access_time, 'Time', _formatTime(data.receivedTimestamp), const Color(0xFF4CAF50)),
          ],
        ),
      ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Row(
            children: [
              Text('$label: ', style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF6B7280))),
              Flexible(child: Text(value, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: const Color(0xFF1A1D21)), overflow: TextOverflow.ellipsis, maxLines: 1)),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTime(String ts) {
    if (ts.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(ts.contains('T') ? ts : ts.replaceFirst(' ', 'T')).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return ts;
    }
  }
}
