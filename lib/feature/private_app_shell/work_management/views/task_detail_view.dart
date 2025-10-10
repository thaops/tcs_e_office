import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tcs_e_office/common/widgets/app_bar_widget.dart';
import 'package:tcs_e_office/common/widgets/error_404_widget.dart';
import 'package:tcs_e_office/core/configs/theme/app_colors.dart';
import 'package:tcs_e_office/common/share/cache/my_id.dart';
import '../controllers/task_detail_controller.dart';
import '../widgets/task_header_card.dart';
import '../widgets/attachments_section.dart';
import '../widgets/content_section.dart';
import '../widgets/comments_section.dart';
import '../widgets/assignees_section.dart';
import '../widgets/task_action_bar.dart';
import '../widgets/task_history_dialog.dart';
import '../widgets/task_detail_section.dart';
import '../widget/assignee_selector_bottom_sheet.dart';
import '../controllers/task_api_service.dart';
import 'update_task_view.dart';

class TaskDetailView extends StatefulWidget {
  final String taskId;
  final String? tabType; // 'assigned_by_me' hoặc 'assigned_to_me'
  const TaskDetailView({super.key, required this.taskId, this.tabType});

  @override
  State<TaskDetailView> createState() => _TaskDetailViewState();
}

class _TaskDetailViewState extends State<TaskDetailView> {
  String _appBarTitle = 'Chi tiết công việc';

