import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

class OTAUpdateService {
  static final OTAUpdateService _instance = OTAUpdateService._internal();
  factory OTAUpdateService() => _instance;
  OTAUpdateService._internal();

  final ShorebirdCodePush _shorebirdCodePush = ShorebirdCodePush();

  /// Kiểm tra và tải patch OTA nếu có
  /// Trả về true nếu có update, false nếu không có
  Future<bool> checkAndDownloadUpdate() async {
    try {
      if (kDebugMode) {
        print('🔍 Checking for OTA updates...');
      }

      // Kiểm tra xem có patch mới không
      final isUpdateAvailable = await _shorebirdCodePush
          .isNewPatchAvailableForDownload();

      if (isUpdateAvailable) {
        if (kDebugMode) {
          print('📦 New patch available, downloading...');
        }

        // Tải patch về
        await _shorebirdCodePush.downloadUpdateIfAvailable();

        if (kDebugMode) {
          print('✅ Patch downloaded successfully');
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
      final patchNumber = await _shorebirdCodePush.currentPatchNumber();
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
      return await _shorebirdCodePush.isNewPatchAvailableForDownload();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking update availability: $e');
      }
      return false;
    }
  }

  /// Restart app để apply patch (nếu cần)
  /// Note: Shorebird tự động apply patch, không cần restart thủ công
  Future<void> restartAppIfNeeded() async {
    try {
      final isUpdateAvailable = await _shorebirdCodePush
          .isNewPatchAvailableForDownload();
      if (isUpdateAvailable) {
        if (kDebugMode) {
          print('✅ Patch will be applied automatically on next app launch');
        }
        // Shorebird tự động apply patch, không cần restart thủ công
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking patch status: $e');
      }
    }
  }
}
