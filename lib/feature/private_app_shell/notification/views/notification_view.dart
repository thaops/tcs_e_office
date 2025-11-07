import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tcs_e_office/common/widgets/app_bar_widget.dart';
import 'package:tcs_e_office/core/configs/theme/app_colors.dart';
import 'package:tcs_e_office/common/widgets/common_tab_bar.dart';
import 'package:tcs_e_office/feature/private_app_shell/notification/controllers/notification_controller.dart';
import 'package:tcs_e_office/feature/private_app_shell/notification/models/notification_model.dart';
import 'package:tcs_e_office/feature/private_app_shell/notification/widgets/notification_item_widget.dart';
import 'package:tcs_e_office/feature/private_app_shell/notification/widgets/notification_filter_bottom_sheet.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  late NotificationController _controller;
  bool _isLoadingMore = false;
  AppLifecycleState? _lastLifecycleState;
  DateTime? _lastSyncTime;
  static const _syncDebounceMs = 1000;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(NotificationController());
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Chỉ sync khi app resume từ background (paused/inactive -> resumed)
    // Không sync khi chỉ navigate giữa các màn hình
    if (state == AppLifecycleState.resumed &&
        (_lastLifecycleState == AppLifecycleState.paused ||
            _lastLifecycleState == AppLifecycleState.inactive)) {
      _syncOnResume();
    }

    _lastLifecycleState = state;
  }

  void _syncOnResume() {
    final now = DateTime.now();

    // Debounce để tránh spam
    if (_lastSyncTime != null &&
        now.difference(_lastSyncTime!).inMilliseconds < _syncDebounceMs) {
      return;
    }

    _lastSyncTime = now;

    // Delay nhỏ để đảm bảo UI đã render xong
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _controller.syncOnResume();
      }
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NotificationFilterBottomSheet(
        currentFilter: _controller.currentFilter,
        onApplyFilter: (filter) {
          _controller.applyFilter(filter);
        },
        onResetFilter: () {
          _controller.resetFilter();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarWidget(
        title: 'Thông báo',
        iconRightfirst: Icons.filter_list,
        functionfirst: _showFilterBottomSheet,
      ),
      body: Column(
        children: [
          CommonTabBar(
            controller: _tabController,
            tabs: const [
              CommonTabItem(
                icon: Icons.notifications_outlined,
                label: 'Chưa đọc',
              ),
              CommonTabItem(icon: Icons.notifications_none, label: 'Tất cả'),
            ],
          ),
          Expanded(
            child: Obx(() {
              if (_controller.isLoading &&
                  _controller.allNotifications.isEmpty) {
                return _buildLoadingState();
              }

              if (_controller.error != null &&
                  _controller.allNotifications.isEmpty) {
                return _buildErrorState();
              }

              return TabBarView(
                controller: _tabController,
                children: [_buildUnreadTab(), _buildReadTab()],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48.sp, color: Colors.grey),
          SizedBox(height: 16.h),
          Text(
            _controller.error ?? 'Có lỗi xảy ra',
            style: TextStyle(color: Colors.grey, fontSize: 14.sp),
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () => _controller.refresh(),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildUnreadTab() {
    return _buildNotificationList(
      notifications: _controller.unreadNotifications,
      emptyMessage: 'Không có thông báo chưa đọc',
      enableCheckbox: true,
    );
  }

  Widget _buildReadTab() {
    return _buildNotificationList(
      notifications: _controller.readNotifications,
      emptyMessage: 'Không có thông báo',
      enableCheckbox: (notification) => !notification.isRead,
    );
  }

  Widget _buildNotificationList({
    required List<NotificationItem> notifications,
    required String emptyMessage,
    required dynamic enableCheckbox,
  }) {
    return Obx(() {
      final notificationList = notifications;

      if ((!_controller.isLoading || !_controller.hasMore) && _isLoadingMore) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _isLoadingMore = false;
            });
          }
        });
      }

      if (notificationList.isEmpty) {
        return _buildEmptyState(emptyMessage);
      }

      return RefreshIndicator(
        onRefresh: () async {
          _isLoadingMore = false;
          await _controller.refresh();
        },
        color: AppColors.primary,
        child: NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) =>
              _handleScroll(scrollInfo, notificationList),
          child: ListView.builder(
            itemCount:
                1 +
                notificationList.length +
                (_controller.hasMore && _controller.isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildSelectAllHeader();
              }

              final notificationIndex = index - 1;
              if (notificationIndex == notificationList.length) {
                return _controller.isLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : const SizedBox.shrink();
              }

              final notification = notificationList[notificationIndex];
              final isCheckboxEnabled = enableCheckbox is bool
                  ? enableCheckbox
                  : enableCheckbox(notification);

              return Obx(
                () => NotificationItemWidget(
                  notification: notification,
                  showCheckbox: true,
                  isSelected: _controller.isNotificationSelected(
                    notification.id,
                  ),
                  enableCheckbox: isCheckboxEnabled,
                  onCheckboxChanged: () {
                    _controller.toggleSelectNotification(notification.id);
                  },
                  onTap: () {
                    _controller.handleNotificationClick(notification.id);
                  },
                ),
              );
            },
          ),
        ),
      );
    });
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64.sp,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16.h),
          Text(
            message,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectAllHeader() {
    return Obx(
      () => Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
        ),
        child: Row(
          children: [
            Checkbox(
              value: _controller.isSelectAll,
              onChanged: (_) => _controller.toggleSelectAll(),
              activeColor: AppColors.primary,
            ),
            SizedBox(width: 8.w),
            Text(
              'Tất cả',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            InkWell(
              onTap: () => _controller.markSelectedAsRead(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check, size: 20.sp, color: Colors.grey.shade600),
                  SizedBox(width: 8.w),
                  Text(
                    'Đã đọc',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _handleScroll(
    ScrollNotification scrollInfo,
    List<NotificationItem> notificationList,
  ) {
    if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200 &&
        !_controller.isLoading &&
        !_isLoadingMore &&
        _controller.hasMore &&
        notificationList.length >= 5) {
      _isLoadingMore = true;
      _controller.loadMore().then((_) {
        if (mounted) {
          setState(() {
            _isLoadingMore = false;
          });
        }
      });
    }
    return false;
  }
}
