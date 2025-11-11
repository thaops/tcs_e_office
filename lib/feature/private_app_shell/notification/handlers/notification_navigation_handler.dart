import 'package:get/get.dart';
import 'package:tcs_e_office/common/Services/services.dart';
import 'package:tcs_e_office/common/widgets/app_dialog.dart';
import 'package:tcs_e_office/feature/private_app_shell/document_management/views/document_detail_view.dart';
import 'package:tcs_e_office/feature/private_app_shell/work_management/views/task_detail_view.dart';
import 'package:tcs_e_office/feature/private_app_shell/notification/services/notification_service.dart';
import 'package:tcs_e_office/common/constants/app_tab_types.dart';

class NotificationNavigationHandler {
  static final NotificationService _notificationService = NotificationService();

  static Future<void> handleNotificationNavigation(
    String notificationId,
  ) async {
    try {
      final result = await _notificationService.getNotificationDetail(
        notificationId,
      );

      if (!result.isSuccess || result.data == null) {
        AppDialog.showError(
          title: 'Thông báo',
          message: 'Không thể tải thông tin thông báo. Vui lòng thử lại sau.',
          useBackdrop: false,
        );
        return;
      }

      final notificationDetail = result.data!;

      await _navigateBySource(
        source: notificationDetail.source,
        sourceId: notificationDetail.sourceId,
      );
    } catch (e) {}
  }

  static Future<void> handleNotificationNavigationWithData({
    required String source,
    required String sourceId,
  }) async {
    await _navigateBySource(source: source, sourceId: sourceId);
  }

  static Future<void> _navigateBySource({
    required String source,
    required String sourceId,
  }) async {
    try {
      final service = await Services.create();
      final accessToken = await service.getAccessToken();

      if (accessToken.isEmpty) {
        AppDialog.showError(
          title: 'Thông báo',
          message: 'Vui lòng đăng nhập để xem thông báo.',
          useBackdrop: false,
        );
        return;
      }

      await Future.delayed(const Duration(milliseconds: 300));

      switch (source) {
        case AppTabTypes.DOCUMENT_IN:
        case AppTabTypes.DOCUMENT_OUT:
          await Get.to(
            () => DocumentDetailView(documentId: sourceId, tabType: source),
          );
          break;

        case AppTabTypes.TASK_ASSIGN:
        case AppTabTypes.TASK_RECEIVED:
          await Get.to(() => TaskDetailView(taskId: sourceId, tabType: source));
          break;

        case 'DayOff':
          AppDialog.showError(
            title: 'Thông báo',
            message:
                'Chức năng này đang được phát triển. Vui lòng thử lại sau.',
            useBackdrop: false,
          );
          break;

        default:
          AppDialog.showError(
            title: 'Thông báo',
            message:
                'Không thể mở thông báo này. Loại thông báo không được hỗ trợ.',
            useBackdrop: false,
          );
      }
    } catch (e) {}
  }
}
