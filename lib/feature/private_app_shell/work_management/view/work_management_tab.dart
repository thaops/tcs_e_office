import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/work_management_controller.dart';
import 'package:tcs_e_office/core/configs/theme/app_colors.dart';
import '../views/tasks_by_me_view.dart';
import '../views/create_task_view.dart';
import '../views/tasks_to_me_view.dart';
import '../widgets/filter_bottom_sheet.dart';

class WorkManagementTab extends StatefulWidget {
  const WorkManagementTab({super.key});

  @override
  State<WorkManagementTab> createState() => _WorkManagementTabState();
}

class _WorkManagementTabState extends State<WorkManagementTab>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late WorkManagementController _controller;
  StreamSubscription? _tabSubscription;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(WorkManagementController());
    _tabController = TabController(length: 2, vsync: this);

    // Lắng nghe thay đổi tab từ controller
    _tabSubscription = _controller.currentTab.listen((index) {
      if (mounted && _tabController.index != index) {
        _tabController.animateTo(index);
      }
    });

    // Lắng nghe thay đổi tab từ TabController
    _tabController.addListener(() {
      if (mounted && _controller.currentTab.value != _tabController.index) {
        _controller.changeTab(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabSubscription?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  // Hiển thị bottom sheet filter
  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        currentFilter: _controller.getCurrentFilter(),
        onApplyFilter: (filter) {
          _controller.applyFilter(filter);
        },
        onResetFilter: () {
          _controller.resetFilter();
        },
        currentTab: _controller.currentTab.value,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        automaticallyImplyLeading: false, // Không có back button
        title: Text(
          'Quản lý công việc',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            width: 24.w,
            height: 24.h,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(width: 1, color: AppColors.bacgroundApp),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () async {
                // TODO: lấy assignerCode từ profile nếu có
                const assignerCode = '';
                await Get.to(
                  () => const CreateTaskView(assignerCode: assignerCode),
                );
                // Sau khi tạo xong, refresh tab "Việc tôi giao"
                _controller.loadTasksByMe(refresh: true);
              },
              icon: const Icon(Icons.add, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          // Ẩn bàn phím khi click bất kỳ đâu
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: [
            // Tab bar với Material Design underline
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.grey.shade600,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(width: 3, color: AppColors.primary),
                  insets: const EdgeInsets.symmetric(horizontal: 16),
                ),
                indicatorSize: TabBarIndicatorSize.label,
                dividerColor: Colors.transparent,
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_outlined, size: 20),
                        const SizedBox(width: 8),
                        const Text('Việc tôi giao'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_turned_in_outlined, size: 20),
                        const SizedBox(width: 8),
                        const Text('Việc giao đến tôi'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Search bar với Material 3 design - tối ưu kích thước
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.shadow.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // TextField với thiết kế mới - Search riêng cho từng tab
                  Expanded(
                    child: Obx(() {
                      // Xác định controller và search query dựa trên tab hiện tại
                      final isTabByMe = _controller.currentTab.value == 0;
                      final searchQuery = isTabByMe
                          ? _controller.searchQueryByMe.value
                          : _controller.searchQueryToMe.value;
                      final isLoading = isTabByMe
                          ? _controller.isLoadingByMe.value
                          : _controller.isLoadingToMe.value;
                      final searchController = isTabByMe
                          ? _controller.searchControllerByMe
                          : _controller.searchControllerToMe;
                      final onSearchChanged = isTabByMe
                          ? _controller.onSearchChangedByMe
                          : _controller.onSearchChangedToMe;
                      final clearSearch = isTabByMe
                          ? _controller.clearSearchByMe
                          : _controller.clearSearchToMe;

                      return TextField(
                        controller: searchController,
                        onChanged: onSearchChanged,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Nhập tên công việc…',
                          hintStyle: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                          prefixIcon: searchQuery.isNotEmpty && isLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.search,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                  size: 18,
                                ),
                          suffixIcon: searchQuery.isNotEmpty && !isLoading
                              ? IconButton(
                                  onPressed: clearSearch,
                                  icon: Icon(
                                    Icons.clear,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                    size: 18,
                                  ),
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                              width: 0.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                              width: 0.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 1,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(width: 8),
                  // Icon filter với Material 3 design - tối ưu kích thước
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 0.5,
                      ),
                    ),
                    child: Obx(
                      () => IconButton(
                        onPressed: _showFilterBottomSheet,
                        icon: Icon(
                          Icons.filter_list,
                          color: _controller.getCurrentFilter().hasActiveFilter
                              ? AppColors.primary
                              : AppColors.black,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tab content với Material 3 background
            Expanded(
              child: Container(
                color: Colors.white,
                child: TabBarView(
                  controller: _tabController,
                  children: const [TasksByMeView(), TasksToMeView()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
