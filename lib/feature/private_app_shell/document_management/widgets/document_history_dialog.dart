import 'package:flutter/material.dart';
import '../models/document_detail_model.dart';

class DocumentHistoryDialog extends StatelessWidget {
  final List<WorkflowModel>? workflows;
  final List<HistoryModel>? histories;
  final String? tabType; // 'incoming' hoặc 'outgoing'

  const DocumentHistoryDialog({
    super.key,
    this.workflows,
    this.histories,
    this.tabType,
  });

  static void show(
    BuildContext context,
    List<WorkflowModel> workflows, {
    String? tabType,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) =>
          DocumentHistoryDialog(workflows: workflows, tabType: tabType),
    );
  }

  static void showHistories(
    BuildContext context,
    List<HistoryModel> histories, {
    String? tabType,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) =>
          DocumentHistoryDialog(histories: histories, tabType: tabType),
    );
  }

  String _getTitle() {
    // Nếu là văn bản đi thì hiển thị "Tiến trình phê duyệt"
    // Nếu là văn bản đến thì hiển thị "Lịch sử cập nhật"
    if (tabType == 'outgoing') {
      return 'Tiến trình phê duyệt';
    }
    return 'Lịch sử cập nhật';
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
                Center(
                  child: Text(
                    _getTitle(),
                    style: const TextStyle(
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
              child: workflows != null && workflows!.isNotEmpty
                  ? _TimelineList(items: workflows!)
                  : histories != null && histories!.isNotEmpty
                  ? _HistoryTimelineList(items: histories!)
                  : const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text(
                          'Không có lịch sử cập nhật',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF9E9E9E),
                          ),
                        ),
                      ),
                    ),
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

class _HistoryTimelineList extends StatelessWidget {
  final List<HistoryModel> items;
  const _HistoryTimelineList({required this.items});

  @override
  Widget build(BuildContext context) {
    // Sắp xếp histories theo actionDate (mới nhất trước)
    final sortedItems = List<HistoryModel>.from(items)
      ..sort((a, b) {
        try {
          final dateA = DateTime.parse(a.actionDate);
          final dateB = DateTime.parse(b.actionDate);
          return dateB.compareTo(dateA);
        } catch (_) {
          return 0;
        }
      });

    return Column(
      children: List.generate(sortedItems.length, (index) {
        final item = sortedItems[index];
        final bool isLast = index == sortedItems.length - 1;

        return _HistoryTimelineTile(
          actor: item.actor,
          department: item.actorDepartment,
          action: item.action,
          dateText: _getDateText(item),
          note: item.note,
          showConnector: !isLast,
        );
      }),
    );
  }

  String _getDateText(HistoryModel history) {
    return _formatDateTime(history.actionDate);
  }

  String _formatDateTime(String iso) {
    try {
      final d = DateTime.parse(iso);
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }
}

class _HistoryTimelineTile extends StatelessWidget {
  final String actor;
  final String department;
  final String action;
  final String dateText;
  final String? note;
  final bool showConnector;

  const _HistoryTimelineTile({
    required this.actor,
    required this.department,
    required this.action,
    required this.dateText,
    this.note,
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
              decoration: const BoxDecoration(
                color: Color(0xFF006884),
                shape: BoxShape.circle,
              ),
            ),
            if (showConnector)
              Container(
                width: 2,
                height: note != null && note!.isNotEmpty ? 80 : 56,
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
                  action,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF424242),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (note != null && note!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    note!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF757575),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
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

class _TimelineList extends StatelessWidget {
  final List<WorkflowModel> items;
  const _TimelineList({required this.items});

  @override
  Widget build(BuildContext context) {
    // Sắp xếp workflows theo step
    final sortedItems = List<WorkflowModel>.from(items)
      ..sort((a, b) => a.step.compareTo(b.step));

    return Column(
      children: List.generate(sortedItems.length, (index) {
        final item = sortedItems[index];
        final bool isLast = index == sortedItems.length - 1;
        // Workflow hiện tại là step đã hoàn thành (isCompleted = true hoặc status = 1)
        final bool isCurrent = item.isCompleted || item.status == 1;
        final Color dotColor = isCurrent
            ? const Color(0xFF006884)
            : const Color(0xFFBDBDBD);

        return _TimelineTile(
          actor: item.name,
          department: item.jobTitle,
          statusText: _statusText(item),
          dateText: _getDateText(item),
          dotColor: dotColor,
          showConnector: !isLast,
        );
      }),
    );
  }

  String _statusText(WorkflowModel workflow) {
    if (workflow.isCompleted) {
      return 'Đã xử lý';
    } else if (workflow.status == 1) {
      return 'Đang xử lý';
    } else {
      return 'Chờ xử lý';
    }
  }

  String _getDateText(WorkflowModel workflow) {
    // Ưu tiên actionDate, nếu không có thì dùng createdDate
    final dateString = workflow.actionDate.isNotEmpty
        ? workflow.actionDate
        : workflow.createdDate;

    return _dateOnly(dateString);
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
