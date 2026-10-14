import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_coach_new/core/di/inject.dart';
import 'package:smart_coach_new/core/network/api_client.dart';
import 'package:smart_coach_new/core/network/api_constants.dart';
import 'package:smart_coach_new/core/network/api_exception.dart';
import 'package:smart_coach_new/core/utils/prefs.dart';
import 'package:smart_coach_new/routes/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2));
    final prefs = getIt<Prefs>();
    final token = prefs.token;

    // No stored token -> always start at login (fresh install included).
    if (token == null || token.isEmpty) {
      _goLogin();
      return;
    }

    // Validate the stored token against the backend so expired/revoked tokens
    // (or a stale token from an Android auto-backup) don't jump to dashboard.
    try {
      await getIt<ApiClient>().get(ApiConstants.profileApiEndpoint);
      if (!mounted) return;
      context.go(AppRouter.dashboardRoute);
    } on ApiException catch (e) {
      final msg = (e.message ?? '').toLowerCase();
      final isAuthFailure = msg.contains('token') ||
          msg.contains('authorization') ||
          msg.contains('user not found') ||
          msg.contains('pending approval') ||
          msg.isEmpty;
      if (isAuthFailure) {
        await prefs.clear();
        _goLogin();
      } else {
        // Server-side error while validating — keep the session and continue.
        if (!mounted) return;
        context.go(AppRouter.dashboardRoute);
      }
    } catch (_) {
      // Network/offline issue — keep the session and continue.
      if (!mounted) return;
      context.go(AppRouter.dashboardRoute);
    }
  }

  void _goLogin() {
    if (!mounted) return;
    context.go(AppRouter.loginRoute);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
