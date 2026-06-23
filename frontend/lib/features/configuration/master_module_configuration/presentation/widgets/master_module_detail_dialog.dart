import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/utils/constants.dart';
import 'package:smart_coach_new/core/utils/enums.dart';
import 'package:smart_coach_new/core/utils/utils.dart';
import 'package:smart_coach_new/core/widgets/chip_view.dart';
import 'package:smart_coach_new/core/widgets/custom_button.dart';
import 'package:smart_coach_new/features/configuration/master_module_configuration/domain/entities/master_module_entity.dart';

class MasterModuleDetailDialog extends StatelessWidget {
  final MasterModuleEntity masterModuleEntity;

  const MasterModuleDetailDialog({super.key, required this.masterModuleEntity});

  @override
  Widget build(BuildContext context) {
    final deviceNames = masterModuleEntity.deviceNames;

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
                    'Module Details',
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
                  _buildTwoCols('Module ID', masterModuleEntity.moduleUniqueId,
                      'Coach ID', masterModuleEntity.coach?.coachUniqueId),
                  _buildTwoCols('Make/Model', masterModuleEntity.makeModel,
                      'Firmware Version', masterModuleEntity.firmwareVersion),
                  _buildTwoCols(
                      'Serial Number',
                      masterModuleEntity.serialNumber,
                      'Installation Date',
                      _formatDateTime(masterModuleEntity.installationDate)),
                  _buildTwoCols('Location', masterModuleEntity.location,
                      'Placement Type', masterModuleEntity.placementType),
                  _buildTwoCols(
                      'SIM Number',
                      masterModuleEntity.simNo,
                      'SIM Status',
                      masterModuleEntity.simStatus,
                      isStatus1: false,
                      isStatus2: true),
                  _buildTwoCols(
                    'Primary Provider',
                    masterModuleEntity.serviceProviderPrimary,
                    'Secondary Provider',
                    masterModuleEntity.serviceProviderSecondary,
                  ),
                  _buildTwoCols(
                    'Activation Date',
                    _formatDateTime(masterModuleEntity.activationDate),
                    'Recharge Date',
                    _formatDateTime(masterModuleEntity.rechargeDate),
                  ),
                  _buildTwoCols(
                    'Battery Capacity',
                    masterModuleEntity.batteryCapacity?.toString(),
                    'Battery Type',
                    masterModuleEntity.batteryType,
                  ),
                  _buildTwoCols(
                    'Battery Replace Date',
                    _formatDateTime(masterModuleEntity.batteryReplacementDate),
                    'Battery Recharge Date',
                    _formatDateTime(masterModuleEntity.batteryRechargeDate),
                  ),
                  _buildTwoCols(
                    'Lora Enabled',
                    masterModuleEntity.loraEnabled ? 'Yes' : 'No',
                    'E-Sim Enabled',
                    masterModuleEntity.esimEnabled ? 'Yes' : 'No',
                  ),
                  _buildTwoCols(
                    'Dual Profile',
                    masterModuleEntity.dualProfileSupported ? 'Yes' : 'No',
                    'Train No/Name',
                    '${masterModuleEntity.train?.trainNumber ?? 'N/A'} - ${masterModuleEntity.train?.trainName ?? ''}',
                  ),
                  if (deviceNames.isNotEmpty)
                    Text('Attached Devices',
                        style: TextStyle(
                            fontSize: 11.sp, color: Colors.grey.shade700)),
                  if (deviceNames.isNotEmpty) SizedBox(height: 0.5.h),
                  if (deviceNames.isNotEmpty)
                    Wrap(
                      spacing: 2.w,
                      runSpacing: 1.h,
                      children: deviceNames
                          .map((name) => _chipView(name,
                              const Color(0xFFE4ECFD), const Color(0xFF1F56C3)))
                          .toList(),
                    ),
                  SizedBox(height: 1.h),
                  _buildTwoCols(
                    'Created By',
                    masterModuleEntity.createdByName,
                    'Created Date',
                    _formatDateTime(masterModuleEntity.createdDate),
                  ),
                  _buildTwoCols(
                    'Updated By',
                    masterModuleEntity.updatedByName,
                    'Last Updated',
                    _formatDateTime(masterModuleEntity.updatedDate),
                  ),
                  SizedBox(height: 0.6.h),
                  SizedBox(height: 1.h),
                ],
              ),
              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton(
                    text: 'Close',
                    padding: EdgeInsets.symmetric(vertical: 1.6.h, horizontal: 5.w),
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
    String? value2, {
    bool isStatus1 = false,
    bool isStatus2 = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            child: _buildItem(
                label: label1, value: value1, isStatusView: isStatus1)),
        SizedBox(width: 3.w),
        Expanded(
            child: _buildItem(
                label: label2, value: value2, isStatusView: isStatus2)),
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
          Text(label,
              style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade700)),
          SizedBox(height: 0.3.h),
          isStatusView
              ? _buildStatusView(label: label, statusValue: value)
              : Text(value ?? 'N/A',
                  style: TextStyle(fontSize: 12.5.sp, color: Colors.black)),
        ],
      ),
    );
  }

  /// Status view with colored chip
  Widget _buildStatusView(
      {required String label, required String? statusValue}) {
    bool isActive =
        statusValue?.toLowerCase() == DeviceStatus.active.name.toLowerCase();
    bool isRegistration = statusValue?.toLowerCase() ==
        DeviceStatus.registration.name.toLowerCase();
    bool isInactive =
        statusValue?.toLowerCase() == DeviceStatus.inactive.name.toLowerCase();

    Color color = Colors.black;
    if (isActive) {
      color = Colors.green;
    } else if (isInactive) {
      color = Colors.red.shade900;
    } else if (isRegistration) {
      color = const Color(0xFFC0AF6A);
    }

    return _chipView(statusValue, color.withValues(alpha: 0.13), color);
  }

  Widget _chipView(String? text, Color bgColor, Color textColor) {
    return ChipView(
        text: text ?? 'N/A', bgColor: bgColor, textColor: textColor);
  }

  String _formatDateTime(String? datetime) {
    return Utils.formatReadableDate(datetime,
            dateFormat: Constants.dateTimeFormatToShowInTable) ??
        '';
  }
}
