import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smart_coach_new/features/reports_and_alerts/fsds_screen/presentation/widgets/fsds_coach_card.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/utils/color_constants.dart';
import 'data/models/fsds_model.dart';

class FsdsCoachesView extends StatelessWidget {
  final List<FsdsAssetModel> assets;
  const FsdsCoachesView({super.key, required this.assets});

  @override
  Widget build(BuildContext context) {
    if (assets.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text("No data found matching filters"),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('FSDS Assets', style: AppTextStyles.header2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: ColorConstants.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    AppIcons.train,
                    width: 14,
                    height: 14,
                    colorFilter: const ColorFilter.mode(ColorConstants.white, BlendMode.srcIn),
                  ),
                  const SizedBox(width: 4),
                  Text('${assets.length} Assets', style: AppTextStyles.badge),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            const double spacing = 12;
            final int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
            final double itemWidth =
                (constraints.maxWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: assets.map((asset) {
                return SizedBox(
                  width: itemWidth,
                  child: FsdsCoachCard(coach: asset),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}