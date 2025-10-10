import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

/// Example widget để test Task Count API
class TestTaskCountApi extends StatelessWidget {
  const TestTaskCountApi({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());

    return Scaffold(
      appBar: AppBar(title: const Text('Test Task Count API')),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  controller.error ?? 'Có lỗi xảy ra',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.refresh(),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        final taskCount = controller.taskCount;
        if (taskCount == null) {
          return const Center(child: Text('Không có dữ liệu'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Assigned To Me
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Việc giao đến tôi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Tổng: ${taskCount.assignedToMe.totalCount}'),
                      Text('Đang xử lý: ${taskCount.assignedToMe.doingCount}'),
                      Text('Trong ngày: ${taskCount.assignedToMe.inDateCount}'),
                      Text('Trễ hạn: ${taskCount.assignedToMe.latedCount}'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Assigned By Me
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Việc tôi giao',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Tổng: ${taskCount.assignedByMe.totalCount}'),
                      Text('Đang xử lý: ${taskCount.assignedByMe.doingCount}'),
                      Text('Trong ngày: ${taskCount.assignedByMe.inDateCount}'),
                      Text('Trễ hạn: ${taskCount.assignedByMe.latedCount}'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Refresh button
              Center(
                child: ElevatedButton(
                  onPressed: () => controller.refresh(),
                  child: const Text('Refresh Data'),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
