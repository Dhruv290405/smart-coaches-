import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/utils/app_dimensions.dart';
import '../../core/utils/app_icons.dart';
import '../../core/utils/app_strings.dart';
import '../../core/utils/app_text_styles.dart';
import '../../core/utils/color_constants.dart';
import '../../core/widgets/action_button.dart';
import '../../core/widgets/filter_dropdown.dart';
import '../../core/widgets/status_chip.dart';

class OdourManagementScreen extends StatefulWidget {
  const OdourManagementScreen({super.key});

  @override
  State<OdourManagementScreen> createState() => _OdourManagementScreenState();
}

class _OdourManagementScreenState extends State<OdourManagementScreen> {
  String selectedTrainNumber = '12952';
  String selectedCoachType = '3AC';
  String selectedCoachNumber = 'B1';
  String selectedStatus = 'All';
  String lastUpdated = '18:55:00';
  bool isRefreshing = false;

  final List<Map<String, dynamic>> dummyTrains = [
    {
      "train_info": {
        "train_number": "12952",
        "train_name": "Rajdhani Express",
        "route": "NDLS-BCT"
      },
      "coaches": [
        {
          "coach_number": "B1",
          "coach_type": "3AC",
          "total_devices": 4,
          "last_synced": "2026-04-21T18:55:00Z",
          "devices": [
            {
              "device_id": "OMD-B1-T1",
              "toilet_position": "L-Side-Front",
              "status": "Active",
              "battery_level": 85,
              "refill_level": 42,
              "usage_count_since_clean": 18,
              "cleanliness_indicator": "Needs Cleaning",
              "last_cleaning_timestamp": "2026-04-21T12:30:00Z",
              "malfunction_alerts": []
            },
            {
              "device_id": "OMD-B1-T2",
              "toilet_position": "R-Side-Front",
              "status": "Active",
              "battery_level": 92,
              "refill_level": 75,
              "usage_count_since_clean": 4,
              "cleanliness_indicator": "Clean",
              "last_cleaning_timestamp": "2026-04-21T17:45:00Z",
              "malfunction_alerts": []
            },
            {
              "device_id": "OMD-B1-T3",
              "toilet_position": "L-Side-Rear",
              "status": "Offline",
              "battery_level": 0,
              "refill_level": 10,
              "usage_count_since_clean": 25,
              "cleanliness_indicator": "Unknown",
              "last_cleaning_timestamp": "2026-04-21T08:00:00Z",
              "malfunction_alerts": ["Power Failure", "Critical Refill Low"]
            },
            {
              "device_id": "OMD-B1-T4",
              "toilet_position": "R-Side-Rear",
              "status": "Active",
              "battery_level": 78,
              "refill_level": 60,
              "usage_count_since_clean": 2,
              "cleanliness_indicator": "Clean",
              "last_cleaning_timestamp": "2026-04-21T18:10:00Z",
              "malfunction_alerts": []
            }
          ]
        },
        {
          "coach_number": "A1",
          "coach_type": "2AC",
          "total_devices": 2,
          "last_synced": "2026-04-21T19:05:00Z",
          "devices": [
            {
              "device_id": "OMD-A1-T1",
              "toilet_position": "L-Side-Front",
              "status": "Active",
              "battery_level": 95,
              "refill_level": 88,
              "usage_count_since_clean": 3,
              "cleanliness_indicator": "Clean",
              "last_cleaning_timestamp": "2026-04-21T18:00:00Z",
              "malfunction_alerts": []
            },
            {
              "device_id": "OMD-A1-T2",
              "toilet_position": "R-Side-Rear",
              "status": "Active",
              "battery_level": 88,
              "refill_level": 12,
              "usage_count_since_clean": 15,
              "cleanliness_indicator": "Needs Cleaning",
              "last_cleaning_timestamp": "2026-04-21T12:00:00Z",
              "malfunction_alerts": ["Refill Low"]
            }
          ]
        }
      ]
    },
    {
      "train_info": {
        "train_number": "12002",
        "train_name": "Shatabdi Express",
        "route": "NDLS-HBJ"
      },
      "coaches": [
        {
          "coach_number": "C1",
          "coach_type": "CC",
          "total_devices": 2,
          "last_synced": "2026-04-21T18:40:00Z",
          "devices": [
            {
              "device_id": "OMD-C1-T1",
              "toilet_position": "L-Side-Front",
              "status": "Active",
              "battery_level": 70,
              "refill_level": 55,
              "usage_count_since_clean": 12,
              "cleanliness_indicator": "Clean",
              "last_cleaning_timestamp": "2026-04-21T16:00:00Z",
              "malfunction_alerts": []
            },
            {
              "device_id": "OMD-C1-T2",
              "toilet_position": "R-Side-Rear",
              "status": "Offline",
              "battery_level": 10,
              "refill_level": 5,
              "usage_count_since_clean": 30,
              "cleanliness_indicator": "Unknown",
              "last_cleaning_timestamp": "2026-04-21T06:00:00Z",
              "malfunction_alerts": ["Battery Critical"]
            }
          ]
        }
      ]
    }
  ];

