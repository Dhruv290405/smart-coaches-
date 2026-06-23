import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_coach_new/core/di/inject.dart';
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
    final token = getIt<Prefs>().token;

    if (token != null && token.isNotEmpty) {
      context.go(AppRouter.dashboardRoute);
    } else {
      context.go(AppRouter.loginRoute);
    }
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