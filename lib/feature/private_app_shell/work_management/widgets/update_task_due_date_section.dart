import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/update_task_controller.dart';

/// Widget cho phần ngày bắt đầu và hết hạn (Update version)
class UpdateTaskDueDateSection extends StatelessWidget {
  const UpdateTaskDueDateSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UpdateTaskController>(
      builder: (c) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
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
