import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_coach_new/features/dashboard/presentation/widgets/custom_drawer.dart';
import 'package:smart_coach_new/features/coach_dashboard/presentation/bloc/coach_dashboard_bloc.dart';
import 'package:smart_coach_new/features/coach_dashboard/presentation/bloc/coach_dashboard_event.dart';
import 'package:smart_coach_new/features/coach_dashboard/presentation/bloc/coach_dashboard_state.dart';
import 'package:smart_coach_new/features/coach_dashboard/data/models/coach_config_response.dart';
import 'package:smart_coach_new/features/coach_dashboard/presentation/coach_history_screen.dart';
import 'package:smart_coach_new/features/reports_and_alerts/hot_axle/data/models/hot_axle_model.dart';
import 'package:smart_coach_new/features/reports_and_alerts/hot_axle/presentation/hot_axle_history_screen.dart';

class CoachDashboardScreen extends StatefulWidget {
  const CoachDashboardScreen({super.key});

  @override
  State<CoachDashboardScreen> createState() => _CoachDashboardScreenState();
}

class _CoachDashboardScreenState extends State<CoachDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CoachDashboardBloc>().add(LoadCoachDashboardData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: Text('Coach Dashboard', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: BlocConsumer<CoachDashboardBloc, CoachDashboardState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFilterSection(context, state),
                const SizedBox(height: 24),
                if (state.coachNotFound)
                  _buildNotFoundState(state.coachNotFoundMessage)
                else if (state.selectedCoach != null && state.coachConfig != null) ...[
                  _buildCoachInfoCard(state.coachConfig!.coachInfo, state),
                  const SizedBox(height: 24),
                  _buildDeviceListSection(state.coachConfig!.fittedDevices, state.coachConfig!.fullConfig, state),
                ] else
                  _buildNoSelectionState(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context, CoachDashboardState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Select Coach", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF2563EB))),
              TextButton.icon(
                onPressed: () {
                  context.read<CoachDashboardBloc>().add(LoadCoachDashboardData());
                  _searchController.clear();
                },
                icon: const Icon(Icons.refresh, size: 16),
                label: Text("Reset Filters", style: GoogleFonts.poppins(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildCascadingDropdown(
                  label: "Train Number",
                  value: state.selectedTrain,
                  items: state.trainNumbers,
                  onChanged: (val) => context.read<CoachDashboardBloc>().add(FilterTrainChanged(val!)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCascadingDropdown(
                  label: "Coach Type",
                  value: state.selectedCoachType,
                  items: state.coachTypes,
                  onChanged: (val) => context.read<CoachDashboardBloc>().add(FilterCoachTypeChanged(val!)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCascadingDropdown(
                  label: "Coach Number",
                  value: state.selectedUniqueId,
                  items: state.coachNumbers,
                  onChanged: (val) => context.read<CoachDashboardBloc>().add(FilterUniqueIdChanged(val!)),
                ),
              ),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider()),
          Text("Manual Search", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Enter Coach Number...",
                    hintStyle: GoogleFonts.poppins(fontSize: 12),
                    prefixIcon: const Icon(Icons.search, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  if (_searchController.text.isNotEmpty) {
                    context.read<CoachDashboardBloc>().add(SearchCoachById(_searchController.text));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Go", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCascadingDropdown({required String label, required String value, required List<String> items, required void Function(String?) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey.shade600)),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: items.contains(value) ? value : items.first,
          isExpanded: true,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.white,
          ),
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.black),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildCoachInfoCard(CoachInfo? info, CoachDashboardState state) {
    if (info == null) return const SizedBox.shrink();

    final deviceId = state.filteredDevices.isNotEmpty
        ? (state.filteredDevices.first.deviceUniqueId ?? 'N/A')
        : 'N/A';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF0F172A)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("COACH NUMBER", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10, letterSpacing: 1.2)),
                  Text(info.coachNo, style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                child: const Text("ACTIVE", style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoTile("Type", info.coachType),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(color: Colors.white60, fontSize: 10)),
        Text(value, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildDeviceListSection(List<String> fittedDevices, FullConfig? fullConfig, CoachDashboardState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("FITTED DEVICES (${fittedDevices.length})", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
        const SizedBox(height: 16),
        if (fittedDevices.isEmpty)
           const Center(child: Padding(padding: EdgeInsets.all(32.0), child: Text("No devices found for this coach")))
        else
          ...fittedDevices.map((d) => _buildDeviceCard(d, fullConfig, state)),
      ],
    );
  }

  Widget _buildDeviceCard(String deviceName, FullConfig? fullConfig, CoachDashboardState state) {
    String status = "FITTED";
    bool isFitted = true;

    // Map device name to status from fullConfig if possible
    if (fullConfig != null) {
      if (deviceName.contains("Water Level")) status = fullConfig.wliSensor;
      else if (deviceName.contains("FSDS")) status = fullConfig.fsdsSensor;
      else if (deviceName.contains("Hot Axle")) status = fullConfig.hotAxleDetector;
      else if (deviceName.contains("Bad Odour")) status = fullConfig.badOdourAlert;
      else if (deviceName.contains("BC Pressure")) status = fullConfig.bcPressure;
      else if (deviceName.contains("ACP")) status = fullConfig.acpBuzzerAlert;

      isFitted = status == "FITTED";
    }

    final isAcp = deviceName.contains("ACP");
    final isHotAxle = deviceName.contains("Hot Axle") || deviceName.contains("Axle");
    final isTappable = isAcp || isHotAxle;
    final coachUniqueId = state.selectedCoach?.coachUniqueId ?? '';
    final deviceId = state.filteredDevices.isNotEmpty
        ? (state.filteredDevices.first.deviceUniqueId ?? 'N/A')
        : 'N/A';

    final card = Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isTappable ? const Color(0xFF2563EB).withValues(alpha: 0.3) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isFitted ? const Color(0xFFEFF6FF) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12)
            ),
            child: Icon(
              deviceName.contains("Water") ? Icons.water_drop :
              deviceName.contains("Fire") || deviceName.contains("FSDS") ? Icons.fireplace :
              isHotAxle ? Icons.settings_input_hdmi :
              Icons.sensors,
              color: isFitted ? const Color(0xFF2563EB) : Colors.grey
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(deviceName, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                if (isTappable)
                  Text('Tap to view history', style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF2563EB))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("Status", style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF64748B))),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isFitted ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4)
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: isFitted ? Colors.green : Colors.red,
                    fontSize: 9,
                    fontWeight: FontWeight.bold
                  )
                ),
              ),
              if (isTappable) ...[
                const SizedBox(height: 4),
                const Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFF2563EB)),
              ],
            ],
          ),
        ],
      ),
    );

    if (!isTappable) return card;

    return GestureDetector(
      onTap: () {
        if (isAcp) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CoachHistoryScreen(
                coachNo: coachUniqueId,
                deviceId: deviceId,
              ),
            ),
          );
        } else if (isHotAxle) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HotAxleHistoryScreen(
                coach: HotAxleCoachModel(
                  coachNumber: coachUniqueId,
                  deviceId: deviceId,
                  coachType: '',
                  owningRly: '',
                  timestamp: '',
                  a11Temp: 0, a12Temp: 0, a21Temp: 0, a22Temp: 0,
                  a31Temp: 0, a32Temp: 0, a41Temp: 0, a42Temp: 0,
                  batteryPercentage: 0,
                  signalStrength: 0,
                ),
              ),
            ),
          );
        }
      },
      child: card,
    );
  }

  Widget _buildNoSelectionState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 60),
          Icon(Icons.directions_railway_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text("Select a coach to view configuration", style: GoogleFonts.poppins(color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildNotFoundState(String message) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFE4E6)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_off_rounded, size: 48, color: Color(0xFFE11D48)),
            ),
            const SizedBox(height: 20),
            Text(
              "No Data Found",
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),
            Text(
              message.isNotEmpty ? message : "Coach details not found in master data",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
