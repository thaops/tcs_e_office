import 'package:get/get.dart';
import 'package:tcs_e_office/feature/private_app_shell/notification/models/notification_model.dart';
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
    _unreadNotifications.value = _allNotifications
        .where((item) => !item.isRead)
        .toList();
    _readNotifications.value = _allNotifications.toList();
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
      final result = await _notificationService.getNotificationList(
        pageIndex: 1,
        pageSize: _allNotifications.length > 0 ? _allNotifications.length : 10,
      );

      if (result.isSuccess && result.data != null) {
        final syncedNotifications = result.data!.data;

        if (syncedNotifications.isNotEmpty) {
          for (var syncedItem in syncedNotifications) {
            final index = _allNotifications.indexWhere(
              (item) => item.id == syncedItem.id,
            );
            if (index != -1) {
              final currentItem = _allNotifications[index];
              final isRead = currentItem.isRead || syncedItem.isRead;
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

    if (notification == null) {
      return;
    }

    if (!notification.isRead) {
      _markAsReadLocal(notificationId);
      _markAsReadInBackground(notificationId);
    }

    await NotificationNavigationHandler.handleNotificationNavigation(
      notificationId,
    );
  }

  void _markAsReadInBackground(String notificationId) {
    _notificationService.markAsRead(notificationId);
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
