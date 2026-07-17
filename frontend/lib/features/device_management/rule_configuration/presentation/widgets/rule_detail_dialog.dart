import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/utils/constants.dart';
import 'package:smart_coach_new/core/utils/utils.dart';
import 'package:smart_coach_new/core/widgets/chip_view.dart';
import 'package:smart_coach_new/core/widgets/custom_button.dart';
import 'package:smart_coach_new/features/device_management/rule_configuration/domain/entities/rule_configuration_entity.dart';

class RuleDetailDialog extends StatelessWidget {
  final RuleConfigurationEntity sensorItem;

  const RuleDetailDialog({super.key, required this.sensorItem});

  @override
  Widget build(BuildContext context) {
    List<String> deviceNames = sensorItem.deviceNames;
    List<String> sensorTypeNames = sensorItem.sensorTypeNames;
    List<ConditionBlockEntity> conditions = sensorItem.conditions;

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
                  Expanded(
                    child: Text(
                      'View Rule: ${sensorItem.ruleName ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, size: 16.sp, color: Colors.black),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Container(
                margin: EdgeInsets.only(bottom: 2.h),
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: Color(0xFFFAFAFC),
                  borderRadius: BorderRadius.circular(4.w),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: _buildItem(
                                label: 'Rule ID',
                                value: 'RULE-${sensorItem.ruleId ?? 'N/A'}')),
                        SizedBox(width: 3.w),
                        Expanded(
                            child: _buildItem(
                                label: 'Rule Name',
                                value: sensorItem.ruleName)),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildItem(
                            label: 'Device(s)',
                            value: deviceNames.isNotEmpty
                                ? deviceNames.join(', ')
                                : 'N/A',
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: _buildItem(
                            label: 'Sensor Type(s)',
                            value: sensorTypeNames.isNotEmpty
                                ? sensorTypeNames.join(', ')
                                : 'N/A',
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildItem(
                            label: 'Evaluation Frequency',
                            value:
                                '${sensorItem.evaluationFrequency ?? 'N/A'} ${sensorItem.evaluationUnit ?? ''}',
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: _buildItem(
                            label: 'Last Updated',
                            value: Utils.formatReadableDate(sensorItem.updatedAt, dateFormat: Constants.dateTimeFormatToShowInTable) ?? '',
                          ),
                        ),
                      ],
                    ),
                    _buildItem(
                      label: 'Status',
                      value: (sensorItem.isActive ?? false)
                          ? 'Active'
                          : 'Inactive',
                      isStatusView: true,
                    ),
                  ],
                ),
              ),
              if (conditions.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 1.h),
                  child: Text(
                    'Conditions',
                    style: TextStyle(
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ...conditions.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final condition = entry.value;
                return Container(
                  margin: EdgeInsets.only(bottom: 1.5.h),
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: Color(0xFFFAFAFC),
                    borderRadius: BorderRadius.circular(4.w),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _chipView(condition.alertType ?? 'N/A',
                              Color(0xFFFBF9C0), Color(0xFF9C8126)),
                          SizedBox(width: 2.w),
                          Text(
                            'Condition $index',
                            style: TextStyle(
                              fontSize: 13.sp,
                              // fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: _buildItem(
                                  label: 'Value Type',
                                  value: condition.valueType)),
                          SizedBox(width: 3.w),
                          Expanded(
                              child: _buildItem(
                                  label: 'Value Format',
                                  value: condition.valueFormat)),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: _buildItem(
                                  label: 'SI Unit', value: condition.siUnit)),
                          SizedBox(width: 3.w),
                          Expanded(
                              child: _buildItem(
                                  label: 'Operator',
                                  value: condition.operator)),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: _buildItem(
                                  label: 'Threshold',
                                  value: condition.threshold.toString())),
                          SizedBox(width: 3.w),
                          Expanded(
                              child: _buildItem(
                                  label: 'Alert Type',
                                  value: condition.alertType)),
                        ],
                      ),
                      _buildItem(
                          label: 'Alert Message',
                          value: condition.alertMessageTemplate),
                      _buildItem(
                          label: 'Alert Description',
                          value: condition.alertDescription),
                    ],
                  ),
                );
              }),
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
                  value ?? 'N/A',
                  style: TextStyle(fontSize: 12.5.sp, color: Colors.black),
                ),
        ],
      ),
    );
  }

  Widget _buildStatusView(
      {required String label, required String? statusValue}) {
    bool isActive = statusValue?.toLowerCase() == 'active';
    bool isPending = statusValue?.toLowerCase() == 'pending';
    bool isInActive = statusValue?.toLowerCase() == 'inactive';
    Color color = Colors.black;

    if (isActive) {
      color = Colors.green;
    } else if (isPending) {
      color = Colors.red.shade900;
    } else if (isInActive) {
      color = Color(0xFFC0AF6A);
    }
    return _chipView(statusValue, color.withValues(alpha: 0.13), color);
  }

  Widget _chipView(String? text, Color bgColor, Color textColor) {
    return ChipView(
      text: text,
      bgColor: bgColor,
      textColor: textColor,
    );
  }
}
