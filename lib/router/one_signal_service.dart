import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tcs_e_office/common/Services/api_endpoints.dart';
import 'package:tcs_e_office/common/repositoty/dio_api.dart';
import 'package:tcs_e_office/feature/private_app_shell/notification/handlers/notification_navigation_handler.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_keychain/flutter_keychain.dart';
import 'package:tcs_e_office/common/Services/device_id_service.dart';

class OneSignalService {
  static const String _appId = "192ddfe5-84c7-4816-9994-4d95b373c823";
  static final OneSignalService _instance = OneSignalService._internal();
  factory OneSignalService() => _instance;
  OneSignalService._internal();

  static OSNotificationClickEvent? _cachedClickEvent;
  static bool _notificationHandled = false;
  static String? _sentToken;
  static const String _storageKeyLastToken = 'last_push_token';
  static const String _storageKeyDeviceUUID = 'onesignal_device_uuid';
  static const String _keychainKeyDeviceUUID = 'onesignal_device_uuid';
  // AccessGroup được cấu hình trong entitlements: $(AppIdentifierPrefix)com.nps.tcs
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    try {
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

      OneSignal.initialize(_appId);

      if (Platform.isIOS) {
        await Future.delayed(Duration(milliseconds: 1000));
      } else {
        await Future.delayed(Duration(milliseconds: 500));
      }

      bool hasPermission = OneSignal.Notifications.permission;
      if (!hasPermission) {
        hasPermission = await OneSignal.Notifications.requestPermission(true);

        if (Platform.isIOS && hasPermission) {
          await Future.delayed(Duration(milliseconds: 500));
        }
      }

      if (hasPermission) {
        await OneSignal.User.pushSubscription.optIn();
      }

      if (hasPermission) {
        await OneSignal.User.addTagWithKey("test_user", "true");
        await OneSignal.User.addTags({"test_user": "true"});
      }

      OneSignal.Notifications.lifecycleInit();

      OneSignal.Notifications.addClickListener((event) async {
        _cachedClickEvent = event;
        _notificationHandled = false;
        await _handleNotificationClick(event);
      });

      await listenForPushToken();
    } catch (e) {
      _initialized = false;
      rethrow;
    }
  }

  Future<void> handlePendingNavigation() async {
    if (!_notificationHandled && _cachedClickEvent != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(Duration(milliseconds: 500));
        await _handleNotificationClick(_cachedClickEvent!);
        _cachedClickEvent = null;
        _notificationHandled = true;
      });
    }
  }

  Future<void> checkPermissionStatus() async {
    bool hasPermission = await OneSignal.Notifications.requestPermission(true);
    if (!hasPermission) {
      await OneSignal.Notifications.requestPermission(true);
    }
  }

  Future<void> listenForPushToken() async {
    try {
      int maxRetries = Platform.isIOS ? 10 : 5;
      int retryDelay = Platform.isIOS ? 2 : 1;

      for (int i = 0; i < maxRetries; i++) {
        String? token = await getPushToken();
        if (token != null && token.isNotEmpty) {
          await registerPushTokenToBackend(token);
          break;
        }
        await Future.delayed(Duration(seconds: retryDelay));
      }

      OneSignal.User.pushSubscription.addObserver((state) {
        if (state.current.id != null && state.current.optedIn) {
          try {
            final token = state.current.id;
            if (token != null && token.isNotEmpty) {
              registerPushTokenToBackend(token);
            }
          } catch (e) {}
        }
      });
    } catch (e) {}
  }

  Future<void> registerPushTokenToBackend(String token) async {
    print("registerPushTokenToBackend: $token");
    if (_sentToken == token) {
      return;
    }

    final box = GetStorage();
    final String? lastToken = box.read<String>(_storageKeyLastToken);
    if (lastToken == token) {
      _sentToken = token;
      return;
    }

    final dio = DioApi();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final deviceInfo = await _getDeviceInfo();

    // Lấy deviceUUID theo platform
    String deviceUUID = await _getDeviceUUID();
    print("deviceUUID: $deviceUUID");

    final data = {
      "deviceUUID": deviceUUID,
      "pushToken": token,
      "devicePlatform": deviceInfo['platform'],
      "deviceOS": deviceInfo['osVersion'],
      "deviceModel": deviceInfo['deviceName'],
      "deviceName": deviceInfo['deviceName'],
      "appBuild": packageInfo.buildNumber,
      "appVersion": packageInfo.version,
      "appLanguage": "vi-VN",
    };

    try {
      await dio.post(ApiEndpoints.notification, data: data);
      _sentToken = token;
      box.write(_storageKeyLastToken, token);
      // Lưu deviceUUID theo platform
      await _saveDeviceUUID(deviceUUID);
    } catch (e) {}
  }

  static bool _isUnregistering = false;

  Future<void> unregisterDevice() async {
    // Guard để tránh gọi nhiều lần đồng thời
    if (_isUnregistering) {
      return;
    }

    _isUnregistering = true;
    try {
      // Lấy deviceUUID bằng cách dùng hàm _getDeviceUUID() để đảm bảo consistency
      String deviceUUID = await _getDeviceUUID();

      if (deviceUUID.isEmpty) {
        _isUnregistering = false;
        return;
      }

      final dio = DioApi();
      final data = {"deviceUUID": deviceUUID};

      try {
        await dio.post(ApiEndpoints.unregisterNotification, data: data);
        // QUAN TRỌNG: KHÔNG xóa DeviceUUID khỏi Keychain
        // DeviceUUID phải giữ nguyên để đảm bảo consistency khi user login lại
        // Chỉ xóa push token
        final box = GetStorage();
        await box.remove(_storageKeyLastToken);
        _sentToken = null;
      } catch (e) {
        // Vẫn xóa push token dù API fail
        final box = GetStorage();
        await box.remove(_storageKeyLastToken);
        _sentToken = null;
      }
    } catch (e) {
      // Log error để debug
      print("❌ Error in unregisterDevice: $e");
    } finally {
      _isUnregistering = false;
    }
  }

  Future<Map<String, dynamic>> _getDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    final deviceInfo = await deviceInfoPlugin.deviceInfo;
    Map<String, dynamic> info;

    if (Platform.isAndroid) {
      final androidInfo = deviceInfo as AndroidDeviceInfo;
      info = {
        'platform': 'Android',
        'deviceName': androidInfo.model,
        'osVersion': androidInfo.version.release,
      };
    } else if (Platform.isIOS) {
      final iosInfo = deviceInfo as IosDeviceInfo;
      info = {
        'platform': 'iOS',
        'deviceName': iosInfo.name,
        'osVersion': iosInfo.systemVersion,
      };
    } else {
      info = {
        'platform': 'unknown',
        'deviceName': 'unknown',
        'osVersion': 'unknown',
      };
    }

    return info;
  }

  Future<String?> getPushToken() async {
    final status = OneSignal.User.pushSubscription;

    if (status.id != null) {
      return status.id;
    }

    return null;
  }

  Future<void> registerTokenAfterLogin() async {
    try {
      final token = await getPushToken();
      if (token != null) {
        await registerPushTokenToBackend(token);
      } else {
        await Future.delayed(Duration(seconds: 2));
        final retryToken = await getPushToken();
        if (retryToken != null) {
          await registerPushTokenToBackend(retryToken);
        }
      }
    } catch (e) {}
  }

  Future<void> _handleNotificationClick(OSNotificationClickEvent event) async {
    try {
      final notification = event.notification;
      final data = notification.additionalData;

      final notificationId =
          data?["notificationId"] ?? data?["id"] ?? data?["Data"]?["id"];

      if (notificationId != null && notificationId is String) {
        await Future.delayed(const Duration(milliseconds: 500));
        await NotificationNavigationHandler.handleNotificationNavigation(
          notificationId,
        );
        _notificationHandled = true;
        return;
      }

      final notificationData = data?["Data"] ?? data;
      // final _directType = data?["type"]; // Reserved for future use
      final directId = data?["id"];
      // final _wrappedType = notificationData?["type"]; // Reserved for future use
      final wrappedId = notificationData?["id"];

      final source = data?["source"] ?? notificationData?["source"];
      final sourceId = wrappedId ?? directId;

      if (source != null && sourceId != null) {
        await Future.delayed(const Duration(milliseconds: 500));
        await NotificationNavigationHandler.handleNotificationNavigationWithData(
          source: source,
          sourceId: sourceId,
        );
        _notificationHandled = true;
        return;
      }

      // final type = NotificationUtils.getNotificationType(
      //   _wrappedType ?? _directType,
      // );
      final id = wrappedId ?? directId;

      if (id == null) {
        return;
      }

      await Future.delayed(const Duration(milliseconds: 500));
      // await NavigationUtils.navigateByNotificationType(type: type, id: id);
      _notificationHandled = true;
    } catch (e) {}
  }

  /// Lấy deviceUUID theo platform
  /// QUAN TRỌNG: Chỉ dùng UUID trong Shared Keychain, KHÔNG dùng IDFV
  Future<String> _getDeviceUUID() async {
    if (Platform.isIOS) {
      try {
        String? savedUUID = await FlutterKeychain.get(key: _keychainKeyDeviceUUID);
        if (savedUUID != null && savedUUID.isNotEmpty) {
          return savedUUID;
        }
      } catch (e) {
      
      }
      
      Uuid uuidGenerator = Uuid();
      String newUUID = uuidGenerator.v4();
      
      try {
        await FlutterKeychain.put(
          key: _keychainKeyDeviceUUID,
          value: newUUID,
        );
      } catch (e) {
      
      }
      
      return newUUID;
    } else if (Platform.isAndroid) {
      // Android: Lấy Android ID
      String? androidId = await DeviceIdService.getAndroidId();
      if (androidId == null || androidId.isEmpty) {
        // Fallback: Tạo UUID nếu không lấy được Android ID
        Uuid uuidGenerator = Uuid();
        androidId = uuidGenerator.v4();
      }
      return androidId;
    } else {
      // Fallback cho platform khác
      Uuid uuidGenerator = Uuid();
      return uuidGenerator.v4();
    }
  }

  /// Lưu deviceUUID theo platform
  /// QUAN TRỌNG: Luôn lưu vào Keychain để đảm bảo persistence
  Future<void> _saveDeviceUUID(String deviceUUID) async {
    if (Platform.isIOS) {
      // iOS: Luôn lưu vào Shared Keychain
      // AccessGroup được cấu hình trong entitlements, package tự động sử dụng
      try {
        await FlutterKeychain.put(
          key: _keychainKeyDeviceUUID,
          value: deviceUUID,
        );
      } catch (e) {
        // Log error nếu cần
      }
    } else if (Platform.isAndroid) {
      // Android: Lưu vào GetStorage (backup, nhưng chủ yếu dùng Android ID)
      final box = GetStorage();
      box.write(_storageKeyDeviceUUID, deviceUUID);
    }
  }

  static Future<void> clearCachedToken() async {
    _sentToken = null;
    final box = GetStorage();
    await box.remove(_storageKeyLastToken);

    // QUAN TRỌNG: KHÔNG xóa DeviceUUID khỏi Keychain
    // DeviceUUID phải giữ nguyên để đảm bảo consistency
    // Chỉ xóa push token và cache
  }
}
