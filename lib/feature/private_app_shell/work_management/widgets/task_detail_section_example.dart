import 'package:flutter/material.dart';
import 'task_detail_section.dart';

/// Example usage of TaskDetailSection for different parts of task detail
class TaskDetailSectionExample extends StatelessWidget {
  const TaskDetailSectionExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Example: Attachments section
        TaskDetailSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tài liệu đính kèm',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF006884),
                ),
              ),
              const SizedBox(height: 8),
              const Text('Không có tài liệu đính kèm'),
            ],
          ),
        ),

        // Example: Content section
        TaskDetailSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nội dung công việc',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF006884),
                ),
              ),
              const SizedBox(height: 8),
              const Text('Nội dung chi tiết của công việc...'),
            ],
          ),
        ),

        // Example: Comments section
        TaskDetailSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bình luận',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF006884),
                ),
              ),
              const SizedBox(height: 8),
              const Text('Chưa có bình luận nào'),
            ],
          ),
        ),

        // Example: Assignees section
        TaskDetailSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Người thực hiện',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF006884),
                ),
              ),
              const SizedBox(height: 8),
              const Text('Danh sách người thực hiện...'),
            ],
          ),
        ),
      ],
    );
  }
}