  void _clearFilters() {
    setState(() {
      selectedTrainNumber = 'All Trains';
      selectedCoachType = 'All Types';
      selectedCoachNumber = 'All Coaches';
      selectedStatus = 'All';
    });
  }

  Future<void> _refreshData() async {
    setState(() => isRefreshing = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        lastUpdated = DateFormat('HH:mm:ss').format(DateTime.now());
        isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Collect dropdown items dynamically
    final trainNumbers = ['All Trains', ...dummyTrains.map((t) => t['train_info']['train_number'].toString())];
    
    List<String> coachTypes = ['All Types'];
    List<String> coachNumbers = ['All Coaches'];
    List<Map<String, dynamic>> filteredCoaches = [];

    // Filter logic
    for (var train in dummyTrains) {
      if (selectedTrainNumber != 'All Trains' && train['train_info']['train_number'] != selectedTrainNumber) continue;
      
      for (var coach in train['coaches']) {
        coachTypes.add(coach['coach_type']);
        
        if (selectedCoachType != 'All Types' && coach['coach_type'] != selectedCoachType) continue;
        coachNumbers.add(coach['coach_number']);
        
        if (selectedCoachNumber != 'All Coaches' && coach['coach_number'] != selectedCoachNumber) continue;
        
        // Final eligibility based on device status within coach if status filter is active
        final devices = coach['devices'] as List;
        bool hasAtLeastOneMatchingDevice = true;
        if (selectedStatus != 'All') {
          hasAtLeastOneMatchingDevice = devices.any((d) {
            if (selectedStatus == 'Clean') return d['cleanliness_indicator'] == 'Clean';
            if (selectedStatus == 'Dirty') return d['cleanliness_indicator'] == 'Needs Cleaning';
            if (selectedStatus == 'Offline') return d['status'] == 'Offline';
            return true;
          });
        }
        
        if (hasAtLeastOneMatchingDevice) {
          filteredCoaches.add({...coach, "train_no": train['train_info']['train_number']});
        }
      }
    }
    coachTypes = ['All Types', ...coachTypes.toSet()];
    coachNumbers = ['All Coaches', ...coachNumbers.toSet()];

    return Scaffold(
      backgroundColor: ColorConstants.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: ColorConstants.scaffoldBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 40,
        leading: IconButton(
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.arrow_back, color: ColorConstants.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 4,
        title: Text(AppStrings.odourManagement, style: AppTextStyles.header1),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                child: Text('Last Updated: $lastUpdated', style: AppTextStyles.bodySmall),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          children: [
            _buildSectionCard(
              child: _buildFiltersSection(trainNumbers, coachTypes, coachNumbers)
            ),
            const SizedBox(height: 8),
            _buildSectionCard(child: _buildQuickActionsSection()),
            const SizedBox(height: 8),
            _buildCoachGrid(filteredCoaches),
          ],
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

  Widget _buildFiltersSection(List<String> trains, List<String> types, List<String> numbers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppStrings.filters, style: AppTextStyles.header2.copyWith(color: ColorConstants.primary)),
            GestureDetector(
              onTap: _clearFilters,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: ColorConstants.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Row(
                  children: [
                    const Icon(Icons.clear_all, size: 14, color: ColorConstants.primary),
                    const SizedBox(width: 4),
                    Text('Clear Filters', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: ColorConstants.primary)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: FilterDropdown(label: AppStrings.trainNumber, value: selectedTrainNumber, items: trains, onChanged: (v) => setState(() => selectedTrainNumber = v!))),
            const SizedBox(width: 8),
            Expanded(child: FilterDropdown(label: 'Coach Type', value: selectedCoachType, items: types, onChanged: (v) => setState(() => selectedCoachType = v!))),
            const SizedBox(width: 8),
            Expanded(child: FilterDropdown(label: AppStrings.coachNumber, value: selectedCoachNumber, items: numbers, onChanged: (v) => setState(() => selectedCoachNumber = v!))),
          ],
        ),
        const SizedBox(height: 12),
        Text(AppStrings.status, style: AppTextStyles.label),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(child: StatusChip(label: AppStrings.all, isSelected: selectedStatus == 'All', onTap: () => setState(() => selectedStatus = 'All'))),
            const SizedBox(width: 8),
            Expanded(child: StatusChip(label: AppStrings.on, isSelected: selectedStatus == 'ON', onTap: () => setState(() => selectedStatus = 'ON'))),
            const SizedBox(width: 8),
            Expanded(child: StatusChip(label: AppStrings.off, isSelected: selectedStatus == 'OFF', onTap: () => setState(() => selectedStatus = 'OFF'))),
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
              onTap: isRefreshing ? () {} : _refreshData,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: ColorConstants.cardBackground,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  border: Border.all(color: ColorConstants.divider),
                ),
                child: isRefreshing 
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: ColorConstants.primary))
                    : SvgPicture.asset(
                        AppIcons.refresh,
                        width: 18,
                        height: 18,
                        colorFilter: const ColorFilter.mode(ColorConstants.iconGrey, BlendMode.srcIn),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCoachGrid(List<Map<String, dynamic>> coaches) {
    if (coaches.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Text('No coaches found matching criteria', style: AppTextStyles.bodyMedium),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: coaches.length,
      itemBuilder: (context, index) {
        return OdourCoachCard(
          coachData: coaches[index],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => OdourDeviceDetailScreen(coachData: coaches[index])),
            );
          },
        );
      },
    );
  }
}

