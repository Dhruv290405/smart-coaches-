import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/utils/constants.dart';
import 'package:smart_coach_new/core/utils/loader.dart';
import 'package:smart_coach_new/core/utils/toast_message_utils.dart';
import 'package:smart_coach_new/core/utils/utils.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/domain/entities/coach_entity.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/presentation/bloc/coach_configuration_bloc.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/presentation/bloc/coach_configuration_event.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/presentation/bloc/coach_configuration_state.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/presentation/widgets/coach_detail_dialog.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/presentation/widgets/coach_table.dart';

class CoachList extends StatefulWidget {
  final Function(CoachEntity) onTapEdit;

  const CoachList({super.key, required this.onTapEdit});

  @override
  State<CoachList> createState() => _CoachListState();
}

class _CoachListState extends State<CoachList> {
  late CoachConfigurationBloc _coachConfigurationBloc;

  @override
  void initState() {
    super.initState();
    _coachConfigurationBloc = context.read<CoachConfigurationBloc>()
      ..add( LoadCoachConfigurationList());
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
            'Coach List',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
          Expanded(
            child:
                BlocConsumer<CoachConfigurationBloc, CoachConfigurationState>(
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
                return CoachTable(
                  items: state.coachList,
                  onTapEdit: (CoachEntity coachEntity) {
                    widget.onTapEdit.call(coachEntity);
                  },
                  onTapView: (CoachEntity coachEntity) {
                    showDialog(
                      context: context,
                      builder: (context) =>
                          CoachDetailDialog(coachEntity: coachEntity),
                    );
                  },
                  onTapDelete: (CoachEntity coachEntity) {
                    Utils.showYesNoDialog(
                      context: context,
                      message: Constants.deleteConfirmationMessage,
                      onYes: () {
                        _coachConfigurationBloc
                            .add(DeleteCoachConfiguration(coachEntity.coachId));
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
