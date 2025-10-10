import 'package:flutter/material.dart';
import 'package:tcs_e_office/core/configs/theme/app_colors.dart';
import 'package:tcs_e_office/common/utils/task_utils.dart';
import 'package:tcs_e_office/common/widgets/enhanced_text_widget.dart';
import '../models/task_model.dart';
import '../views/task_detail_view.dart';
import '../widgets/task_chip.dart';

class TaskCardStyles {
  static TextStyle get taskTitle =>
      AppTextStyles.bodyLarge.copyWith(color: AppColors.primary, height: 1.3);

  static TextStyle get taskDescription => AppTextStyles.bodyMedium.copyWith(
    color: AppColors.colorBacklog,
    height: 1.4,
  );

  static TextStyle get infoLabel => AppTextStyles.labelMedium.copyWith(
    color: AppColors.colorBacklog,
    fontWeight: FontWeight.w400,
  );

  static TextStyle get infoValue => AppTextStyles.labelMedium.copyWith(
    color: AppColors.colorBacklog,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get footerText =>
      AppTextStyles.caption.copyWith(color: AppColors.colorBacklog);
}

class AppDecorations {
  static final cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: AppColors.bacgroundApp, width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static final innerDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(8),
    border: Border(left: BorderSide(color: AppColors.primary, width: 3)),
  );
}

class TaskCardWidget extends StatelessWidget {
  final TaskModel task;
  final String? tabType; // 'assigned_by_me' hoặc 'assigned_to_me'

  const TaskCardWidget({super.key, required this.task, this.tabType});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppDecorations.cardDecoration,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => TaskDetailView(taskId: task.id, tabType: tabType),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: AppDecorations.innerDecoration,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTaskTitle(),
                if (task.note.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildTaskDescription(),
                ],
                const SizedBox(height: 5),

                Divider(color: AppColors.colorBacklog),
                const SizedBox(height: 5),

                _buildTaskInfo(),
                const SizedBox(height: 14),
                _buildStatusAndPriority(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskTitle() {
    return Text(
      task.taskName,
      style: TaskCardStyles.taskTitle,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTaskDescription() {
    return Text(
      task.note,
      style: TaskCardStyles.taskDescription,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTaskInfo() {
    return Column(
      children: [
        _buildInfoRow(Icons.person_outline, 'Người giao: ', task.creator),
        const SizedBox(height: 4),
        if (task.roleName.isNotEmpty)
          _buildInfoRow(Icons.person_outline, 'Vai trò xử lý: ', task.roleName),
        const SizedBox(height: 4),
        _buildInfoRow(
          Icons.calendar_today_outlined,
          'Ngày đến hạn: ',
          TaskUtils.formatTaskDate(task.dueDate),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.colorBacklog),
        const SizedBox(width: 8),
        Text(label, style: TaskCardStyles.infoLabel),
        Text(value, style: TaskCardStyles.infoValue),
      ],
    );
  }

  Widget _buildStatusAndPriority() {
    return Row(
      children: [
        TaskChip(
          label: task.statusName,
          value: task.status.toString(),
          type: TaskChipType.status,
        ),
        const SizedBox(width: 8),
        TaskChip(
          label: task.priorityName,
          value: task.priority.toString(),
          type: TaskChipType.priority,
        ),
        const Spacer(),
        _buildFooter(),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildFooterIcon(
          Icons.attach_file_outlined,
          task.totalAttachment.toString(),
        ),
        const SizedBox(width: 16),
        _buildFooterIcon(Icons.comment_outlined, task.totalComment.toString()),
      ],
    );
  }

  Widget _buildFooterIcon(IconData icon, String count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(count, style: TaskCardStyles.footerText),
      ],
    );
  }
}
