import 'dart:ui' show PlatformDispatcher;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:smart_coach_new/core/di/inject.dart';
import 'package:smart_coach_new/core/widgets/responsive_web_wrapper.dart';
import 'package:smart_coach_new/core/widgets/in_app_notification_banner.dart';
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
import 'core/network/api_constants.dart';
import 'core/config/remote_app_config.dart';

final Logger _log = Logger('Main');

Future<void> _loadApiBaseUrl() async {
  final preferences = await SharedPreferences.getInstance();
  final fallback = ApiConstants.normalizeBaseUrl(ApiConstants.devUrl);

  try {
    final response = await http
        .get(Uri.parse(ApiConstants.bootstrapConfigUrl))
        .timeout(const Duration(seconds: 8));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('API bootstrap returned HTTP ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    final configuredUrl =
        decoded is Map<String, dynamic> ? decoded['apiBaseUrl'] : null;
    if (configuredUrl is! String || !_isValidApiBaseUrl(configuredUrl)) {
      throw Exception('API bootstrap returned an invalid apiBaseUrl');
    }

    await preferences.setString(
      ApiConstants.apiBaseUrlKey,
      ApiConstants.normalizeBaseUrl(configuredUrl),
    );
    ApiConstants.activeBaseUrl = ApiConstants.normalizeBaseUrl(configuredUrl);
    _log.info('API base URL loaded from backend configuration');

    final config = decoded is Map<String, dynamic> ? decoded['config'] : null;
    if (config is Map<String, dynamic>) {
      final remoteConfig = RemoteAppConfig.fromJson(config);
      RemoteAppConfig.current = remoteConfig;
      await preferences.setString(
        'remote_app_config',
        RemoteAppConfig.encode(remoteConfig),
      );
    }
  } catch (error) {
    _log.warn('API bootstrap unavailable; using saved URL or fallback: $error');
  }

  if ((preferences.getString(ApiConstants.apiBaseUrlKey) ?? '').trim().isEmpty) {
    await preferences.setString(ApiConstants.apiBaseUrlKey, fallback);
  }
  ApiConstants.activeBaseUrl = ApiConstants.normalizeBaseUrl(
    preferences.getString(ApiConstants.apiBaseUrlKey) ?? fallback,
  );

  final savedConfig = preferences.getString('remote_app_config');
  if (savedConfig != null) {
    try {
      final decoded = jsonDecode(savedConfig);
      if (decoded is Map<String, dynamic>) {
        RemoteAppConfig.current = RemoteAppConfig.fromJson(decoded);
      }
    } catch (error) {
      _log.warn('Saved remote app configuration is invalid: $error');
    }
  }
}

bool _isValidApiBaseUrl(String value) {
  final uri = Uri.tryParse(value.trim());
  return uri != null &&
      uri.scheme == 'https' &&
      uri.host.isNotEmpty &&
      uri.userInfo.isEmpty &&
      uri.query.isEmpty &&
      uri.fragment.isEmpty;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    _log.error('Uncaught error', error, stack);
    return true;
  };

  FlutterError.onError = (FlutterErrorDetails details) {
    _log.error('Flutter error: ${details.exception}', details.exception, details.stack);
  };

  await _loadApiBaseUrl();
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
        child: kIsWeb
          ? Builder(
              builder: (context) {
                final screenWidth = MediaQuery.of(context).size.width;
                if (screenWidth <= 600) {
                  return Sizer(
                    builder: (context, orientation, deviceType) {
                      return MaterialApp.router(
                        theme: AppTheme.lightTheme,
                        debugShowCheckedModeBanner: false,
                        builder: EasyLoading.init(),
                        routerConfig: AppRouter.router,
                      );
                    },
                  );
                }
                return ResponsiveWebWrapper(
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
                );
              },
            )
          : Sizer(
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

  static String _routeForNotificationType(String? type) {
    if (type == null || type.isEmpty) return '/notifications';
    final t = type.toUpperCase();
    if (t.contains('ODOUR') || t.contains('ODOR')) return '/odour_management';
    if (t.contains('BRAKE') || t.contains('OVERCHARGE')) return '/break_binding';
    if (t.contains('ACP')) return '/acp_monitoring';
    if (t.contains('HOT_AXLE') || t.contains('AXLE')) return '/hot_axle_monitoring';
    if (t.contains('WATER')) return '/water_tank_monitoring';
    if (t.contains('DIESEL') || t.contains('FUEL')) return '/diesel_level_monitoring';
    return '/notifications';
  }

  Future<void> _initFcm() async {
    try {
      await FCMService.initializeFCM();
      if (!mounted) return;

      // Foreground messages
      FCMService.listenForeground(
        onMessage: (RemoteMessage message) {
          final notification = message.notification;
          if (notification == null) return;
          if (!mounted) return;

          final title = notification.title ?? '';
          final body = notification.body ?? '';
          final type = message.data['type'] as String? ?? 'info';

          context.read<NotificationBloc>().add(
                FcmNotificationReceived(title: title, body: body, type: type),
              );
          if (!kIsWeb) FCMService.showLocalNotification(message);

          InAppNotificationBanner.show(
            context,
            title: title,
            body: body,
            type: type,
            onTap: () => AppRouter.router.go(_routeForNotificationType(type)),
          );
        },
      );

      // Background tap: user tapped notification while app was backgrounded
      FCMService.listenNotificationTap(
        onTap: (RemoteMessage message) {
          final type = message.data['type'] as String? ?? message.data['module'] as String?;
          AppRouter.router.go(_routeForNotificationType(type));
        },
      );

      // Terminated tap: user tapped notification that launched the app
      final RemoteMessage? initialMessage =
          await FCMService.getInitialNotification();
      if (initialMessage != null) {
        final type = initialMessage.data['type'] as String? ?? initialMessage.data['module'] as String?;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AppRouter.router.go(_routeForNotificationType(type));
        });
      }

      // Foreground local notification tap — receives type from notification payload
      FCMService.setOnLocalNotificationTap((String? type) {
        AppRouter.router.go(_routeForNotificationType(type));
      });
    } catch (e) {
      _log.warn('FCM init failed (non-critical)', e);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
