import 'package:flutter/material.dart';
import '../models/task_detail_model.dart';
import 'task_chip.dart';
import 'task_container.dart';

class TaskHeaderCard extends StatelessWidget {
  final TaskDetailModel detail;

  const TaskHeaderCard({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12), // Giảm margin
      child: TaskContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            // Task title với spacing tốt hơn
            Text(
              detail.taskName,
              style: const TextStyle(
                fontSize: 16, // Tăng lại để title nổi bật
                fontWeight: FontWeight.w600,
                color: Color(0xFF006884),
                height: 1.3, // Line height
              ),
            ),
            const SizedBox(height: 8), // Tăng spacing
            // Chips row với spacing tốt hơn
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
            const SizedBox(height: 12), // Tăng spacing
            // Info section với background nhạt
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFE8E8E8), width: 0.5),
              ),
              child: Column(
                children: [
                  _iconText(
                    Icons.person_outline,
                    'Người giao việc: ${detail.assignerName}',
                  ),
                  const SizedBox(height: 8),
                  _iconText(
                    Icons.calendar_month_rounded,
                    'Ngày giao việc: ${_formatDate(detail.startDate)}',
                  ),
                  const SizedBox(height: 8),
                  _iconText(
                    Icons.calendar_month_rounded,
                    'Ngày đến hạn: ${_formatDate(detail.dueDate)}',
                  ),
                ],
              ),
            ),

            // Note section nếu có
            if (detail.note.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: const Color(0xFFE8E8E8),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.note_outlined,
                      size: 16,
                      color: const Color(0xFF757575),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        detail.note,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF666666),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _iconText(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F4F8),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(icon, size: 12, color: const Color(0xFF006884)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF333333),
              fontWeight: FontWeight.w500,
            ),
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
