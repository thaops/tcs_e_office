import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tcs_e_office/common/widgets/app_bar_widget.dart';
import 'package:tcs_e_office/core/configs/theme/app_colors.dart';
import '../controllers/create_task_controller.dart';
import '../widgets/task_title_section.dart';
import '../widgets/task_due_date_section.dart';
import '../widgets/task_priority_section.dart';
import '../widgets/task_attachment_section.dart';
import '../widgets/task_assignee_section.dart';
import '../widgets/task_submit_button.dart';

class CreateTaskView extends StatefulWidget {
  final String assignerCode; // mã người giao việc
  final String? documentId; // id tài liệu đã lưu (optional)
  final String? documentTitle; // tiêu đề tài liệu (optional)
  const CreateTaskView({
    super.key,
    required this.assignerCode,
    this.documentId,
    this.documentTitle,
  });

  @override
  State<CreateTaskView> createState() => _CreateTaskViewState();
}

class _CreateTaskViewState extends State<CreateTaskView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateTaskController>(
      init: CreateTaskController(),
      builder: (c) {
        if (widget.documentTitle != null) {
          c.titleController.text = widget.documentTitle!;
        }
        // Gán documentId nếu có (chỉ gán một lần)
        if (c.documentId == null && widget.documentId != null) {
          c.documentId = widget.documentId;
        }
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          resizeToAvoidBottomInset:
              false, // Ngăn auto scroll khi keyboard xuất hiện
          appBar: AppBarWidget(
            title: 'Tạo công việc',
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
                        const TaskTitleSection(),
                        const TaskPrioritySection(),
                        const TaskDueDateSection(),
                        const TaskAttachmentSection(),
                        const TaskAssigneeSection(),
                        const SizedBox(height: 16), // Thêm spacing cuối
                      ],
                    ),
                  ),
                ),
                TaskSubmitButton(
                  assignerCode: widget.assignerCode,
                  onSuccess: () => Get.back(result: true),
                ),
              ],
            );
          }),
        );
      },
    );
  }
}
