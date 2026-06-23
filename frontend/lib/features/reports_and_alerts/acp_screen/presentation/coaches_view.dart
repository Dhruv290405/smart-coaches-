import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smart_coach_new/features/reports_and_alerts/acp_screen/presentation/widgets/acp_coach_card.dart';
import 'package:smart_coach_new/features/reports_and_alerts/acp_screen/presentation/widgets/chain_pulled_modal.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/utils/color_constants.dart';
import '../data/models/acp_model.dart';

class AcpCoachesView extends StatelessWidget {
  final List<AcpCoachModel> coaches;

  const AcpCoachesView({super.key, required this.coaches});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppStrings.alarmChain, style: AppTextStyles.header2),
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
                    colorFilter: const ColorFilter.mode(
                      ColorConstants.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text('${coaches.length} Coaches',
                      style: AppTextStyles.badge),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Dynamic height grid using Wrap
        LayoutBuilder(
          builder: (context, constraints) {
            final double spacing = 12;
            final int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
            final double itemWidth = (constraints.maxWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: coaches.map((coach) {
                return SizedBox(
                  width: itemWidth,
                  child: AcpCoachCard(
                    coach: coach,
                    onEyeIconTap: () {
                      showDialog(
                        context: context,
                        barrierColor: Colors.black.withValues(alpha: 0.5),
                        builder: (_) => ChainPulledModal(coach: coach),
                      );
                    },
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
