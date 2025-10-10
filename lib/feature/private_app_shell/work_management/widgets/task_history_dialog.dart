import 'package:flutter/material.dart';
import '../models/task_detail_model.dart';

class TaskHistoryDialog extends StatelessWidget {
  final List<TaskHistory> histories;

  const TaskHistoryDialog({super.key, required this.histories});

  static void show(BuildContext context, List<TaskHistory> histories) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => TaskHistoryDialog(histories: histories),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.only(top: 12, bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Center(
                  child: Text(
                    'Tiến trình xử lý',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF006884),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF424242)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE0E0E0)),

          // Timeline list
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _TimelineList(items: histories),
            ),
          ),

          const SizedBox(height: 8),

          // Footer button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFE0E0E0)),
                foregroundColor: const Color(0xFF006884),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 24,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Đóng'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineList extends StatelessWidget {
  final List<TaskHistory> items;
  const _TimelineList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(items.length, (index) {
        final item = items[index];
        final bool isLast = index == items.length - 1;
        final bool isCurrent = index == isLast; // bước hiện tại cuối danh sách
        final Color dotColor =
            isCurrent ? const Color(0xFFBDBDBD) : const Color(0xFF006884);
        return _TimelineTile(
          actor: item.actor,
          department: item.actorDepartment,
          statusText: _statusText(item),
          dateText: _dateOnly(item.actionDate),
          dotColor: dotColor,
          showConnector: !isLast,
        );
      }),
    );
  }

  String _statusText(TaskHistory h) {
    switch (h.actionCode) {
      case 'Create':
        return 'Tạo công việc';
      case 'Update':
        return 'Cập nhật';
      case 'Forward':
        return 'Được chuyển giao';
      case 'Forwarded':
        return 'Chuyển giao';
      default:
        return h.action;
    }
  }

  String _dateOnly(String iso) {
    try {
      final d = DateTime.parse(iso);
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (_) {
      return iso;
    }
  }
}

class _TimelineTile extends StatelessWidget {
  final String actor;
  final String department;
  final String statusText;
  final String dateText;
  final Color dotColor;
  final bool showConnector;

  const _TimelineTile({
    required this.actor,
    required this.department,
    required this.statusText,
    required this.dateText,
    required this.dotColor,
    required this.showConnector,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline axis
        Column(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            if (showConnector)
              Container(
                width: 2,
                height: 56,
                margin: const EdgeInsets.symmetric(vertical: 6),
                color: const Color(0xFFE0E0E0),
              ),
          ],
        ),
        const SizedBox(width: 12),

        // Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF212121),
                    ),
                    children: [
                      TextSpan(
                        text: actor,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const TextSpan(text: '  '),
                      TextSpan(
                        text: department,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF757575),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusText,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF424242),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateText,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
