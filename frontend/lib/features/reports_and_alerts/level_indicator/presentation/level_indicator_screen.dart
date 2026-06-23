import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/network/api_constants.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/core/widgets/custom_drop_down.dart';
import 'package:smart_coach_new/core/widgets/screen_card_padding.dart';
import 'package:smart_coach_new/features/reports_and_alerts/level_indicator/data/models/train_list_response.dart';
import 'package:smart_coach_new/features/reports_and_alerts/level_indicator/presentation/bloc/train_list_bloc.dart';
import 'package:smart_coach_new/features/reports_and_alerts/level_indicator/presentation/widgets/chart_view.dart';
import 'package:smart_coach_new/features/reports_and_alerts/level_indicator/presentation/widgets/water_tank_view.dart';
import '../data/datasources/sensor_api_service.dart';
import 'bloc/train_list_event.dart';
import 'bloc/train_list_state.dart';

class _SegmentItem {
  final IconData icon;
  final String label;

  _SegmentItem(this.icon, this.label);
}

class LevelIndicatorScreen extends StatefulWidget {
  const LevelIndicatorScreen({super.key});

  @override
  State<LevelIndicatorScreen> createState() => _LevelIndicatorScreenState();
}

class _LevelIndicatorScreenState extends State<LevelIndicatorScreen> {
  final apiService = SensorApiService(baseUrl: ApiConstants.devUrl);
  late TrainListBloc _trainListBloc;
  bool _filtersExpanded = false;
  String? selectedLevel;
  TrainItem? selectedTrainNumber;
  BasicCoachItem? selectedCoachNumber;
  String? selected;
  List<String> levelList = ['Warning', 'Good'];
  List<String> coachNumberList = ['C-001', 'C-002'];
  List<String> statuses = ['Good', 'Warning', 'Critical'];
  int selectedIndex = 0;

  final List<_SegmentItem> items = [
    _SegmentItem(Icons.show_chart, 'Chart\nView'),
    _SegmentItem(Icons.water_drop_outlined, 'Water\nTanks'),
    _SegmentItem(Icons.notifications_none_outlined, 'Alerts'),
  ];

