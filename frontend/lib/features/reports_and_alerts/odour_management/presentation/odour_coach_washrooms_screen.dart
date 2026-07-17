import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_coach_new/core/utils/app_dimensions.dart';
import 'package:smart_coach_new/core/utils/app_text_styles.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import '../data/models/odour_model.dart';
import 'widgets/odour_washroom_details_view.dart';

class OdourCoachWashroomsScreen extends StatelessWidget {
  final CoachToiletGroup group;

  const OdourCoachWashroomsScreen({super.key, required this.group});

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
        title: Text('Coach ${group.coachNumber} Washrooms', style: AppTextStyles.header1),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${group.trainNumber} - ${group.trainName}', style: AppTextStyles.bodyMedium),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: group.toilets.length,
              itemBuilder: (context, index) {
                final toilet = group.toilets[index];
                return _WashroomCard(toilet: toilet);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _WashroomCard extends StatefulWidget {
  final OdourCoachModel toilet;

  const _WashroomCard({required this.toilet});

  @override
  State<_WashroomCard> createState() => _WashroomCardState();
}

class _WashroomCardState extends State<_WashroomCard> {
  bool _isPressed = false;

  Color _statusColor(String status) {
    if (status.toLowerCase() == 'alert') return const Color(0xFFD32F2F);
    if (status.toLowerCase() == 'inactive') return const Color(0xFFBE8B22);
    return const Color(0xFF2E7D32);
  }

  @override
  Widget build(BuildContext context) {
    final isAlert = widget.toilet.hasAlert;
    final isActive = widget.toilet.isActive;
    
    String statusStr = 'Active';
    if (!isActive) statusStr = 'Inactive';
    if (isAlert) statusStr = 'Alert';
    
    final wc = _statusColor(statusStr);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OdourWashroomDetailsView(toilet: widget.toilet),
          ),
        );
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isAlert ? const Color(0xFFFFF0F0) : ColorConstants.cardBackground,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            border: Border.all(
              color: isAlert ? Colors.red.withValues(alpha: 0.15) : ColorConstants.divider,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.toilet.toiletPosition,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: ColorConstants.textPrimary),
                    ),
                  ),
                  Icon(
                    isAlert ? Icons.warning_amber_rounded : (isActive ? Icons.check_circle : Icons.cancel),
                    size: 18,
                    color: wc,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: wc.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  statusStr.toUpperCase(),
                  style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.bold, color: wc),
                ),
              ),
              const Spacer(),
              Text('Hygiene Score', style: GoogleFonts.poppins(fontSize: 10, color: ColorConstants.textSecondary)),
              Text('${widget.toilet.hygieneScore.toStringAsFixed(0)}%', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: wc)),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Door', style: GoogleFonts.poppins(fontSize: 9, color: ColorConstants.textSecondary)),
                      Text(widget.toilet.doorStatus, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: widget.toilet.doorStatus.toLowerCase() == 'open' ? ColorConstants.statusWarning : Colors.green)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('VOC', style: GoogleFonts.poppins(fontSize: 9, color: ColorConstants.textSecondary)),
                      Text('${widget.toilet.voc.toStringAsFixed(2)}', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: ColorConstants.textPrimary)),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
