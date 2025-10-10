import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tcs_e_office/feature/private_app_shell/profile/logic/profile_logic.dart';

class HomeHeader extends StatefulWidget {
  const HomeHeader({super.key});

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  late ProfileLogic _profileLogic;

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
              Container(
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
                    // Notification badge - giảm kích thước
                    Positioned(
                      right: 6.w,
                      top: 6.h,
                      child: Container(
                        width: 6.w,
                        height: 6.h,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
