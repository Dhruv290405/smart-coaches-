import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/utils/constants.dart';
import 'package:smart_coach_new/core/utils/loader.dart';
import 'package:smart_coach_new/core/utils/toast_message_utils.dart';
import 'package:smart_coach_new/core/utils/utils.dart';
import 'package:smart_coach_new/features/device_management/rule_configuration/domain/entities/rule_configuration_entity.dart';
import 'package:smart_coach_new/features/device_management/rule_configuration/presentation/bloc/rule_configuration_bloc.dart';
import 'package:smart_coach_new/features/device_management/rule_configuration/presentation/bloc/rule_configuration_event.dart';
import 'package:smart_coach_new/features/device_management/rule_configuration/presentation/bloc/rule_configuration_state.dart';
import 'package:smart_coach_new/features/device_management/rule_configuration/presentation/widgets/rule_detail_dialog.dart';
import 'package:smart_coach_new/features/device_management/rule_configuration/presentation/widgets/rule_table.dart';

class RuleList extends StatefulWidget {
  final Function(RuleConfigurationEntity) onTapEdit;

  const RuleList({super.key, required this.onTapEdit});

  @override
  State<RuleList> createState() => _RuleListState();
}

class _RuleListState extends State<RuleList> {
  late RuleConfigurationBloc _sensorTypeConfigurationBloc;

  @override
  void initState() {
    super.initState();
    _sensorTypeConfigurationBloc = context.read<RuleConfigurationBloc>()
      ..add(LoadRuleConfigurationList());
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
            'Rule List',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 2.h),
          Expanded(
            child: BlocConsumer<RuleConfigurationBloc,
                RuleConfigurationState>(
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
                return RuleTable(
                  items: state.rulesList,
                  onTapEdit: (RuleConfigurationEntity ruleItem) {
                    widget.onTapEdit.call(ruleItem);
                  },
                  onTapView: (RuleConfigurationEntity ruleItem) {
                    showDialog(
                      context: context,
                      builder: (context) =>
                          RuleDetailDialog(sensorItem: ruleItem),
                    );
                  },
                  onTapDelete: (RuleConfigurationEntity ruleItem) {
                    Utils.showYesNoDialog(
                      context: context,
                      message: Constants.deleteConfirmationMessage,
                      onYes: () {
                        _sensorTypeConfigurationBloc
                            .add(DeleteRuleConfiguration(ruleItem.ruleId));
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
