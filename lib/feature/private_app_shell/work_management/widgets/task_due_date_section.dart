import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/create_task_controller.dart';
import 'task_form_section.dart';

/// Widget cho phần chọn ngày hết hạn
class TaskDueDateSection extends StatelessWidget {
  const TaskDueDateSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateTaskController>(
      builder: (c) {
        return TaskFormSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Ngày hết hạn'),
              const SizedBox(height: 6),
              InkWell(
                onTap: () async {
                  final now = DateTime.now();
                  final startDate = c.startDate.value ?? now;

                  final picked = await showDatePicker(
                    context: context,
                    initialDate: c.dueDate.value ?? now,
                    firstDate: startDate, // Ngày hết hạn phải >= ngày bắt đầu
                    lastDate: DateTime(now.year + 3),
                  );
                  if (picked != null) c.dueDate.value = picked;
                },
                child: Obx(
                  () => InputDecorator(
                    decoration: _inputDecoration().copyWith(
                      suffixIcon: const Icon(Icons.calendar_today_outlined),
                    ),
                    child: Text(
                      _formatDateWithPlaceholder(
                        c.dueDate.value,
                        placeholder: 'Chọn ngày hết hạn xử lý công việc',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _label(String text) {
    return Text(text, style: const TextStyle(fontWeight: FontWeight.w600));
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

  String _formatDate(DateTime? d) {
    if (d == null) return 'Ngày bắt đầu hạn dự kiến';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  String _formatDateWithPlaceholder(
    DateTime? d, {
    required String placeholder,
  }) {
    if (d == null) return placeholder;
    return _formatDate(d);
  }
}
