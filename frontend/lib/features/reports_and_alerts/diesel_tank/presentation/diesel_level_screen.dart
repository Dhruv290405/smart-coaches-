// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import '../../constants/app_colors.dart';
// import '../../constants/app_text_styles.dart';
// import '../../constants/app_strings.dart';
// import '../../constants/app_dimensions.dart';
// import '../../constants/app_icons.dart';
// import '../../widgets/common/filter_dropdown.dart';
// import '../../widgets/common/status_chip.dart';
// import '../../widgets/common/action_button.dart';
// import '../../widgets/common/view_type_selector.dart';
// import '../../models/diesel_tank_model.dart';
// import '../../widgets/diesel_tank/tank_info_section.dart';
// import '../../widgets/diesel_tank/view_history_button.dart';
// import 'diesel_tank_view.dart';
// import 'diesel_chart_view.dart';
// import 'diesel_alerts_view.dart';
// import 'diesel_tank_history.dart';

// class DieselLevelScreen extends StatefulWidget {
//   const DieselLevelScreen({Key? key}) : super(key: key);

//   @override
//   State<DieselLevelScreen> createState() => _DieselLevelScreenState();
// }

// class _DieselLevelScreenState extends State<DieselLevelScreen> {
//   // Filter State
//   String selectedTrainNumber = '12615/6 Grand Trunk Express';
//   String selectedStatus = 'All';
//   String selectedViewType = 'Diesel Tanks';

//   // Dummy Data for dropdown
//   final List<String> trainNumbers = [
//     '12615/6 Grand Trunk Express',
//     '12617/8 Mangala Express',
//     '12619/0 Matsyagandha Express',
//   ];

//   // Mock Diesel Tank Data
//   final DieselTankModel dieselTank = DieselTankModel(
//     engineId: 'WDP4D #40345',
//     sensorId: 'WLI 125678',
//     locoNumber: 'WDP4D #40345',
//     trainName: '12615/6 Grand Trunk Express',
//     percentage: 75,
//     status: 'Good',
//     height: 180,
//     width: 120,
//     length: 220,
//     capacity: 5000,
//     consumptionRate: 400,
//     estimatedRunTime: 8.5,
//     rangeLeft: 950,
//     refilledBy: 'Ramesh Kumar',
//     lastUpdated: DateTime(2026, 2, 7, 10, 42),
//   );

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ColorConstants.scaffoldBackground,
//       appBar: AppBar(
//         backgroundColor: ColorConstants.scaffoldBackground,
//         elevation: 0,
//         scrolledUnderElevation: 0,
//         leadingWidth: 40,
//         leading: IconButton(
//           padding: EdgeInsets.zero,
//           icon: const Icon(
//             Icons.arrow_back,
//             color: ColorConstants.textPrimary,
//           ),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         titleSpacing: 4,
//         title: Text(
//           AppStrings.dieselLevelIndicator,
//           style: AppTextStyles.header1,
//         ),
//         actions: [
//           Center(
//             child: Padding(
//               padding: const EdgeInsets.only(right: 16),
//               child: Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: ColorConstants.white,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Text(
//                   'Last Updated: 10:46 AM',
//                   style: AppTextStyles.bodySmall,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(AppDimensions.paddingLarge),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Filters Section Card
//               _buildSectionCard(child: _buildFiltersSection()),
//               const SizedBox(height: 16),

//               // Quick Actions Section Card
//               _buildSectionCard(child: _buildQuickActionsSection()),
//               const SizedBox(height: 16),

//               // View Type Section Card
//               _buildSectionCard(child: _buildViewTypeSection()),
//               const SizedBox(height: 16),

