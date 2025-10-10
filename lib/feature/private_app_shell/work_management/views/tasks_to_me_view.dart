import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/work_management_controller.dart';
// import '../models/task_model.dart';
import '../widget/task_card_widget.dart';

// Hằng số style\

// Hằng số decoration

class TasksToMeView extends StatelessWidget {
  const TasksToMeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WorkManagementController>();

    return Obx(() {
      if (controller.isLoadingToMe.value && controller.tasksToMe.isEmpty) {
        return _buildInitialLoadingState();
      }

      if (controller.filteredTasksToMe.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        onRefresh: controller.refresh,
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            // Kiểm tra nếu scroll gần cuối danh sách (còn 200px)
            if (scrollInfo.metrics.pixels >=
                    scrollInfo.metrics.maxScrollExtent - 200 &&
                !controller.isLoadingToMe.value &&
                controller.tasksToMe.length <
                    controller.totalRecordToMe.value) {
              controller.loadMore();
            }
            return false;
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount:
                controller.filteredTasksToMe.length +
                (controller.isLoadingToMe.value ? 1 : 0),
            itemBuilder: (context, index) {
              // Hiển thị loading indicator ở cuối danh sách khi đang tải
              if (index == controller.filteredTasksToMe.length) {
                return _buildLoadingIndicator();
              }

              final task = controller.filteredTasksToMe[index];
              return TaskCardWidget(task: task, tabType: 'assigned_to_me');
            },
          ),
        ),
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
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
              Icons.assignment_turned_in_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Chưa có công việc nào được giao',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Chưa có ai giao công việc cho bạn',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
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
