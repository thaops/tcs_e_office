import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tcs_e_office/common/Services/config.dart';
import 'package:tcs_e_office/common/repositoty/dio_api.dart';
import 'package:tcs_e_office/common/share/auth/controller_cache_clear.dart';
import 'package:tcs_e_office/common/share/auth/sign_out_clear.dart';
import 'package:tcs_e_office/common/utils/check_awaiting_services.dart';
import 'package:tcs_e_office/core/configs/theme/app_colors.dart';
import 'package:tcs_e_office/router/app_router.dart';
import 'package:tcs_e_office/src/services/lib/services/auth_service.dart';

class ShowDialogSetUrl {
  void showConfigDialog({
    required TextEditingController baseUrlController,
    required DioApi dioApi,
    required RxInt tapCount,
  }) async {
    if (tapCount.value == 5) {
      final storage = GetStorage();
      print('=== ShowDialogSetUrl Debug ===');
      print('awaiting: ${storage.read('awaiting')}');
      print('base_url: ${storage.read('base_url')}');
      print(
        'manual_environment_set: ${storage.read('manual_environment_set')}',
      );
      print('Config.baseUrl: ${Config.baseUrl}');
      print('Config.hasManualUrl(): ${Config.hasManualUrl()}');
      print('==============================');
      baseUrlController.text = Config.baseUrl;
      String initialBaseUrl = Config.baseUrl;
      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: Colors.white,
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Developer Settings",
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: baseUrlController,
                  style: TextStyle(fontSize: 14, color: AppColors.black),
                  decoration: InputDecoration(
                    labelText: 'Base URL',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50.h,
                        child: ElevatedButton(
                          onPressed: () {
                            Get.back();
                            tapCount.value = 0;
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade200,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Cancel",
                            style: TextStyle(color: Colors.black, fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 50.h,
                        child: ElevatedButton(
                          onPressed: () async {
                            String currentBaseUrl = baseUrlController.text
                                .trim();
                            if (currentBaseUrl != initialBaseUrl) {
                              try {
                                // Đổi URL
                                Config.baseUrl = currentBaseUrl;

                                // Clear toàn bộ cache và state
                                final signOutClear = Get.find<SignOutClear>();
                                final authService = AuthService();

                                // Clear toàn bộ cache
                                await signOutClear.clearCacheOnly();

                                // Clear awaiting flag để không ảnh hưởng đến URL thủ công
                                final checkAwaiting =
                                    await CheckAwaitingServices.createCheckAwaitingServices();
                                await checkAwaiting.deleteawaiting();

                                // Clear access token và sign out
                                await authService.clearAccessTokenNpp();
                                await authService.signOut();

                                // Clear tất cả controllers trước khi navigate
                                ControllerCacheClear.clearControllersOnly();

                                // Navigate về login để app hoàn toàn mới
                                Get.back();
                                tapCount.value = 0;
                                Get.snackbar('Success', 'Base URL updated');

                                // Delay nhỏ để đảm bảo snackbar hiển thị và clear hoàn tất
                                await Future.delayed(
                                  Duration(milliseconds: 500),
                                );

                                Get.offAllNamed(AppRouter.login);
                              } catch (e) {
                                print('Error changing URL: $e');
                                Get.back();
                                Get.snackbar('Error', 'Failed to update URL');
                                tapCount.value = 0;
                              }
                            } else {
                              // Nếu không thay đổi, chỉ thông báo
                              Get.back();
                              Get.snackbar(
                                'Info',
                                'No changes made to Base URL',
                              );
                              tapCount.value = 0;
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Apply",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );
    }
  }
}
