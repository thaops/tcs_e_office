import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tcs_e_office/common/widgets/app_dialog.dart';
import 'package:tcs_e_office/common/widgets/success_dialog.dart';
import 'package:tcs_e_office/core/configs/theme/app_colors.dart';
import '../controllers/create_task_controller.dart';

/// Widget cho nút submit tạo công việc
class TaskSubmitButton extends StatelessWidget {
  final String assignerCode;
  final VoidCallback? onSuccess;

  const TaskSubmitButton({
    super.key,
    required this.assignerCode,
    this.onSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateTaskController>(
      builder: (c) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          color: Colors.white,
          child: Obx(() {
            final isLoading = c.loading.value;
            final errorMessage = c.error.value;

            // Hiển thị lỗi ngay khi có lỗi (trừ lỗi validate form)
            if (errorMessage.isNotEmpty &&
                !errorMessage.contains('Tên việc không được để trống') &&
                !errorMessage.contains('Nội dung không được để trống')) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                AppDialog.showError(
                  title: 'Lỗi',
                  message: errorMessage,
                  useBackdrop: false,
                );
                // Clear error sau khi hiển thị
                c.error.value = '';
              });
            }

            return ElevatedButton(
              onPressed: isLoading ? null : () => _handleSubmit(context, c),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.yellow,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.6,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Tạo công việc',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            );
          }),
        );
      },
    );
  }

  Future<void> _handleSubmit(
    BuildContext context,
    CreateTaskController c,
  ) async {
    FocusScope.of(context).unfocus();
    final ok = await c.submit(assignerCode: assignerCode);

    if (ok) {
      // Hiển thị success dialog trước khi đóng màn hình
      await SuccessDialogWithBackdrop.show(
        context: context,
        title: 'Thành công',
        message: 'Tạo công việc thành công',
        buttonText: 'Đóng',
        autoClose: true,
        autoCloseDelay: const Duration(seconds: 2),
        onClose: () {
          onSuccess?.call();
          Get.back(result: true);
        },
      );
    }
    // Lỗi đã được xử lý trong build method
  }
}
