import 'package:flutter/material.dart';

import '../utils/app_text_styles.dart';

class UpdateInfo extends StatelessWidget {
  final String lastUpdated;
  final String refilledBy;

  const UpdateInfo({
    super.key,
    required this.lastUpdated,
    required this.refilledBy,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Last Updated: $lastUpdated',
          style: AppTextStyles.bodySmall,
        ),
        const SizedBox(height: 2),
        Text(
          'Refilled By: $refilledBy',
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }
}
