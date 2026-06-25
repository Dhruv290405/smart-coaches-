import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/core/utils/device_id_mapper.dart';
import 'package:smart_coach_new/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:smart_coach_new/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:smart_coach_new/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:smart_coach_new/routes/app_router.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(LoadDashboardData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.screenBgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'Critical & Maintenance Alerts',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<DashboardBloc>().add(LoadDashboardData());
        },
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DashboardDataLoaded) {
              final acpAlerts = state.recentAlerts;
              final pneumaticAlerts = state.recentPneumaticAlerts;

              if (acpAlerts.isEmpty && pneumaticAlerts.isEmpty) {
                return Center(
                  child: Text(
                    'No active alerts found',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                  ),
                );
              }

              return ListView(
                padding: EdgeInsets.all(4.w),
                children: [
                  if (acpAlerts.isNotEmpty) ...[
                    _buildSectionHeader('Alarm Chain Pulls'),
                    ...acpAlerts.map((alert) {
                      final isCritical = alert.acpStatus?.toLowerCase().contains('active') ?? false;
                      return _buildAlertCard(
                        context,
                        title: 'Train: ${alert.trainNo ?? "N/A"}',
                        subtitle: 'Coach: ${alert.commCoachNo ?? "N/A"} (${alert.techCoachNo ?? "N/A"})',
                        status: alert.acpStatus?.toUpperCase() ?? "N/A",
                        isCritical: isCritical,
                        icon: Icons.notifications_active_outlined,
                        onTap: () => context.push(AppRouter.acpMonitoringRoute),
                      );
                    }),
                    SizedBox(height: 3.h),
                  ],
                  if (pneumaticAlerts.isNotEmpty) ...[
                    _buildSectionHeader('Brake Binding Faults'),
                    ...pneumaticAlerts.map((alert) {
                      final fault = alert.brakeFault?.toString().toLowerCase() ?? "";
                      final isCritical = (fault.isNotEmpty && fault != "null" && fault != "none");
                      return _buildAlertCard(
                        context,
                        title: 'Train: ${alert.trainNo ?? "N/A"}',
                        subtitle: 'Coach: ${alert.coachNo ?? "N/A"} (Device: ${DeviceIdMapper.resolve(alert.deviceId?.toString())})',
                        status: alert.brakeStatus?.toString().toUpperCase() ?? "N/A",
                        isCritical: isCritical,
                        icon: Icons.settings_input_component_outlined,
                        onTap: () => context.push(AppRouter.breakBinding),
                      );
                    }),
                  ],
                ],
              );
            } else if (state is DashboardError) {
              return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.5.h, left: 1.w),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildAlertCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String status,
    required bool isCritical,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 1.5.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(3.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.5.w),
              decoration: BoxDecoration(
                color: (isCritical ? Colors.red : Colors.orange).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isCritical ? Colors.red : Colors.orange,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
              decoration: BoxDecoration(
                color: (isCritical ? Colors.red : Colors.orange).withOpacity(0.1),
                borderRadius: BorderRadius.circular(2.w),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: isCritical ? Colors.red : Colors.orange,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
