import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'update_task_view.dart';

/// Test screen để kiểm tra update task functionality
class TestUpdateTask extends StatelessWidget {
  const TestUpdateTask({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Update Task'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Test Update Task Functionality',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Test với task ID thực tế
                Get.to(
                  () => UpdateTaskView(
                    assignerCode: '9999',
                    taskId: '1bf3c7b2-47a2-4656-9465-a8e8e4ea24b8',
                    documentId: 'test-document-id',
                  ),
                );
              },
              child: const Text('Test Update Task'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Nếu click vào nút này không hoạt động, có thể có vấn đề với:',
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              '1. API endpoint không đúng\n'
              '2. Controller không được khởi tạo đúng\n'
              '3. Navigation không hoạt động\n'
              '4. Form không được populate',
              style: TextStyle(fontSize: 12, color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
