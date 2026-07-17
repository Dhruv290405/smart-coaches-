import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/utils/constants.dart';
import 'package:smart_coach_new/core/utils/image_utils.dart';
import 'package:smart_coach_new/core/utils/loader.dart';
import 'package:smart_coach_new/core/utils/toast_message_utils.dart';
import 'package:smart_coach_new/core/utils/utils.dart';
import 'package:smart_coach_new/core/widgets/custom_button.dart';
import 'package:smart_coach_new/core/widgets/custom_drop_down.dart';
import 'package:smart_coach_new/core/widgets/custom_text_field.dart';
import 'package:smart_coach_new/core/widgets/field_label_text_view.dart';
import 'package:smart_coach_new/core/widgets/positive_integer_input_formatter.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/data/models/coach_configuration_request.dart';
import 'package:smart_coach_new/features/configuration/coach_configuration/domain/entities/coach_entity.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/data/models/train_configuration_request.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/domain/entities/train_configs_entity.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/presentation/bloc/train_configuration_bloc.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/presentation/bloc/train_configuration_event.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/presentation/bloc/train_configuration_state.dart';
import 'package:smart_coach_new/features/configuration/train_configuration/presentation/widgets/train_coach_grid.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/region_list_response.dart';
import 'package:smart_coach_new/features/drop_down_value/data/models/station_list_response.dart';

class CoachConfig {
  String? uniqueNumber;
  String? entityType;
  String? displayId;
  int? position;

  CoachConfig({this.uniqueNumber, this.entityType = 'Coach'});

  bool get isConfigured => entityType == 'Coach'
      ? uniqueNumber != null
      : uniqueNumber != null && displayId != null && position != null;
}

class ConfigureTrain extends StatefulWidget {
  final Function onGoToListAndRefresh;
  final TrainConfigsEntity? selectedTrainItem;

  const ConfigureTrain({
    super.key,
    required this.onGoToListAndRefresh,
    this.selectedTrainItem,
  });

  @override
  State<ConfigureTrain> createState() => _ConfigureTrainState();
}

class _ConfigureTrainState extends State<ConfigureTrain> {
  late TrainConfigurationBloc _trainConfigurationBloc;
  final TextEditingController trainNumberController = TextEditingController();
  final TextEditingController trainNameController = TextEditingController();
  final TextEditingController engineNumberController = TextEditingController();

  int? selectedOriginationRegionId;
  int? selectedRegionId;
  int? selectedDepartureStationId;
  int? selectedDestinationStationId;
  String? selectedLine;
  String? selectedTrainOperator;

  List<CoachConfig>? coaches;

  List<int> numberOfCoachesList = List.generate(24, (index) => index + 1);

  @override
  void dispose() {
    trainNumberController.dispose();
    trainNameController.dispose();
    engineNumberController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _trainConfigurationBloc = context.read<TrainConfigurationBloc>()
      ..add(LoadInitialData());
    _prefillDataIfAvailable();
  }

