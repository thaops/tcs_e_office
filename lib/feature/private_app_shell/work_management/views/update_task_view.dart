import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tcs_e_office/common/widgets/app_bar_widget.dart';
import 'package:tcs_e_office/core/configs/theme/app_colors.dart';
import '../controllers/update_task_controller.dart';
import '../widgets/update_task_title_section.dart';
import '../widgets/update_task_due_date_section.dart';
import '../widgets/update_task_priority_section.dart';
import '../widgets/update_task_attachment_section.dart';
import '../widgets/update_task_assignee_section.dart';
import '../widgets/update_task_submit_button.dart';

class UpdateTaskView extends StatefulWidget {
  final String assignerCode; // mã người giao việc
  final String? documentId; // id tài liệu đã lưu (optional)
  final String taskId; // ID của task cần update

  const UpdateTaskView({
    super.key,
    required this.assignerCode,
    required this.taskId,
    this.documentId,
  });

  @override
  State<UpdateTaskView> createState() => _UpdateTaskViewState();
}

class _UpdateTaskViewState extends State<UpdateTaskView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UpdateTaskController>(
      init: UpdateTaskController(),
      builder: (c) {
        // Gán documentId nếu có (chỉ gán một lần)
        if (c.documentId == null && widget.documentId != null) {
          c.documentId = widget.documentId;
        }

        // Load task data khi controller được khởi tạo
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (c.taskId == null || c.taskId != widget.taskId) {
            print(
              '🔍 UpdateTaskView: Loading task data for taskId: ${widget.taskId}',
            );
            c.loadTaskData(widget.taskId);
          } else {
            print(
              '🔍 UpdateTaskView: Task data already loaded for taskId: ${widget.taskId}',
            );
          }
        });

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          resizeToAvoidBottomInset:
              false, // Ngăn auto scroll khi keyboard xuất hiện
          appBar: AppBarWidget(
            title: 'Cập nhật công việc',
            backgroundColor: AppColors.primary,
            isTitleCenter: true,
          ),

          body: Obx(() {
            if (c.loading.value &&
                c.priorities.isEmpty &&
                c.allEmployees.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 6,
                      children: [
                        const UpdateTaskTitleSection(),
                        const UpdateTaskPrioritySection(),
                        const UpdateTaskDueDateSection(),
                        const UpdateTaskAttachmentSection(),
                        const UpdateTaskAssigneeSection(),
                        const SizedBox(height: 16), // Thêm spacing cuối
                      ],
                    ),
                  ),
                ),
                UpdateTaskSubmitButton(
                  assignerCode: widget.assignerCode,
                  onSuccess: () async {
                    // Trả về 'updated' để báo hiệu đã có thay đổi
                    Get.back(result: 'updated');
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
