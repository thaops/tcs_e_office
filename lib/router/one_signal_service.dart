import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tcs_e_office/common/Services/api_endpoints.dart';
import 'package:tcs_e_office/common/repositoty/dio_api.dart';
import 'package:tcs_e_office/common/utils/navigation_utils.dart';
import 'package:tcs_e_office/common/utils/notification_utils.dart';
import 'package:tcs_e_office/feature/private_app_shell/notification/handlers/notification_navigation_handler.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';

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

    Uuid uuid = Uuid();
    String deviceUUID = uuid.v4();

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
      box.write(_storageKeyDeviceUUID, deviceUUID);
    } catch (e) {}
  }

  Future<void> unregisterDevice() async {
    try {
      final box = GetStorage();
      final String? deviceUUID = box.read<String>(_storageKeyDeviceUUID);

      if (deviceUUID == null || deviceUUID.isEmpty) {
        return;
      }

      final dio = DioApi();
      final data = {"deviceUUID": deviceUUID};

      try {
        await dio.post(ApiEndpoints.unregisterNotification, data: data);
        await box.remove(_storageKeyDeviceUUID);
      } catch (e) {
        await box.remove(_storageKeyDeviceUUID);
      }
    } catch (e) {}
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
      final directType = data?["type"];
      final directId = data?["id"];
      final wrappedType = notificationData?["type"];
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
      //   wrappedType ?? directType,
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

  static Future<void> clearCachedToken() async {
    _sentToken = null;
    final box = GetStorage();
    await box.remove(_storageKeyLastToken);
    await box.remove(_storageKeyDeviceUUID);
  }
}
