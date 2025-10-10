import 'package:flutter/material.dart';
import 'package:tcs_e_office/core/configs/theme/app_colors.dart';
import '../models/task_detail_model.dart';
import 'task_chip.dart';
import 'task_container.dart';

class TaskHeaderCard extends StatelessWidget {
  final TaskDetailModel detail;

  const TaskHeaderCard({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TaskContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              detail.taskName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF006884),
              ),
            ),
            const SizedBox(height: 6),
            Divider(color: AppColors.colorBacklog),
            const SizedBox(height: 6),
            Row(
              children: [
                TaskChip(
                  label: _getStatusText(detail.status),
                  value: detail.status.toString(),
                  type: TaskChipType.status,
                ),
                const SizedBox(width: 8),
                TaskChip(
                  label: _getPriorityText(detail.priority),
                  value: detail.priority.toString(),
                  type: TaskChipType.priority,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _iconText(
              Icons.person_outline,
              'Người giao việc: ${detail.assignerName}',
            ),
            const SizedBox(height: 6),
            _iconText(
              Icons.calendar_today_outlined,
              'Ngày giao việc: ${_formatDate(detail.startDate)}',
            ),
            const SizedBox(height: 6),
            _iconText(
              Icons.access_time,
              'Ngày đến hạn: ${_formatDate(detail.dueDate)}',
            ),
            if (detail.note.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                detail.note,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _iconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF757575)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Color(0xFF757575)),
          ),
        ),
      ],
    );
  }

  String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (_) {
      return iso;
    }
  }

  /// Convert status int to display text
  String _getStatusText(int status) {
    switch (status) {
      case 1:
        return 'Đang xử lý';
      case 2:
        return 'Hoàn thành';
      case 3:
        return 'Quá hạn';
      default:
        return 'Đang xử lý';
    }
  }

  /// Convert priority int to display text
  String _getPriorityText(int priority) {
    switch (priority) {
      case 0:
        return 'Khẩn cấp';
      case 1:
        return 'Ưu tiên cao';
      case 2:
        return 'Trung bình';
      case 3:
        return 'Bình thường';
      case 4:
        return 'Thấp';
      case 5:
        return 'Khẩn cấp';
      default:
        return 'Bình thường';
    }
  }
}
