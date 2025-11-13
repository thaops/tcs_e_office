import 'package:flutter/material.dart';
import '../models/document_detail_model.dart';
import 'package:tcs_e_office/common/constants/app_tab_types.dart';

class _GroupedHistoryAction {
  final String actionCode;
  final String action;
  final String actionDate;

  _GroupedHistoryAction({
    required this.actionCode,
    required this.action,
    required this.actionDate,
  });
}

class DocumentHistoryDialog extends StatelessWidget {
  final List<WorkflowModel>? workflows;
  final List<HistoryModel>? histories;
  final String? tabType;

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
    List<HistoryModel>? histories,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => DocumentHistoryDialog(
        workflows: workflows,
        histories: histories,
        tabType: tabType,
      ),
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
    if (tabType == AppTabTypes.DOCUMENT_OUT) {
      return 'Tiến trình phê duyệt';
    }
    return 'Lịch sử cập nhật';
  }

  List<WorkflowModel> _getMergedWorkflows() {
    if (workflows == null || workflows!.isEmpty) {
      return [];
    }

    final mergedWorkflows = List<WorkflowModel>.from(workflows!);

    if (tabType == AppTabTypes.DOCUMENT_OUT &&
        histories != null &&
        histories!.isNotEmpty) {
      final filteredHistories = histories!
          .where((h) => h.actionCode == 'Create' || h.actionCode == 'Submit')
          .toList();

      if (filteredHistories.isNotEmpty) {
        final groupedByActor = <String, List<HistoryModel>>{};
        for (final history in filteredHistories) {
          final key = history.actor;
          if (!groupedByActor.containsKey(key)) {
            groupedByActor[key] = [];
          }
          groupedByActor[key]!.add(history);
        }

        final historyWorkflows = <WorkflowModel>[];
        for (final entry in groupedByActor.entries) {
          final actorHistories = entry.value;
          actorHistories.sort((a, b) {
            try {
              final dateA = DateTime.parse(a.actionDate);
              final dateB = DateTime.parse(b.actionDate);
              return dateA.compareTo(dateB);
            } catch (_) {
              return 0;
            }
          });

          final hasCreate = actorHistories.any((h) => h.actionCode == 'Create');
          final hasSubmit = actorHistories.any((h) => h.actionCode == 'Submit');

          if (hasCreate && hasSubmit) {
            final createHistory = actorHistories.firstWhere(
              (h) => h.actionCode == 'Create',
            );
            final submitHistory = actorHistories.firstWhere(
              (h) => h.actionCode == 'Submit',
            );
            final workflow = _convertGroupedHistoryToWorkflow(
              createHistory,
              submitHistory,
            );
            historyWorkflows.add(workflow);
          } else {
            for (final history in actorHistories) {
              historyWorkflows.add(_convertHistoryToWorkflow(history));
            }
          }
        }

        historyWorkflows.sort((a, b) {
          try {
            final dateA = DateTime.parse(a.actionDate);
            final dateB = DateTime.parse(b.actionDate);
            return dateA.compareTo(dateB);
          } catch (_) {
            return 0;
          }
        });

        mergedWorkflows.insertAll(0, historyWorkflows);
      }
    }

    return mergedWorkflows;
  }

  Map<String, List<_GroupedHistoryAction>> _getHistoryActionMap() {
    final map = <String, List<_GroupedHistoryAction>>{};
    if (tabType == AppTabTypes.DOCUMENT_OUT &&
        histories != null &&
        histories!.isNotEmpty) {
      final filteredHistories = histories!
          .where((h) => h.actionCode == 'Create' || h.actionCode == 'Submit')
          .toList();

      final groupedByActor = <String, List<HistoryModel>>{};
      for (final history in filteredHistories) {
        final key = history.actor;
        if (!groupedByActor.containsKey(key)) {
          groupedByActor[key] = [];
        }
        groupedByActor[key]!.add(history);
      }

      for (final entry in groupedByActor.entries) {
        final actorHistories = entry.value;
        actorHistories.sort((a, b) {
          try {
            final dateA = DateTime.parse(a.actionDate);
            final dateB = DateTime.parse(b.actionDate);
            return dateA.compareTo(dateB);
          } catch (_) {
            return 0;
          }
        });

        final hasCreate = actorHistories.any((h) => h.actionCode == 'Create');
        final hasSubmit = actorHistories.any((h) => h.actionCode == 'Submit');

        if (hasCreate && hasSubmit) {
          final createHistory = actorHistories.firstWhere(
            (h) => h.actionCode == 'Create',
          );
          final submitHistory = actorHistories.firstWhere(
            (h) => h.actionCode == 'Submit',
          );
          final workflowId = '${createHistory.id}_${submitHistory.id}';
          map[workflowId] = [
            _GroupedHistoryAction(
              actionCode: createHistory.actionCode,
              action: _getActionDisplayText(createHistory.actionCode),
              actionDate: createHistory.actionDate,
            ),
            _GroupedHistoryAction(
              actionCode: submitHistory.actionCode,
              action: _getActionDisplayText(submitHistory.actionCode),
              actionDate: submitHistory.actionDate,
            ),
          ];
        } else {
          for (final history in actorHistories) {
            map[history.id] = [
              _GroupedHistoryAction(
                actionCode: history.actionCode,
                action: history.action,
                actionDate: history.actionDate,
              ),
            ];
          }
        }
      }
    }
    return map;
  }

  String _getActionDisplayText(String actionCode) {
    switch (actionCode) {
      case 'Create':
        return 'Khởi tạo';
      case 'Submit':
        return 'Gửi văn bản';
      default:
        return '';
    }
  }

  WorkflowModel _convertHistoryToWorkflow(HistoryModel history) {
    return WorkflowModel(
      id: history.id,
      userId: '',
      name: history.actor,
      email: '',
      jobTitle: history.actorDepartment,
      step: -1,
      status: history.actionCode == 'Create' ? 1 : 0,
      isCompleted: history.actionCode == 'Create',
      actionDate: history.actionDate,
      createdDate: history.actionDate,
      note: history.note,
    );
  }

  WorkflowModel _convertGroupedHistoryToWorkflow(
    HistoryModel createHistory,
    HistoryModel submitHistory,
  ) {
    return WorkflowModel(
      id: '${createHistory.id}_${submitHistory.id}',
      userId: '',
      name: createHistory.actor,
      email: '',
      jobTitle: createHistory.actorDepartment,
      step: -1,
      status: 1,
      isCompleted: true,
      actionDate: createHistory.actionDate,
      createdDate: createHistory.actionDate,
      note: submitHistory.note ?? createHistory.note,
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

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _buildContent(),
            ),
          ),

          const SizedBox(height: 8),

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

  Widget _buildContent() {
    // Nếu là "Lịch sử cập nhật" (DOCUMENT_IN), chỉ hiển thị histories, không merge gì cả
    if (tabType == AppTabTypes.DOCUMENT_IN) {
      if (histories != null && histories!.isNotEmpty) {
        return _HistoryTimelineList(items: histories!);
      }
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'Không có lịch sử cập nhật',
            style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
          ),
        ),
      );
    }

    // Nếu là "Tiến trình phê duyệt" (DOCUMENT_OUT), hiển thị workflows (có merge histories)
    if (workflows != null && workflows!.isNotEmpty) {
      final mergedWorkflows = _getMergedWorkflows();
      if (mergedWorkflows.isNotEmpty) {
        final historyActionMap = _getHistoryActionMap();
        return _TimelineList(
          items: mergedWorkflows,
          tabType: tabType,
          historyActionMap: historyActionMap,
        );
      }
    }

    if (histories != null && histories!.isNotEmpty) {
      return _HistoryTimelineList(items: histories!);
    }

    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Text(
          'Không có lịch sử cập nhật',
          style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
        ),
      ),
    );
  }
}

