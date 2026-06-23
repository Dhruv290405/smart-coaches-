import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/utils/constants.dart';
import 'package:smart_coach_new/core/utils/loader.dart';
import 'package:smart_coach_new/core/utils/toast_message_utils.dart';
import 'package:smart_coach_new/core/utils/utils.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/domain/entities/sensor_type_entity.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/presentation/bloc/sensor_type_configuration_bloc.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/presentation/bloc/sensor_type_configuration_event.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/presentation/bloc/sensor_type_configuration_state.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/presentation/widgets/sensor_type_detail_dialog.dart';
import 'package:smart_coach_new/features/device_management/sensor_type_configuration/presentation/widgets/sensor_type_table.dart';

class SensorTypeList extends StatefulWidget {
  final Function(SensorTypeEntity) onTapEdit;

  const SensorTypeList({super.key, required this.onTapEdit});

  @override
  State<SensorTypeList> createState() => _SensorTypeListState();
}

class _SensorTypeListState extends State<SensorTypeList> {
  late SensorTypeConfigurationBloc _sensorTypeConfigurationBloc;

  @override
  void initState() {
    super.initState();
    _sensorTypeConfigurationBloc = context.read<SensorTypeConfigurationBloc>()
      ..add(LoadSensorTypeConfigurationList());
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
            'Sensors List',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
          Expanded(
            child: BlocConsumer<SensorTypeConfigurationBloc,
                SensorTypeConfigurationState>(
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
                return SensorTypeTable(
                  items: state.sensorList,
                  onTapEdit: (SensorTypeEntity sensorItem) {
                    widget.onTapEdit.call(sensorItem);
                  },
                  onTapView: (SensorTypeEntity sensorItem) {
                    showDialog(
                      context: context,
                      builder: (context) =>
                          SensorTypeDetailDialog(sensorItem: sensorItem),
                    );
                  },
                  onTapDelete: (SensorTypeEntity sensorItem) {
                    Utils.showYesNoDialog(
                      context: context,
                      message: Constants.deleteConfirmationMessage,
                      onYes: () {
                        _sensorTypeConfigurationBloc
                            .add(DeleteSensorTypeConfiguration(sensorItem.sensorTypeId));
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
