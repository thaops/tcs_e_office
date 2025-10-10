import 'package:flutter/material.dart';
import 'package:tcs_e_office/core/configs/theme/app_colors.dart';
import 'task_container.dart';

/// Reusable widget for task detail sections
class TaskDetailSection extends StatelessWidget {
  final Widget child;
  final bool showDivider;
  final EdgeInsets? padding;

  const TaskDetailSection({
    super.key,
    required this.child,
    this.showDivider = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16), // Giảm margin từ 16 xuống 12
      child: TaskContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            child,
            if (showDivider) ...[
              const SizedBox(height: 4), // Giảm spacing
              Divider(
                color: AppColors.colorBacklog,
                height: 1,
              ), // Giảm height divider
            ],
          ],
        ),
      ),
    );
  }
}
