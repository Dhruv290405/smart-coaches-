import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/utils/toast_message_utils.dart';
import 'package:smart_coach_new/core/widgets/custom_button.dart';
import 'package:smart_coach_new/core/widgets/custom_text_field.dart';
import 'package:smart_coach_new/core/widgets/positive_integer_input_formatter.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/presentation/widgets/configure_train.dart';

class TrainCoachConfigDialog extends StatefulWidget {
  final CoachConfig config;
  final int coachIndex;

  const TrainCoachConfigDialog({
    super.key,
    required this.config,
    required this.coachIndex,
  });

  @override
  State<TrainCoachConfigDialog> createState() => _TrainCoachConfigDialogState();
}

class _TrainCoachConfigDialogState extends State<TrainCoachConfigDialog> {
  late TextEditingController uniqueNumberController;
  late TextEditingController displayIdController;
  late TextEditingController positionController;

  @override
  void initState() {
    super.initState();
    uniqueNumberController =
        TextEditingController(text: widget.config.uniqueNumber ?? '');
    displayIdController =
        TextEditingController(text: widget.config.displayId ?? '');
    positionController =
        TextEditingController(text: widget.config.position?.toString() ?? '');
  }

  @override
  void dispose() {
    uniqueNumberController.dispose();
    displayIdController.dispose();
    positionController.dispose();
    super.dispose();
  }

  void _saveCoach() {
    final uniqueNumberText = uniqueNumberController.text.trim();
    final displayIdText = displayIdController.text.trim();
    final positionText = positionController.text.trim();

    if (uniqueNumberText.isEmpty) {
      ToastMessageUtils.showMessage(
          context, 'Please enter ${widget.config.entityType} Unique Number');
      return;
    }

    if (displayIdText.isEmpty) {
      ToastMessageUtils.showMessage(context, 'Please enter ${widget.config.entityType} Display ID');
      return;
    }

    if (positionText.isEmpty) {
      ToastMessageUtils.showMessage(context, 'Please enter Position');
      return;
    }

    final position = int.parse(positionText);

    final updated = CoachConfig()
      ..uniqueNumber = uniqueNumberController.text.trim()
      ..displayId = displayIdController.text.trim()
      ..entityType = widget.config.entityType
      ..position = position;

    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.w)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3.w),
          color: Colors.white,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Configure ${widget.config.entityType}',
                    style: TextStyle(fontSize: 14.sp, color: Colors.black),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, size: 16.sp, color: Colors.black),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              CustomTextField(
                hintText: '${widget.config.entityType} Unique Number',
                labelText: 'Enter ${widget.config.entityType} Unique Number',
                controller: uniqueNumberController,
                isRequired: true,
              ),
              SizedBox(height: 2.h),
              CustomTextField(
                hintText: '${widget.config.entityType} Display ID',
                labelText: 'Enter ${widget.config.entityType} Display ID',
                controller: displayIdController,
                isRequired: true,
              ),
              SizedBox(height: 2.h),
              CustomTextField(
                hintText: 'Position',
                labelText: 'Enter Position',
                controller: positionController,
                isRequired: true,
                textInputType: TextInputType.number,
                inputFormatters: [PositiveIntegerInputFormatter()],
              ),
              SizedBox(height: 3.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton(
                    text: 'Cancel',
                    padding:
                        EdgeInsets.symmetric(vertical: 1.6.h, horizontal: 5.w),
                    textSize: 12,
                    radius: 6,
                    color: const Color(0xFFF2F3F5),
                    textColor: Colors.black,
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(width: 3.w),
                  CustomButton(
                    text: 'Save Coach',
                    padding:
                        EdgeInsets.symmetric(vertical: 1.6.h, horizontal: 5.w),
                    textSize: 12,
                    radius: 6,
                    onPressed: _saveCoach,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
