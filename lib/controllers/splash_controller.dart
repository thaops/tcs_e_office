import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:tcs_e_office/common/Services/services.dart';
import 'package:tcs_e_office/common/services/ota_update_service.dart';
import 'package:tcs_e_office/router/app_router.dart';

class SplashController extends GetxController {
  final OTAUpdateService _otaService = OTAUpdateService();

  // Observable states
  final RxString loadingText = 'Đang khởi tạo...'.obs;
  final RxBool isCheckingUpdate = false.obs;
  final RxBool hasUpdate = false.obs;
  final RxString currentPatchNumber = 'Unknown'.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  /// Khởi tạo app với OTA flow
  Future<void> _initializeApp() async {
    try {
      // Bước 1: Hiển thị splash và bắt đầu check OTA
      loadingText.value = 'Đang kiểm tra cập nhật...';
      isCheckingUpdate.value = true;

      // Bước 2: Chạy OTA check song song với minimum splash time
      final splashTimer = Future.delayed(const Duration(seconds: 2));
      final otaFuture = _checkOTAUpdate();

      // Đợi cả hai hoàn thành
      await Future.wait([splashTimer, otaFuture]);

      // Bước 3: Kiểm tra authentication và navigate
      await _checkAuthenticationAndNavigate();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in splash initialization: $e');
      }
      // Fallback: navigate to login
      await _navigateToLogin();
    }
  }

  /// Kiểm tra và tải OTA update
  Future<void> _checkOTAUpdate() async {
    try {
      // Lấy patch number hiện tại
      currentPatchNumber.value = await _otaService.getCurrentPatchNumber();

      if (kDebugMode) {
        print('📱 Current patch number: ${currentPatchNumber.value}');
      }

      // Kiểm tra và tải update
      final hasUpdateResult = await _otaService.checkAndDownloadUpdate();
      hasUpdate.value = hasUpdateResult;

      if (hasUpdateResult) {
        loadingText.value = 'Đã tải cập nhật mới!';
        if (kDebugMode) {
          print('✅ OTA update downloaded successfully');
        }
      } else {
        loadingText.value = 'Ứng dụng đã cập nhật';
        if (kDebugMode) {
          print('✅ App is up to date');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in OTA check: $e');
      }
      loadingText.value = 'Khởi tạo hoàn tất';
    } finally {
      isCheckingUpdate.value = false;
    }
  }

  /// Kiểm tra authentication và navigate
  Future<void> _checkAuthenticationAndNavigate() async {
    try {
      loadingText.value = 'Đang kiểm tra đăng nhập...';

      final service = await Services.create();
      final token = await service.getAccessToken();

      if (token.isNotEmpty) {
        loadingText.value = 'Chào mừng trở lại!';
        await Future.delayed(const Duration(milliseconds: 500));
        await _navigateToMain();
      } else {
        loadingText.value = 'Chuyển đến trang đăng nhập...';
        await Future.delayed(const Duration(milliseconds: 500));
        await _navigateToLogin();
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking authentication: $e');
      }
      await _navigateToLogin();
    }
  }

  /// Navigate to main app
  Future<void> _navigateToMain() async {
    await Get.offAllNamed(AppRouter.main);
  }

  /// Navigate to login
  Future<void> _navigateToLogin() async {
    await Get.offAllNamed(AppRouter.login);
  }

  /// Manual check for updates (có thể gọi từ settings)
  Future<void> checkForUpdates() async {
    try {
      isCheckingUpdate.value = true;
      loadingText.value = 'Đang kiểm tra cập nhật...';

      final hasUpdateResult = await _otaService.checkAndDownloadUpdate();
      hasUpdate.value = hasUpdateResult;

      if (hasUpdateResult) {
        Get.snackbar(
          'Cập nhật',
          'Đã tải cập nhật mới! Khởi động lại app để áp dụng.',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Cập nhật',
          'Ứng dụng đã là phiên bản mới nhất!',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể kiểm tra cập nhật: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isCheckingUpdate.value = false;
    }
  }

  /// Restart app để apply patch
  Future<void> restartApp() async {
    await _otaService.restartAppIfNeeded();
  }
}
