import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tcs_e_office/feature/private_app_shell/profile/logic/profile_logic.dart';
import 'package:tcs_e_office/feature/private_app_shell/notification/views/notification_view.dart';
import 'package:tcs_e_office/feature/private_app_shell/notification/controllers/notification_controller.dart';

class HomeHeader extends StatefulWidget {
  const HomeHeader({super.key});

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  late ProfileLogic _profileLogic;
  late NotificationController _notificationController;

  @override
  void initState() {
    super.initState();
    // Khởi tạo ProfileLogic nếu chưa có, hoặc lấy instance hiện có
    try {
      _profileLogic = Get.find<ProfileLogic>();
    } catch (e) {
      // Nếu chưa có ProfileLogic, tạo mới
      _profileLogic = Get.put(ProfileLogic());
    }

    // Khởi tạo NotificationController nếu chưa có
    try {
      _notificationController = Get.find<NotificationController>();
    } catch (e) {
      // Nếu chưa có NotificationController, tạo mới
      _notificationController = Get.put(NotificationController());
    }

    // Đảm bảo load notifications ngầm khi vào màn hình home
    // Refresh để lấy data mới nhất từ server
    _notificationController.loadNotifications(refresh: true, silent: true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF006884), // Màu xanh đậm theo yêu cầu
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
      child: Column(
        children: [
          // Status bar space
          SizedBox(height: MediaQuery.of(context).padding.top),

          // Header content
          Row(
            children: [
              // Avatar - giảm kích thước
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Icon(Icons.person, color: Colors.white, size: 20.sp),
              ),

              SizedBox(width: 10.w),

              // Greeting text - giảm kích thước
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xin chào 👋',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Obx(() {
                      // Sử dụng getDisplayName() để có fallback từ cache
                      final displayName = _profileLogic.getDisplayName();
                      return Text(
                        displayName.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }),
                  ],
                ),
              ),

              // Notification bell - giảm kích thước
              GestureDetector(
                onTap: () async {
                  // Navigate đến NotificationView và đợi kết quả
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const NotificationView()),
                  );
                  // Refresh notifications khi quay lại để có số liệu realtime
                  _notificationController.loadNotifications(
                    refresh: true,
                    silent: true,
                  );
                },
                child: Container(
                  width: 36.w,
                  height: 36.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                      ),
                      // Notification badge - hiển thị số lượng thông báo chưa đọc
                      // Lấy data trực tiếp từ controller để đảm bảo chính xác
                      Obx(() {
                        // Lấy danh sách unread notifications trực tiếp từ controller
                        final unreadList =
                            _notificationController.unreadNotifications;
                        final unreadCount = unreadList.length;

                        // Chỉ hiển thị badge khi có thông báo chưa đọc (unreadCount > 0)
                        if (unreadCount == 0) {
                          return const SizedBox.shrink();
                        }

                        return Positioned(
                          right: 2.w,
                          top: 2.h,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: unreadCount > 99 ? 4.w : 5.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: const Color(0xFF006884),
                                width: 1.5,
                              ),
                            ),
                            constraints: BoxConstraints(
                              minWidth: 16.w,
                              minHeight: 16.h,
                            ),
                            child: Text(
                              unreadCount > 99 ? '99+' : '$unreadCount',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
