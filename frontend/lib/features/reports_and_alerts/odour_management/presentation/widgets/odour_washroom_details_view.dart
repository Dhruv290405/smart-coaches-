import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:smart_coach_new/core/utils/app_icons.dart';
import 'package:smart_coach_new/core/utils/app_text_styles.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import '../../data/models/odour_model.dart';
import '../../data/repository/odour_repository.dart';
import 'odour_sensor_modal.dart';

class OdourWashroomDetailsView extends StatelessWidget {
  final OdourCoachModel toilet;
  
  const OdourWashroomDetailsView({super.key, required this.toilet});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'good': 
      case 'normal':
        return Colors.green;
      case 'cold':
        return Colors.blue;
      case 'hot':
        return Colors.red;
      case 'warning': 
      case 'moderate':
      case 'dry':
        return ColorConstants.statusWarning;
      case 'critical': 
      case 'bad':
      case 'hot':
      case 'humid':
        return ColorConstants.statusCritical;
      default: return ColorConstants.iconGrey;
    }
  }

  String _fmtDt(String ts) {
    try { return DateFormat('dd/MM/yy HH:mm').format(DateTime.parse(ts).toLocal()); }
    catch (_) { return ts; }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<OdourCoachModel>>(
      stream: OdourRepository().watchOdourData(),
      initialData: [toilet],
      builder: (context, snapshot) {
        final currentToilet = snapshot.data?.firstWhere(
          (t) => t.deviceId == toilet.deviceId, 
          orElse: () => toilet
        ) ?? toilet;

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
            title: Text('${currentToilet.coachNumber} - ${currentToilet.toiletPosition}', style: AppTextStyles.header1),
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline, color: ColorConstants.primary),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => OdourSensorModal(coach: currentToilet),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _trainInfoCard(currentToilet),
                const SizedBox(height: 12),

                _card(child: _hygieneSection(currentToilet)),
                const SizedBox(height: 10),

                _card(child: _sensorSection(currentToilet)),
                const SizedBox(height: 10),

                _card(child: _doorSection(currentToilet)),
                const SizedBox(height: 10),

                _card(child: _deviceInfoSection(currentToilet)),
                const SizedBox(height: 10),

                _card(child: _systemHealthSection(currentToilet)),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _card({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: ColorConstants.white, borderRadius: BorderRadius.circular(12)),
    child: child,
  );

  Widget _trainInfoCard(OdourCoachModel wm) => Container(
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
        Expanded(child: Text('${wm.trainNumber} - ${wm.trainName}', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: ColorConstants.primary))),
      ]),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          _infoPill('Coach: ${wm.coachNumber}'),
          _infoPill(wm.coachType),
          _infoPill('Device: ${wm.deviceId}'),
          _infoPill('Updated: ${_fmtDt(wm.timestamp)}'),
        ],
      ),
    ]),
  );

  Widget _infoPill(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: ColorConstants.cardBackground, borderRadius: BorderRadius.circular(8)),
    child: Text(label, style: AppTextStyles.bodySmall),
  );

  Widget _hygieneSection(OdourCoachModel wm) {
    final score = wm.hygieneScore;
    final status = score >= 70 ? 'Good' : score >= 50 ? 'Warning' : 'Critical';
    final color = _statusColor(status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Overall Hygiene Score', style: AppTextStyles.header2),
        const SizedBox(height: 24),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 160,
              height: 160,
              child: CircularProgressIndicator(
                value: score / 100,
                strokeWidth: 14,
                backgroundColor: color.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation(color),
                strokeCap: StrokeCap.round,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${score.toStringAsFixed(0)}%', style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w800, color: color)),
                Text(status, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: color)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          '* Hygiene score is considered Low if below 70% and Critical if below 50%.',
          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: ColorConstants.textSecondary, fontStyle: FontStyle.italic),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _sensorSection(OdourCoachModel wm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sensor Readings', style: AppTextStyles.header2),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
          children: [
            _circularSensorTile('VOC', wm.voc, 'ppm', wm.vocThreshold, wm.vocStatus),
            _circularSensorTile('NH₃', wm.nh3, 'ppm', wm.nh3Threshold, wm.nh3Status),
            _circularSensorTile('H₂S', wm.h2s, 'ppm', wm.h2sThreshold, wm.h2sStatus),
            _circularSensorTile('Smoke', wm.smoke, 'ppm', wm.smokeThreshold, wm.smokeStatus),
            _circularSensorTile('Temp', wm.temperature, '°C', 40.0, wm.tempStatus),
            _circularSensorTile('Humidity', wm.humidity, '% RH', 90.0, wm.humidityStatus),
          ],
        ),
      ],
    );
  }

  Widget _circularSensorTile(String label, double value, String unit, double threshold, String status) {
    final color = _statusColor(status);
    double percent = value / threshold;
    if (percent > 1.0) percent = 1.0;
    if (label == 'Temp' || label == 'Humidity') {
       percent = value / (label == 'Temp' ? 50.0 : 100.0);
    }
    
    String displayStatus = status;
    String dsLower = status.toLowerCase();
    
    IconData statusIcon = Icons.check_circle;
    if (dsLower == 'warning' || dsLower == 'moderate' || dsLower == 'dry' || dsLower == 'cold') {
      statusIcon = Icons.warning_rounded;
    } else if (dsLower == 'critical' || dsLower == 'bad' || dsLower == 'hot' || dsLower == 'humid') {
      statusIcon = Icons.error_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: ColorConstants.textSecondary)),
          const SizedBox(height: 12),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CustomPaint(
                  painter: NeedleGaugePainter(percent: percent, color: color),
                ),
              ),
              Positioned(
                bottom: 0,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text('${value.toStringAsFixed(2)}', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(unit, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: ColorConstants.textSecondary)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15), 
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, size: 10, color: color),
                const SizedBox(width: 4),
                Text(displayStatus.toUpperCase(), style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w800, color: color, letterSpacing: 0.5)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _doorSection(OdourCoachModel wm) {
    final isOpen = wm.doorStatus.toLowerCase() == 'open';
    final doorColor = isOpen ? ColorConstants.statusWarning : Colors.green;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Door Activity', style: AppTextStyles.header2),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: doorColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: doorColor.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(isOpen ? Icons.door_front_door : Icons.door_front_door_outlined, size: 28, color: doorColor),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Current State', style: AppTextStyles.bodySmall),
                Text(wm.doorStatus.toUpperCase(), style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: doorColor)),
              ]),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.water_drop, size: 14, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text('U Count', style: AppTextStyles.bodySmall),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('${wm.uCount}', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.blue)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.brown.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.brown.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.spa, size: 14, color: Colors.brown),
                        const SizedBox(width: 4),
                        Text('F Count', style: AppTextStyles.bodySmall),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('${wm.fCount}', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.brown)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _dataRow('Open Events Today', '${wm.doorOpenEventsToday}'),
        const Divider(color: ColorConstants.divider),
        _dataRow('Total Cycles Today', '${wm.totalDoorCyclesToday}'),
        const Divider(color: ColorConstants.divider),
        _dataRow('Average Open Duration', wm.averageOpenDuration),
        const Divider(color: ColorConstants.divider),
        _dataRow('Longest Open Duration', wm.longestOpenDuration),
        const SizedBox(height: 16),
        Text('Recent Events', style: AppTextStyles.header2.copyWith(fontSize: 14)),
        const SizedBox(height: 8),
        if (wm.recentDoorEventsTimeline.isEmpty)
          Text('No recent events', style: AppTextStyles.bodyMedium.copyWith(color: ColorConstants.textSecondary)),
        ...wm.recentDoorEventsTimeline.map((e) {
          final isClose = e['event']?.contains('Closed') ?? false;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(isClose ? Icons.check_circle : Icons.door_front_door, size: 14, color: isClose ? Colors.green : ColorConstants.primary),
                const SizedBox(width: 8),
                Text(e['time'] ?? '', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: ColorConstants.textPrimary)),
                const SizedBox(width: 8),
                Text(e['event'] ?? '', style: GoogleFonts.poppins(fontSize: 12, color: ColorConstants.textSecondary)),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _deviceInfoSection(OdourCoachModel wm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Device Information', style: AppTextStyles.header2),
        const SizedBox(height: 12),
        _dataRow('Device ID', wm.deviceId),
        const Divider(color: ColorConstants.divider),
        _dataRow('Sensor ID', wm.sensorId),
        const Divider(color: ColorConstants.divider),
        _dataRow('Train Number', wm.trainNumber),
        const Divider(color: ColorConstants.divider),
        _dataRow('Coach Number', wm.coachNumber),
      ],
    );
  }

  Widget _systemHealthSection(OdourCoachModel wm) {
    final onlineColor = wm.isOnline ? Colors.green : ColorConstants.statusCritical;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('System Health', style: AppTextStyles.header2),
        const SizedBox(height: 12),
        Row(children: [
          Container(
            width: 10, height: 10,
            decoration: BoxDecoration(shape: BoxShape.circle, color: onlineColor),
          ),
          const SizedBox(width: 8),
          Text(wm.isOnline ? 'Online' : 'Offline', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: onlineColor)),
        ]),
        const SizedBox(height: 8),
        _dataRow('Communication', wm.communicationStatus),
        const Divider(color: ColorConstants.divider),
        _dataRow('Last Data Received', _fmtDt(wm.lastDataReceived)),
      ],
    );
  }

  Widget _dataRow(String label, String value, {Color? valueColor}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Flexible(child: Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500, color: valueColor ?? ColorConstants.textPrimary), textAlign: TextAlign.right)),
      ],
    ),
  );
}

class NeedleGaugePainter extends CustomPainter {
  final double percent;
  final Color color;

  NeedleGaugePainter({required this.percent, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 5);
    final radius = size.width / 2;

    final Paint trackPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final Paint valuePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius - 4);

    final startAngle = math.pi * 0.8; 
    final sweepAngle = math.pi * 1.4; 

    canvas.drawArc(rect, startAngle, sweepAngle, false, trackPaint);
    canvas.drawArc(rect, startAngle, sweepAngle * percent, false, valuePaint);

    final angle = startAngle + (sweepAngle * percent);
    final needleLength = radius - 10;
    
    final needleEnd = Offset(
      center.dx + needleLength * math.cos(angle),
      center.dy + needleLength * math.sin(angle),
    );

    final Paint needlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, needleEnd, needlePaint);
    
    final Paint dotPaint = Paint()..color = color;
    canvas.drawCircle(center, 5, dotPaint);
    final Paint innerDotPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, 2, innerDotPaint);
  }

  @override
  bool shouldRepaint(covariant NeedleGaugePainter oldDelegate) {
    return oldDelegate.percent != percent || oldDelegate.color != color;
  }
}
