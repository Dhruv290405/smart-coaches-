import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_coach_new/core/di/inject.dart';
import 'package:smart_coach_new/core/network/api_client.dart';
import 'package:smart_coach_new/core/utils/app_dimensions.dart';
import 'package:smart_coach_new/core/utils/app_icons.dart';
import 'package:smart_coach_new/core/utils/app_strings.dart';
import 'package:smart_coach_new/core/utils/prefs.dart';
import 'package:smart_coach_new/core/utils/app_text_styles.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/core/widgets/action_button.dart';
import 'package:smart_coach_new/core/widgets/filter_dropdown.dart';
import 'package:smart_coach_new/core/widgets/status_chip.dart';
import 'package:smart_coach_new/core/widgets/view_type_selector.dart';
import 'package:intl/intl.dart';
import 'package:smart_coach_new/features/reports_and_alerts/hot_axle/data/models/hot_axle_response.dart';
import 'package:smart_coach_new/features/reports_and_alerts/hot_axle/data/repository/hot_axle_repository.dart';
import 'package:smart_coach_new/features/reports_and_alerts/hot_axle/presentation/hot_axle_alert_view.dart';
import 'package:smart_coach_new/features/reports_and_alerts/hot_axle/presentation/hot_axle_chart_view.dart';
import 'package:smart_coach_new/features/reports_and_alerts/hot_axle/presentation/widgets/hams_device_card.dart';
import 'package:smart_coach_new/features/reports_and_alerts/hot_axle/presentation/widgets/hot_axle_device_card.dart';
import 'package:smart_coach_new/features/reports_and_alerts/hot_axle/presentation/widgets/hot_axle_modal.dart';
import 'package:smart_coach_new/features/reports_and_alerts/hot_axle/presentation/widgets/hot_axle_report_generator.dart';
import 'package:smart_coach_new/features/reports_and_alerts/hot_axle/presentation/hot_axle_detail_screen.dart';
import '../data/models/hot_axle_model.dart';

class HotAxleDashboard extends StatefulWidget {
  const HotAxleDashboard({super.key});

  @override
  State<HotAxleDashboard> createState() => _HotAxleDashboardState();
}

class _HotAxleDashboardState extends State<HotAxleDashboard> {
  String selectedTrainNumber = 'All Trains';
  String selectedCoachType = 'All Types';
  String selectedCoachNumber = 'All Coach Numbers';
  String selectedStatus = 'All';
  String selectedCompany = 'All';
  String lastUpdated = 'Never';
  bool isRefreshing = false;
  bool _isInitialLoad = true;
  String selectedViewType = 'Monitor';
  Timer? _refreshTimer;

  List<String> trainNumbers = ['All Trains'];
  List<String> coachTypes = ['All Types'];
  List<String> coachNumbers = ['All Coach Numbers'];

  List<HotAxleCoachModel> _allCoaches = [];
  List<HotAxleCoachModel> _filteredCoaches = [];
  List<HotAxleCoachModel> _allHamsCoaches = [];
  List<HotAxleCoachModel> _filteredHamsCoaches = [];
  List<HamsDataModel> _newCompanyData = [];
  final Set<String> _expandedSections = {'our', 'ecr'};

  bool get _isDanapur => (getIt<Prefs>().getUser()?.regionName ?? '').toLowerCase() == 'danapur';

