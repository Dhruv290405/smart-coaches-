import 'dart:ui' show PlatformDispatcher;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get_it/get_it.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/di/inject.dart';
import 'package:smart_coach_new/core/permissions/bloc/permission_bloc.dart';
import 'package:smart_coach_new/core/services/socket_service.dart';
import 'package:smart_coach_new/core/utils/logger.dart';
import 'package:smart_coach_new/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:smart_coach_new/features/notifications/presentation/bloc/notification_event.dart';
import 'package:smart_coach_new/services/fcm_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';
import 'firebase_options.dart';
import 'package:smart_coach_new/routes/app_router.dart';
import 'core/theme/app_theme.dart';

final Logger _log = Logger('Main');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    _log.error('Uncaught error', error, stack);
    return true;
  };

  FlutterError.onError = (FlutterErrorDetails details) {
    _log.error('Flutter error: ${details.exception}', details.exception, details.stack);
  };

  await configureDependencies();
  Logger.setLevel(LogLevel.debug);

  try {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  } catch (e) {
    _log.warn('Supabase init failed (non-critical)', e);
  }

  _initFirebaseAndFcm();

  runApp(const MyApp());
}

Future<void> _initFirebaseAndFcm() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    _log.warn('Firebase init failed (non-critical)', e);
  }
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initSocketIo();
      _initFcm();
    });
  }

  void _initSocketIo() {
    try {
      SocketService().connect();
    } catch (e) {
      _log.warn('Socket init failed', e);
    }
  }

  Future<void> _initFcm() async {
    try {
      await FCMService.initializeFCM();
      if (!mounted) return;

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
      _log.warn('FCM init failed (non-critical)', e);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
