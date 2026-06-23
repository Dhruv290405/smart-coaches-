import 'package:flutter/material.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';


class StatusHelper {
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'good':
        return Colors.green;
      case 'warning':
        return ColorConstants.statusWarning;
      case 'critical':
        return ColorConstants.statusCritical;
      default:
        return ColorConstants.iconGrey;
    }
  }
}
