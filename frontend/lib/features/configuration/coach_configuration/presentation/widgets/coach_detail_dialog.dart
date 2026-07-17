import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/utils/constants.dart';
import 'package:smart_coach_new/core/utils/enums.dart';
import 'package:smart_coach_new/core/utils/utils.dart';
import 'package:smart_coach_new/core/widgets/chip_view.dart';
import 'package:smart_coach_new/core/widgets/custom_button.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/domain/entities/coach_entity.dart';

class CoachDetailDialog extends StatelessWidget {
  final CoachEntity coachEntity;

  const CoachDetailDialog({super.key, required this.coachEntity});

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
              /// Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Coach Details',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, size: 18.sp, color: Colors.black),
                  ),
                ],
              ),
              SizedBox(height: 2.h),

              /// Coach Info Fields
              _buildTwoCols(
                'Coach ID',
                coachEntity.coachId?.toString(),
                'Entity Type',
                coachEntity.entityType?.isNotEmpty == true ? coachEntity.entityType : null,
              ),
              _buildTwoCols(
                'Coach Technical No',
                coachEntity.coachUniqueId,
                'Make',
                coachEntity.makeOfCoach?.isNotEmpty == true ? coachEntity.makeOfCoach : null,
              ),
              _buildTwoCols(
                'Type',
                coachEntity.typeOfCoach?.isNotEmpty == true ? coachEntity.typeOfCoach : null,
                'Manufacturing Year',
                coachEntity.manufacturingYear.toString(),
              ),
              _buildTwoCols(
                '# Master Modules',
                coachEntity.noOfMasterModule?.toString(),
                'Coach Status',
                coachEntity.coachStatus,
              ),

              SizedBox(height: 1.h),
              _buildTwoCols(
                'Created By',
                coachEntity.createdBy?.toString(),
                'Last Updated',
                _formatDateTime(coachEntity.updatedAt),
              ),

              /// Master Module Details
              if (coachEntity.masterModuleIds?.isNotEmpty == true) ...[
                SizedBox(height: 1.h),
                Container(
                  width: double.infinity,
                  height: 1,
                  color: Colors.grey.shade300,
                ),
                SizedBox(height: 1.h),
                Text(
                  'Master Module Details',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 0.5.h),
                _buildItem(
                  label: 'Module IDs',
                  value: coachEntity.masterModuleIds,
                ),
                if (coachEntity.masterModuleLocations?.isNotEmpty == true)
                  _buildItem(
                    label: 'Locations',
                    value: coachEntity.masterModuleLocations,
                  ),
              ],
              SizedBox(height: 2.h),

              /// Action Button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton(
                    text: 'Close',
                    padding: EdgeInsets.symmetric(
                      vertical: 1.6.h,
                      horizontal: 5.w,
                    ),
                    textSize: 12,
                    radius: 6,
                    color: const Color(0xFFF2F3F5),
                    textColor: Colors.black,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a single row with two columns
  Widget _buildTwoCols(
    String label1,
    String? value1,
    String label2,
    String? value2,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildItem(
            label: label1,
            value: value1,
            isStatusView: false,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: _buildItem(
            label: label2,
            value: value2,
            isStatusView: false,
          ),
        ),
      ],
    );
  }

  /// Common label-value item (reused)
  Widget _buildItem({
    required String label,
    required String? value,
    bool isStatusView = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.0.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade700),
          ),
          SizedBox(height: 0.3.h),
          isStatusView
              ? _buildStatusView(label: label, statusValue: value)
              : Text(
                  value ?? '----',
                  style: TextStyle(fontSize: 12.5.sp, color: Colors.black),
                ),
        ],
      ),
    );
  }

  /// Status view with colored chip
  Widget _buildStatusView({
    required String label,
    required String? statusValue,
  }) {
    final statusText = statusValue?.replaceAll(' ', '').toLowerCase();
    bool isActive =
        statusText == DeviceStatus.active.name.toLowerCase();
    bool isUnderMaintenance =
        statusText == DeviceStatus.underMaintenance.name.toLowerCase();
    bool isRetired =
        statusText == DeviceStatus.retired.name.toLowerCase();

    Color color = Colors.black;
    if (isActive) {
      color = Colors.green;
    } else if (isUnderMaintenance) {
      color = const Color(0xFFC0AF6A);
    } else if (isRetired) {
      color = Colors.red.shade900;
    }

    return _chipView(statusValue, color.withValues(alpha: 0.13), color);
  }

  Widget _chipView(String? text, Color bgColor, Color textColor) {
    return ChipView(
      text: text ?? 'N/A',
      bgColor: bgColor,
      textColor: textColor,
    );
  }

  String _formatDateTime(String? datetime) {
    return Utils.formatReadableDate(
          datetime,
          dateFormat: Constants.dateTimeFormatToShowInTable,
        ) ??
        '';
  }
}
