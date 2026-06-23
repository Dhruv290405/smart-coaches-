import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/utils/image_utils.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/presentation/widgets/train_coach_config_dialog.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/presentation/widgets/configure_train.dart';

class TrainCoachGrid extends StatefulWidget {
  final List<CoachConfig> coaches;

  const TrainCoachGrid({super.key, required this.coaches});

  @override
  State<TrainCoachGrid> createState() => _TrainCoachGridState();
}

class _TrainCoachGridState extends State<TrainCoachGrid> {
  // late List<CoachConfig> coaches;

  @override
  void didUpdateWidget(covariant TrainCoachGrid oldWidget) {
    super.didUpdateWidget(oldWidget);

    // if (oldWidget.coaches.length != widget.coaches.length) {
    //   final updatedCoaches = List<CoachConfig>.generate(
    //     widget.coaches.length,
    //     (index) => index < widget.coaches.length ? widget.coaches[index] : CoachConfig(),
    //   );
    //
    //   setState(() {
    //     widget.coaches = updatedCoaches;
    //   });
    // }
  }

  @override
  void initState() {
    super.initState();
    // coaches = List.generate(widget.coaches.length, (_) => CoachConfig());
  }

  @override
  @override
  Widget build(BuildContext context) {
    // Create a new sorted list — don't modify the original directly
    final sortedCoaches = List<CoachConfig>.from(widget.coaches)
      ..sort((a, b) {
        if (a.entityType == 'Loco' && b.entityType != 'Loco') return -1;
        if (a.entityType != 'Loco' && b.entityType == 'Loco') return 1;
        return 0;
      });

    return GridView.builder(
      itemCount: sortedCoaches.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4.w,
        mainAxisSpacing: 2.h,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final coach = sortedCoaches[index];
        return GestureDetector(
          onTap: () async {
            final updated = await showDialog<CoachConfig>(
              context: context,
              builder: (_) => TrainCoachConfigDialog(
                coachIndex: index + 1,
                config: coach,
              ),
            );

            if (updated != null) {
              setState(() {
                // Update original list at the right index
                final originalIndex =
                widget.coaches.indexOf(coach);
                widget.coaches[originalIndex] = updated;
              });
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: coach.isConfigured ? Color(0xFFDCFCE7) : Color(0xFFFEE2E1),
              borderRadius: BorderRadius.circular(3.w),
            ),
            padding: EdgeInsets.all(3.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  ImageUtils.icTrain,
                  height: 4.h,
                  width: 4.h,
                  colorFilter: ColorFilter.mode(
                    coach.isConfigured ? Color(0xFF1E6138) : Color(0xFF59030C),
                    BlendMode.srcIn,
                  ),
                ),
                Text(
                  coach.isConfigured
                      ? coach.displayId!
                      : '${coach.entityType} ${index + 1}',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: coach.isConfigured
                        ? Color(0xFF1E6138)
                        : Color(0xFF59030C),
                  ),
                ),
                if (coach.isConfigured && coach.entityType == "Loco")
                  Text(
                    '${coach.entityType}',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: coach.isConfigured
                          ? Color(0xFF1E6138)
                          : Color(0xFF59030C),
                    ),
                  ),
                if (coach.isConfigured)
                  Padding(
                    padding: EdgeInsets.only(top: 0.3.h),
                    child: Text(
                      'Position ${coach.position}',
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1E6138),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
