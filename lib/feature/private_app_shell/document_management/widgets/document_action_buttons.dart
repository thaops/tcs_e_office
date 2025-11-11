import 'package:flutter/material.dart';
import 'package:tcs_e_office/core/configs/theme/app_colors.dart';
import '../models/document_detail_model.dart';
import 'document_approve_dialog.dart';
import 'document_reject_dialog.dart';
import 'package:tcs_e_office/common/constants/app_tab_types.dart';

class DocumentActionButtons extends StatelessWidget {
  final String tabType; // AppTabTypes.DOCUMENT_IN hoặc DOCUMENT_OUT
  final VoidCallback? onProcess; // Chuyển xử lý (văn bản đến)
  final VoidCallback? onMarkRead; // Đã đọc (văn bản đến)
  final VoidCallback? onCreateTask; // Tạo công việc (văn bản đến)
  final Function(String note)? onReject; // Từ chối (văn bản đi) - nhận note
  final Function(bool isApprove)?
  onApprove; // Duyệt (văn bản đi) - nhận isApprove
  final bool isLoading; // Loading state
  final bool isRead; // Trạng thái đã đọc
  final int? status; // Status của văn bản
  final List<WorkflowModel>? workflows; // Workflows để check user
  final String? currentUserId; // User ID hiện tại
  

  const DocumentActionButtons({
    super.key,
    required this.tabType,
    this.onProcess,
    this.onMarkRead,
    this.onCreateTask,
    this.onReject,
    this.onApprove,
    this.isLoading = false,
    this.isRead = false,
    this.status,
    this.workflows,
    this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tabType == AppTabTypes.DOCUMENT_IN)
            _buildIncomingActions()
          else
            _buildOutgoingActions(context),
        ],
      ),
    );
  }

  Widget _buildIncomingActions() {
    List<Widget> buttons = [
      // Chuyển xử lý
      Expanded(
        child: _buildActionButton(
          label: 'Chuyển xử lý',
          color: AppColors.primary,
          onPressed: onProcess,
        ),
      ),
    ];

    // Chỉ hiển thị nút "Đã đọc" nếu chưa đọc
    if (!isRead) {
      buttons.add(const SizedBox(width: 8));
      buttons.add(
        Expanded(
          child: _buildActionButton(
            label: 'Đã đọc',
            color: const Color(0xFF339B00),
            onPressed: onMarkRead,
          ),
        ),
      );
    }

    buttons.add(const SizedBox(width: 8));
    // Tạo công việc
    buttons.add(
      Expanded(
        child: _buildActionButton(
          label: 'Tạo công việc',
          color: const Color(0xFFE39516),
          onPressed: onCreateTask,
        ),
      ),
    );

    return Row(children: buttons);
  }

  Widget _buildOutgoingActions(BuildContext context) {
    // Chỉ hiển thị nút "Từ chối" và "Duyệt" khi status == 2
    if (status != 2) {
      return const SizedBox.shrink();
    }

    // Kiểm tra xem user hiện tại có trong workflows không
    bool hasUserInWorkflow = false;
    WorkflowModel? currentUserWorkflow;

    if (currentUserId != null &&
        currentUserId!.isNotEmpty &&
        workflows != null &&
        workflows!.isNotEmpty) {
      try {
       
        currentUserWorkflow = workflows!.firstWhere(
          (workflow) => workflow.userId == currentUserId,
        );
        hasUserInWorkflow = true;
      } catch (e) {
        hasUserInWorkflow = false;
      }
    }

    // Chỉ hiển thị nút nếu user có trong workflows
    if (!hasUserInWorkflow) {
      return const SizedBox.shrink();
    }

    // Nếu workflow của user hiện tại có status != 0 (đã xử lý) thì ẩn nút
    if (currentUserWorkflow != null &&
        currentUserWorkflow.status != 0 &&
        currentUserWorkflow.status != 1) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        // Từ chối - hiển thị popup khi click
        Expanded(
          child: _buildActionButton(
            label: 'Từ chối',
            color: const Color(0xFFFF2323),
            onPressed: () {
              // Hiển thị popup từ chối
              DocumentRejectDialog.show(
                context,
                onConfirm: (note) {
                  // Gọi callback onReject với lý do từ chối
                  onReject?.call(note);
                },
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        // Duyệt - hiển thị popup khi click
        Expanded(
          child: _buildActionButton(
            label: 'Duyệt',
            color: const Color(0xFF339B00),
            onPressed: () {
              // Hiển thị popup xác nhận duyệt
              DocumentApproveDialog.show(
                context,
                onConfirm: (isApprove) {
                  // Gọi callback onApprove với thông tin isApprove
                  onApprove?.call(isApprove);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: color.withOpacity(0.3), width: 1),
        ),
      ),
      child: isLoading
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            )
          : Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
    );
  }
}
