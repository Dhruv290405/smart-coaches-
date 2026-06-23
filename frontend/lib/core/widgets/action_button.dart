import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../utils/app_dimensions.dart';
import '../utils/app_text_styles.dart';
import '../utils/color_constants.dart';

class ActionButton extends StatelessWidget {
  final String label;
  final String? svgIcon;
  final VoidCallback onTap;
  final bool isPrimary;
  final bool isFullWidth;

  const ActionButton({
    super.key,
    required this.label,
    this.svgIcon,
    required this.onTap,
    this.isPrimary = false,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth < 360 ? 11.0 : 13.0;
    final iconSize = screenWidth < 360 ? 14.0 : AppDimensions.iconSmall;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isFullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isPrimary ? ColorConstants.primary : ColorConstants.cardBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: isPrimary ? null : Border.all(
            color: ColorConstants.divider,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (svgIcon != null) ...[
              SvgPicture.asset(
                svgIcon!,
                width: iconSize,
                height: iconSize,
                colorFilter: ColorFilter.mode(
                  isPrimary ? ColorConstants.white : ColorConstants.iconGrey,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                label,
                style: isPrimary
                    ? AppTextStyles.button.copyWith(fontSize: fontSize)
                    : AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: fontSize,
                      ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
