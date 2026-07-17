import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/utils/constants.dart';
import 'package:smart_coach_new/core/utils/utils.dart';
import 'package:smart_coach_new/core/widgets/custom_button.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/domain/entities/train_configs_entity.dart';

class TrainDetailDialog extends StatelessWidget {
  final TrainConfigsEntity trainEntity;

  const TrainDetailDialog({super.key, required this.trainEntity});

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
                    'Train Details',
                    style: TextStyle(fontSize: 14.sp, color: Colors.black),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, size: 16.sp, color: Colors.black),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTwoCols(
                      'Train Number',
                      trainEntity.trainNumber?.toString() ?? '',
                      'Train Name',
                      trainEntity.trainName),
                  _buildTwoCols(
                      'Origination Region',
                      trainEntity.originationRegionName?.toString(),
                      'Region Name',
                      trainEntity.regionName?.toString()),
                  _buildTwoCols(
                      'Departure Station',
                      trainEntity.departureStationName?.toString(),
                      'Destination Station',
                      trainEntity.destinationStationName?.toString()),
                  _buildTwoCols('Line', trainEntity.line, 'Train Operator',
                      trainEntity.trainOperator),
                  _buildTwoCols(
                      'Loco Number',
                      trainEntity.engineNumber,
                      'Number of Coaches',
                      trainEntity.coaches?.length.toString() ?? 'N/A'),
                  SizedBox(height: 1.h),
                  _buildTwoCols('Created By', trainEntity.createdBy?.toString(),
                      'Last Updated', _formatDateTime(trainEntity.updatedAt ?? trainEntity.createdAt)),
                  SizedBox(height: 1.h),
                ],
              ),
              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton(
                    text: 'Close',
                    padding:
                        EdgeInsets.symmetric(vertical: 1.6.h, horizontal: 5.w),
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

  /// Two-column row
  Widget _buildTwoCols(
    String label1,
    String? value1,
    String label2,
    String? value2,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildItem(label: label1, value: value1)),
        SizedBox(width: 3.w),
        Expanded(child: _buildItem(label: label2, value: value2)),
      ],
    );
  }

  /// Common label-value item (reused)
  Widget _buildItem({
    required String label,
    required String? value,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.0.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade700)),
          SizedBox(height: 0.3.h),
          Text(value ?? 'N/A',
              style: TextStyle(fontSize: 12.5.sp, color: Colors.black)),
        ],
      ),
    );
  }

  String _formatDateTime(String? datetime) {
    return Utils.formatReadableDate(datetime,
            dateFormat: Constants.dateTimeFormatToShowInTable) ??
        '';
  }
}
