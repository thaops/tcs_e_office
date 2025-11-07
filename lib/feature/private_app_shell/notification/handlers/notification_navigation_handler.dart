import 'package:get/get.dart';
import 'package:tcs_e_office/common/Services/services.dart';
import 'package:tcs_e_office/common/widgets/app_dialog.dart';
import 'package:tcs_e_office/feature/private_app_shell/document_management/views/document_detail_view.dart';
import 'package:tcs_e_office/feature/private_app_shell/work_management/views/task_detail_view.dart';
import 'package:tcs_e_office/feature/private_app_shell/notification/services/notification_service.dart';

/// Handler chung để xử lý navigation từ notification
/// Sử dụng cho cả click từ UI và OneSignal
class NotificationNavigationHandler {
  static final NotificationService _notificationService = NotificationService();

  /// Xử lý navigation từ notification ID
  /// Lấy detail từ API rồi navigate đến đúng màn hình
  static Future<void> handleNotificationNavigation(
    String notificationId,
  ) async {
    try {
      // Lấy notification detail từ API
      final result = await _notificationService.getNotificationDetail(
        notificationId,
      );

      if (!result.isSuccess || result.data == null) {
        print('❌ Failed to get notification detail: ${result.error}');
        AppDialog.showError(
          title: 'Thông báo',
          message: 'Không thể tải thông tin thông báo. Vui lòng thử lại sau.',
          useBackdrop: false,
        );
        return;
      }

      final notificationDetail = result.data!;

      // Navigate dựa trên source và sourceId
      await _navigateBySource(
        source: notificationDetail.source,
        sourceId: notificationDetail.sourceId,
      );
    } catch (e) {
      print('❌ Error handling notification navigation: $e');
    }
  }

  /// Xử lý navigation từ notification data có sẵn
  /// Dùng khi đã có source và sourceId (không cần gọi API)
  static Future<void> handleNotificationNavigationWithData({
    required String source,
    required String sourceId,
  }) async {
    await _navigateBySource(source: source, sourceId: sourceId);
  }

  /// Navigate đến màn hình tương ứng dựa trên source
  static Future<void> _navigateBySource({
    required String source,
    required String sourceId,
  }) async {
    try {
      print('🚀 Navigating with source: $source, sourceId: $sourceId');

      // Check login trực tiếp, không navigate về main
      final service = await Services.create();
      final accessToken = await service.getAccessToken();

      if (accessToken.isEmpty) {
        print('❌ User not logged in, cannot navigate');
        AppDialog.showError(
          title: 'Thông báo',
          message: 'Vui lòng đăng nhập để xem thông báo.',
          useBackdrop: false,
        );
        return;
      }

      // Delay một chút để đảm bảo UI ổn định
      await Future.delayed(const Duration(milliseconds: 300));

      switch (source) {
        case 'DocumentIn':
        case 'DocumentOut':
          // Navigate đến Document Detail
          print('📄 Navigating to DocumentDetailView: $sourceId');
          await Get.to(
            () => DocumentDetailView(
              documentId: sourceId,
              tabType: source == 'DocumentIn' ? 'incoming' : 'outgoing',
            ),
          );
          break;

        case 'TaskAssign':
        case 'TaskReceived':
          // Navigate đến Task Detail
          print('📋 Navigating to TaskDetailView: $sourceId');
          await Get.to(
            () => TaskDetailView(
              taskId: sourceId,
              tabType: source == 'TaskAssign'
                  ? 'assigned_by_me'
                  : 'assigned_to_me',
            ),
          );
          break;

        case 'DayOff':
          // Navigate đến Leave Detail
          // TODO: Thay bằng LeaveDetailView khi có
          // await Get.to(() => LeaveDetailView(leaveId: sourceId));
          print('⚠️ DayOff navigation not implemented yet for: $sourceId');
          AppDialog.showError(
            title: 'Thông báo',
            message:
                'Chức năng này đang được phát triển. Vui lòng thử lại sau.',
            useBackdrop: false,
          );
          break;

        default:
          print('⚠️ Unknown notification source: $source with id: $sourceId');
          AppDialog.showError(
            title: 'Thông báo',
            message:
                'Không thể mở thông báo này. Loại thông báo không được hỗ trợ.',
            useBackdrop: false,
          );
      }
    } catch (e) {
      print('❌ Error in _navigateBySource: $e');
    }
  }
}
