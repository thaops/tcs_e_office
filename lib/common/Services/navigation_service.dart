import 'package:get/get.dart';
import 'package:tcs_e_office/feature/private_app_shell/work_management/controllers/work_management_controller.dart';
import 'package:tcs_e_office/feature/private_app_shell/work_management/models/filter_model.dart';

/// Service để handle navigation từ home tab đến work management tab với filter
class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  // Callback để switch tab trong MainScreen
  static Function(int)? _onTabChanged;

  /// Set callback để switch tab
  static void setTabChangeCallback(Function(int) callback) {
    _onTabChanged = callback;
  }

  /// Navigate đến work management tab với filter tương ứng
  static void navigateToWorkManagement({
    required int targetTab, // 0: Việc tôi giao, 1: Việc giao đến tôi
    FilterModel? filter,
    bool resetFilter = false,
  }) {
    // Switch to work management tab (index 1)
    _onTabChanged?.call(1);

    // Delay một chút để đảm bảo tab đã switch xong
    Future.delayed(const Duration(milliseconds: 100), () {
      try {
        final workController = Get.find<WorkManagementController>();
        workController.changeTab(targetTab);

        // Reset filter nếu cần
        if (resetFilter) {
          workController.resetFilter();
        }
        // Apply filter nếu có
        else if (filter != null) {
          workController.applyFilter(filter);
        }
      } catch (e) {
        // Controller chưa được khởi tạo, thử lại sau
        Future.delayed(const Duration(milliseconds: 200), () {
          try {
            final workController = Get.find<WorkManagementController>();
            workController.changeTab(targetTab);

            // Reset filter nếu cần
            if (resetFilter) {
              workController.resetFilter();
            }
            // Apply filter nếu có
            else if (filter != null) {
              workController.applyFilter(filter);
            }
          } catch (e2) {
            print('Error applying navigation: $e2');
          }
        });
      }
    });
  }

  /// Navigate với filter theo trạng thái cụ thể
  static void navigateWithStatusFilter({
    required int targetTab,
    required int status,
  }) {
    final filter = FilterModel(status: status);
    navigateToWorkManagement(targetTab: targetTab, filter: filter);
  }

  /// Navigate với filter cho "Công việc trong ngày" (filter theo ngày hôm nay)
  static void navigateWithInDateFilter({required int targetTab}) {
    // Tạo filter với ngày hôm nay
    final today = DateTime.now();
    final startDate =
        "${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    final dueDate = "${startDate}T23:59:59.000+07:00";

    final filter = FilterModel(startDate: startDate, dueDate: dueDate);

    navigateToWorkManagement(targetTab: targetTab, filter: filter);
  }

  /// Navigate với filter cho "Công việc đang xử lý" (status = 1)
  static void navigateWithDoingFilter({required int targetTab}) {
    final filter = FilterModel(status: 1);
    navigateToWorkManagement(targetTab: targetTab, filter: filter);
  }

  /// Navigate với filter theo mức độ ưu tiên
  static void navigateWithPriorityFilter({
    required int targetTab,
    required int priority,
  }) {
    final filter = FilterModel(priority: priority);
    navigateToWorkManagement(targetTab: targetTab, filter: filter);
  }
}
