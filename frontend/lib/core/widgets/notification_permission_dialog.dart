import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';

class NotificationPermissionDialog extends StatefulWidget {
  const NotificationPermissionDialog({super.key});

  /// Check permission and show the dialog if not already granted (or if forced).
  static Future<void> showIfNeeded(BuildContext context, {bool force = false}) async {
    try {
      final status = await Permission.notification.status;
      if (force || !status.isGranted) {
        if (!context.mounted) return;
        await showDialog(
          context: context,
          barrierDismissible: true,
          builder: (dialogContext) => const NotificationPermissionDialog(),
        );
      }
    } catch (_) {
      // Non-critical fallback
    }
  }

  @override
  State<NotificationPermissionDialog> createState() =>
      _NotificationPermissionDialogState();
}

class _NotificationPermissionDialogState
    extends State<NotificationPermissionDialog> with WidgetsBindingObserver {
  bool _isGranted = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Refresh status when user returns from phone settings
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermission();
    }
  }

  Future<void> _checkPermission() async {
    try {
      final status = await Permission.notification.status;
      if (mounted) {
        setState(() {
          _isGranted = status.isGranted;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _togglePermission(bool value) async {
    if (value) {
      final status = await Permission.notification.request();
      if (status.isGranted) {
        if (mounted) setState(() => _isGranted = true);
      } else if (status.isPermanentlyDenied || status.isDenied) {
        // Must be enabled from phone settings
        await openAppSettings();
      }
    } else {
      // On Android/iOS, turning off permission granted by the system requires settings
      await openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: EdgeInsets.all(3.5.w),
              decoration: BoxDecoration(
                color: ColorConstants.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isGranted
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_off_rounded,
                size: 26.sp,
                color: _isGranted ? Colors.green[700] : ColorConstants.primary,
              ),
            ),
            SizedBox(height: 2.h),

            // Title
            Text(
              "Mobile Push Notifications",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 1.h),

            // Description
            Text(
              "Receive instant real-time alerts in your phone's notification panel for Brake Binding, CR Overcharge, Hot Axle, and ACP safety events.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.5.sp,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
            SizedBox(height: 2.5.h),

            // Interactive ON/OFF Card
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: _isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isGranted ? Colors.green : Colors.red,
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              _isGranted ? "Status: ON (Active)" : "Status: OFF (Disabled)",
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: _isGranted ? Colors.green[800] : Colors.red[800],
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: _isGranted,
                          activeColor: ColorConstants.primary,
                          onChanged: _togglePermission,
                        ),
                      ],
                    ),
            ),
            SizedBox(height: 2.5.h),

            // Open Phone Settings Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await openAppSettings();
                },
                icon: Icon(Icons.settings, size: 13.sp, color: Colors.white),
                label: Text(
                  "Click here to Open Phone Settings",
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorConstants.primary,
                  padding: EdgeInsets.symmetric(vertical: 1.4.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
            SizedBox(height: 1.h),

            // Dismiss Button
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                _isGranted ? "Done" : "Later / Keep Off",
                style: TextStyle(
                  fontSize: 10.5.sp,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
