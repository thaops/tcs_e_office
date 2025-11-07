import 'package:get/get.dart';
import 'package:tcs_e_office/feature/private_app_shell/notification/models/notification_model.dart';
import 'package:tcs_e_office/feature/private_app_shell/notification/services/notification_service.dart';
import 'package:tcs_e_office/feature/private_app_shell/notification/handlers/notification_navigation_handler.dart';

/// Controller cho Notification Screen
class NotificationController extends GetxController {
  final NotificationService _notificationService = NotificationService();

  // Observable state
  final _allNotifications = <NotificationItem>[].obs;
  final _unreadNotifications = <NotificationItem>[].obs;
  final _readNotifications = <NotificationItem>[].obs;
  final _isLoading = false.obs;
  final _error = RxnString();
  final _totalRecord = 0.obs;
  final _currentPageIndex = 1.obs;
  final _hasMore = true.obs;
  final _isSelectAll = false.obs; // Checkbox "Tất cả"
  final _selectedNotificationIds = <String>{}.obs; // Danh sách ID đã chọn

  // Getters
  List<NotificationItem> get allNotifications => _allNotifications;
  List<NotificationItem> get unreadNotifications => _unreadNotifications;
  List<NotificationItem> get readNotifications => _readNotifications;
  bool get isLoading => _isLoading.value;
  String? get error => _error.value;
  int get totalRecord => _totalRecord.value;
  bool get hasMore => _hasMore.value;
  bool get isSelectAll => _isSelectAll.value;
  Set<String> get selectedNotificationIds => _selectedNotificationIds;
  bool isNotificationSelected(String notificationId) =>
      _selectedNotificationIds.contains(notificationId);

  @override
  void onInit() {
    super.onInit();
    // Luôn call API khi mở màn hình để lấy dữ liệu mới nhất
    loadNotifications(refresh: true);
  }

