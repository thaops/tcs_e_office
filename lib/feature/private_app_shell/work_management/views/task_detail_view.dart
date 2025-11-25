import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tcs_e_office/common/widgets/app_bar_widget.dart';
import 'package:tcs_e_office/common/widgets/error_404_widget.dart';
import 'package:tcs_e_office/common/widgets/success_dialog.dart';
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
import '../widgets/reprocess_reason_dialog.dart';
import '../controllers/work_management_controller.dart';
import 'package:tcs_e_office/common/constants/app_tab_types.dart';

class TaskDetailView extends StatefulWidget {
  final String taskId;
  final String? tabType; // AppTabTypes.TASK_ASSIGN hoặc TASK_RECEIVED
  const TaskDetailView({super.key, required this.taskId, this.tabType});

  @override
  State<TaskDetailView> createState() => _TaskDetailViewState();
}

class _TaskDetailViewState extends State<TaskDetailView> {
  String _appBarTitle = 'Chi tiết công việc';

  // Method để xác định title dựa trên tabType
  void _updateAppBarTitle() {
    if (widget.tabType == AppTabTypes.TASK_ASSIGN) {
      setState(() {
        _appBarTitle = 'Việc tôi giao';
      });
    } else if (widget.tabType == AppTabTypes.TASK_RECEIVED) {
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

    // Đảm bảo controller mới được tạo mỗi lần mở detail
    // Xóa controller cũ nếu tồn tại (nếu user quay lại detail cũ)
    final tag = 'task_detail_${widget.taskId}';
    if (Get.isRegistered<TaskDetailController>(tag: tag)) {
      Get.delete<TaskDetailController>(tag: tag);
    }
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

  /// Kiểm tra xem user hiện tại có phải là assignee của task không
  Future<bool> _isCurrentUserAssignee(detail) async {
    try {
      final myId = await MyId.create();
      final currentUserId = await myId.getMyId();

      if (currentUserId.isEmpty) {
        return false;
      }

      // Kiểm tra xem user hiện tại có trong danh sách assignees không
      final isAssignee = detail.assignees.any(
        (assignee) => assignee.id == currentUserId,
      );

      return isAssignee;
    } catch (e) {
      return false;
    }
  }

  /// Kiểm tra xem user hiện tại có phải là người đã hoàn thành trong bất kỳ role nào (xử lý chính, phối hợp, theo dõi)
  Future<bool> _isCurrentUserCompleted(detail) async {
    try {
      final myId = await MyId.create();
      final currentUserId = await myId.getMyId();

      if (currentUserId.isEmpty) {
        return false;
      }

      // Tìm tất cả assignees với ID trùng với user hiện tại (không phân biệt role)
      final currentUserAssignees = detail.assignees
          .where((a) => a.id == currentUserId)
          .toList();

      // Kiểm tra xem có bất kỳ role nào của user hiện tại đã hoàn thành (statusCode == 2)
      for (final assignee in currentUserAssignees) {
        if (assignee.statusCode == 2) {
          return true; // User hiện tại đã hoàn thành trong ít nhất một role
        }
      }

      return false;
    } catch (e) {
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
          final dueDate = detail.dueDate.isNotEmpty
              ? detail.dueDate
              : DateTime.now()
                    .add(const Duration(days: 7))
                    .toIso8601String()
                    .split('T')[0];

          final success = await c.forwardTask(
            selectedEmployeeCodes: selectedEmployeeCodes,
            dueDate: dueDate,
          );

          if (success) {
            // Hiển thị success dialog khi chuyển xử lý thành công
            await SuccessDialogWithBackdrop.show(
              context: context,
              title: 'Thành công',
              message: 'Chuyển xử lý thành công',
              buttonText: 'Đóng',
              autoClose: true,
              autoCloseDelay: const Duration(seconds: 2),
            );
          }
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
            widget.tabType == AppTabTypes.TASK_ASSIGN &&
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
            TaskHistoryDialog.show(
              context,
              histories,
              widget.tabType ?? AppTabTypes.TASK_RECEIVED,
            );
          },
          functionSecond: () async {
            // Navigate to update task screen
            if (detail != null) {
              final result = await Get.to(
                () => UpdateTaskView(
                  assignerCode: detail.assignerCode,
                  taskId: widget.taskId,
                  documentId: detail.documentId,
                  taskData: detail, // Truyền data có sẵn để tối ưu
                ),
              );

              // Chỉ refresh khi thực sự có thay đổi (result == 'updated')
              if (result == 'updated') {
                // Refresh ngay lập tức để tránh giật
                c.refreshDetail();
              }
            }
          },
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Sử dụng tag dựa trên taskId để mỗi task có controller riêng
    // GetBuilder sẽ tự động tạo controller mới nếu chưa tồn tại với tag này
    final tag = 'task_detail_${widget.taskId}';

    return GetBuilder<TaskDetailController>(
      init: TaskDetailController(widget.taskId),
      tag: tag,
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

            return Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header card
                            TaskHeaderCard(detail: detail),
                            // Content HTML (nội dung công việc)
                            if (detail.content != null &&
                                detail.content!.isNotEmpty)
                              TaskDetailSection(
                                child: ContentSection(content: detail.content),
                              ),
                            // Attachments
                            TaskDetailSection(
                              child: AttachmentsSection(
                                attachments: detail.attachments,
                              ),
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
                              child: AssigneesSection(
                                assignees: detail.assignees,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Action bar - chỉ hiển thị khi:
                    // 1. Task chưa hoàn thành (kể cả quá hạn)
                    // 2. Không phải "việc tôi giao"
                    // 3. User hiện tại là assignee của task
                    // 4. User chưa hoàn thành trong bất kỳ role nào
                    if (!_isTaskCompleted(detail) &&
                        widget.tabType != AppTabTypes.TASK_ASSIGN)
                      FutureBuilder<List<bool>>(
                        future: Future.wait([
                          _isCurrentUserAssignee(detail),
                          _isCurrentUserCompleted(detail),
                        ]),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox.shrink();
                          }

                          final results = snapshot.data!;
                          final isCurrentUserAssignee = results[0];
                          final isCurrentUserCompleted = results[1];

                          // Ẩn action bar nếu:
                          // - User không phải assignee
                          // - User đã hoàn thành trong bất kỳ role nào
                          if (!isCurrentUserAssignee ||
                              isCurrentUserCompleted) {
                            return const SizedBox.shrink();
                          }

                          return Obx(
                            () => TaskActionBar(
                              isCompleting: c.isCompleting.value,
                              isForwarding: c.isForwarding.value,
                              onTransfer: () => _handleForwardTask(c),
                              onComplete: () async {
                                final success = await c.completeTask();
                                if (success) {
                                  await SuccessDialogWithBackdrop.show(
                                    context: context,
                                    title: 'Thành công',
                                    message: 'Hoàn thành công việc thành công',
                                    buttonText: 'Đóng',
                                    autoClose: true,
                                    autoCloseDelay: const Duration(seconds: 2),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),

                    // Button "Xử lý lại" - chỉ hiển thị khi là "việc tôi giao" và đã hoàn thành
                    if (widget.tabType == AppTabTypes.TASK_ASSIGN &&
                        _isTaskCompleted(detail))
                      Obx(
                        () => Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, -2),
                              ),
                            ],
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: c.isReprocessing.value
                                  ? null
                                  : () async {
                                      HapticFeedback.lightImpact();
                                      await ReprocessReasonDialog.show(
                                        context: context,
                                        onConfirm: (reason) async {
                                          final success = await c.reprocessTask(
                                            note: reason,
                                          );
                                          if (success) {
                                            // Silent refresh list (không hiển thị loading UI)
                                            try {
                                              final listController =
                                                  Get.find<
                                                    WorkManagementController
                                                  >();
                                              await listController
                                                  .silentRefresh();
                                            } catch (e) {
                                              // Nếu không tìm thấy controller thì bỏ qua
                                            }

                                            // Hiển thị success dialog
                                            await SuccessDialogWithBackdrop.show(
                                              context: context,
                                              title: 'Thành công',
                                              message:
                                                  'Xử lý lại công việc thành công',
                                              buttonText: 'Đóng',
                                              autoClose: true,
                                              autoCloseDelay: const Duration(
                                                seconds: 2,
                                              ),
                                            );
                                          } else {
                                            Get.snackbar(
                                              'Lỗi',
                                              c.error.value.isNotEmpty
                                                  ? c.error.value
                                                  : 'Không thể xử lý lại công việc',
                                              backgroundColor: Colors.red,
                                              colorText: Colors.white,
                                            );
                                          }
                                        },
                                      );
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: c.isReprocessing.value
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Text(
                                      'Yêu cầu xử lý lại',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                // Loading indicator mượt mà cho refresh
                if (c.isRefreshing.value)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 3,
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
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
/// Cần có departmentTree và searching properties để assignee selector hoạt động
class _ControllerWithData {
  final List<dynamic> _departmentTree;
  final RxBool _searching = false.obs;
  static bool _globalInitialized =
      false; // Static flag để cache across instances
  final TaskApiService _apiService = TaskApiService(); // Thêm API service

  _ControllerWithData(this._departmentTree);

  List<dynamic> get departmentTree => _departmentTree;
  RxBool get searching => _searching;

  /// Method để search employees (real API implementation)
  Future<void> searchEmployees(String keyword) async {
    final trimmedKeyword = keyword.trim();

    // Nếu keyword rỗng và đã khởi tạo globally, skip hoàn toàn
    if (trimmedKeyword.isEmpty && _globalInitialized) {
      return; // Skip reset nếu đã có data globally
    }

    // Chỉ hiển thị loading khi có keyword thực sự
    if (trimmedKeyword.isNotEmpty) {
      _searching.value = true;
      try {
        // Gọi API thực sự để search employees
        final searchResults = await _apiService.searchEmployeesByDepartment(
          trimmedKeyword,
        );
        // Update departmentTree với kết quả search
        _departmentTree.clear();
        _departmentTree.addAll(searchResults);
      } catch (e) {
        // Ignore search error
      } finally {
        _searching.value = false;
      }
    } else {
      // Lần đầu khởi tạo - không cần loading vì data đã sẵn sàng
      // Chỉ đánh dấu đã khởi tạo globally
      _globalInitialized = true;
    }
  }
}
