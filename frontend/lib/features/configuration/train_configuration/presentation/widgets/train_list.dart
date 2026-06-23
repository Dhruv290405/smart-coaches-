import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/utils/constants.dart';
import 'package:smart_coach_new/core/utils/loader.dart';
import 'package:smart_coach_new/core/utils/toast_message_utils.dart';
import 'package:smart_coach_new/core/utils/utils.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/domain/entities/train_configs_entity.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/presentation/bloc/train_configuration_bloc.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/presentation/bloc/train_configuration_event.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/presentation/bloc/train_configuration_state.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/presentation/widgets/train_detail_dialog.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/presentation/widgets/train_table.dart';

class TrainList extends StatefulWidget {
  final Function(TrainConfigsEntity) onTapEdit;

  const TrainList({super.key, required this.onTapEdit});

  @override
  State<TrainList> createState() => _TrainListState();
}

class _TrainListState extends State<TrainList> {
  late TrainConfigurationBloc _trainConfigurationBloc;

  @override
  void initState() {
    super.initState();
    _trainConfigurationBloc = context.read<TrainConfigurationBloc>()
      ..add(LoadTrainConfigurationList());
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
            'Train List',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
          Expanded(
            child:
                BlocConsumer<TrainConfigurationBloc, TrainConfigurationState>(
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
                return TrainTable(
                  items: state.trainList,
                  onTapEdit: (TrainConfigsEntity trainEntity) {
                    widget.onTapEdit.call(trainEntity);
                  },
                  onTapView: (TrainConfigsEntity trainEntity) {
                    showDialog(
                      context: context,
                      builder: (context) =>
                          TrainDetailDialog(trainEntity: trainEntity),
                    );
                  },
                  onTapDelete: (TrainConfigsEntity trainEntity) {
                    Utils.showYesNoDialog(
                      context: context,
                      message: Constants.deleteConfirmationMessage,
                      onYes: () {
                        _trainConfigurationBloc.add(
                            DeleteTrainConfiguration(trainEntity.trainId));
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
