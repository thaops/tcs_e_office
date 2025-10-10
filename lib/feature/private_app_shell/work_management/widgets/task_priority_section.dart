import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/create_task_controller.dart';
import '../models/task_detail_model.dart';

/// Widget cho phần chọn độ khẩn
class TaskPrioritySection extends StatelessWidget {
  const TaskPrioritySection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateTaskController>(
      builder: (c) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Độ khẩn'),
              const SizedBox(height: 6),
              // Sử dụng PopupMenuButton để đảm bảo dropdown hiển thị ở dưới
              LayoutBuilder(
                builder: (context, constraints) {
                  return PopupMenuButton<PriorityOption>(
                    initialValue: c.selectedPriority.value,
                    onSelected: (PriorityOption value) {
                      c.selectedPriority.value = value;
                    },
                    itemBuilder: (BuildContext context) {
                      return c.priorities.map((PriorityOption option) {
                        return PopupMenuItem<PriorityOption>(
                          value: option,
                          child: Container(
                            width:
                                constraints.maxWidth, // Sử dụng width của field
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              option.label,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        );
                      }).toList();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFE8E8E8),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Obx(
                              () => Text(
                                c.selectedPriority.value?.label ??
                                    'Chọn độ khẩn',
                                style: const TextStyle(
                                  color: Color(0xFF333333),
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: Color(0xFF666666),
                          ),
                        ],
                      ),
                    ),
                    // Đảm bảo popup hiển thị ở dưới và có cùng width
                    position: PopupMenuPosition.under,
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    // Đảm bảo dropdown có cùng width với field
                    constraints: BoxConstraints(
                      minWidth: constraints.maxWidth, // Sử dụng width của field
                    ),
                    offset: const Offset(0, 0), // Không offset để giữ alignment
                  );
                },
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
}
