import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/update_task_controller.dart';
import '../models/task_detail_model.dart';
import 'task_form_section.dart';

/// Widget cho phần ưu tiên (Update version)
class UpdateTaskPrioritySection extends StatelessWidget {
  const UpdateTaskPrioritySection({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<UpdateTaskController>();

    return TaskFormSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _labelRequired('Mức độ ưu tiên'),
          const SizedBox(height: 6),
          Obx(() => _priorityDropdown(c)),
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

  Widget _priorityDropdown(UpdateTaskController c) {
    if (c.priorities.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text('Đang tải...', style: TextStyle(color: Colors.grey)),
      );
    }

    return DropdownButtonFormField<PriorityOption>(
      value: c.selectedPriority.value,
      decoration: _inputDecoration(),
      hint: const Text('Chọn mức độ ưu tiên'),
      items:
          c.priorities.map((priority) {
            return DropdownMenuItem<PriorityOption>(
              value: priority,
              child: Text(priority.label),
            );
          }).toList(),
      onChanged: (PriorityOption? newValue) {
        c.selectedPriority.value = newValue;
      },
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
