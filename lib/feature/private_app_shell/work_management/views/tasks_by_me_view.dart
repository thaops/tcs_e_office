import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/work_management_controller.dart';
// import '../models/task_model.dart';
import '../widget/task_card_widget.dart';
import 'create_task_view.dart';
import 'package:tcs_e_office/common/constants/app_tab_types.dart';

class TasksByMeView extends StatelessWidget {
  const TasksByMeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WorkManagementController>();

    return Obx(() {
      if (controller.isLoadingByMe.value && controller.tasksByMe.isEmpty) {
        return _buildInitialLoadingState();
      }

      if (controller.filteredTasksByMe.isEmpty) {
        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: _buildEmptyState(controller),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refresh,
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            // Kiểm tra nếu scroll gần cuối danh sách (còn 200px)
            if (scrollInfo.metrics.pixels >=
                    scrollInfo.metrics.maxScrollExtent - 200 &&
                !controller.isLoadingByMe.value &&
                controller.tasksByMe.length <
                    controller.totalRecordByMe.value) {
              controller.loadMore();
            }
            return false;
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount:
                controller.filteredTasksByMe.length +
                (controller.isLoadingByMe.value ? 1 : 0),
            itemBuilder: (context, index) {
              // Hiển thị loading indicator ở cuối danh sách khi đang tải
              if (index == controller.filteredTasksByMe.length) {
                return _buildLoadingIndicator();
              }

              final task = controller.filteredTasksByMe[index];
              return TaskCardWidget(task: task, tabType: AppTabTypes.TASK_ASSIGN);
            },
          ),
        ),
      );
    });
  }

  Widget _buildEmptyState(WorkManagementController controller) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(Get.context!).size.height * 0.7,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.assignment_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Chưa có công việc nào',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bạn chưa giao công việc nào cho ai',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () async {
                  const assignerCode = '';
                  final created = await Get.to(
                    () => const CreateTaskView(assignerCode: assignerCode),
                  );
                  if (created == true) {
                    controller.loadTasksByMe(refresh: true);
                  }
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Tạo công việc mới'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C5F5F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  const Color(0xFF006884),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Đang tải thêm...',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF006884).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF006884)),
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Đang tải danh sách công việc...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vui lòng chờ trong giây lát',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

// Đã thay bằng widget TaskCard chung từ ../widget/task_card_widget.dart