class OdourCoachCard extends StatelessWidget {
  final Map<String, dynamic> coachData;
  final VoidCallback onTap;

  const OdourCoachCard({super.key, required this.coachData, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final devices = coachData['devices'] as List;
    final bool hasIssues = devices.any((d) => d['status'] == 'Offline' || (d['malfunction_alerts'] as List).isNotEmpty || d['cleanliness_indicator'] == 'Needs Cleaning');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: hasIssues ? const Color(0xFFFFF0F0) : ColorConstants.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          border: Border.all(color: hasIssues ? Colors.red.withOpacity(0.15) : ColorConstants.divider, width: 1),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Coach ${coachData['coach_number']}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: hasIssues ? const Color(0xFFD32F2F) : ColorConstants.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.chevron_right, size: 20, color: hasIssues ? const Color(0xFFD32F2F) : Colors.grey[400]),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Train: ${coachData['train_no']}',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.sensors, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('${devices.length} Devices', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class OdourDeviceDetailScreen extends StatelessWidget {
  final Map<String, dynamic> coachData;
  const OdourDeviceDetailScreen({super.key, required this.coachData});

  @override
  Widget build(BuildContext context) {
    final devices = coachData['devices'] as List;

    return Scaffold(
      backgroundColor: ColorConstants.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: ColorConstants.scaffoldBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ColorConstants.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Coach ${coachData['coach_number']} Details', style: AppTextStyles.header2),
            Text('Train: ${coachData['train_no']}', style: AppTextStyles.bodySmall),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ...devices.map((d) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: OdourDeviceCard(device: d),
            )),
          ],
        ),
      ),
    );
  }
}

class OdourDeviceCard extends StatelessWidget {
  final Map<String, dynamic> device;
  const OdourDeviceCard({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    final bool isOffline = device['status'] == 'Offline';
    final bool needsCleaning = device['cleanliness_indicator'] == 'Needs Cleaning';
    final bool hasAlerts = (device['malfunction_alerts'] as List).isNotEmpty;
    
    final Color cardColor = isOffline || needsCleaning || hasAlerts ? const Color(0xFFFFF0F0) : ColorConstants.cardBackground;
    final Color themeColor = isOffline || needsCleaning || hasAlerts ? const Color(0xFFD32F2F) : ColorConstants.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: themeColor.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(device['device_id'], style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: themeColor)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: themeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(device['status'], style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: themeColor)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(device['toilet_position'], style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w600)),
          const Divider(height: 24),
          Row(
            children: [
              _buildMetricItem(Icons.battery_charging_full, '${device['battery_level']}%', 'Battery', Colors.green),
              _buildMetricItem(Icons.water_drop, '${device['refill_level']}%', 'Refill', Colors.blue),
              _buildMetricItem(Icons.cleaning_services, '${device['usage_count_since_clean']}', 'Usages', Colors.orange),
            ],
          ),
          if (hasAlerts) ...[
            const SizedBox(height: 16),
            Text('Malfunction Alerts', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFFD32F2F))),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: (device['malfunction_alerts'] as List).map((alert) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFD32F2F).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(alert, style: GoogleFonts.poppins(fontSize: 9, color: const Color(0xFFD32F2F), fontWeight: FontWeight.w600)),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricItem(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: color.withOpacity(0.8)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: ColorConstants.primary)),
          Text(label, style: GoogleFonts.poppins(fontSize: 9, color: Colors.grey[500])),
        ],
      ),
    );
  }
}
