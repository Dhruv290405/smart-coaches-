import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/utils/constants.dart';
import 'package:smart_coach_new/core/utils/loader.dart';
import 'package:smart_coach_new/core/utils/toast_message_utils.dart';
import 'package:smart_coach_new/core/utils/utils.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/domain/entities/device_entity.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/presentation/bloc/device_configuration_bloc.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/presentation/bloc/device_configuration_event.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/presentation/bloc/device_configuration_state.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/presentation/widgets/device_detail_dialog.dart';
import 'package:smart_coach_new/features/device_management/device_configuration/presentation/widgets/device_table.dart';

class DeviceList extends StatefulWidget {
  final Function(DeviceEntity) onTapEdit;

  const DeviceList({super.key, required this.onTapEdit});

  @override
  State<DeviceList> createState() => _DeviceListState();
}

class _DeviceListState extends State<DeviceList> {
  late DeviceConfigurationBloc _deviceConfigurationBloc;

  @override
  void initState() {
    super.initState();
    _deviceConfigurationBloc = context.read<DeviceConfigurationBloc>()
      ..add(LoadDeviceConfigurationList());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Device List',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
          Expanded(
            child:
                BlocConsumer<DeviceConfigurationBloc, DeviceConfigurationState>(
              listener: (context, state) {
                if (state.isLoading) {
                  Loader.show();
                } else {
                  Loader.dismiss();
                }

                if (state.errorMessage != null) {
                  Utils.showApiErrorMessageOrList(context,
                      message: state.errorMessage!);
                }

                if (state.actionMessage != null) {
                  ToastMessageUtils.showMessage(context, state.actionMessage!);
                }
              },
              builder: (context, state) {
                return DeviceTable(
                  items: state.deviceList,
                  onTapEdit: (DeviceEntity device) {
                    widget.onTapEdit.call(device);
                  },
                  onTapView: (DeviceEntity device) {
                    showDialog(
                      context: context,
                      builder: (context) => DeviceDetailDialog(device: device),
                    );
                  },
                  onTapDelete: (DeviceEntity device) {
                    Utils.showYesNoDialog(
                      context: context,
                      message: Constants.deleteConfirmationMessage,
                      onYes: () {
                        _deviceConfigurationBloc
                            .add(DeleteDeviceConfiguration(device.deviceId));
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
