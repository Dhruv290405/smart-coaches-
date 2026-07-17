import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_coach_new/core/utils/app_dimensions.dart';
import 'package:smart_coach_new/core/utils/app_icons.dart';
import 'package:smart_coach_new/core/utils/app_text_styles.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import '../../data/models/odour_model.dart';
import '../odour_coach_washrooms_screen.dart';

class OdourCoachesView extends StatelessWidget {
  final List<OdourCoachModel> coaches;
  final List<CoachToiletGroup> grouped;

  const OdourCoachesView({
    super.key,
    required this.coaches,
    required this.grouped,
  });

  @override
  Widget build(BuildContext context) {
    if (grouped.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Text("No coaches found matching filters"),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${grouped.length} Coaches', style: AppTextStyles.header3),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.95,
          ),
          itemCount: grouped.length,
          itemBuilder: (context, index) {
            return _CoachGroupCard(group: grouped[index]);
          },
        ),
      ],
    );
  }
}

class _CoachGroupCard extends StatefulWidget {
  final CoachToiletGroup group;
  const _CoachGroupCard({required this.group});

  @override
  State<_CoachGroupCard> createState() => _CoachGroupCardState();
}

class _CoachGroupCardState extends State<_CoachGroupCard> {
  bool _isPressed = false;

  Color _statusColor(String status) {
    if (status == 'Alert') return const Color(0xFFD32F2F);
    if (status == 'Inactive') return const Color(0xFFBE8B22);
    return const Color(0xFF2E7D32);
  }

  @override
  Widget build(BuildContext context) {
    final wc = _statusColor(widget.group.worstStatus);
    final displayReading = widget.group.toilets.isNotEmpty
        ? widget.group.toilets.map((t) => t.reading).reduce((a, b) => a > b ? a : b)
        : 0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OdourCoachWashroomsScreen(group: widget.group),
          ),
        );
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.group.alertToilets > 0 ? const Color(0xFFFFF0F0) : ColorConstants.cardBackground,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            border: Border.all(
              color: widget.group.alertToilets > 0 ? Colors.red.withValues(alpha: 0.15) : ColorConstants.divider,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Coach ${widget.group.coachNumber}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: ColorConstants.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: wc.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(Icons.air, color: wc, size: 16),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Train: ${widget.group.trainNumber}',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: ColorConstants.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '${widget.group.trainName}',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: ColorConstants.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Washrooms', style: GoogleFonts.poppins(fontSize: 8, color: ColorConstants.textTertiary)),
                      Text(
                        '${widget.group.totalToilets}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: ColorConstants.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Peak', style: GoogleFonts.poppins(fontSize: 8, color: ColorConstants.textTertiary)),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${displayReading.toStringAsFixed(2)} ppm',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: wc,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
