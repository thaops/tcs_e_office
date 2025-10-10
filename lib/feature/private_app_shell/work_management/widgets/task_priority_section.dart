import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/create_task_controller.dart';
import '../models/task_detail_model.dart';
import 'task_form_section.dart';

/// Widget cho phần chọn độ khẩn
class TaskPrioritySection extends StatelessWidget {
  const TaskPrioritySection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateTaskController>(
      builder: (c) {
        return TaskFormSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Độ khẩn'),
              const SizedBox(height: 6),
              DropdownButtonFormField<PriorityOption>(
                value: c.selectedPriority.value,
                items:
                    c.priorities
                        .map(
                          (e) =>
                              DropdownMenuItem(value: e, child: Text(e.label)),
                        )
                        .toList(),
                onChanged: (v) => c.selectedPriority.value = v,
                decoration: _inputDecoration(),
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
}