  @override
  void initState() {
    super.initState();
    _trainListBloc = context.read<TrainListBloc>()
      ..add(LoadInitData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          "Level Indicator",
          style: TextStyle(
            color: Colors.black,
            fontSize: 14.sp,
            fontWeight: FontWeight.normal,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: BlocConsumer<TrainListBloc, TrainListState>(
        listener: (context, state) {
          // 🔹 Add side effects here (loading, error, toast messages, etc.)
          if (state.isLoading) {
            // show loader
          } else {
            // hide loader
          }
          if (state.errorMessage != null) {
            // show error toast/dialog
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Column(
                children: [
                  _viewTypeView(),
                  SizedBox(height: 2.h),
                  _filtersView(
                    trainList: state.trainList,
                    coachList: state.coachList,
                  ),
                  SizedBox(height: 2.h),
                  Expanded(
                    child: IndexedStack(
                      index: selectedIndex,
                      children: [
                        ChartView(
                            key: ValueKey(selectedCoachNumber?.coach_id),
                            coachId: selectedCoachNumber?.coach_id
                        ),
                        WaterTankView(sensors: state.sensorList, apiService: apiService),
                        Center(
                          child: Text(
                            'Alerts View - Coming Soon',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _viewTypeView() {
    return ScreenCardPadding(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'View Type',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 2.h),
          Row(children: [_viewTypeItem(0), _viewTypeItem(1), _viewTypeItem(2)]),
        ],
      ),
    );
  }

  Widget _viewTypeItem(int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedIndex = index),
        child: Container(
          height: 80,
          padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
          margin: EdgeInsets.symmetric(horizontal: 1.w),
          decoration: BoxDecoration(
            color: selectedIndex == index
                ? ColorConstants.primary
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                items[index].icon,
                color: selectedIndex == index ? Colors.white : Colors.black,
                size: 5.w,
              ),
              SizedBox(height: 4), // spacing between icon and text
              Text(
                items[index].label,
                textAlign: TextAlign.center,
                maxLines: 2, // wrap text but within defined space
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selectedIndex == index ? Colors.white : Colors.black87,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filtersView({
    required List<TrainItem> trainList,
    required List<BasicCoachItem> coachList, // 🔹 new param
  }) {
    return ScreenCardPadding(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _filtersExpanded = !_filtersExpanded;
              });
            },
            child: Row(
              children: [
                Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  _filtersExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _filtersExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Column(
              children: [
                // SizedBox(height: 1.h),
                // CustomDropDown<String>(
                //   hintText: 'Select Level',
                //   label: 'Level',
                //   value: selectedLevel,
                //   items: levelList,
                //   getValue: (e) => e,
                //   displayText: (e) => e,
                //   onChanged: (value) {
                //     setState(() {
                //       selectedLevel = value;
                //     });
                //   },
                // ),
                SizedBox(height: 2.h),
                CustomDropDown<TrainItem>(
                  hintText: 'Select Train',
                  label: 'Train Number',
                  value: selectedTrainNumber,
                  items: trainList,
                  getValue: (e) => e,
                  displayText: (e) => e.trainNumber.toString(),
                  onChanged: (value) {
                    setState(() {
                      selectedTrainNumber = value;
                      selectedCoachNumber = null; // reset coach selection
                    });
                    if (value != null) {
                      context.read<TrainListBloc>().add(
                        LoadCoachData(value.trainId),
                      );
                    }
                  },
                ),
                SizedBox(height: 2.h),
                CustomDropDown<BasicCoachItem>(
                  hintText: 'Select Coach',
                  label: 'Coach Number',
                  value: selectedCoachNumber,
                  items: coachList,
                  getValue: (e) => e,
                  displayText: (e) => e.coach_unique_id,
                  onChanged: (value) {
                    setState(() {
                      selectedCoachNumber = value;
                    });
                    if(value != null) {
                      context.read<TrainListBloc>().add(
                        LoadSensorData(value.coach_id),
                      );
                    }
                  },
                ),
                SizedBox(height: 2.h),
                // FieldLabelTextView(labelText: 'Status'),
                // SizedBox(height: 1.h),
                // Row(
                //   children: statuses.map((status) {
                //     final isSelected = selected == status;
                //     return Expanded(
                //       child: Padding(
                //         padding: EdgeInsets.symmetric(horizontal: 1.w),
                //         child: GestureDetector(
                //           onTap: () {
                //             setState(() {
                //               selected = status;
                //             });
                //           },
                //           child: Container(
                //             height: 3.8.h,
                //             alignment: Alignment.center,
                //             decoration: BoxDecoration(
                //               color: isSelected
                //                   ? ColorConstants.primary
                //                   : const Color(0xFFF0F1F4),
                //               borderRadius: BorderRadius.circular(4),
                //             ),
                //             child: Text(
                //               status,
                //               style: TextStyle(
                //                 color:
                //                 isSelected ? Colors.white : Colors.black87,
                //                 fontSize: 10.sp,
                //               ),
                //             ),
                //           ),
                //         ),
                //       ),
                //     );
                //   }).toList(),
                // ),
                SizedBox(height: 2.h),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.end,
                //   children: [
                //     CustomButton(
                //       text: "Apply Filter",
                //       prefixIcon: Icons.filter_list,
                //       color: ColorConstants.primary,
                //       textColor: Colors.white,
                //       onPressed: () {},
                //       padding: EdgeInsets.symmetric(
                //         vertical: 1.4.h,
                //         horizontal: 4.w,
                //       ),
                //       textSize: 12,
                //       iconSize: 4,
                //       radius: 6,
                //     ),
                //   ],
                // ),
              ],
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}