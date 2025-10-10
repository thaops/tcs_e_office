import 'package:get/get.dart';
import 'package:tcs_e_office/feature/private_app_shell/filter_user/controller/filter_user_controller.dart';
import 'package:tcs_e_office/feature/private_app_shell/profile/logic/profile_logic.dart';

/// Service để clear cache của các controllers cụ thể
class ControllerCacheClear {
  /// Clear tất cả controllers và reset state (KHÔNG reset GetX hoàn toàn)
  static void clearControllersOnly() {
    try {


      // Clear Filter User Controller
      if (Get.isRegistered<FilterUserController>()) {
        final filterUserController = Get.find<FilterUserController>();
        filterUserController.employeeIdToDepartment.clear();
        filterUserController.userList.clear();
      }

      // Clear Profile Controller
      if (Get.isRegistered<ProfileLogic>()) {
        final profileController = Get.find<ProfileLogic>();
        profileController.resetProfile();
      }

      // KHÔNG gọi Get.reset() để tránh xóa GetMaterialApp context
    } catch (e) {
      print('Error clearing controllers: $e');
    }
  }

  /// Clear tất cả controllers và reset state (DÀNH CHO TRƯỜNG HỢP ĐẶC BIỆT)
  static void clearAllControllers() {
    try {
      // Clear Filter User Controller
      if (Get.isRegistered<FilterUserController>()) {
        final filterUserController = Get.find<FilterUserController>();
        filterUserController.employeeIdToDepartment.clear();
        filterUserController.userList.clear();
      }

      // Clear Profile Controller
      if (Get.isRegistered<ProfileLogic>()) {
        final profileController = Get.find<ProfileLogic>();
        profileController.resetProfile();
      }

      // Clear tất cả GetX dependencies (CHỈ DÙNG KHI CẦN THIẾT)
      Get.reset();
    } catch (e) {
      print('Error clearing controllers: $e');
    }
  }

  /// Clear chỉ leave management controllers
  static void clearLeaveControllers() {
    try {
    } catch (e) {
      print('Error clearing leave controllers: $e');
    }
  }

  /// Clear chỉ user filter controllers
  static void clearUserControllers() {
    try {
      if (Get.isRegistered<FilterUserController>()) {
        final controller = Get.find<FilterUserController>();
        controller.employeeIdToDepartment.clear();
        controller.userList.clear();
      }

      if (Get.isRegistered<ProfileLogic>()) {
        final controller = Get.find<ProfileLogic>();
        controller.resetProfile();
      }
    } catch (e) {
      print('Error clearing user controllers: $e');
    }
  }
}
