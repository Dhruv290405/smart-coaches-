import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/utils/constants.dart';
import 'package:smart_coach_new/core/utils/loader.dart';
import 'package:smart_coach_new/core/utils/toast_message_utils.dart';
import 'package:smart_coach_new/core/utils/utils.dart';
import 'package:smart_coach_new/features/configuration/master_module_configuration/domain/entities/master_module_entity.dart';
import 'package:smart_coach_new/features/configuration/master_module_configuration/presentation/bloc/master_module_configuration_bloc.dart';
import 'package:smart_coach_new/features/configuration/master_module_configuration/presentation/bloc/master_module_configuration_event.dart';
import 'package:smart_coach_new/features/configuration/master_module_configuration/presentation/bloc/master_module_configuration_state.dart';
import 'package:smart_coach_new/features/configuration/master_module_configuration/presentation/widgets/master_module_detail_dialog.dart';
import 'package:smart_coach_new/features/configuration/master_module_configuration/presentation/widgets/master_module_table.dart';

class MasterModuleList extends StatefulWidget {
  final Function(MasterModuleEntity) onTapEdit;

  const MasterModuleList({super.key, required this.onTapEdit});

  @override
  State<MasterModuleList> createState() => _MasterModuleListState();
}

class _MasterModuleListState extends State<MasterModuleList> {
  late MasterModuleConfigurationBloc _deviceConfigurationBloc;

  @override
  void initState() {
    super.initState();
    _deviceConfigurationBloc = context.read<MasterModuleConfigurationBloc>()
      ..add(LoadMasterModuleConfigurationList());
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
            'Master Module List',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
          Expanded(
            child: BlocConsumer<MasterModuleConfigurationBloc,
                MasterModuleConfigurationState>(
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
                return MasterModuleTable(
                  items: state.masterModuleList,
                  onTapEdit: (MasterModuleEntity masterModuleEntity) {
                    widget.onTapEdit.call(masterModuleEntity);
                  },
                  onTapView: (MasterModuleEntity masterModuleEntity) {
                    showDialog(
                      context: context,
                      builder: (context) => MasterModuleDetailDialog(
                          masterModuleEntity: masterModuleEntity),
                    );
                  },
                  onTapDelete: (MasterModuleEntity masterModuleEntity) {
                    Utils.showYesNoDialog(
                      context: context,
                      message: Constants.deleteConfirmationMessage,
                      onYes: () {
                        _deviceConfigurationBloc.add(
                            DeleteMasterModuleConfiguration(
                                masterModuleEntity.moduleId));
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
