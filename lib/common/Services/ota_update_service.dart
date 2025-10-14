import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

class OTAUpdateService {
  static final OTAUpdateService _instance = OTAUpdateService._internal();
  factory OTAUpdateService() => _instance;
  OTAUpdateService._internal();

  final ShorebirdUpdater _shorebirdUpdater = ShorebirdUpdater();

  /// Kiểm tra và tải patch OTA nếu có
  /// Trả về true nếu có update, false nếu không có
  Future<bool> checkAndDownloadUpdate() async {
    try {
      if (kDebugMode) {
        print('🔍 Checking for OTA updates...');
      }

      // Sử dụng ShorebirdUpdater mới
      final status = await _shorebirdUpdater.checkForUpdate();

      if (status == UpdateStatus.outdated) {
        if (kDebugMode) {
          print('📦 New patch available, downloading...');
        }

        // Tải và install patch
        await _shorebirdUpdater.downloadUpdateIfAvailable();
        await _shorebirdUpdater.installUpdate();

        if (kDebugMode) {
          print('✅ Patch downloaded and installed successfully');
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
  /// Trả về true nếu có update và đã restart, false nếu không có update
  Future<bool> checkAndDownloadUpdateWithRestart() async {
    try {
      if (kDebugMode) {
        print('🔍 Checking for OTA updates with force restart...');
      }

      // Sử dụng ShorebirdUpdater mới
      final status = await _shorebirdUpdater.checkForUpdate();

      if (status == UpdateStatus.outdated) {
        if (kDebugMode) {
          print('📦 New patch available, downloading...');
        }

        // Tải và install patch
        await _shorebirdUpdater.downloadUpdateIfAvailable();
        await _shorebirdUpdater.installUpdate();

        if (kDebugMode) {
          print('✅ Patch installed, force restarting app...');
        }

        // Force restart bằng SystemNavigator.pop()
        await SystemNavigator.pop();

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
      final patchNumber = await _shorebirdUpdater.currentPatchNumber();
      return patchNumber.toString();
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
      final status = await _shorebirdUpdater.checkForUpdate();
      return status == UpdateStatus.outdated;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking update availability: $e');
      }
      return false;
    }
  }

  /// Restart app để apply patch (nếu cần)
  /// Note: Sử dụng SystemNavigator.pop() để force restart
  Future<void> restartAppIfNeeded() async {
    try {
      final status = await _shorebirdUpdater.checkForUpdate();
      if (status == UpdateStatus.outdated) {
        if (kDebugMode) {
          print('✅ Force restarting app to apply patch...');
        }
        // Force restart để apply patch ngay lập tức
        await SystemNavigator.pop();
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking patch status: $e');
      }
    }
  }
}