  void _prefillDataIfAvailable() {
    final item = widget.selectedTrainItem;
    if (item == null) return;
    trainNumberController.text = item.trainNumber?.toString() ?? '';
    trainNameController.text = item.trainName ?? '';
    engineNumberController.text = item.engineNumber ?? '';

    selectedOriginationRegionId = item.originationRegionId;
    selectedRegionId = item.regionId;
    selectedDepartureStationId = item.departureStationId;
    selectedDestinationStationId = item.destinationStationId;
    selectedLine = item.line;
    selectedTrainOperator = item.trainOperator;

    if (item.coaches != null && item.coaches!.isNotEmpty) {
      coaches ??= [];
      for (CoachEntity coachEntity in (item.coaches ?? [])) {
        final updated = CoachConfig()
          ..uniqueNumber = coachEntity.coachUniqueId
          ..displayId = coachEntity.coachDisplayId
          ..position = coachEntity.position
          ..entityType = coachEntity.entityType;

        coaches?.add(updated);
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
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
        child: BlocConsumer<TrainConfigurationBloc, TrainConfigurationState>(
          listener: (context, state) {
            if (state.isLoading) {
              Loader.show();
            } else {
              Loader.dismiss();
            }

            if (state.actionMessage != null) {
              ToastMessageUtils.showMessage(context, state.actionMessage!);
              widget.onGoToListAndRefresh.call();
            }

            if (state.errorMessage != null) {
              Utils.showApiErrorMessageOrList(
                context,
                message: state.errorMessage!,
              );
            }
          },
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Train Information',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Basic Information',
                  style: TextStyle(fontSize: 12.sp, color: Colors.black),
                ),
                Container(
                  width: double.infinity,
                  height: 1,
                  color: Colors.grey.shade300,
                  margin: EdgeInsets.symmetric(vertical: 1.5.h),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: trainNumberController,
                        labelText: 'Train Number',
                        hintText: 'Enter Train Number',
                        isRequired: true,
                        textInputType: TextInputType.number,
                        inputFormatters: [PositiveIntegerInputFormatter()],
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Column(
                      children: [
                        FieldLabelTextView(labelText: ''),
                        SizedBox(height: 0.5.h),
                        CustomButton(
                          text: 'Fetch',
                          prefixIcon: Icons.search,
                          textSize: 12,
                          radius: 6,
                          iconSize: 5,
                          padding: EdgeInsets.symmetric(
                            vertical: 1.5.h,
                            horizontal: 5.w,
                          ),
                          onPressed: () {
                            _doFetch();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                CustomTextField(
                  controller: trainNameController,
                  labelText: 'Train name',
                  hintText: 'Enter Train name',
                  isRequired: true,
                ),
                SizedBox(height: 2.h),
                CustomDropDown<RegionItem>(
                  label: 'Origination Region',
                  hintText: 'Select Origination Region',
                  value: selectedOriginationRegionId,
                  items: state.regionList,
                  getValue: (e) => e.regionId,
                  displayText: (e) => e.name ?? '',
                  isRequired: true,
                  onChanged: (value) {
                    setState(() {
                      selectedOriginationRegionId = value;
                    });
                  },
                ),
                SizedBox(height: 2.h),
                CustomDropDown<RegionItem>(
                  label: 'Region Name',
                  hintText: 'Select Region Name',
                  value: selectedRegionId,
                  items: state.regionList,
                  getValue: (e) => e.regionId,
                  displayText: (e) => e.name ?? '',
                  isRequired: true,
                  onChanged: (value) {
                    setState(() {
                      selectedRegionId = value;
                    });
                  },
                ),
                SizedBox(height: 2.h),
                CustomDropDown<StationItem>(
                  label: 'Departure Station',
                  hintText: 'Select Departure Station',
                  value: selectedDepartureStationId,
                  items: state.stationList,
                  getValue: (e) => e.regionId,
                  displayText: (e) => e.name ?? '',
                  isRequired: true,
                  onChanged: (value) {
                    setState(() {
                      selectedDepartureStationId = value;
                    });
                  },
                ),
                SizedBox(height: 2.h),
                CustomDropDown<StationItem>(
                  label: 'Destination Station',
                  hintText: 'Select Destination Station',
                  value: selectedDestinationStationId,
                  items: state.stationList,
                  getValue: (e) => e.regionId,
                  displayText: (e) => e.name ?? '',
                  isRequired: true,
                  onChanged: (value) {
                    setState(() {
                      selectedDestinationStationId = value;
                    });
                  },
                ),
                SizedBox(height: 2.h),
                CustomDropDown<String>(
                  label: 'Line',
                  hintText: 'Select Line',
                  value: selectedLine,
                  isRequired: true,
                  items: Constants.lineList,
                  onChanged: (value) {
                    setState(() {
                      selectedLine = value;
                    });
                  },
                ),
                SizedBox(height: 2.h),
                CustomDropDown<String>(
                  label: 'Train Operator',
                  hintText: 'Select Train Operator',
                  value: selectedTrainOperator,
                  items: Constants.trainOperatorList,
                  onChanged: (value) {
                    setState(() {
                      selectedTrainOperator = value;
                    });
                  },
                ),
                SizedBox(height: 2.h),
                CustomTextField(
                  controller: engineNumberController,
                  labelText: 'Loco Number',
                  hintText: 'Enter Loco Number',
                ),
                SizedBox(height: 2.h),
                CustomDropDown<int>(
                  label: 'Number of Coaches',
                  hintText: 'Select Number of Coaches',
                  value: coaches?.length,
                  items: numberOfCoachesList,
                  isRequired: true,
                  onChanged: (value) {
                    if (coaches?.length != value) {
                      final updatedCoaches = List<CoachConfig>.generate(
                        value,
                        (index) => CoachConfig(),
                      );

                      coaches = updatedCoaches;

                      int isHaveAnyLocoItem = coaches!.indexWhere(
                        (item) => item.entityType == 'Loco',
                      );
                      if (isHaveAnyLocoItem == -1) {
                        coaches!.insert(0, CoachConfig(entityType: 'Loco'));
                      }

                      setState(() {});
                    }
                  },
                ),
                SizedBox(height: 2.5.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      ImageUtils.icTrain,
                      fit: BoxFit.contain,
                      height: 7.w,
                      width: 7.w,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      'Coach Configuration',
                      style: TextStyle(fontSize: 12.sp, color: Colors.black),
                    ),
                  ],
                ),
                Container(
                  width: double.infinity,
                  height: 1,
                  color: Colors.grey.shade300,
                  margin: EdgeInsets.symmetric(vertical: 1.h),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Color(0xFF4E82D6),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 17,
                    ),
                    margin: EdgeInsets.only(left: 1.4.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF5FF),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 5.w),
                        SizedBox(width: 1.5.w),
                        Expanded(
                          child: Text(
                            'Configure coaches by clicking on each coach box below. Red boxes indicate unconfigured coaches.',
                            style: TextStyle(fontSize: 13, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                if (coaches == null)
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFF3F3F5),
                      ),
                      padding: EdgeInsets.all(5.w),
                      child: SvgPicture.asset(
                        ImageUtils.icTrain,
                        fit: BoxFit.contain,
                        height: 4.h,
                        width: 4.h,
                        colorFilter: const ColorFilter.mode(
                          Colors.grey,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                if (coaches == null) SizedBox(height: 0.5.h),
                if (coaches == null)
                  Text(
                    'Please select the number of coaches to continue',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black, fontSize: 12.sp),
                  ),
                if (coaches != null) TrainCoachGrid(coaches: coaches ?? []),
                SizedBox(height: 2.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomButton(
                      text: 'Cancel',
                      color: const Color(0xFFF2F3F5),
                      textColor: Colors.black,
                      textSize: 12,
                      padding: EdgeInsets.symmetric(
                        vertical: 1.6.h,
                        horizontal: 5.w,
                      ),
                      radius: 6,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(width: 3.w),
                    CustomButton(
                      text: 'Save Train',
                      textSize: 12,
                      radius: 6,
                      padding: EdgeInsets.symmetric(
                        vertical: 1.6.h,
                        horizontal: 5.w,
                      ),
                      onPressed: () {
                        _doProcess();
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _doProcess() {
    if (!_doValidate()) return;

    List<CoachConfigurationRequest>? coachesRequest;

    for (CoachConfig coachConfig in (coaches ?? [])) {
      coachesRequest ??= [];

      coachesRequest.add(
        CoachConfigurationRequest(
          entityType: coachConfig.entityType,
          coachUniqueId: coachConfig.uniqueNumber,
          coachDisplayId: coachConfig.displayId,
          position: coachConfig.position,
        ),
      );
    }

    final request = TrainConfigurationRequest(
      trainNumber: int.parse(trainNumberController.text.trim()),
      trainName: trainNameController.text.trim(),
      originationRegionId: selectedOriginationRegionId,
      regionId: selectedRegionId,
      departureStationId: selectedDepartureStationId,
      destinationStationId: selectedDestinationStationId,
      numberOfCoaches: coachesRequest?.length,
      line: selectedLine,
      trainOperator: selectedTrainOperator,
      engineNumber: engineNumberController.text.trim(),
      coaches: coachesRequest,
    );

    _trainConfigurationBloc.add(
      CreateEditTrainConfiguration(
        request,
        trainId: widget.selectedTrainItem?.trainId,
      ),
    );
  }

  bool _doValidate() {
    final trainNumber = trainNumberController.text.trim();
    if (trainNumber.isEmpty) {
      ToastMessageUtils.showMessage(context, 'Please enter Train Number');
      return false;
    } 

    final state = context.read<TrainConfigurationBloc>().state;
    final isDuplicate = state.trainList.any((t) => 
      t.trainNumber.toString() == trainNumber && 
      t.trainId != widget.selectedTrainItem?.trainId
    );

    if (isDuplicate) {
      ToastMessageUtils.showMessage(context, 'Train Number $trainNumber already exists');
      return false;
    }

    if (trainNameController.text.trim().isEmpty) {
      ToastMessageUtils.showMessage(context, 'Please enter Train Name');
      return false;
    } else if (selectedOriginationRegionId == null) {
      ToastMessageUtils.showMessage(
        context,
        'Please Select Origination Region',
      );
      return false;
    } else if (selectedDepartureStationId == null) {
      ToastMessageUtils.showMessage(context, 'Please Select Departure Station');
      return false;
    } else if (selectedDestinationStationId == null) {
      ToastMessageUtils.showMessage(
        context,
        'Please Select Destination Station',
      );
      return false;
    } else if (selectedLine == null) {
      ToastMessageUtils.showMessage(context, 'Please Select Line');
      return false;
    } else if ((coaches ?? []).isEmpty) {
      ToastMessageUtils.showMessage(context, 'Please Select Number of Coach');
      return false;
    }

    int indexOfUnConfiguredCoach = (coaches ?? []).indexWhere(
      (item) => item.isConfigured == false,
    );

    if (indexOfUnConfiguredCoach == -1) {
      return true;
    } else {
      CoachConfig coachConfig = coaches![indexOfUnConfiguredCoach];
      ToastMessageUtils.showMessage(
        context,
        'Please Configure you ${coachConfig.entityType ?? 'Coach'} ${indexOfUnConfiguredCoach + 1}',
      );
      return false;
    }
  }

  void _doFetch() {
    final trainNumber = trainNumberController.text.trim();
    if (trainNumber.isEmpty) {
      ToastMessageUtils.showMessage(context, 'Please enter Train Number to fetch');
      return;
    }

    final state = context.read<TrainConfigurationBloc>().state;
    final existingTrain = state.trainList.firstWhere(
      (t) => t.trainNumber.toString() == trainNumber,
      orElse: () => const TrainConfigsEntity(),
    );

    if (existingTrain.trainId != null) {
      setState(() {
        trainNameController.text = existingTrain.trainName ?? '';
        engineNumberController.text = existingTrain.engineNumber ?? '';
        selectedOriginationRegionId = existingTrain.originationRegionId;
        selectedRegionId = existingTrain.regionId;
        selectedDepartureStationId = existingTrain.departureStationId;
        selectedDestinationStationId = existingTrain.destinationStationId;
        selectedLine = existingTrain.line;
        selectedTrainOperator = existingTrain.trainOperator;

        if (existingTrain.coaches != null && existingTrain.coaches!.isNotEmpty) {
          coaches = existingTrain.coaches!.map((c) => CoachConfig()
            ..uniqueNumber = c.coachUniqueId
            ..displayId = c.coachDisplayId
            ..position = c.position
            ..entityType = c.entityType).toList();
        }
      });
      ToastMessageUtils.showMessage(context, 'Train information fetched successfully');
    } else {
      ToastMessageUtils.showMessage(context, 'No existing train found with this number');
    }
  }
}
