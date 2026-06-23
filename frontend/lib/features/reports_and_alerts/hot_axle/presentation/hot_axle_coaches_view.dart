import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smart_coach_new/core/utils/app_icons.dart';
import 'package:smart_coach_new/core/utils/app_strings.dart';
import 'package:smart_coach_new/core/utils/app_text_styles.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/features/reports_and_alerts/hot_axle/data/models/hot_axle_model.dart';
import 'package:smart_coach_new/features/reports_and_alerts/hot_axle/presentation/widgets/hot_axle_coach_card.dart';
import 'package:smart_coach_new/features/reports_and_alerts/hot_axle/presentation/widgets/hot_axle_modal.dart';

class HotAxleCoachesView extends StatelessWidget {
  final List<HotAxleCoachModel> coaches;

  const HotAxleCoachesView({super.key, required this.coaches});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppStrings.hotAxles, style: AppTextStyles.header2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: ColorConstants.primary, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  SvgPicture.asset(AppIcons.train, width: 14, height: 14, colorFilter: const ColorFilter.mode(ColorConstants.white, BlendMode.srcIn)),
                  const SizedBox(width: 4),
                  Text('${coaches.length} Coaches', style: AppTextStyles.badge),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth - 10) / 2;
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: coaches.map((coach) => SizedBox(
                width: cardWidth,
                child: HotAxleCoachCard(
                  coach: coach,
                  onEyeIconTap: () => showDialog(
                    context: context,
                    builder: (_) => HotAxleModal(coach: coach),
                  ),
                ),
              )).toList(),
            );
          },
        ),
      ],
    );
  }
}