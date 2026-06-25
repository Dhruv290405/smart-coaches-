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
import 'package:smart_coach_new/core/network/api_constants.dart';
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
import '../data/datasources/diesel_data_service.dart';
import '../data/models/diesel_tank_model.dart';
import 'diesel_chart_view.dart';
import 'diesel_alerts_view.dart';
import 'diesel_tank_history.dart';
import 'diesel_tank_view.dart';
import 'widgets/diesel_report_generator.dart';

class DieselLevelScreen extends StatefulWidget {
  const DieselLevelScreen({super.key});

  @override
  State<DieselLevelScreen> createState() => _DieselLevelScreenState();
}

class _DieselLevelScreenState extends State<DieselLevelScreen> {
  final DieselDataService _dataService = DieselDataService(baseUrl: ApiConstants.devUrl);
  String selectedTrainNumber = 'All';
  String selectedLocoNumber = 'All Locos'; 
  String selectedStatus = 'All';
  String selectedViewType = 'Diesel Tanks';
  List<DieselTankModel> _allTanks = [];
  bool _isLoading = true;
  String? _errorMessage;

  List<String> get trainNumbers {
    final unique = <String>{'All'};
    for (final t in _allTanks) {
      if (t.trainName.isNotEmpty) unique.add(t.trainName);
    }
    return unique.toList()..sort();
  }

  List<String> get locoNumbers {
    final unique = <String>{'All Locos'};
    for (final t in _allTanks) {
      if (t.locoNumber.isNotEmpty) unique.add(t.locoNumber);
    }
    return unique.toList()..sort();
  }

  List<DieselTankModel> get _filteredTanks {
    return _allTanks.where((t) {
      if (selectedStatus != 'All' && t.status.toLowerCase() != selectedStatus.toLowerCase()) return false;
      if (selectedLocoNumber != 'All Locos' && t.locoNumber != selectedLocoNumber) return false;
      if (selectedTrainNumber != 'All' && t.trainName != selectedTrainNumber) return false;
      return true;
    }).toList();
  }

  DieselTankModel? get _selectedTank => _filteredTanks.isNotEmpty ? _filteredTanks.first : null;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadMockData() {
    final now = DateTime.now();
    _allTanks = [
      DieselTankModel(
        engineId: 'WDP4D #40345',
        sensorId: 'DSL-001',
        locoNumber: 'WDP4D #40345',
        trainName: '12615/6 Grand Trunk Express',
        percentage: 75,
        status: 'Good',
        height: 180, width: 120, length: 220,
        capacity: 5000, consumptionRate: 400,
        estimatedRunTime: 8.5, rangeLeft: 950,
        refilledBy: 'Ramesh Kumar',
        lastUpdated: now,
      ),
      DieselTankModel(
        engineId: 'WAP7 #30217',
        sensorId: 'DSL-002',
        locoNumber: 'WAP7 #30217',
        trainName: '12617/8 Mangala Express',
        percentage: 25,
        status: 'Warning',
        height: 180, width: 120, length: 220,
        capacity: 5000, consumptionRate: 400,
        estimatedRunTime: 2.5, rangeLeft: 300,
        refilledBy: 'Suresh Singh',
        lastUpdated: now.subtract(const Duration(hours: 2)),
      ),
      DieselTankModel(
        engineId: 'WAG9 #45123',
        sensorId: 'DSL-003',
        locoNumber: 'WAG9 #45123',
        trainName: '12619/0 Matsyagandha Express',
        percentage: 10,
        status: 'Critical',
        height: 180, width: 120, length: 220,
        capacity: 5000, consumptionRate: 400,
        estimatedRunTime: 1.0, rangeLeft: 120,
        refilledBy: 'Amit Verma',
        lastUpdated: now.subtract(const Duration(hours: 5)),
      ),
    ];
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final tanks = await _dataService.fetchDieselReadings();
      if (mounted) {
        setState(() {
          _allTanks = tanks;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        _loadMockData();
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearFilters() {
    setState(() {
      selectedTrainNumber = 'All';
      selectedLocoNumber = 'All Locos';
      selectedStatus = 'All';
    });
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  void _generateReport() {
    if (_filteredTanks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data available for report')),
      );
      return;
    }
    DieselReportGenerator.generate(context, _filteredTanks);
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
                  _selectedTank?.getFormattedLastUpdated() ?? 'No data',
                  style: AppTextStyles.bodySmall,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cloud_off, size: 48, color: ColorConstants.textSecondary),
                        const SizedBox(height: 16),
                        Text('Unable to load data', style: AppTextStyles.header2),
                        const SizedBox(height: 8),
                        Text(_errorMessage!, style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
                      ],
                    ),
                  ),
                )
              : _allTanks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.inbox_outlined, size: 48, color: ColorConstants.textSecondary),
                          const SizedBox(height: 16),
                          Text('No diesel tank data available', style: AppTextStyles.header2),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_filteredTanks.length > 1)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  '${_filteredTanks.length} tank(s) matching filters',
                                  style: AppTextStyles.bodySmall.copyWith(color: ColorConstants.primary),
                                ),
                              ),
                            _buildSectionCard(child: _buildFiltersSection()),
                            const SizedBox(height: 8),

                            _buildSectionCard(child: _buildQuickActionsSection()),
                            const SizedBox(height: 8),

                            _buildSectionCard(child: _buildViewTypeSection()),
                            const SizedBox(height: 8),

                            if (_selectedTank != null) ...[
                              if (selectedViewType == 'Diesel Tanks') ...[
                                _buildSectionCard(child: DieselTankView(tank: _selectedTank!)),
                                const SizedBox(height: 16),
                                _buildSectionCard(
                                  child: Column(
                                    children: [
                                      TankInfoSection(
                                        title: AppStrings.dieselTankInfo,
                                        tank: _selectedTank!,
                                      ),
                                      const SizedBox(height: 20),
                                      ViewHistoryButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  DieselTankHistory(tank: _selectedTank!),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ] else if (selectedViewType == 'Chart View')
                                _buildSectionCard(child: DieselChartView(tank: _selectedTank!))
                              else if (selectedViewType == 'Alerts')
                                _buildSectionCard(child: const DieselAlertsView()),
                            ],
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
                  onTap: _generateReport,
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