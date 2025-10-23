import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/update_task_controller.dart';
import 'html_content_editor.dart';

/// Widget cho phần tên và nội dung công việc (Update version)
class UpdateTaskTitleSection extends StatelessWidget {
  const UpdateTaskTitleSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UpdateTaskController>(
      builder: (c) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
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
              // Sử dụng GetBuilder để rebuild khi controller update
              GetBuilder<UpdateTaskController>(
                id: 'html_content_editor', // ID để trigger rebuild cụ thể
                builder: (c) => HtmlContentEditor(
                  key: ValueKey(
                    'html_editor_${c.contentController.text.hashCode}',
                  ), // Force rebuild khi content thay đổi
                  initialContent: c.contentController.text,
                  hintText: 'Nhập nội dung công việc',
                  height: 200,
                  contentController: c.contentController,
                  showToolbar: false, // Tắt toolbar
                  onFocus: () {
                    // Khi HTML editor được focus, scroll để đảm bảo title vẫn visible
                    // Không cần làm gì đặc biệt vì đã tắt auto adjust
                  },
                ),
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
      filled: true,
      fillColor: Color(0xFFFAFAFA),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: Color(0xFFE8E8E8), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: Color(0xFFE8E8E8), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: Color(0xFF006884), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }
}
