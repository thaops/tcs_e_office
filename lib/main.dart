import 'dart:io';
import 'package:app_links/app_links.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tcs_e_office/common/Services/device_udid.dart';
import 'package:tcs_e_office/common/Services/network_controller.dart';
import 'package:tcs_e_office/common/share/auth/sign_out_clear.dart';
import 'package:tcs_e_office/common/utils/check_awaiting_approval.dart';
import 'package:tcs_e_office/common/widgets/splash_screen_widget.dart';
import 'package:tcs_e_office/controllers/splash_controller.dart';
import 'package:tcs_e_office/core/configs/theme/app_theme.dart';
import 'package:tcs_e_office/router/app_router.dart';
import 'package:tcs_e_office/router/deep_link_handler.dart';
import 'package:tcs_e_office/router/one_signal_service.dart';
import 'package:uuid/uuid.dart';

bool? _cachedIsIPad;

Future<bool> _isIPad() async {
  if (_cachedIsIPad != null) return _cachedIsIPad!;

  if (kIsWeb) {
    _cachedIsIPad = false;
    return false;
  }

  if (defaultTargetPlatform == TargetPlatform.macOS) {
    _cachedIsIPad = false;
    return false;
  }

  final deviceInfo = DeviceInfoPlugin();
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    final iosInfo = await deviceInfo.iosInfo;
    _cachedIsIPad = iosInfo.model.toLowerCase().contains('ipad');
    return _cachedIsIPad!;
  } else if (defaultTargetPlatform == TargetPlatform.android) {
    final mediaQuery = MediaQueryData.fromWindow(
      WidgetsBinding.instance.window,
    );
    final shortestSide = mediaQuery.size.shortestSide;
    _cachedIsIPad = shortestSide >= 600;
    return _cachedIsIPad!;
  }

  _cachedIsIPad = false;
  return false;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();

  final results = await Future.wait([
    AppLinks().getInitialLink(),
    _initializeCriticalServices(),
  ]);

  final initialDeepLink = results[0] as Uri?;

  runApp(
    CalendarControllerProvider(
      controller: EventController(),
      child: MyApp(initialDeepLink: initialDeepLink),
    ),
  );

  _initializeBackgroundServices();
}

Future<void> _initializeCriticalServices() async {
  await Future.wait([
    Hive.initFlutter(),
    initializeDateFormatting('vi_VN', null),
  ]);

  Get.put(NetworkController());
  Get.put(SignOutClear());

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).catchError((_) {});

  // Đảm bảo UUID được generate trước khi check awaiting approval
  await generateUUID().catchError((_) {});

  // Kiểm tra awaiting approval và set domain tương ứng
  await _checkAndSetAwaitingApproval();
}

/// Gọi API checkAwaitingApproval và set flag awaiting trong storage
/// Nếu true -> chuyển sang dev domain, nếu false -> dùng prod domain
Future<void> _checkAndSetAwaitingApproval() async {
  try {
    // Đảm bảo UUID đã được generate trước
    final deviceUdid = await DeviceUdid.createDeviceUdid();
    String udid = await deviceUdid.getUdid();

    // Nếu chưa có UDID, tạo mới
    if (udid.isEmpty) {
      final uuid = Uuid();
      udid = uuid.v4();
      await deviceUdid.saveUdid(udid);
    }

    // Lấy thông tin app
    final packageInfo = await PackageInfo.fromPlatform();
    final platform = Platform.isIOS ? "iOS" : "Android";
    final appId = packageInfo.packageName;
    final appBuild = packageInfo.buildNumber;
    final appVersion = packageInfo.version;

    // Gọi API checkAwaitingApproval
    final checkAwaitingApproval = CheckAwaitingApproval();
    final isAwaiting = await checkAwaitingApproval.checkAwaitingApproval(
      platform: platform,
      appId: appId,
      appBuild: appBuild,
      appVersion: appVersion,
      udid: udid,
    );

    // Set flag awaiting trong storage
    final storage = GetStorage();
    storage.write('awaiting', isAwaiting);

    print('Awaiting approval check result: $isAwaiting');
  } catch (e) {
    // Nếu có lỗi, mặc định dùng prod domain (awaiting = false)
    print('Error checking awaiting approval: $e');
    final storage = GetStorage();
    storage.write('awaiting', false);
  }
}

void _initializeBackgroundServices() {
  Future.microtask(() async {
    try {
      await OneSignalService().init();
    } catch (e) {}
  });

  Future.microtask(() async {
    try {
      final networkController = Get.find<NetworkController>();
      await networkController.checkInternet();
    } catch (e) {}
  });
}

class MyApp extends StatefulWidget {
  final Uri? initialDeepLink;

  const MyApp({super.key, this.initialDeepLink});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final DeepLinkHandler _deepLinkHandler = DeepLinkHandler();
  Future<bool>? _isIPadFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _isIPadFuture = _isIPad();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 100));

      try {
        await OneSignalService().handlePendingNavigation();
      } catch (e) {}

      _deepLinkHandler.init();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      OneSignalService().handlePendingNavigation().catchError((_) {});
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _deepLinkHandler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final future = _isIPadFuture ?? _isIPad();

    return FutureBuilder<bool>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text('Error: ${snapshot.error}'),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => setState(() {
                        _isIPadFuture = _isIPad();
                      }),
                      child: Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final isIPad = snapshot.data ?? false;

        Size designSize;
        if (defaultTargetPlatform == TargetPlatform.macOS) {
          designSize = const Size(1200, 800);
        } else if (isIPad) {
          designSize = const Size(768, 1024);
        } else {
          designSize = const Size(375, 812);
        }

        return ScreenUtilInit(
          designSize: designSize,
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MainApp(initialDeepLink: widget.initialDeepLink);
          },
        );
      },
    );
  }
}

class MainApp extends StatefulWidget {
  final Uri? initialDeepLink;

  const MainApp({super.key, this.initialDeepLink});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: SplashScreen(initialDeepLink: widget.initialDeepLink),
      getPages: AppRouter.routes,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      onUnknownRoute: (settings) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAllNamed(AppRouter.main);
        });
        return GetPageRoute(
          settings: settings,
          page: () => const SizedBox.shrink(),
        );
      },
      unknownRoute: GetPage(
        name: '/unknown',
        page: () => SplashScreen(initialDeepLink: widget.initialDeepLink),
      ),
    );
  }
}

Future<void> generateUUID() async {
  try {
    final deviceUdid = await DeviceUdid.createDeviceUdid();
    final uuid = Uuid();
    await deviceUdid.saveUdid(uuid.v4());
  } catch (e) {}
}

class SplashScreen extends StatelessWidget {
  final Uri? initialDeepLink;

  const SplashScreen({super.key, this.initialDeepLink});

  @override
  Widget build(BuildContext context) {
    Get.put(SplashController(initialDeepLink: initialDeepLink));

    return SplashScreenWidget(onComplete: () {});
  }
}