  @override
  void initState() {
    super.initState();
    _refreshData();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (mounted) _refreshData(isBackgroundRefresh: true);
    });
  }

  int _getHamsAxleIndex(String deviceId) {
    final cleanId = deviceId.trim().toUpperCase();
    const mapping = {
      'HAMS001': 0,
      'HAMS002': 1,
      'HAMS003': 2,
      'HAMS004': 3,
      'HAMS005': 4,
      'HAMS006': 5,
      'HAMS008': 6,
      'HAMS009': 7,
    };
    if (mapping.containsKey(cleanId)) {
      return mapping[cleanId]!;
    }
    final numStr = cleanId.replaceAll(RegExp(r'\D'), '');
    final num = int.tryParse(numStr);
    if (num != null) {
      if (num <= 6) return num - 1;
      if (num >= 8 && num <= 9) return num - 2;
    }
    return -1;
  }

  void _updateFilterLists() {
    final showNewData = _isDanapur || selectedCompany == 'All' || selectedCompany == 'Section 1';
    final showOldData = !_isDanapur && (selectedCompany == 'All' || selectedCompany == 'Section 2');

    final Set<String> trains = {};
    final Set<String> types = {};
    final Set<String> coaches = {};

    if (showOldData) {
      trains.addAll(_allCoaches.map((e) => e.trainNo).where((e) => e.isNotEmpty));
      types.addAll(_allCoaches.map((e) => e.coachType).where((e) => e.isNotEmpty));
      coaches.addAll(_allCoaches.map((e) => e.coachNumber).where((e) => e.isNotEmpty));
    }

    if (showNewData) {
      trains.addAll(_allHamsCoaches.map((e) => e.trainNo).where((e) => e.isNotEmpty));
      types.addAll(_allHamsCoaches.map((e) => e.coachType).where((e) => e.isNotEmpty));
      coaches.addAll(_allHamsCoaches.map((e) => e.coachNumber).where((e) => e.isNotEmpty));
    }

    final sortedTrains = trains.toList()..sort();
    final sortedTypes = types.toList()..sort();
    final sortedCoaches = coaches.toList()..sort();

    trainNumbers = ['All Trains', ...sortedTrains];
    coachTypes = ['All Types', ...sortedTypes];
    coachNumbers = ['All Coach Numbers', ...sortedCoaches];

    if (selectedTrainNumber != 'All Trains' && !trains.contains(selectedTrainNumber)) {
      selectedTrainNumber = 'All Trains';
    }
    if (selectedCoachType != 'All Types' && !types.contains(selectedCoachType)) {
      selectedCoachType = 'All Types';
    }
    if (selectedCoachNumber != 'All Coach Numbers' && !coaches.contains(selectedCoachNumber)) {
      selectedCoachNumber = 'All Coach Numbers';
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredCoaches = _allCoaches.where((coach) {
        final matchesTrain = selectedTrainNumber == 'All Trains' || coach.trainNo == selectedTrainNumber;
        final matchesCoachType = selectedCoachType == 'All Types' || coach.coachType == selectedCoachType;
        final matchesCoachNumber = selectedCoachNumber == 'All Coach Numbers' || coach.coachNumber == selectedCoachNumber;
        final matchesStatus = selectedStatus == 'All' || coach.status.toUpperCase() == selectedStatus.toUpperCase();
        bool matchesCompany;
        if (selectedCompany == 'All') {
          matchesCompany = true;
        } else if (selectedCompany == 'Section 2') {
          matchesCompany = coach.owningRly == 'ECR';
        } else {
          matchesCompany = coach.owningRly != 'ECR';
        }
        return matchesTrain && matchesCoachType && matchesCoachNumber && matchesStatus && matchesCompany;
      }).toList();

      _filteredHamsCoaches = _allHamsCoaches.where((coach) {
        final matchesTrain = selectedTrainNumber == 'All Trains' || coach.trainNo == selectedTrainNumber;
        final matchesCoachType = selectedCoachType == 'All Types' || coach.coachType == selectedCoachType;
        final matchesCoachNumber = selectedCoachNumber == 'All Coach Numbers' || coach.coachNumber == selectedCoachNumber;
        final matchesStatus = selectedStatus == 'All' || coach.status.toUpperCase() == selectedStatus.toUpperCase();
        bool matchesCompany;
        if (selectedCompany == 'All') {
          matchesCompany = true;
        } else if (selectedCompany == 'Section 1') {
          matchesCompany = true;
        } else {
          matchesCompany = false;
        }
        return matchesTrain && matchesCoachType && matchesCoachNumber && matchesStatus && matchesCompany;
      }).toList();
    });
  }

  double _validTemp(double t) => t < 0 ? 0.0 : t;

  HotAxleCoachModel _mapDataToModel(HotAxleData d) {
    return HotAxleCoachModel(
      deviceId: d.deviceId ?? 'Unknown',
      masterId: d.deviceId ?? '',
      coachNumber: d.coachNumber ?? d.techCoachNo ?? 'Unknown',
      coachType: d.coachType ?? 'Unknown',
      owningRly: d.owningRly ?? 'Unknown',
      trainNo: d.trainNo ?? '',
      timestamp: d.timestamp ?? '',
      a11Temp: _validTemp(d.a11Temp),
      a12Temp: _validTemp(d.a12Temp),
      a21Temp: _validTemp(d.a21Temp),
      a22Temp: _validTemp(d.a22Temp),
      a31Temp: _validTemp(d.a31Temp),
      a32Temp: _validTemp(d.a32Temp),
      a41Temp: _validTemp(d.a41Temp),
      a42Temp: _validTemp(d.a42Temp),
      batteryPercentage: d.batteryPercentage,
      signalStrength: d.signalStrength,
      apiStatus: _mapAlertStatus(d.alertStatus),
      technicalId: d.technicalId ?? '',
    );
  }

  String _mapAlertStatus(String? raw) {
    switch ((raw ?? '').toLowerCase()) {
      case 'warning': return 'Warning';
      case 'critical': return 'Critical';
      default: return 'Good';
    }
  }

  Future<void> _refreshData({bool isBackgroundRefresh = false}) async {
    if (!isBackgroundRefresh) {
      if (mounted) setState(() => isRefreshing = true);
    }

    try {
      final String? trainFilter = selectedTrainNumber == 'All Trains' ? null : selectedTrainNumber;
      final String? coachTypeFilter = selectedCoachType == 'All Types' ? null : selectedCoachType;
      final List<HotAxleData> rawData = await getIt<HotAxleRepository>().getHotAxleDashboard(
        trainNo: trainFilter,
        coachType: coachTypeFilter,
      );
      final List<HotAxleCoachModel> coaches = rawData.map(_mapDataToModel).toList();

      List<HamsDataModel> newData = [];
      try {
        final resp = await getIt<ApiClient>().get('/hot-axle/new-company-data');
        if (resp is Map && resp['success'] == true && resp['data'] is List) {
          newData = (resp['data'] as List).map((e) => HamsDataModel.fromJson(e as Map<String, dynamic>)).toList();
        }
      } catch (e) {
        log('New company data fetch error: $e');
      }

      if (mounted) {
        setState(() {
          isRefreshing = false;
          _isInitialLoad = false;
          lastUpdated = DateFormat('HH:mm:ss').format(DateTime.now());
          _allCoaches = coaches;
          _newCompanyData = newData;

          final Map<String, List<HamsDataModel>> grouped = {};
          for (final d in newData) {
            if (d.masterId.isEmpty) continue;
            grouped.putIfAbsent(d.masterId, () => []).add(d);
          }
          _allHamsCoaches = [];
          for (final entry in grouped.entries) {
            _allHamsCoaches.add(_mapMasterDevicesToCoach(entry.key, entry.value));
          }

          _updateFilterLists();
          _applyFilters();
        });
      }
    } catch (e) {
      log('Hot Axle error: $e');
      if (mounted) {
        setState(() {
          isRefreshing = false;
          _isInitialLoad = false;
        });
      }
    }
  }

  void _clearFilters() {
    setState(() {
      selectedTrainNumber = 'All Trains';
      selectedCoachType = 'All Types';
      selectedCoachNumber = 'All Coach Numbers';
      selectedStatus = 'All';
      selectedCompany = 'All';
      _updateFilterLists();
    });
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1D21)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Hot Axle Monitoring',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1D21),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Updated: $lastUpdated',
                  style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _isInitialLoad
          ? const Center(child: CircularProgressIndicator(color: ColorConstants.primary))
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!_isDanapur) _buildSectionCard(child: _buildCompanyFilter()),
                      const SizedBox(height: 8),
                      _buildSectionCard(child: _buildFiltersSection()),
                      const SizedBox(height: 8),
                      _buildSectionCard(child: _buildQuickActionsSection()),
                      const SizedBox(height: 8),
                      _buildSectionCard(child: _buildViewTypeSection()),
                      const SizedBox(height: 8),
                      if (selectedViewType == 'Monitor')
                        _buildDeviceSections()
                      else if (selectedViewType == 'Analytics')
                        _buildSectionCard(child: HotAxleChartView(coaches: _filteredCoaches))
                      else if (selectedViewType == 'Alerts')
                        _buildSectionCard(child: HotAxleAlertView(alerts: _buildAlertData())),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildCompanyFilter() {
    return FilterDropdown(
      label: 'Company',
      value: selectedCompany,
      items: const ['All', 'Section 2', 'Section 1'],
      onChanged: (value) {
        setState(() {
          selectedCompany = value!;
          _updateFilterLists();
        });
        _applyFilters();
      },
    );
  }

  Widget _buildFiltersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Filters', style: AppTextStyles.header2.copyWith(color: ColorConstants.primary)),
            GestureDetector(
              onTap: _clearFilters,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ColorConstants.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
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
            Expanded(
              child: FilterDropdown(
                label: 'Train Number',
                value: selectedTrainNumber,
                items: trainNumbers,
                onChanged: (value) {
                  setState(() => selectedTrainNumber = value!);
                  _refreshData();
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilterDropdown(
                label: 'Coach Type',
                value: selectedCoachType,
                items: coachTypes,
                onChanged: (value) {
                  setState(() => selectedCoachType = value!);
                  _refreshData();
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilterDropdown(
                label: 'Coach Number',
                value: selectedCoachNumber,
                items: coachNumbers,
                onChanged: (value) {
                  setState(() => selectedCoachNumber = value!);
                  _applyFilters();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text('Status', style: AppTextStyles.label),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(child: StatusChip(label: 'All',      isSelected: selectedStatus == 'All',      onTap: () { setState(() => selectedStatus = 'All'); _applyFilters(); })),
            const SizedBox(width: 8),
            Expanded(child: StatusChip(label: 'Good',     isSelected: selectedStatus == 'Good',     onTap: () { setState(() => selectedStatus = 'Good'); _applyFilters(); })),
            const SizedBox(width: 8),
            Expanded(child: StatusChip(label: 'Warning',  isSelected: selectedStatus == 'Warning',  onTap: () { setState(() => selectedStatus = 'Warning'); _applyFilters(); })),
            const SizedBox(width: 8),
            Expanded(child: StatusChip(label: 'Critical', isSelected: selectedStatus == 'Critical', onTap: () { setState(() => selectedStatus = 'Critical'); _applyFilters(); })),
          ],
        ),
      ],
    );
  }

  Widget _buildDeviceSections() {
    if (_isDanapur) {
      if (_filteredHamsCoaches.isEmpty) {
        return Container(
          height: 200,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sensors_off, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text('No devices found', style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF6B7280))),
            ],
          ),
        );
      }
      return _buildHamsGridForList(_filteredHamsCoaches);
    }

    final showNewData = selectedCompany == 'All' || selectedCompany == 'Section 1';
    final showOldData = selectedCompany == 'All' || selectedCompany == 'Section 2';

    final hasNew = _filteredHamsCoaches.isNotEmpty && showNewData;
    final hasOld = _filteredCoaches.isNotEmpty && showOldData;

    if (!hasNew && !hasOld) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sensors_off, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text('No devices found', style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF6B7280))),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasNew) _buildExpandableSection('Section 1', _filteredHamsCoaches.length, 'our', _buildHamsGridForList(_filteredHamsCoaches)),
        if (hasNew && hasOld) const SizedBox(height: 8),
        if (hasOld) _buildExpandableSection('Section 2', _filteredCoaches.length, 'ecr', _buildDeviceGridForList(_filteredCoaches)),
      ],
    );
  }

  Widget _buildExpandableSection(String title, int count, String key, Widget content) {
    final expanded = _expandedSections.contains(key);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8ECF0), width: 1),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              setState(() {
                if (expanded) { _expandedSections.remove(key); }
                else { _expandedSections.add(key); }
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 3, height: 18,
                    decoration: BoxDecoration(color: ColorConstants.primary, borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(width: 10),
                  Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1A1D21))),
                  const Spacer(),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down, color: ColorConstants.iconGrey),
                  ),
                ],
              ),
            ),
          ),
          if (expanded) ...[
            const Divider(height: 1, color: Color(0xFFE8ECF0)),
            Padding(
              padding: const EdgeInsets.all(12),
              child: content,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHamsGridForList(List<HotAxleCoachModel> coaches) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.62,
      ),
      itemCount: coaches.length,
      itemBuilder: (context, index) {
        final coach = coaches[index];
        return HotAxleDeviceCard(
          coach: coach,
          sequenceNumber: index + 1,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HotAxleDetailScreen(coach: coach),
            ),
          ),
        );
      },
    );
  }

  HotAxleCoachModel _mapMasterDevicesToCoach(String masterId, List<HamsDataModel> allDevices) {
    final latestByDevice = <String, HamsDataModel>{};
    for (final d in allDevices) {
      if (!latestByDevice.containsKey(d.deviceId)) {
        latestByDevice[d.deviceId] = d;
      }
    }
    final devices = latestByDevice.values.toList();
    devices.removeWhere((d) => d.deviceId == 'HAMS007');

    final firstDev = devices.isNotEmpty ? devices.first : null;
    double a11 = 0, a12 = 0, a21 = 0, a22 = 0, a31 = 0, a32 = 0, a41 = 0, a42 = 0;
    int batteryPct = 50;
    if (firstDev != null) {
      final bat = firstDev.batteryStatus.toLowerCase();
      if (bat == 'low') batteryPct = 15;
      else if (bat == 'moderate') batteryPct = 40;
      else if (bat == 'high') batteryPct = 80;
    }

    for (final d in devices) {
      final temp = d.temperature;
      final idx = _getHamsAxleIndex(d.deviceId);
      if (idx == 0) a11 = temp;
      else if (idx == 1) a12 = temp;
      else if (idx == 2) a21 = temp;
      else if (idx == 3) a22 = temp;
      else if (idx == 4) a31 = temp;
      else if (idx == 5) a32 = temp;
      else if (idx == 6) a41 = temp;
      else if (idx == 7) a42 = temp;
    }

    final List<AxleModel> axles = [];
    final hamsDeviceIds = ['HAMS001', 'HAMS002', 'HAMS003', 'HAMS004', 'HAMS005', 'HAMS006', 'HAMS008', 'HAMS009'];
    for (int i = 0; i < 8; i++) {
      final devId = hamsDeviceIds[i];
      final match = devices.firstWhere((d) => d.deviceId.toUpperCase() == devId.toUpperCase(), orElse: () => HamsDataModel(
        id: 0,
        deviceId: devId,
        masterId: masterId,
        temperature: 0,
        status: 'Low',
        tempState: 'Normal',
        receivedTimestamp: firstDev?.receivedTimestamp ?? '',
        batteryStatus: 'N/A',
        batteryVoltage: 0.0,
      ));
      final tempStr = '${match.temperature}°C';
      final status = match.temperature > 60 ? 'Warning' : 'Good';
      axles.add(AxleModel(
        axleNumber: i + 1,
        status: status,
        maxTemp: tempStr,
        currentTemp: tempStr,
        sensorId: match.deviceId,
        deviceId: match.deviceId,
        speed: 'N/A',
        detectedAt: match.receivedTimestamp,
        location: match.location.isNotEmpty ? match.location : 'N/A',
        lastMaintenance: 'N/A',
        updateTime: match.receivedTimestamp,
        batteryStatus: match.batteryStatus,
        batteryVoltage: match.batteryVoltage,
      ));
    }

    return HotAxleCoachModel(
      deviceId: masterId,
      masterId: masterId,
      coachNumber: firstDev?.coachNumber ?? 'Master: $masterId',
      technicalId: firstDev?.technicalId ?? '',
      coachType: firstDev?.coachType ?? 'HAMS',
      owningRly: 'VASP',
      trainNo: firstDev?.trainNo ?? '',
      timestamp: firstDev?.receivedTimestamp ?? '',
      batteryPercentage: batteryPct,
      signalStrength: 0,
      a11Temp: a11, a12Temp: a12,
      a21Temp: a21, a22Temp: a22,
      a31Temp: a31, a32Temp: a32,
      a41Temp: a41, a42Temp: a42,
      apiStatus: axles.any((a) => a.status == 'Warning') ? 'Warning' : 'Good',
      customAxles: axles,
    );
  }

  Widget _buildDeviceGridForList(List<HotAxleCoachModel> coaches) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.62,
      ),
      itemCount: coaches.length,
      itemBuilder: (context, index) {
        final coach = coaches[index];
        return HotAxleDeviceCard(
          coach: coach,
          sequenceNumber: index + 1,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HotAxleDetailScreen(coach: coach),
            ),
          ),
        );
      },
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
              child: isRefreshing
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      decoration: BoxDecoration(
                        color: ColorConstants.cardBackground,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                        border: Border.all(color: ColorConstants.divider),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: ColorConstants.primary)),
                          const SizedBox(width: 6),
                          Text('Refreshing...', style: GoogleFonts.poppins(fontSize: 12, color: ColorConstants.textSecondary)),
                        ],
                      ),
                    )
                  : ActionButton(
                      label: AppStrings.refreshData,
                      svgIcon: AppIcons.refresh,
                      onTap: () => _refreshData(),
                      isPrimary: true,
                      isFullWidth: true,
                    ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ActionButton(
                label: AppStrings.generateReport,
                svgIcon: AppIcons.report,
                onTap: () => HotAxleReportGenerator.generate(context, [..._filteredHamsCoaches, ..._filteredCoaches]),
                isFullWidth: true,
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
            Expanded(child: ViewTypeSelector(label: 'Monitor', svgIcon: AppIcons.eye, isSelected: selectedViewType == 'Monitor', onTap: () => setState(() => selectedViewType = 'Monitor'))),
            const SizedBox(width: 8),
            Expanded(child: ViewTypeSelector(label: AppStrings.chartView, svgIcon: AppIcons.graph, isSelected: selectedViewType == 'Analytics', onTap: () => setState(() => selectedViewType = 'Analytics'))),
            const SizedBox(width: 8),
            Expanded(child: ViewTypeSelector(label: AppStrings.alerts, svgIcon: AppIcons.alert, isSelected: selectedViewType == 'Alerts', onTap: () => setState(() => selectedViewType = 'Alerts'))),
          ],
        ),
      ],
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

  List<Map<String, dynamic>> _buildAlertData() {
    return [..._filteredHamsCoaches, ..._filteredCoaches]
        .where((c) => c.status == 'Warning' || c.status == 'Critical')
        .map((c) => {
              'type': c.status.toLowerCase(),
              'title': 'High temperature on ${c.coachNumber}',
              'coach': c.coachNumber,
              'device': c.deviceId,
              'time': c.timestamp.isNotEmpty ? DateFormat('hh:mm a').format(DateTime.tryParse(c.timestamp.replaceFirst(' ', 'T')) ?? DateTime.now()) : 'N/A',
              'detail': 'Max temp: ${c.maxTemp.toStringAsFixed(1)}°C',
              'note': c.status == 'Critical' ? 'Immediate action required' : 'Monitor closely',
            })
        .toList();
  }
}