//               // Content based on View Type
//               if (selectedViewType == 'Diesel Tanks') ...[
//                 _buildSectionCard(
//                     child: DieselTankView(tank: dieselTank)),
//                 const SizedBox(height: 16),
//                 _buildSectionCard(
//                   child: Column(
//                     children: [
//                       TankInfoSection(
//                         title: AppStrings.dieselTankInfo,
//                         tank: dieselTank,
//                       ),
//                       const SizedBox(height: 20),
//                       ViewHistoryButton(
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) =>
//                                   DieselTankHistory(tank: dieselTank),
//                             ),
//                           );
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ] else if (selectedViewType == 'Chart View')
//                 _buildSectionCard(
//                     child: DieselChartView(tank: dieselTank))
//               else if (selectedViewType == 'Alerts')
//                 _buildSectionCard(child: const DieselAlertsView()),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionCard({required Widget child}) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(AppDimensions.paddingLarge),
//       decoration: BoxDecoration(
//         color: ColorConstants.white,
//         borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
//       ),
//       child: child,
//     );
//   }

//   Widget _buildFiltersSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           AppStrings.filters,
//           style: AppTextStyles.header2.copyWith(color: ColorConstants.primary),
//         ),
//         const SizedBox(height: 12),

//         // Train Number/Loco Dropdown
//         FilterDropdown(
//           label: AppStrings.trainNumberLoco,
//           value: selectedTrainNumber,
//           items: trainNumbers,
//           onChanged: (value) {
//             setState(() {
//               selectedTrainNumber = value!;
//             });
//           },
//         ),

//         const SizedBox(height: 16),

//         // Status Filter
//         Text(AppStrings.status, style: AppTextStyles.label),
//         const SizedBox(height: 8),
//         Wrap(
//           spacing: 8,
//           runSpacing: 8,
//           children: [
//             StatusChip(
//               label: AppStrings.all,
//               isSelected: selectedStatus == 'All',
//               onTap: () => setState(() => selectedStatus = 'All'),
//             ),
//             StatusChip(
//               label: AppStrings.good,
//               isSelected: selectedStatus == 'Good',
//               onTap: () => setState(() => selectedStatus = 'Good'),
//             ),
//             StatusChip(
//               label: AppStrings.warning,
//               isSelected: selectedStatus == 'Warning',
//               onTap: () => setState(() => selectedStatus = 'Warning'),
//             ),
//             StatusChip(
//               label: AppStrings.critical,
//               isSelected: selectedStatus == 'Critical',
//               onTap: () => setState(() => selectedStatus = 'Critical'),
//             ),
//           ],
//         ),

//         const SizedBox(height: 16),

//         // Apply Filters Button
//         ActionButton(
//           label: AppStrings.applyFilters,
//           onTap: () {},
//           isPrimary: true,
//           isFullWidth: true,
//         ),
//       ],
//     );
//   }

