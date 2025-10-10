import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/create_task_controller.dart';
import 'task_form_section.dart';
import 'html_content_editor.dart';

/// Widget cho phần tên và nội dung công việc
class TaskTitleSection extends StatelessWidget {
  const TaskTitleSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateTaskController>(
      builder: (c) {
        return TaskFormSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _labelRequired('Tên công việc'),
              const SizedBox(height: 6),
              TextField(
                controller: c.titleController,
                decoration: _inputDecoration().copyWith(
                  hintText: 'Nhập tên công việc',
                ),
              ),
              // Hiển thị thông báo lỗi từ server
              Obx(() {
                if (c.error.value.isNotEmpty &&
                    c.error.value.contains('Tên việc')) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      c.error.value,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
              const SizedBox(height: 6),
              _labelRequired('Nội dung công việc'),
              const SizedBox(height: 6),
              HtmlContentEditor(
                initialContent: c.contentController.text,
                hintText: 'Nhập nội dung công việc',
                height: 200,
                contentController: c.contentController,
                onFocus: () {
                  // Khi HTML editor được focus, scroll để đảm bảo title vẫn visible
                  // Không cần làm gì đặc biệt vì đã tắt auto adjust
                },
              ),
              // Hiển thị thông báo lỗi từ server cho nội dung
              Obx(() {
                if (c.error.value.isNotEmpty &&
                    (c.error.value.contains('Nội dung') ||
                        c.error.value.contains('công việc'))) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      c.error.value,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _labelRequired(String text) {
    return Row(
      children: [
        Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
        const Text(' *', style: TextStyle(color: Colors.red)),
      ],
    );
  }

  InputDecoration _inputDecoration() {
    return const InputDecoration(
      filled: false,
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF006884)),
      ),
    );
  }
}
