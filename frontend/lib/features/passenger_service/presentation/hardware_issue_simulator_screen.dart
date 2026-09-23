import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/network/api_constants.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/core/utils/loader.dart';
import 'package:smart_coach_new/core/utils/toast_message_utils.dart';

class HardwareIssueSimulatorScreen extends StatefulWidget {
  const HardwareIssueSimulatorScreen({super.key});

  @override
  State<HardwareIssueSimulatorScreen> createState() => _HardwareIssueSimulatorScreenState();
}

class _HardwareIssueSimulatorScreenState extends State<HardwareIssueSimulatorScreen> {
  List<Map<String, dynamic>> _devices = [];
  String? _selectedDevice;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMapping();
  }

  Future<void> _loadMapping() async {
    setState(() => _loading = true);
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.devUrl}/hardware-issues/mapping'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        setState(() {
          _devices = List<Map<String, dynamic>>.from(body['data']['devices'] ?? []);
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
        ToastMessageUtils.showMessage(context, 'Failed to load devices');
      }
    } catch (e) {
      setState(() => _loading = false);
      ToastMessageUtils.showMessage(context, 'Network error');
    }
  }

  Future<void> _sendEvent(String eventType) async {
    final deviceId = _selectedDevice;
    if (deviceId == null) return;

    Loader.show();
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.devUrl}/hardware-issues/event'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'device_id': deviceId, 'event_type': eventType}),
      );
      Loader.dismiss();
      final body = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        ToastMessageUtils.showMessage(context, body['message'] ?? 'Event sent');
      } else {
        ToastMessageUtils.showMessage(context, body['message'] ?? 'Event failed');
      }
    } catch (e) {
      Loader.dismiss();
      ToastMessageUtils.showMessage(context, 'Network error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.screenBgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black87, size: 5.w),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Device Simulator",
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: ColorConstants.primary))
          : _devices.isEmpty
              ? Center(
                  child: Text("No devices mapped. Run the seed script.",
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey)))
              : SingleChildScrollView(
                  padding: EdgeInsets.all(5.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Test Train 20917/20916 — 43 compartments",
                          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600)),
                      SizedBox(height: 2.h),
                      _buildDevicePicker(),
                      SizedBox(height: 3.h),
                      if (_selectedDevice != null) _buildButtonPanel(_selectedDevice!),
                      SizedBox(height: 3.h),
                      _buildAllCoachesQuickView(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildDevicePicker() {
    final coaches = ['A1', 'A2', 'B1', 'B2', 'B3'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: coaches.map((coach) {
        final coachDevices = _devices.where((d) => d['coach_no'] == coach).toList()
          ..sort((a, b) => int.parse('${a['compartment_no']}').compareTo(int.parse('${b['compartment_no']}')));
        return Padding(
          padding: EdgeInsets.only(bottom: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Coach $coach",
                  style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: ColorConstants.primary)),
              SizedBox(height: 1.h),
              Wrap(
                spacing: 2.w,
                runSpacing: 1.h,
                children: coachDevices.map((d) {
                  final isSelected = _selectedDevice == d['device_id'];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDevice = d['device_id']),
                    child: Container(
                      width: 18.w,
                      padding: EdgeInsets.symmetric(vertical: 1.2.h),
                      decoration: BoxDecoration(
                        color: isSelected ? ColorConstants.primary : Colors.white,
                        borderRadius: BorderRadius.circular(2.w),
                        border: Border.all(
                          color: isSelected ? ColorConstants.primary : Colors.grey.shade300,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text('${d['compartment_no']}',
                              style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? Colors.white : Colors.black87)),
                          Text('${d['device_id']}',
                              style: TextStyle(
                                  fontSize: 7.sp,
                                  color: isSelected ? Colors.white70 : Colors.grey)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildButtonPanel(String deviceId) {
    final device = _devices.firstWhere((d) => d['device_id'] == deviceId);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3.w),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Device ${device['device_id']}  ·  ${device['coach_no']} / Comp ${device['compartment_no']}",
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  label: 'Linen Issue',
                  icon: Icons.checkroom,
                  color: const Color(0xFF7B1FA2),
                  onTap: () => _sendEvent('linen'),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _actionButton(
                  label: 'Cleaning Issue',
                  icon: Icons.cleaning_services,
                  color: const Color(0xFF1A9DF8),
                  onTap: () => _sendEvent('cleaning'),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  label: 'Reset / Work Done',
                  icon: Icons.check_circle_outline,
                  color: const Color(0xFF2E7D32),
                  outlined: true,
                  onTap: () => _sendEvent('reset'),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _actionButton(
                  label: 'Reset / Work Done',
                  icon: Icons.check_circle_outline,
                  color: const Color(0xFF2E7D32),
                  outlined: true,
                  onTap: () => _sendEvent('reset'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool outlined = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.5.h),
        decoration: BoxDecoration(
          color: outlined ? Colors.white : color,
          borderRadius: BorderRadius.circular(3.w),
          border: outlined ? Border.all(color: color) : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: outlined ? color : Colors.white, size: 8.w),
            SizedBox(height: 1.h),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w600,
                    color: outlined ? color : Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildAllCoachesQuickView() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3.w),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Quick Actions", style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700)),
          SizedBox(height: 1.h),
          Text(
            "43 devices seeded for train 20917/20916:\nA1(1-8) · A2(1-8) · B1(1-9) · B2(1-9) · B3(1-9)",
            style: TextStyle(fontSize: 10.sp, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}