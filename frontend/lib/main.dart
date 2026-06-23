import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get_it/get_it.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/di/inject.dart';
import 'package:smart_coach_new/core/permissions/bloc/permission_bloc.dart';
import 'package:smart_coach_new/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:smart_coach_new/features/notifications/presentation/bloc/notification_event.dart';
import 'package:smart_coach_new/services/fcm_service.dart';
import 'firebase_options.dart';
import 'package:smart_coach_new/routes/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureDependencies();

  // Firebase initialize karo — lekin FCM baad mein lazily karo
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  // App pehle start karo — FCM permission dialog se block nahi hoga
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => GetIt.I<PermissionBloc>()),
        BlocProvider(create: (_) => GetIt.I<NotificationBloc>()),
      ],
      child: _AppBootstrap(
        child: Sizer(
          builder: (context, orientation, deviceType) {
            return MaterialApp.router(
              theme: AppTheme.lightTheme,
              debugShowCheckedModeBanner: false,
              builder: EasyLoading.init(),
              routerConfig: AppRouter.router,
            );
          },
        ),
      ),
    );
  }
}

// Firebase aur FCM ko app render hone ke baad initialize karta hai
class _AppBootstrap extends StatefulWidget {
  final Widget child;
  const _AppBootstrap({required this.child});

  @override
  State<_AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<_AppBootstrap> {
  @override
  void initState() {
    super.initState();
    // First frame render ke baad FCM setup karo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initFcm();
    });
  }

  Future<void> _initFcm() async {
    try {
      await FCMService.initializeFCM();
      if (!mounted) return;

      // Foreground message listener wire karo
      FCMService.listenForeground(
        onMessage: (RemoteMessage message) {
          final notification = message.notification;
          if (notification == null) return;
          if (!mounted) return;

          context.read<NotificationBloc>().add(
                FcmNotificationReceived(
                  title: notification.title ?? '',
                  body: notification.body ?? '',
                  type: message.data['type'] as String? ?? 'info',
                ),
              );
        },
      );
    } catch (e) {
      debugPrint('FCM initialization failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