  /// Load danh sách notification
  Future<void> loadNotifications({bool refresh = false}) async {
    try {
      if (refresh) {
        _currentPageIndex.value = 1;
        _allNotifications.clear();
        _unreadNotifications.clear();
        _readNotifications.clear();
        _hasMore.value = true;
      }

      if (!_hasMore.value && !refresh) return;

      _isLoading.value = true;
      _error.value = null;

      final result = await _notificationService.getNotificationList(
        pageIndex: _currentPageIndex.value,
        pageSize: 10,
      );

      if (result.isSuccess && result.data != null) {
        final newNotifications = result.data!.data;
        _totalRecord.value = result.data!.totalRecord;

        if (newNotifications.isEmpty) {
          _hasMore.value = false;
        } else {
          _allNotifications.addAll(newNotifications);
          _updateFilteredLists();
          _currentPageIndex.value++;

          // Nếu số lượng items mới ít hơn pageSize, có nghĩa là đã hết data
          if (newNotifications.length < 10) {
            _hasMore.value = false;
          }
        }
      } else {
        _error.value = result.error ?? 'Không thể tải danh sách thông báo';
        // Nếu có lỗi, set hasMore = false để tránh load more liên tục
        _hasMore.value = false;
      }
    } catch (e) {
      _error.value = 'Lỗi: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  /// Load thêm notification (pagination)
  Future<void> loadMore() async {
    if (!_isLoading.value && _hasMore.value) {
      await loadNotifications();
    }
  }

  /// Refresh danh sách
  Future<void> refresh() async {
    await loadNotifications(refresh: true);
  }

  /// Cập nhật danh sách đã đọc và chưa đọc
  void _updateFilteredLists() {
    _unreadNotifications.value = _allNotifications
        .where((item) => !item.isRead)
        .toList();
    _readNotifications.value = _allNotifications.toList(); // Lấy tất cả
  }

  /// Đánh dấu notification là đã đọc (local update - tạm thời)
  void _markAsReadLocal(String notificationId) {
    final index = _allNotifications.indexWhere(
      (item) => item.id == notificationId,
    );
    if (index != -1) {
      final updatedItem = _allNotifications[index].copyWith(isRead: true);
      _allNotifications[index] = updatedItem;
      _updateFilteredLists();
    }
  }

  /// Đánh dấu notification là đã đọc qua API và đồng bộ
  Future<void> markAsRead(String notificationId) async {
    try {
      // Cập nhật local trước để UI phản hồi nhanh
      _markAsReadLocal(notificationId);

      // Gọi API để đánh dấu đã đọc
      final result = await _notificationService.markAsRead(notificationId);
      print('result: $result');
      if (result.isSuccess) {
        // Load ngầm danh sách notification để đồng bộ từ API
        _syncNotificationsInBackground();
      } else {
        // Nếu API fail, revert lại local state
        final index = _allNotifications.indexWhere(
          (item) => item.id == notificationId,
        );
        if (index != -1) {
          final updatedItem = _allNotifications[index].copyWith(isRead: false);
          _allNotifications[index] = updatedItem;
          _updateFilteredLists();
        }
        print('❌ Failed to mark notification as read: ${result.error}');
      }
    } catch (e) {
      print('❌ Error marking notification as read: $e');
      // Revert local state nếu có lỗi
      final index = _allNotifications.indexWhere(
        (item) => item.id == notificationId,
      );
      if (index != -1) {
        final updatedItem = _allNotifications[index].copyWith(isRead: false);
        _allNotifications[index] = updatedItem;
        _updateFilteredLists();
      }
    }
  }

  /// Đồng bộ danh sách notification từ API (load ngầm)
  Future<void> _syncNotificationsInBackground() async {
    try {
      // Load lại từ đầu để đồng bộ
      final result = await _notificationService.getNotificationList(
        pageIndex: 1,
        pageSize: _allNotifications.length > 0 ? _allNotifications.length : 10,
      );

      if (result.isSuccess && result.data != null) {
        final syncedNotifications = result.data!.data;

        // Cập nhật danh sách với data từ API
        if (syncedNotifications.isNotEmpty) {
          // Merge với danh sách hiện tại dựa trên ID
          for (var syncedItem in syncedNotifications) {
            final index = _allNotifications.indexWhere(
              (item) => item.id == syncedItem.id,
            );
            if (index != -1) {
              final currentItem = _allNotifications[index];
              // Ưu tiên giữ isRead: true nếu local đã là true
              // Tránh trường hợp đã đọc rồi click thành chưa đọc
              // Chỉ cập nhật thành đã đọc nếu API trả về đã đọc
              // Không bao giờ revert từ đã đọc thành chưa đọc
              final isRead = currentItem.isRead || syncedItem.isRead;
              final updatedItem = syncedItem.copyWith(isRead: isRead);
              _allNotifications[index] = updatedItem;
            }
          }
          _updateFilteredLists();
        }
      }
    } catch (e) {
      print('❌ Error syncing notifications in background: $e');
      // Không hiển thị lỗi cho user vì đây là sync ngầm
    }
  }

  /// Xử lý click notification và navigate
  /// Cập nhật local state thành đã đọc ngay lập tức
  /// Gọi API để đánh dấu đã đọc ở background
  Future<void> handleNotificationClick(String notificationId) async {
    // Tìm notification item để lấy source và sourceId
    final notification = _allNotifications.firstWhereOrNull(
      (item) => item.id == notificationId,
    );

    if (notification == null) {
      print('❌ Notification not found: $notificationId');
      return;
    }

    // Cập nhật local state thành đã đọc ngay lập tức (chỉ nếu chưa đọc)
    // Tránh trường hợp đã đọc rồi click thành chưa đọc
    if (!notification.isRead) {
      _markAsReadLocal(notificationId);
      // Gọi API để đánh dấu đã đọc ở background
      _markAsReadInBackground(notificationId);
    }

    // Luôn gọi API getNotificationDetail để lấy thông tin mới nhất từ server
    // Sau đó navigate dựa trên data từ API
    await NotificationNavigationHandler.handleNotificationNavigation(
      notificationId,
    );
  }

  /// Đánh dấu đã đọc ngầm (chỉ gọi API, không cập nhật local)
  /// Xử lý lỗi 404 một cách graceful (có thể notification đã được đánh dấu đọc rồi)
  void _markAsReadInBackground(String notificationId) {
    _notificationService
        .markAsRead(notificationId)
        .then((result) {
          if (result.isSuccess) {
            print(
              '✅ Notification marked as read in background: $notificationId',
            );
          } else {
            // Chỉ log lỗi nếu không phải 404 (có thể notification đã được đánh dấu đọc rồi)
            final errorCode = result.statusCode;
            if (errorCode != 404) {
              print('❌ Failed to mark notification as read: ${result.error}');
            }
            // 404 có thể do notification đã được đánh dấu đọc rồi, không cần log lỗi
          }
        })
        .catchError((e) {
          // Xử lý exception - không log lỗi nếu có thể là 404
          final errorMessage = e.toString();
          if (errorMessage.contains('404') ||
              errorMessage.contains('Not Found')) {
            // Có thể notification đã được đánh dấu đọc rồi, không cần log lỗi
            return;
          }
          print('❌ Error marking notification as read: $e');
        });
  }

  /// Sync notifications khi quay lại màn hình
  /// Gọi API để cập nhật trạng thái từ server
  Future<void> syncOnResume() async {
    await _syncNotificationsInBackground();
  }

  /// Toggle checkbox "Tất cả" - chỉ để select/deselect, không call API
  void toggleSelectAll() {
    _isSelectAll.value = !_isSelectAll.value;

    if (_isSelectAll.value) {
      // Select tất cả items chưa đọc
      final unreadIds = _unreadNotifications.map((item) => item.id).toSet();
      _selectedNotificationIds.addAll(unreadIds);
    } else {
      // Deselect tất cả
      _selectedNotificationIds.clear();
    }
  }

  /// Toggle select cho một notification
  void toggleSelectNotification(String notificationId) {
    if (_selectedNotificationIds.contains(notificationId)) {
      _selectedNotificationIds.remove(notificationId);
    } else {
      _selectedNotificationIds.add(notificationId);
    }

    // Cập nhật checkbox "Tất cả" dựa trên số lượng selected
    final unreadIds = _unreadNotifications.map((item) => item.id).toSet();
    _isSelectAll.value =
        unreadIds.isNotEmpty && _selectedNotificationIds.containsAll(unreadIds);
  }

  /// Xử lý click "Đã đọc" - call API
  Future<void> markSelectedAsRead() async {
    try {
      if (_isSelectAll.value) {
        // Nếu checkbox "Tất cả" được bật: gọi API readAllNotifications
        final result = await _notificationService.readAllNotifications();

        if (result.isSuccess) {
          // Đánh dấu tất cả local items là đã đọc
          for (var i = 0; i < _allNotifications.length; i++) {
            _allNotifications[i] = _allNotifications[i].copyWith(isRead: true);
          }
          _updateFilteredLists();
          _selectedNotificationIds.clear();
          _isSelectAll.value = false;

          // Load ngầm để đồng bộ từ API
          _syncNotificationsInBackground();
        } else {
          print('❌ Failed to read all notifications: ${result.error}');
        }
      } else {
        // Nếu checkbox "Tất cả" không được bật: gọi API readNotifications với danh sách ID đã chọn
        final notificationIds = _selectedNotificationIds.toList();

        if (notificationIds.isNotEmpty) {
          final result = await _notificationService.readNotifications(
            notificationIds,
          );

          if (result.isSuccess) {
            // Đánh dấu các selected items là đã đọc
            for (var notificationId in notificationIds) {
              final index = _allNotifications.indexWhere(
                (item) => item.id == notificationId,
              );
              if (index != -1) {
                _allNotifications[index] = _allNotifications[index].copyWith(
                  isRead: true,
                );
              }
            }
            _updateFilteredLists();
            _selectedNotificationIds.clear();
            _isSelectAll.value = false;

            // Load ngầm để đồng bộ từ API
            _syncNotificationsInBackground();
          } else {
            print('❌ Failed to read notifications: ${result.error}');
          }
        }
      }
    } catch (e) {
      print('❌ Error marking selected as read: $e');
    }
  }
}