  // Method để xác định title dựa trên tabType
  void _updateAppBarTitle() {
    if (widget.tabType == 'assigned_by_me') {
      setState(() {
        _appBarTitle = 'Việc tôi giao';
      });
    } else if (widget.tabType == 'assigned_to_me') {
      setState(() {
        _appBarTitle = 'Việc giao đến tôi';
      });
    } else {
      // Fallback nếu không có tabType
      setState(() {
        _appBarTitle = 'Chi tiết công việc';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _updateAppBarTitle();
  }

  /// Kiểm tra xem task đã hoàn thành hay chưa
  /// Dựa trên status hoặc completedDate của assignees
  bool _isTaskCompleted(detail) {
    // Kiểm tra status - status = 2 là hoàn thành
    // Status 1: Đang thực hiện, Status 2: Hoàn thành, Status 3: Quá hạn
    if (detail.status == 2) {
      return true;
    }

    // Kiểm tra completedDate của assignees
    // Nếu tất cả assignees đều có completedDate thì task đã hoàn thành
    if (detail.assignees.isNotEmpty) {
      final allCompleted = detail.assignees.every(
        (assignee) =>
            assignee.completedDate != null &&
            assignee.completedDate!.isNotEmpty,
      );
      if (allCompleted) {
        return true;
      }
    }

    return false;
  }

  /// Kiểm tra xem user hiện tại có phải là người xử lý chính đã hoàn thành hay không
  Future<bool> _isCurrentUserPrimaryCompleted(detail) async {
    try {
      final myId = await MyId.create();
      final currentUserId = await myId.getMyId();

      print('🔍 Current user ID: $currentUserId');

      if (currentUserId.isEmpty) {
        print('🔍 Current user ID is empty');
        return false;
      }

      // Tìm người xử lý chính (roleId == 1) với ID trùng với user hiện tại
      final primaryAssignees =
          detail.assignees.where((a) => a.roleId == 1).toList();

      print(
        '🔍 Primary assignees: ${primaryAssignees.map((a) => '${a.id} - ${a.code} - ${a.name} - status: ${a.statusCode}').toList()}',
      );

      for (final assignee in primaryAssignees) {
        print(
          '🔍 Checking assignee ID: ${assignee.id} vs current: $currentUserId, status: ${assignee.statusCode}',
        );
        if (assignee.id == currentUserId && assignee.statusCode == 2) {
          print('🔍 Found completed primary assignee: ${assignee.name}');
          return true; // User hiện tại là người xử lý chính đã hoàn thành
        }
      }

      print('🔍 No completed primary assignee found for current user');
      return false;
    } catch (e) {
      print('Error checking current user primary completion: $e');
      return false;
    }
  }

  /// Xử lý chuyển tiếp task
  void _handleForwardTask(TaskDetailController c) async {
    final detail = c.detail.value;
    if (detail == null) return;

    try {
      // Thêm haptic feedback
      HapticFeedback.lightImpact();

      // Hiển thị loading state ngay lập tức
      c.isForwarding.value = true;

      // Tải metadata (departments, employees) để hiển thị trong selector
      final taskApiService = TaskApiService();
      final metadata = await taskApiService.loadMetadata();

      // Tạo controller với department tree thực tế
      final controllerWithData = _ControllerWithData(
        metadata['departments'] ?? [],
      );

      // Tắt loading state trước khi hiển thị bottom sheet
      c.isForwarding.value = false;

      showAssigneeSelectorBottomSheet(
        context,
        controller: controllerWithData,
        title: 'Chọn người chuyển giao',
        onConfirm: (selectedEmployeeCodes) async {
          if (selectedEmployeeCodes.isEmpty) {
            Get.snackbar(
              'Thông báo',
              'Vui lòng chọn ít nhất một người để chuyển giao',
              backgroundColor: Colors.orange,
              colorText: Colors.white,
            );
            return;
          }

          // Sử dụng dueDate hiện tại của task hoặc mặc định
          final dueDate =
              detail.dueDate.isNotEmpty
                  ? detail.dueDate
                  : DateTime.now()
                      .add(const Duration(days: 7))
                      .toIso8601String()
                      .split('T')[0];

          await c.forwardTask(
            selectedEmployeeCodes: selectedEmployeeCodes,
            dueDate: dueDate,
          );
        },
      );
    } catch (e) {
      c.isForwarding.value = false;
    }
  }

  /// Tạo AppBar reactive với state changes
  PreferredSizeWidget _buildReactiveAppBar(TaskDetailController c) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Obx(() {
        final detail = c.detail.value;
        final showEditIcon =
            widget.tabType == 'assigned_by_me' &&
            detail != null &&
            !_isTaskCompleted(detail);

        return AppBarWidget(
          title: _appBarTitle,
          backgroundColor: AppColors.primary,
          isTitleCenter: true,
          iconRightfirst: Icons.history,
          iconRightSecond: showEditIcon ? Icons.edit_note_outlined : null,
          functionfirst: () {
            final histories = detail?.histories ?? [];
            TaskHistoryDialog.show(context, histories);
          },
          functionSecond: () async {
            // Navigate to update task screen
            if (detail != null) {
              final result = await Get.to(
                () => UpdateTaskView(
                  assignerCode: detail.assignerCode,
                  taskId: widget.taskId,
                  documentId: detail.documentId,
                ),
              );

              // Nếu cập nhật thành công, refresh data
              if (result == true) {
                print(
                  '🔍 TaskDetailView: Update successful, refreshing data...',
                );
                c.fetchDetail();
              }
            }
          },
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TaskDetailController>(
      init: TaskDetailController(widget.taskId),
      builder: (c) {
        return Scaffold(
          backgroundColor: AppColors.bacgroundApp,
          appBar: _buildReactiveAppBar(c),

          body: Obx(() {
            if (c.isLoading.value && c.detail.value == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (c.error.isNotEmpty) {
              return Error404Widget(
                title: 'Không thể tải dữ liệu',
                message: c.error.value,
                buttonText: 'Thử lại',
                onRetry: () {
                  c.fetchDetail();
                },
              );
            }
            final detail = c.detail.value;
            if (detail == null) {
              return const Error404Widget(
                title: 'Không tìm thấy công việc',
                message: 'Công việc này không tồn tại hoặc đã bị xóa.',
                showRetryButton: false,
              );
            }

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header card
                        TaskHeaderCard(detail: detail),

                        // Attachments
                        TaskDetailSection(
                          child: AttachmentsSection(
                            attachments: detail.attachments,
                          ),
                        ),

                        // Content HTML (nội dung công việc)
                        TaskDetailSection(
                          child: ContentSection(content: detail.content),
                        ),

                        // Comments
                        TaskDetailSection(
                          child: CommentsSection(
                            comments: detail.comments,
                            documentId: detail.id,
                            onAddComment: () {
                              // Refresh comments after adding
                              c.fetchDetail();
                            },
                          ),
                        ),

                        // Assignees
                        TaskDetailSection(
                          child: AssigneesSection(assignees: detail.assignees),
                        ),
                      ],
                    ),
                  ),
                ),

                // Action bar - chỉ hiển thị khi task chưa hoàn thành, không phải "việc tôi giao" và user chưa hoàn thành phần xử lý chính
                if (!_isTaskCompleted(detail) &&
                    widget.tabType != 'assigned_by_me')
                  FutureBuilder<bool>(
                    future: _isCurrentUserPrimaryCompleted(detail),
                    builder: (context, snapshot) {
                      final isCurrentUserCompleted = snapshot.data ?? false;

                      // Ẩn action bar nếu user hiện tại đã hoàn thành phần xử lý chính
                      if (isCurrentUserCompleted) {
                        return const SizedBox.shrink();
                      }

                      return Obx(
                        () => TaskActionBar(
                          isCompleting: c.isCompleting.value,
                          isForwarding: c.isForwarding.value,
                          onTransfer: () => _handleForwardTask(c),
                          onComplete: () async {
                            await c.completeTask();
                          },
                        ),
                      );
                    },
                  ),
              ],
            );
          }),
        );
      },
    );
  }
}

/// Controller với data thực tế để sử dụng với assignee selector
/// Cần có departmentTree property để assignee selector hoạt động
class _ControllerWithData {
  final List<dynamic> _departmentTree;

  _ControllerWithData(this._departmentTree);

  List<dynamic> get departmentTree => _departmentTree;
}
