import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/update_task_controller.dart';
import 'task_form_section.dart';

/// Widget cho phần ngày bắt đầu và hết hạn (Update version)
class UpdateTaskDueDateSection extends StatelessWidget {
  const UpdateTaskDueDateSection({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<UpdateTaskController>();

    return TaskFormSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _labelRequired('Ngày bắt đầu'),
          const SizedBox(height: 6),
          Obx(
            () => _dateField(
              context,
              'Chọn ngày bắt đầu',
              c.startDate.value,
              (date) => c.startDate.value = date,
              isDueDate: false,
            ),
          ),
          const SizedBox(height: 16),
          _labelRequired('Ngày hết hạn'),
          const SizedBox(height: 6),
          Obx(
            () => _dateField(
              context,
              'Chọn ngày hết hạn',
              c.dueDate.value,
              (date) => c.dueDate.value = date,
              isDueDate: true,
            ),
          ),
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

  Widget _dateField(
    BuildContext context,
    String hintText,
    DateTime? value,
    Function(DateTime?) onChanged, {
    bool isDueDate = false,
  }) {
    return InkWell(
      onTap: () => _selectDate(context, value, onChanged, isDueDate: isDueDate),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value != null
                    ? '${value.day}/${value.month}/${value.year}'
                    : hintText,
                style: TextStyle(
                  color: value != null ? Colors.black87 : Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    DateTime? initialDate,
    Function(DateTime?) onChanged, {
    bool isDueDate = false,
  }) async {
    final c = Get.find<UpdateTaskController>();

    // Xác định firstDate dựa trên loại ngày
    DateTime firstDate;
    if (isDueDate) {
      // Nếu chọn ngày hết hạn, firstDate phải >= ngày bắt đầu
      firstDate = c.startDate.value ?? DateTime.now();
    } else {
      // Nếu chọn ngày bắt đầu, có thể chọn từ 1 năm trước
      firstDate = DateTime.now().subtract(const Duration(days: 365));
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != initialDate) {
      onChanged(picked);
    }
  }
}
