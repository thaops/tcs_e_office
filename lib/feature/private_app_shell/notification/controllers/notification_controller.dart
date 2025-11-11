import 'package:get/get.dart';
import 'package:tcs_e_office/feature/private_app_shell/notification/models/notification_model.dart';
import 'package:tcs_e_office/feature/private_app_shell/notification/models/notification_filter_model.dart';
import 'package:tcs_e_office/feature/private_app_shell/notification/services/notification_service.dart';
import 'package:tcs_e_office/feature/private_app_shell/notification/handlers/notification_navigation_handler.dart';

class NotificationController extends GetxController {
  final NotificationService _notificationService = NotificationService();

  final _allNotifications = <NotificationItem>[].obs;
  final _unreadNotifications = <NotificationItem>[].obs;
  final _readNotifications = <NotificationItem>[].obs;
  final _isLoading = false.obs;
  final _error = RxnString();
  final _totalRecord = 0.obs;
  final _currentPageIndex = 1.obs;
  final _hasMore = true.obs;
  final _isSelectAll = false.obs;
  final _selectedNotificationIds = <String>{}.obs;
  final _currentFilter = NotificationFilterModel.empty().obs;
  final _processingNotificationId = RxnString();
  final _processingNotificationIds =
      <String>{}.obs; // Track các notification đang xử lý
  List<NotificationItem> get allNotifications => _allNotifications;
  List<NotificationItem> get unreadNotifications => _unreadNotifications;
  List<NotificationItem> get readNotifications => _readNotifications;
  bool get isLoading => _isLoading.value;
  String? get error => _error.value;
  int get totalRecord => _totalRecord.value;
  bool get hasMore => _hasMore.value;
  bool get isSelectAll => _isSelectAll.value;
  Set<String> get selectedNotificationIds => _selectedNotificationIds;
  NotificationFilterModel get currentFilter => _currentFilter.value;
  String? get processingNotificationId => _processingNotificationId.value;
  bool isNotificationSelected(String notificationId) =>
      _selectedNotificationIds.contains(notificationId);
  bool isNotificationProcessing(String notificationId) =>
      _processingNotificationId.value == notificationId ||
      _processingNotificationIds.contains(notificationId);

  @override
  void onInit() {
    super.onInit();
    // Load ngầm khi khởi tạo (không hiển thị loading)
    loadNotifications(refresh: true, silent: true);
  }

