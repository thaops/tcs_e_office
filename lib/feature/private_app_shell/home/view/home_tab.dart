import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../widgets/home_header.dart';
import '../widgets/task_group_section.dart';
import '../widgets/task_item_card.dart';
import 'package:tcs_e_office/common/services/navigation_service.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Khởi tạo controller
    final HomeController controller = Get.put(HomeController());
    final isMacOS = Platform.isMacOS;
    
    return Scaffold(
      backgroundColor: isMacOS ? const Color(0xFFF8F9FA) : Colors.white,
      appBar: isMacOS ? null : AppBar(
        backgroundColor: const Color(0xFF006884), // Màu xanh đậm
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 0, // Ẩn AppBar nhưng giữ màu nền
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFF006884), // Màu status bar
          statusBarIconBrightness: Brightness.light, // Icon sáng
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header với avatar và thông báo
            const HomeHeader(),

            // Nội dung chính - responsive cho macOS
            Expanded(
              child: Obx(() {
                if (controller.isLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: isMacOS ? const Color(0xFF006884) : null,
                        ),
                        if (isMacOS) ...[
                          SizedBox(height: 16.h),
                          Text(
                            'Đang tải dữ liệu...',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                if (controller.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: isMacOS ? 48.sp : 64.sp,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          controller.error ?? 'Có lỗi xảy ra',
                          style: TextStyle(
                            fontSize: isMacOS ? 14.sp : 16.sp,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16.h),
                        ElevatedButton(
                          onPressed: () => controller.refresh(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isMacOS ? const Color(0xFF006884) : null,
                            foregroundColor: isMacOS ? Colors.white : null,
                            padding: EdgeInsets.symmetric(
                              horizontal: isMacOS ? 24.w : 16.w,
                              vertical: isMacOS ? 12.h : 8.h,
                            ),
                          ),
                          child: Text(
                            'Thử lại',
                            style: TextStyle(
                              fontSize: isMacOS ? 14.sp : 16.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.refresh,
                  color: isMacOS ? const Color(0xFF006884) : null,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isMacOS ? 20.w : 12.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nhóm 1: Việc giao đến tôi
                        TaskGroupSection(
                          title: 'Việc giao đến tôi',
                          totalCount: controller.assignedToMe?.totalCount ?? 0,
                          children: [
                            TaskItemCard(
                              icon: Icons.work_outline,
                              iconColor: const Color(0xFF8E24AA), // Purple
                              title: 'Công việc trong ngày',
                              count: controller.assignedToMe?.inDateCount ?? 0,
                              countColor: const Color(0xFF8E24AA),
                              onTap: () {
                                // Navigate đến tab "Việc giao đến tôi" (index 1) với filter "trong ngày"
                                NavigationService.navigateWithInDateFilter(
                                  targetTab: 1, // Việc giao đến tôi
                                );
                              },
                            ),
                            TaskItemCard(
                              icon: Icons.schedule_outlined,
                              iconColor: const Color(0xFFFF9800), // Orange
                              title: 'Công việc trễ hạn',
                              count: controller.assignedToMe?.latedCount ?? 0,
                              countColor: const Color(0xFFFF9800),
                              onTap: () {
                                // Navigate đến tab "Việc giao đến tôi" (index 1) với filter "trễ hạn" và clear ngày
                                NavigationService.navigateWithStatusFilter(
                                  targetTab: 1, // Việc giao đến tôi
                                  status: 3, // Trễ hạn
                                );
                              },
                            ),
                            TaskItemCard(
                              icon: Icons.hourglass_empty_outlined,
                              iconColor: const Color(0xFF2196F3), // Blue
                              title: 'Công việc đang xử lý',
                              count: controller.assignedToMe?.doingCount ?? 0,
                              countColor: const Color(0xFF2196F3),
                              onTap: () {
                                // Navigate đến tab "Việc giao đến tôi" (index 1) với filter "đang xử lý" và clear ngày
                                NavigationService.navigateWithDoingFilter(
                                  targetTab: 1, // Việc giao đến tôi
                                );
                              },
                            ),
                          ],
                        ),

                        SizedBox(height: 12.h),

                        // Nhóm 2: Việc tôi giao
                        TaskGroupSection(
                          title: 'Việc tôi giao',
                          totalCount: controller.assignedByMe?.totalCount ?? 0,
                          children: [
                            TaskItemCard(
                              icon: Icons.work_outline,
                              iconColor: const Color(0xFF8E24AA), // Purple
                              title: 'Công việc trong ngày',
                              count: controller.assignedByMe?.inDateCount ?? 0,
                              countColor: const Color(0xFF8E24AA),
                              onTap: () {
                                // Navigate đến tab "Việc tôi giao" (index 0) với filter "trong ngày"
                                NavigationService.navigateWithInDateFilter(
                                  targetTab: 0, // Việc tôi giao
                                );
                              },
                            ),
                            TaskItemCard(
                              icon: Icons.schedule_outlined,
                              iconColor: const Color(0xFFFF9800), // Orange
                              title: 'Công việc trễ hạn',
                              count: controller.assignedByMe?.latedCount ?? 0,
                              countColor: const Color(0xFFFF9800),
                              onTap: () {
                                // Navigate đến tab "Việc tôi giao" (index 0) với filter "trễ hạn" và clear ngày
                                NavigationService.navigateWithStatusFilter(
                                  targetTab: 0, // Việc tôi giao
                                  status: 3, // Trễ hạn
                                );
                              },
                            ),
                            TaskItemCard(
                              icon: Icons.hourglass_empty_outlined,
                              iconColor: const Color(0xFF2196F3), // Blue
                              title: 'Công việc đang xử lý',
                              count: controller.assignedByMe?.doingCount ?? 0,
                              countColor: const Color(0xFF2196F3),
                              onTap: () {
                                // Navigate đến tab "Việc tôi giao" (index 0) với filter "đang xử lý" và clear ngày
                                NavigationService.navigateWithDoingFilter(
                                  targetTab: 0, // Việc tôi giao
                                );
                              },
                            ),
                          ],
                        ),

                        SizedBox(height: 12.h),

                        // Nhóm 3: Văn bản đến (giữ nguyên hardcode vì chưa có API)
                        // TaskGroupSection(
                        //   title: 'Văn bản đến',
                        //   totalCount: 0,
                        //   children: [
                        //     TaskItemCard(
                        //       icon: Icons.description_outlined,
                        //       iconColor: const Color(0xFF4CAF50), // Green
                        //       title: 'Văn bản chưa xử lý',
                        //       count: 0,
                        //       countColor: const Color(0xFF4CAF50),
                        //     ),
                        //     TaskItemCard(
                        //       icon: Icons.assignment_outlined,
                        //       iconColor: const Color(0xFF9C27B0), // Purple
                        //       title: 'Văn bản đang xử lý',
                        //       count: 0,
                        //       countColor: const Color(0xFF9C27B0),
                        //     ),
                        //     TaskItemCard(
                        //       icon: Icons.check_circle_outline,
                        //       iconColor: const Color(0xFF607D8B), // Blue Grey
                        //       title: 'Văn bản đã xử lý',
                        //       count: 0,
                        //       countColor: const Color(0xFF607D8B),
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
