import 'package:flutter/material.dart';
import 'package:tcs_e_office/common/utils/task_utils.dart';

/// Reusable chip widget for task status and priority
class TaskChip extends StatelessWidget {
  final String label;
  final String value;
  final TaskChipType type;

  const TaskChip({
    super.key,
    required this.label,
    required this.value,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final backgroundColor = _getBackgroundColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getColor() {
    switch (type) {
      case TaskChipType.status:
        return TaskUtils.getStatusColor(value);
      case TaskChipType.priority:
        return TaskUtils.getPriorityColor(value);
    }
  }

  Color _getBackgroundColor() {
    switch (type) {
      case TaskChipType.status:
        return TaskUtils.getStatusBackgroundColor(value);
      case TaskChipType.priority:
        return TaskUtils.getPriorityBackgroundColor(value);
    }
  }
}

enum TaskChipType { status, priority }
