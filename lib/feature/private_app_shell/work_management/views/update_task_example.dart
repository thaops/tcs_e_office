import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'update_task_view.dart';

/// Example usage của UpdateTaskView
/// Để sử dụng màn hình update task:
///
/// ```dart
/// Get.to(() => UpdateTaskView(
///   assignerCode: '9999', // Mã người giao việc
///   taskId: '1bf3c7b2-47a2-4656-9465-a8e8e4ea24b8', // ID task cần update
///   documentId: 'optional-document-id', // Optional
/// ));
/// ```
class UpdateTaskExample extends StatelessWidget {
  const UpdateTaskExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Task Example')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Example: Navigate to update task screen
            Get.to(
              () => UpdateTaskView(
                assignerCode: '9999', // Mã người giao việc
                taskId:
                    '1bf3c7b2-47a2-4656-9465-a8e8e4ea24b8', // ID task cần update
                documentId: 'optional-document-id', // Optional
              ),
            );
          },
          child: const Text('Mở màn hình cập nhật task'),
        ),
      ),
    );
  }
}
