import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/utils/constants.dart';
import 'package:smart_coach_new/core/utils/loader.dart';
import 'package:smart_coach_new/core/utils/toast_message_utils.dart';
import 'package:smart_coach_new/core/utils/utils.dart';
import 'package:smart_coach_new/features/configuration/sensor_device_configuration/domain/entities/sensor_device_entity.dart';
import 'package:smart_coach_new/features/configuration/sensor_device_configuration/presentation/bloc/sensor_device_configuration_bloc.dart';
import 'package:smart_coach_new/features/configuration/sensor_device_configuration/presentation/bloc/sensor_device_configuration_event.dart';
import 'package:smart_coach_new/features/configuration/sensor_device_configuration/presentation/bloc/sensor_device_configuration_state.dart';
import 'package:smart_coach_new/features/configuration/sensor_device_configuration/presentation/widgets/sensor_device_detail_dialog.dart';
import 'package:smart_coach_new/features/configuration/sensor_device_configuration/presentation/widgets/sensor_device_table.dart';

class SensorDeviceList extends StatefulWidget {
  final Function(SensorDeviceEntity) onTapEdit;

  const SensorDeviceList({super.key, required this.onTapEdit});

  @override
  State<SensorDeviceList> createState() => _SensorDeviceListState();
}

class _SensorDeviceListState extends State<SensorDeviceList> {
  late SensorDeviceConfigurationBloc _coachConfigurationBloc;

  @override
  void initState() {
    super.initState();
    _coachConfigurationBloc = context.read<SensorDeviceConfigurationBloc>()
      ..add(LoadSensorDeviceConfigurationList());
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
            'Sensor List',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
          Expanded(
            child: BlocConsumer<SensorDeviceConfigurationBloc,
                SensorDeviceConfigurationState>(
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
                return SensorDeviceTable(
                  items: state.sensorDeviceList,
                  onTapEdit: (SensorDeviceEntity sensorDeviceEntity) {
                    widget.onTapEdit.call(sensorDeviceEntity);
                  },
                  onTapView: (SensorDeviceEntity sensorDeviceEntity) {
                    showDialog(
                      context: context,
                      builder: (context) => SensorDeviceDetailDialog(
                          sensorDeviceEntity: sensorDeviceEntity),
                    );
                  },
                  onTapDelete: (SensorDeviceEntity sensorDeviceEntity) {
                    Utils.showYesNoDialog(
                      context: context,
                      message: Constants.deleteConfirmationMessage,
                      onYes: () {
                        _coachConfigurationBloc.add(
                            DeleteSensorDeviceConfiguration(
                                sensorDeviceEntity.sensorConfigId));
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
