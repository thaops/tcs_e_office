import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:in_app_update/in_app_update.dart';
// import 'package:shorebird_code_push/shorebird_code_push.dart';

class OTAUpdateService {
  static final OTAUpdateService _instance = OTAUpdateService._internal();
  factory OTAUpdateService() => _instance;
  OTAUpdateService._internal();

  // final ShorebirdCodePush _shorebirdCodePush = ShorebirdCodePush();

  /// Kiểm tra và tải patch OTA nếu có
  Future<bool> checkAndDownloadUpdate() async {
    try {
      if (kDebugMode) {
        print('🔍 Checking for OTA updates...');
      }

      // Sử dụng In-App Update thay vì Shorebird
      final updateInfo = await InAppUpdate.checkForUpdate();

      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if (kDebugMode) {
          print('📦 New update available, downloading...');
        }

        // Tải update về
        await InAppUpdate.performImmediateUpdate();

        if (kDebugMode) {
          print('✅ Update downloaded successfully');
        }

        return true;
      } else {
        if (kDebugMode) {
          print('✅ App is up to date');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking/downloading OTA update: $e');
      }
      return false;
    }
  }

  /// Kiểm tra và tải patch OTA với force restart
  Future<bool> checkAndDownloadUpdateWithRestart() async {
    try {
      if (kDebugMode) {
        print('🔍 Checking for OTA updates with force restart...');
      }

      // Sử dụng In-App Update thay vì Shorebird
      final updateInfo = await InAppUpdate.checkForUpdate();

      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if (kDebugMode) {
          print('📦 New update available, downloading...');
        }

        // Tải update về và restart app
        await InAppUpdate.performImmediateUpdate();

        if (kDebugMode) {
          print('✅ Update downloaded, app will restart automatically');
        }

        return true;
      } else {
        if (kDebugMode) {
          print('✅ App is up to date');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking/downloading OTA update: $e');
      }
      return false;
    }
  }

  /// Lấy thông tin version hiện tại
  Future<String> getCurrentPatchNumber() async {
    try {
      // TODO: Implement Shorebird v2.0+ API
      // final patchNumber = await _shorebirdCodePush.currentPatchNumber();
      // return patchNumber.toString();
      return '1';
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting patch number: $e');
      }
      return 'Unknown';
    }
  }

  /// Kiểm tra xem có patch mới không (không tải)
  Future<bool> isUpdateAvailable() async {
    try {
      // Sử dụng In-App Update thay vì Shorebird
      final updateInfo = await InAppUpdate.checkForUpdate();
      return updateInfo.updateAvailability ==
          UpdateAvailability.updateAvailable;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking update availability: $e');
      }
      return false;
    }
  }

  /// Restart app để apply patch (nếu cần)
  Future<void> restartAppIfNeeded() async {
    try {
      // Sử dụng In-App Update thay vì Shorebird
      final updateInfo = await InAppUpdate.checkForUpdate();
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if (kDebugMode) {
          print('✅ Force restarting app to apply update...');
        }
        // Force restart để apply update ngay lập tức
        await SystemNavigator.pop();
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking update status: $e');
      }
    }
  }
}
