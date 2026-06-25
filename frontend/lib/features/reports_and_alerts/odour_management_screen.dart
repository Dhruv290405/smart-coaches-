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
import 'odour_management/data/models/odour_model.dart';
import 'odour_management/data/repository/odour_repository.dart';

class OdourManagementScreen extends StatefulWidget {
  const OdourManagementScreen({super.key});

  @override
  State<OdourManagementScreen> createState() => _OdourManagementScreenState();
}

class _OdourManagementScreenState extends State<OdourManagementScreen> {
  final OdourRepository _repository = OdourRepository();
  String selectedTrainNumber = 'All Trains';
  String selectedCoachType = 'All Types';
  String selectedCoachNumber = 'All Coaches';
  String selectedStatus = 'All';
  String lastUpdated = '--:--:--';
  bool isRefreshing = false;

  List<OdourCoachModel> _allCoaches = [];
  List<OdourCoachModel> _filteredCoaches = [];

  List<String> get trainNumbers => ['All Trains', ..._allCoaches.map((c) => c.trainNumber).toSet()];
  List<String> get coachTypes => ['All Types', ..._allCoaches.map((c) => c.coachType).toSet()];
  List<String> get coachNumbers => ['All Coaches', ..._allCoaches.map((c) => c.coachNumber).toSet()];

  void _clearFilters() {
    setState(() {
      selectedTrainNumber = 'All Trains';
      selectedCoachType = 'All Types';
      selectedCoachNumber = 'All Coaches';
      selectedStatus = 'All';
    });
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _filteredCoaches = _allCoaches.where((c) {
        if (selectedTrainNumber != 'All Trains' && c.trainNumber != selectedTrainNumber) return false;
        if (selectedCoachType != 'All Types' && c.coachType != selectedCoachType) return false;
        if (selectedCoachNumber != 'All Coaches' && c.coachNumber != selectedCoachNumber) return false;
        if (selectedStatus != 'All') {
          if (selectedStatus == 'Alert' && !c.hasActiveAlert) return false;
          if (selectedStatus == 'Active' && c.hasActiveAlert) return false;
        }
        return true;
      }).toList();
    });
  }

  Future<void> _refreshData() async {
    setState(() => isRefreshing = true);
    try {
      final data = await _repository.getOdourData();
      if (mounted) {
        setState(() {
          _allCoaches = data;
          lastUpdated = DateFormat('HH:mm:ss').format(DateTime.now());
        });
        _applyFilters();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => isRefreshing = false);
    }
  }

  void _sendAlerts() {
    final critical = _allCoaches.where((c) => c.hasActiveAlert).length;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sent alerts for $critical coaches with active alerts')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredCoaches;

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
            _buildSectionCard(child: _buildFiltersSection()),
            const SizedBox(height: 8),
            _buildSectionCard(child: _buildQuickActionsSection()),
            const SizedBox(height: 8),
            if (filtered.isEmpty)
              Container(
                height: 200,
                alignment: Alignment.center,
                child: Text('No coaches found matching criteria', style: AppTextStyles.bodyMedium),
              )
            else
              _buildCoachGrid(filtered),
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

  Widget _buildFiltersSection() {
    final trains = trainNumbers;
    final types = coachTypes;
    final numbers = coachNumbers;

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
            Expanded(child: FilterDropdown(label: AppStrings.trainNumber, value: selectedTrainNumber, items: trains, onChanged: (v) => setState(() { selectedTrainNumber = v!; _applyFilters(); }))),
            const SizedBox(width: 8),
            Expanded(child: FilterDropdown(label: 'Coach Type', value: selectedCoachType, items: types, onChanged: (v) => setState(() { selectedCoachType = v!; _applyFilters(); }))),
            const SizedBox(width: 8),
            Expanded(child: FilterDropdown(label: AppStrings.coachNumber, value: selectedCoachNumber, items: numbers, onChanged: (v) => setState(() { selectedCoachNumber = v!; _applyFilters(); }))),
          ],
        ),
        const SizedBox(height: 12),
        Text(AppStrings.status, style: AppTextStyles.label),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(child: StatusChip(label: AppStrings.all, isSelected: selectedStatus == 'All', onTap: () => setState(() { selectedStatus = 'All'; _applyFilters(); }))),
            const SizedBox(width: 8),
            Expanded(child: StatusChip(label: 'Alert', isSelected: selectedStatus == 'Alert', onTap: () => setState(() { selectedStatus = 'Alert'; _applyFilters(); }))),
            const SizedBox(width: 8),
            Expanded(child: StatusChip(label: 'Active', isSelected: selectedStatus == 'Active', onTap: () => setState(() { selectedStatus = 'Active'; _applyFilters(); }))),
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
                onTap: _sendAlerts,
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

  Widget _buildCoachGrid(List<OdourCoachModel> coaches) {
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
        final coach = coaches[index];
        return _OdourCoachCard(
          coach: coach,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => _OdourCoachDetailScreen(coach: coach)),
            );
          },
        );
      },
    );
  }
}

class _OdourCoachCard extends StatelessWidget {
  final OdourCoachModel coach;
  final VoidCallback onTap;

  const _OdourCoachCard({required this.coach, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool hasIssues = coach.hasActiveAlert;

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
                    coach.coachNumber,
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
              'Train: ${coach.trainNumber}',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.sensors, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('${coach.toilets.length} Sensors', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87)),
                if (coach.alertCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)),
                    child: Text('${coach.alertCount}', style: GoogleFonts.poppins(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OdourCoachDetailScreen extends StatelessWidget {
  final OdourCoachModel coach;
  const _OdourCoachDetailScreen({required this.coach});

  @override
  Widget build(BuildContext context) {
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
            Text('${coach.coachNumber} Details', style: AppTextStyles.header2),
            Text('Train: ${coach.trainNumber}', style: AppTextStyles.bodySmall),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: coach.toilets.map((t) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _ToiletSensorCard(sensor: t),
          )).toList(),
        ),
      ),
    );
  }
}

class _ToiletSensorCard extends StatelessWidget {
  final ToiletSensor sensor;
  const _ToiletSensorCard({required this.sensor});

  @override
  Widget build(BuildContext context) {
    final bool isAlert = sensor.isBad;
    final Color themeColor = isAlert ? const Color(0xFFD32F2F) : ColorConstants.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isAlert ? const Color(0xFFFFF0F0) : ColorConstants.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: themeColor.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(sensor.id, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: themeColor)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: themeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(sensor.status, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: themeColor)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(sensor.position, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w600)),
          const Divider(height: 24),
          Row(
            children: [
              _buildMetricItem(Icons.air, '${sensor.reading} ppm', 'Reading', themeColor),
              _buildMetricItem(Icons.info_outline, sensor.levelLabel, 'Level', sensor.isBad ? Colors.red : Colors.green),
            ],
          ),
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
