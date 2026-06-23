import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../utils/app_icons.dart';
import '../utils/app_text_styles.dart';
import '../utils/color_constants.dart';

class LocoBadge extends StatelessWidget {
  final String label;

  const LocoBadge({super.key, this.label = '1 Loco'});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: ColorConstants.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            AppIcons.train,
            width: 14,
            height: 14,
            colorFilter: const ColorFilter.mode(
              ColorConstants.white,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.badge),
        ],
      ),
    );
  }
}
