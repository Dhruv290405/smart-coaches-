import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../utils/app_dimensions.dart';
import '../utils/app_text_styles.dart';
import '../utils/color_constants.dart';

class ViewTypeSelector extends StatelessWidget {
  final String label;
  final String svgIcon;
  final bool isSelected;
  final VoidCallback onTap;

  const ViewTypeSelector({
    super.key,
    required this.label,
    required this.svgIcon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth < 360 ? 14.0 : AppDimensions.iconSmall;
    final fontSize = screenWidth < 360 ? 11.0 : 13.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? ColorConstants.primary : ColorConstants.cardBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(
            color: isSelected ? ColorConstants.primary : ColorConstants.divider,
            width: 1.5,
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                svgIcon,
                width: iconSize,
                height: iconSize,
                colorFilter: const ColorFilter.mode(
                  ColorConstants.iconGrey,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isSelected ? ColorConstants.white : ColorConstants.textSecondary,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  fontSize: fontSize,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
