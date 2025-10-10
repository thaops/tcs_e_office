import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/update_task_controller.dart';
import 'task_form_section.dart';
import 'html_content_editor.dart';

/// Widget cho phần tên và nội dung công việc (Update version)
class UpdateTaskTitleSection extends StatelessWidget {
  const UpdateTaskTitleSection({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<UpdateTaskController>();

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
                c.error.value.contains('Nội dung')) {
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
  }

  Widget _labelRequired(String text) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        children: const [
          TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.blue),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }
}