  /// Load notifications
  /// [refresh] = true: reset và load lại từ đầu
  /// [silent] = true: load ngầm không hiển thị loading indicator
  Future<void> loadNotifications({
    bool refresh = false,
    bool silent = false,
  }) async {
    try {
      if (refresh) {
        _currentPageIndex.value = 1;
        _allNotifications.clear();
        _unreadNotifications.clear();
        _readNotifications.clear();
        _hasMore.value = true;
      }

      if (!_hasMore.value && !refresh) return;

      if (!silent) {
        _isLoading.value = true;
      }
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

          if (newNotifications.length < 10) {
            _hasMore.value = false;
          }
        }
      } else {
        _error.value = result.error ?? 'Không thể tải danh sách thông báo';
        _hasMore.value = false;
      }
    } catch (e) {
      _error.value = 'Lỗi: $e';
    } finally {
      if (!silent) {
        _isLoading.value = false;
      }
    }
  }

  Future<void> loadMore() async {
    if (!_isLoading.value && _hasMore.value) {
      await loadNotifications();
    }
  }

  /// Refresh data (hiển thị loading khi refresh)
  Future<void> refresh() async {
    await loadNotifications(refresh: true, silent: false);
  }

  void _updateFilteredLists() {
    List<NotificationItem> filtered = _allNotifications;

    // Áp dụng filter loại thông báo
    if (_currentFilter.value.notificationType != null) {
      filtered = filtered
          .where((item) => item.source == _currentFilter.value.notificationType)
          .toList();
    }

    // Áp dụng filter trạng thái đọc
    if (_currentFilter.value.readStatus != null) {
      filtered = filtered
          .where((item) => item.isRead == _currentFilter.value.readStatus)
          .toList();
    }

    _unreadNotifications.value = filtered
        .where((item) => !item.isRead)
        .toList();
    _readNotifications.value = filtered;
  }

  void applyFilter(NotificationFilterModel filter) {
    _currentFilter.value = filter;
    _updateFilteredLists();
  }

  void resetFilter() {
    _currentFilter.value = NotificationFilterModel.empty();
    _updateFilteredLists();
  }

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

  Future<void> markAsRead(String notificationId) async {
    try {
      _markAsReadLocal(notificationId);

      final result = await _notificationService.markAsRead(notificationId);
      if (result.isSuccess) {
        _syncNotificationsInBackground();
      } else {
        final index = _allNotifications.indexWhere(
          (item) => item.id == notificationId,
        );
        if (index != -1) {
          final updatedItem = _allNotifications[index].copyWith(isRead: false);
          _allNotifications[index] = updatedItem;
          _updateFilteredLists();
        }
      }
    } catch (e) {
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

  Future<void> _syncNotificationsInBackground() async {
    try {
      // Sync với pageSize lớn hơn để đảm bảo sync đầy đủ
      final pageSize = _allNotifications.length > 0
          ? (_allNotifications.length > 50 ? 50 : _allNotifications.length)
          : 20;

      final result = await _notificationService.getNotificationList(
        pageIndex: 1,
        pageSize: pageSize,
      );

      if (result.isSuccess && result.data != null) {
        final syncedNotifications = result.data!.data;

        if (syncedNotifications.isNotEmpty) {
          // Update các notification đã có trong list
          for (var syncedItem in syncedNotifications) {
            final index = _allNotifications.indexWhere(
              (item) => item.id == syncedItem.id,
            );
            if (index != -1) {
              // Ưu tiên trạng thái từ server (syncedItem.isRead)
              // Nhưng giữ local state nếu server chưa cập nhật
              final isRead =
                  syncedItem.isRead || _allNotifications[index].isRead;
              final updatedItem = syncedItem.copyWith(isRead: isRead);
              _allNotifications[index] = updatedItem;
            }
          }
          _updateFilteredLists();
        }
      }
    } catch (e) {}
  }

  Future<void> handleNotificationClick(String notificationId) async {
    final notification = _allNotifications.firstWhereOrNull(
      (item) => item.id == notificationId,
    );

    // Kiểm tra notification có tồn tại không
    if (notification == null) {
      return;
    }

    // Kiểm tra xem notification đã được xử lý hoặc đang xử lý chưa
    // Tránh click liên tục
    if (_processingNotificationIds.contains(notificationId) ||
        notification.isRead) {
      // Nếu đang xử lý hoặc đã đọc, chỉ navigate thôi
      await NotificationNavigationHandler.handleNotificationNavigation(
        notificationId,
      );
      return;
    }

    // Thêm vào Set để lock, tránh click liên tục
    _processingNotificationIds.add(notificationId);
    _processingNotificationId.value = notificationId;

    try {
      // Delay nhỏ để user thấy được feedback
      await Future.delayed(const Duration(milliseconds: 150));

      // Gọi API để đánh dấu đã đọc
      final result = await _notificationService.markAsRead(notificationId);

      // Chỉ update local state sau khi API thành công
      if (result.isSuccess) {
        _markAsReadLocal(notificationId);
        // Sync background sau khi thành công
        _syncNotificationsInBackground();
      } else {
        // Nếu API fail, giữ nguyên trạng thái chưa đọc
        // Không update local state
      }

      // Navigate đến màn hình chi tiết
      await NotificationNavigationHandler.handleNotificationNavigation(
        notificationId,
      );
    } catch (e) {
      // Nếu có lỗi, giữ nguyên trạng thái
      // Không update local state
    } finally {
      // Clear processing state sau khi hoàn thành
      _processingNotificationIds.remove(notificationId);
      _processingNotificationId.value = null;
    }
  }

  Future<void> syncOnResume() async {
    await _syncNotificationsInBackground();
  }

  void toggleSelectAll() {
    _isSelectAll.value = !_isSelectAll.value;

    if (_isSelectAll.value) {
      final unreadIds = _unreadNotifications.map((item) => item.id).toSet();
      _selectedNotificationIds.addAll(unreadIds);
    } else {
      _selectedNotificationIds.clear();
    }
  }

  void toggleSelectNotification(String notificationId) {
    if (_selectedNotificationIds.contains(notificationId)) {
      _selectedNotificationIds.remove(notificationId);
    } else {
      _selectedNotificationIds.add(notificationId);
    }

    final unreadIds = _unreadNotifications.map((item) => item.id).toSet();
    _isSelectAll.value =
        unreadIds.isNotEmpty && _selectedNotificationIds.containsAll(unreadIds);
  }

  Future<void> markSelectedAsRead() async {
    try {
      if (_isSelectAll.value) {
        final result = await _notificationService.readAllNotifications();

        if (result.isSuccess) {
          for (var i = 0; i < _allNotifications.length; i++) {
            _allNotifications[i] = _allNotifications[i].copyWith(isRead: true);
          }
          _updateFilteredLists();
          _selectedNotificationIds.clear();
          _isSelectAll.value = false;

          _syncNotificationsInBackground();
        }
      } else {
        final notificationIds = _selectedNotificationIds.toList();

        if (notificationIds.isNotEmpty) {
          final result = await _notificationService.readNotifications(
            notificationIds,
          );

          if (result.isSuccess) {
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

            _syncNotificationsInBackground();
          }
        }
      }
    } catch (e) {}
  }
}
