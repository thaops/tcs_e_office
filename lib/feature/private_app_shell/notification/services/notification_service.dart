import 'package:tcs_e_office/common/Services/api_endpoints.dart';
import 'package:tcs_e_office/common/repositoty/dio_api.dart';
import 'package:tcs_e_office/common/utils/api_response_handler.dart';
import 'package:tcs_e_office/feature/private_app_shell/notification/models/notification_model.dart';
import 'package:tcs_e_office/feature/private_app_shell/notification/models/notification_detail_model.dart';

/// Service để call API lấy notification list
class NotificationService {
  final DioApi _dioApi = DioApi();

  /// Lấy danh sách notification từ API
  /// [pageIndex] - số trang (bắt đầu từ 1)
  /// [pageSize] - số lượng item mỗi trang
  Future<ApiResult<NotificationListModel>> getNotificationList({
    int pageIndex = 1,
    int pageSize = 10,
  }) async {
    try {
      final url = ApiEndpoints.getNotificationList(pageIndex: pageIndex, pageSize: pageSize);
      final response = await _dioApi.get(url);

      // Parse trực tiếp từ response vì NotificationListModel cần toàn bộ response map
      if (response.statusCode != 200) {
        return ApiResult<NotificationListModel>.error(
          'HTTP Error: ${response.statusCode}',
          response.statusCode,
        );
      }

      if (response.data == null) {
        return ApiResult<NotificationListModel>.error('Response data is null');
      }

      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        final statusCode = responseData['statusCode'] ?? responseData['StatusCode'];
        final message = responseData['message'] ?? responseData['Message'] as String?;

        if (statusCode == 200) {
          try {
            final parsedData = NotificationListModel.fromJson(responseData);
            return ApiResult<NotificationListModel>.success(parsedData, message);
          } catch (e) {
            return ApiResult<NotificationListModel>.error('Parse error: $e');
          }
        } else {
          return ApiResult<NotificationListModel>.error(
            message ?? 'API Error: $statusCode',
            statusCode,
          );
        }
      } else {
        return ApiResult<NotificationListModel>.error('Response is not a valid format');
      }
    } catch (e) {
      return ApiResult<NotificationListModel>.error('Lỗi khi lấy danh sách thông báo: $e');
    }
  }

  /// Lấy chi tiết notification từ API
  Future<ApiResult<NotificationDetailModel>> getNotificationDetail(
    String notificationId,
  ) async {
    try {
      final url = ApiEndpoints.getNotificationDetail(notificationId);
      final response = await _dioApi.get(url);

      if (response.statusCode != 200) {
        return ApiResult<NotificationDetailModel>.error(
          'HTTP Error: ${response.statusCode}',
          response.statusCode,
        );
      }

      if (response.data == null) {
        return ApiResult<NotificationDetailModel>.error('Response data is null');
      }

      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        final statusCode = responseData['statusCode'] ?? responseData['StatusCode'];
        final message = responseData['message'] ?? responseData['Message'] as String?;

        if (statusCode == 200) {
          try {
            final data = responseData['data'] as Map<String, dynamic>?;
            if (data == null) {
              return ApiResult<NotificationDetailModel>.error('Data is null');
            }
            final parsedData = NotificationDetailModel.fromJson(data);
            return ApiResult<NotificationDetailModel>.success(parsedData, message);
          } catch (e) {
            return ApiResult<NotificationDetailModel>.error('Parse error: $e');
          }
        } else {
          return ApiResult<NotificationDetailModel>.error(
            message ?? 'API Error: $statusCode',
            statusCode,
          );
        }
      } else {
        return ApiResult<NotificationDetailModel>.error(
          'Response is not a valid format',
        );
      }
    } catch (e) {
      return ApiResult<NotificationDetailModel>.error(
        'Lỗi khi lấy chi tiết thông báo: $e',
      );
    }
  }

  /// Đánh dấu notification là đã đọc
  Future<ApiResult<bool>> markAsRead(String notificationId) async {
    try {
      final url = ApiEndpoints.markNotificationAsRead(notificationId);
      final response = await _dioApi.post(url);

      // Xử lý lỗi 404 một cách graceful (có thể notification đã được đánh dấu đọc rồi)
      if (response.statusCode == 404) {
        return ApiResult<bool>.error(
          'Notification not found or already marked as read',
          404,
        );
      }

      if (response.statusCode != 200) {
        return ApiResult<bool>.error(
          'HTTP Error: ${response.statusCode}',
          response.statusCode,
        );
      }

      if (response.data == null) {
        return ApiResult<bool>.error('Response data is null');
      }

      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        final statusCode = responseData['statusCode'] ?? responseData['StatusCode'];
        final message = responseData['message'] ?? responseData['Message'] as String?;

        if (statusCode == 200) {
          return ApiResult<bool>.success(true, message);
        } else {
          return ApiResult<bool>.error(
            message ?? 'API Error: $statusCode',
            statusCode,
          );
        }
      } else {
        return ApiResult<bool>.error('Response is not a valid format');
      }
    } catch (e) {
      // Xử lý exception - kiểm tra xem có phải 404 không
      final errorMessage = e.toString();
      if (errorMessage.contains('404') || errorMessage.contains('Not Found')) {
        return ApiResult<bool>.error(
          'Notification not found or already marked as read',
          404,
        );
      }
      return ApiResult<bool>.error('Lỗi khi đánh dấu thông báo đã đọc: $e');
    }
  }

  /// Đánh dấu nhiều notifications là đã đọc
  Future<ApiResult<bool>> readNotifications(List<String> notificationIds) async {
    try {
      final url = ApiEndpoints.readNotifications;
      final response = await _dioApi.post(url, data: notificationIds);

      if (response.data['statusCode'] != 200) {
        return ApiResult<bool>.error(
          'HTTP Error: ${response.data['statusCode']}',
          response.statusCode,
        );
      }

      if (response.data == null) {
        return ApiResult<bool>.error('Response data is null');
      }

      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        final statusCode = responseData['statusCode'] ?? responseData['StatusCode'];
        final message = responseData['message'] ?? responseData['Message'] as String?;

        if (statusCode == 200) {
          return ApiResult<bool>.success(true, message);
        } else {
          return ApiResult<bool>.error(
            message ?? 'API Error: $statusCode',
            statusCode,
          );
        }
      } else {
        return ApiResult<bool>.error('Response is not a valid format');
      }
    } catch (e) {
      return ApiResult<bool>.error('Lỗi khi đánh dấu thông báo đã đọc: $e');
    }
  }

  /// Đánh dấu tất cả notifications là đã đọc
  Future<ApiResult<bool>> readAllNotifications() async {
    try {
      final url = ApiEndpoints.readAllNotifications;
      final response = await _dioApi.post(url);

      if (response.statusCode != 200) {
        return ApiResult<bool>.error(
          'HTTP Error: ${response.statusCode}',
          response.statusCode,
        );
      }

      if (response.data == null) {
        return ApiResult<bool>.error('Response data is null');
      }

      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        final statusCode = responseData['statusCode'] ?? responseData['StatusCode'];
        final message = responseData['message'] ?? responseData['Message'] as String?;

        if (statusCode == 200) {
          return ApiResult<bool>.success(true, message);
        } else {
          return ApiResult<bool>.error(
            message ?? 'API Error: $statusCode',
            statusCode,
          );
        }
      } else {
        return ApiResult<bool>.error('Response is not a valid format');
      }
    } catch (e) {
      return ApiResult<bool>.error('Lỗi khi đánh dấu tất cả thông báo đã đọc: $e');
    }
  }
}