//   Widget _buildQuickActionsSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(AppStrings.quickActions, style: AppTextStyles.header2),
//         const SizedBox(height: 12),
//         Row(
//           children: [
//             Expanded(
//               child: ActionButton(
//                 label: AppStrings.sendAlerts,
//                 svgIcon: AppIcons.alert,
//                 onTap: () {},
//                 isPrimary: true,
//                 isFullWidth: true,
//               ),
//             ),
//             const SizedBox(width: 8),
//             Expanded(
//               child: ActionButton(
//                 label: AppStrings.generateReport,
//                 svgIcon: AppIcons.report,
//                 onTap: () {},
//                 isFullWidth: true,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         Row(
//           children: [
//             Expanded(
//               child: ActionButton(
//                 label: AppStrings.refreshData,
//                 svgIcon: AppIcons.refresh,
//                 onTap: () {},
//                 isFullWidth: true,
//               ),
//             ),
//             const SizedBox(width: 8),
//             Expanded(
//               child: ActionButton(
//                 label: AppStrings.settings,
//                 svgIcon: AppIcons.setting,
//                 onTap: () {},
//                 isFullWidth: true,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildViewTypeSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(AppStrings.viewType, style: AppTextStyles.header2),
//         const SizedBox(height: 12),
//         Row(
//           children: [
//             Expanded(
//               child: ViewTypeSelector(
//                 label: AppStrings.dieselTanks,
//                 svgIcon: AppIcons.waterDrop,
//                 isSelected: selectedViewType == 'Diesel Tanks',
//                 onTap: () =>
//                     setState(() => selectedViewType = 'Diesel Tanks'),
//               ),
//             ),
//             const SizedBox(width: 8),
//             Expanded(
//               child: ViewTypeSelector(
//                 label: AppStrings.chartView,
//                 svgIcon: AppIcons.graph,
//                 isSelected: selectedViewType == 'Chart View',
//                 onTap: () =>
//                     setState(() => selectedViewType = 'Chart View'),
//               ),
//             ),
//             const SizedBox(width: 8),
//             Expanded(
//               child: ViewTypeSelector(
//                 label: AppStrings.alerts,
//                 svgIcon: AppIcons.alert,
//                 isSelected: selectedViewType == 'Alerts',
//                 onTap: () => setState(() => selectedViewType = 'Alerts'),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:smart_coach_new/core/widgets/view_type_selector.dart';
import 'package:smart_coach_new/features/reports_and_alerts/diesel_tank/presentation/widgets/tank_info_section.dart';
import 'package:smart_coach_new/features/reports_and_alerts/diesel_tank/presentation/widgets/view_history_button.dart';
import '../../../../core/utils/app_dimensions.dart';
import '../../../../core/utils/app_icons.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/utils/color_constants.dart';
import '../../../../core/widgets/action_button.dart';
import '../../../../core/widgets/filter_dropdown.dart';
import '../../../../core/widgets/status_chip.dart';
import '../data/models/diesel_tank_model.dart';
import 'diesel_chart_view.dart';
import 'diesel_alerts_view.dart';
import 'diesel_tank_history.dart';
import 'diesel_tank_view.dart';

class DieselLevelScreen extends StatefulWidget {
  const DieselLevelScreen({super.key});

  @override
  State<DieselLevelScreen> createState() => _DieselLevelScreenState();
}

class _DieselLevelScreenState extends State<DieselLevelScreen> {
  String selectedTrainNumber = '12615/6 Grand Tr...';
  String selectedLocoNumber = 'All Locos'; 
  String selectedStatus = 'All';
  String selectedViewType = 'Diesel Tanks';

  final List<String> trainNumbers = [
    '12615/6 Grand Tr...',
    '12617/8 Express',
    '12619/0 Special',
  ];

  final List<String> locoNumbers = [
    'All Locos',
    'WDP4D #40345',
    'WDP4D #40346',
    'WDP4D #40347',
  ];

  final DieselTankModel dieselTank = DieselTankModel(
    engineId: 'WDP4D #40345',
    sensorId: 'WLI 125678',
    locoNumber: 'WDP4D #40345',
    trainName: '12615/6 Grand Trunk Express',
    percentage: 75,
    status: 'Good',
    height: 180,
    width: 120,
    length: 220,
    capacity: 5000,
    consumptionRate: 400,
    estimatedRunTime: 8.5,
    rangeLeft: 950,
    refilledBy: 'Ramesh Kumar',
    lastUpdated: DateTime(2026, 2, 7, 10, 42),
  );

  void _clearFilters() {
    setState(() {
      selectedTrainNumber = trainNumbers.first;
      selectedLocoNumber = 'All Locos';
      selectedStatus = 'All';
    });
  }

