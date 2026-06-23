import 'package:flutter/material.dart';

import '../utils/app_text_styles.dart';
import '../utils/color_constants.dart';


class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  Color _getBackgroundColor() {
    switch (status.toLowerCase()) {
      case 'good':
        return ColorConstants.statusGood;
      case 'warning':
        return ColorConstants.statusWarning;
      case 'critical':
        return ColorConstants.statusCritical;
      default:
        return ColorConstants.iconGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getBackgroundColor();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          status,
          style: AppTextStyles.badge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
