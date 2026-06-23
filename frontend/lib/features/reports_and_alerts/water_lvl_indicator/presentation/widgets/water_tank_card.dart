import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smart_coach_new/core/utils/app_dimensions.dart';
import 'package:smart_coach_new/core/utils/app_icons.dart';
import 'package:smart_coach_new/core/utils/app_text_styles.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/core/widgets/status_badge.dart';


class WaterTankCard extends StatelessWidget {
  final String coachNumber;
  final int ppPercentage;
  final int nppPercentage;
  final String ppStatus;
  final String nppStatus;
  final String lastUpdated;
  final VoidCallback onEyeIconTap;

  const WaterTankCard({
    super.key,
    required this.coachNumber,
    required this.ppPercentage,
    required this.nppPercentage,
    required this.ppStatus,
    required this.nppStatus,
    required this.lastUpdated,
    required this.onEyeIconTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 360;
    final labelSize = isSmall ? 10.0 : 12.0;
    final percentSize = isSmall ? 11.0 : 13.0;
    final coachSize = isSmall ? 12.0 : 14.0;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: ColorConstants.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  coachNumber,
                  style: AppTextStyles.coachNumber.copyWith(fontSize: coachSize),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: onEyeIconTap,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: ColorConstants.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: SvgPicture.asset(
                    AppIcons.eye,
                    width: 16,
                    height: 16,
                    colorFilter: const ColorFilter.mode(
                      ColorConstants.iconGrey,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _buildTankSection('PP', ppPercentage, ppStatus, labelSize, percentSize),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildTankSection('NPP', nppPercentage, nppStatus, labelSize, percentSize),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          Center(
            child: Text(
              lastUpdated,
              style: AppTextStyles.timestamp,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTankSection(String label, int percentage, String status, double labelSize, double percentSize) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: ColorConstants.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: AppTextStyles.label.copyWith(fontSize: labelSize),
                ),
                const SizedBox(width: 3),
                Text(
                  '$percentage%',
                  style: AppTextStyles.percentage.copyWith(fontSize: percentSize),
                ),
              ],
            ),
          ),
          const SizedBox(height: 7),
          StatusBadge(status: status),
        ],
      ),
    );
  }
}