class _HistoryTimelineList extends StatelessWidget {
  final List<HistoryModel> items;
  const _HistoryTimelineList({required this.items});

  @override
  Widget build(BuildContext context) {
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
                if (dateText.isNotEmpty)
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
  final String? tabType;
  final Map<String, List<_GroupedHistoryAction>> historyActionMap;
  const _TimelineList({
    required this.items,
    this.tabType,
    this.historyActionMap = const {},
  });

  @override
  Widget build(BuildContext context) {
    final sortedItems = List<WorkflowModel>.from(items)
      ..sort((a, b) => a.step.compareTo(b.step));

    final bool isOutgoing = tabType == AppTabTypes.DOCUMENT_OUT;

    return Column(
      children: List.generate(sortedItems.length, (index) {
        final item = sortedItems[index];
        final bool isLast = index == sortedItems.length - 1;
        final bool isApproved = item.status == 2; // status == 2 là Phê duyệt
        final bool isRejected = item.status == 3;
        final bool isPending = item.status == 0;
        final bool isNotApproved =
            item.status == 1; // status == 1 là Chưa duyệt
        final bool isNotIssued = isLast && !item.isCompleted;
        // Chỉ hiển thị dot xanh khi đã phê duyệt (status == 2) hoặc từ chối (status == 3) hoặc completed
        final bool isCurrent = item.isCompleted || isApproved || isRejected;
        final Color dotColor = isCurrent
            ? const Color(0xFF006884)
            : const Color(0xFFBDBDBD);

        // Ẩn date khi status == 0 (pending), status == 1 (Chưa duyệt) hoặc isNotIssued
        final bool shouldHideDate =
            isOutgoing && (isPending || isNotApproved || isNotIssued);
        final bool isHistoryItem = item.step == -1;
        final bool isGroupedHistory =
            isHistoryItem && historyActionMap.containsKey(item.id);
        final List<_GroupedHistoryAction>? groupedActions = isGroupedHistory
            ? historyActionMap[item.id]
            : null;
        final String statusText = isGroupedHistory && groupedActions != null
            ? groupedActions.first.action
            : _statusText(item, isLast, isOutgoing);
        final String? dateText = shouldHideDate
            ? null
            : _getDateText(item, isApproved, isRejected, isOutgoing);

        final Color statusColor = _getStatusColor(
          item.status,
          isNotIssued,
          isOutgoing,
        );

        return _TimelineTile(
          actor: item.name,
          department: item.jobTitle,
          statusText: statusText,
          statusColor: statusColor,
          dateText: dateText,
          note: item.note,
          dotColor: dotColor,
          showConnector: !isLast,
          isOutgoing: isOutgoing,
          groupedActions: groupedActions,
        );
      }),
    );
  }

  String _statusText(WorkflowModel workflow, bool isLast, bool isOutgoing) {
    if (isOutgoing) {
      if (isLast && !workflow.isCompleted) {
        return 'Chưa ban hành';
      }
      // Nếu step ở cuối và status == 2 thì là "Đã ban hành"
      if (isLast && workflow.status == 2) {
        return 'Ban hành';
      }
      if (workflow.status == 3) {
        return 'Từ chối';
      }
      if (workflow.status == 2) {
        return 'Phê duyệt';
      }
      if (workflow.status == 1) {
        return 'Chưa duyệt';
      }
      if (workflow.status == 0) {
        return 'Chưa duyệt';
      }
    }
    if (workflow.isCompleted && workflow.status == 2) {
      return 'Phê duyệt';
    } else {
      return 'Chờ xử lý';
    }
  }

  String? _getDateText(
    WorkflowModel workflow,
    bool isApproved,
    bool isRejected,
    bool isOutgoing,
  ) {
    final dateString = workflow.actionDate.isNotEmpty
        ? workflow.actionDate
        : workflow.createdDate;

    if (dateString.isEmpty) {
      return null;
    }

    if (isOutgoing) {
      final formatted = _formatDateTime(dateString);
      return formatted.isNotEmpty ? formatted : null;
    } else {
      return null;
    }
  }

  String _formatDateTime(String iso) {
    try {
      final d = DateTime.parse(iso);
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }

  Color _getStatusColor(int status, bool isNotIssued, bool isOutgoing) {
    if (!isOutgoing) {
      return const Color(0xFF424242);
    }
    if (isNotIssued || status == 0) {
      return const Color(0xFF9E9E9E); // Xám cho pending
    }
    if (status == 1) {
      return const Color(0xFF9E9E9E); // Xám cho Chưa duyệt (thay vì xanh)
    }
    if (status == 2) {
      return const Color(0xFF006884); // Xanh cho Phê duyệt
    }
    if (status == 3) {
      return const Color(0xFFD32F2F); // Đỏ cho Từ chối
    }
    return const Color(0xFF424242);
  }
}

class _TimelineTile extends StatelessWidget {
  final String actor;
  final String department;
  final String statusText;
  final Color statusColor;
  final String? dateText;
  final String? note;
  final Color dotColor;
  final bool showConnector;
  final bool isOutgoing;
  final List<_GroupedHistoryAction>? groupedActions;

  const _TimelineTile({
    required this.actor,
    required this.department,
    required this.statusText,
    required this.statusColor,
    this.dateText,
    this.note,
    required this.dotColor,
    required this.showConnector,
    required this.isOutgoing,
    this.groupedActions,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                height: groupedActions != null && groupedActions!.length > 1
                    ? 80
                    : 45,
                margin: const EdgeInsets.symmetric(vertical: 6),
                color: const Color(0xFFE0E0E0),
              ),
          ],
        ),
        const SizedBox(width: 12),

        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              bottom:
                  (note != null && note!.isNotEmpty) ||
                      (dateText != null && dateText!.isNotEmpty) ||
                      (groupedActions != null && groupedActions!.length > 1)
                  ? 12
                  : 0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
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
                if (groupedActions != null && groupedActions!.length > 1)
                  ...groupedActions!.map((action) {
                    final formattedDate = _formatDateTime(action.actionDate);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Text(
                            action.action,
                            style: TextStyle(
                              fontSize: 13,
                              color: statusColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            ': ',
                            style: TextStyle(
                              fontSize: 13,
                              color: statusColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9E9E9E),
                            ),
                          ),
                        ],
                      ),
                    );
                  })
                else if (isOutgoing && dateText != null && dateText!.isNotEmpty)
                  Row(
                    children: [
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 13,
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        ': ',
                        style: TextStyle(
                          fontSize: 13,
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        dateText!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9E9E9E),
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 13,
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (note != null && note!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Lý do: $note',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF757575),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                if (!isOutgoing &&
                    dateText != null &&
                    dateText!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    dateText!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
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
