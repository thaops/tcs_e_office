import 'package:flutter/material.dart';
import 'package:tcs_e_office/common/widgets/text_widget.dart';
import 'package:tcs_e_office/core/configs/theme/app_colors.dart';

class TaskActionBar extends StatelessWidget {
  final VoidCallback? onTransfer;
  final VoidCallback? onComplete;
  final bool isCompleting;
  final bool isForwarding;

  const TaskActionBar({
    super.key,
    this.onTransfer,
    this.onComplete,
    this.isCompleting = false,
    this.isForwarding = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isForwarding ? null : onTransfer,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: AppColors.grey),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:
                  isForwarding
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.grey,
                          ),
                        ),
                      )
                      : TextWidget(text: "Chuyển xử lý", color: AppColors.grey),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              onPressed: isCompleting ? null : onComplete,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:
                  isCompleting
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : TextWidget(text: "Hoàn thành", color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}