  Future<void> _refreshData() async {
    // Mock refresh logic
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: ColorConstants.scaffoldBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 40,
        leading: IconButton(
          padding: EdgeInsets.zero,
          icon: const Icon(
            Icons.arrow_back,
            color: ColorConstants.textPrimary,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        titleSpacing: 4,
        title: Text(
          AppStrings.dieselLevelIndicator,
          style: AppTextStyles.header1,
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ColorConstants.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Last Updated: 10:46 AM',
                  style: AppTextStyles.bodySmall,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionCard(child: _buildFiltersSection()),
              const SizedBox(height: 8),

              _buildSectionCard(child: _buildQuickActionsSection()),
              const SizedBox(height: 8),

              _buildSectionCard(child: _buildViewTypeSection()),
              const SizedBox(height: 8),

              if (selectedViewType == 'Diesel Tanks') ...[
                _buildSectionCard(child: DieselTankView(tank: dieselTank)),
                const SizedBox(height: 16),
                _buildSectionCard(
                  child: Column(
                    children: [
                      TankInfoSection(
                        title: AppStrings.dieselTankInfo,
                        tank: dieselTank,
                      ),
                      const SizedBox(height: 20),
                      ViewHistoryButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  DieselTankHistory(tank: dieselTank),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ] else if (selectedViewType == 'Chart View')
                _buildSectionCard(child: DieselChartView(tank: dieselTank))
              else if (selectedViewType == 'Alerts')
                _buildSectionCard(child: const DieselAlertsView()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        color: ColorConstants.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      ),
      child: child,
    );
  }

  Widget _buildFiltersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.filters,
              style: AppTextStyles.header2.copyWith(color: ColorConstants.primary),
            ),
            GestureDetector(
              onTap: _clearFilters,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ColorConstants.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.clear_all, size: 14, color: ColorConstants.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Clear Filters',
                      style: AppTextStyles.label.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ColorConstants.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: FilterDropdown(
                label: AppStrings.trainNumber,
                value: selectedTrainNumber,
                items: trainNumbers,
                onChanged: (value) =>
                    setState(() => selectedTrainNumber = value!),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilterDropdown(
                label: 'Loco Number',
                value: selectedLocoNumber,
                items: locoNumbers,
                onChanged: (value) =>
                    setState(() => selectedLocoNumber = value!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(AppStrings.status, style: AppTextStyles.label),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: StatusChip(
                label: AppStrings.all,
                isSelected: selectedStatus == 'All',
                onTap: () => setState(() => selectedStatus = 'All'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StatusChip(
                label: AppStrings.good,
                isSelected: selectedStatus == 'Good',
                onTap: () => setState(() => selectedStatus = 'Good'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StatusChip(
                label: AppStrings.warning,
                isSelected: selectedStatus == 'Warning',
                onTap: () => setState(() => selectedStatus = 'Warning'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StatusChip(
                label: AppStrings.critical,
                isSelected: selectedStatus == 'Critical',
                onTap: () => setState(() => selectedStatus = 'Critical'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.quickActions, style: AppTextStyles.header2),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ActionButton(
                label: AppStrings.sendAlerts,
                svgIcon: AppIcons.alert,
                onTap: () {},
                isPrimary: true,
                isFullWidth: true,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ActionButton(
                label: AppStrings.generateReport,
                svgIcon: AppIcons.report,
                onTap: () {},
                isFullWidth: true,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _refreshData,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: ColorConstants.cardBackground,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  border: Border.all(color: ColorConstants.divider),
                ),
                child: const Icon(Icons.refresh, size: 18, color: ColorConstants.iconGrey),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildViewTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.viewType, style: AppTextStyles.header2),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ViewTypeSelector(
                label: AppStrings.dieselTanks,
                svgIcon: AppIcons.waterDrop,
                isSelected: selectedViewType == 'Diesel Tanks',
                onTap: () =>
                    setState(() => selectedViewType = 'Diesel Tanks'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ViewTypeSelector(
                label: AppStrings.chartView,
                svgIcon: AppIcons.graph,
                isSelected: selectedViewType == 'Chart View',
                onTap: () =>
                    setState(() => selectedViewType = 'Chart View'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ViewTypeSelector(
                label: AppStrings.alerts,
                svgIcon: AppIcons.alert,
                isSelected: selectedViewType == 'Alerts',
                onTap: () => setState(() => selectedViewType = 'Alerts'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}