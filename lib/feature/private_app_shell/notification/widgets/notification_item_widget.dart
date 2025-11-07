import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:tcs_e_office/core/configs/theme/app_colors.dart';
import 'package:tcs_e_office/feature/private_app_shell/notification/models/notification_model.dart';

class NotificationItemWidget extends StatelessWidget {
  final NotificationItem notification;
  final VoidCallback? onTap;
  final bool showCheckbox;
  final bool isSelected;
  final VoidCallback? onCheckboxChanged;
  final bool enableCheckbox; // Cho phép enable/disable checkbox

  const NotificationItemWidget({
    super.key,
    required this.notification,
    this.onTap,
    this.showCheckbox = false,
    this.isSelected = false,
    this.onCheckboxChanged,
    this.enableCheckbox = true, // Mặc định cho phép click
  });

  @override
  Widget build(BuildContext context) {
    // Màu background xanh nhẹ cho notification chưa đọc
    final backgroundColor = notification.isRead
        ? Colors.white
        : const Color(0xFFE3F2FD); // Màu xanh nhẹ

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.h),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(
            color: AppColors.primary.withOpacity(0.4),
            width: 0.4,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox - hiển thị nếu showCheckbox = true
            // Disable nếu enableCheckbox = false hoặc notification đã đọc
            if (showCheckbox) ...[
              Checkbox(
                value: isSelected,
                onChanged: enableCheckbox && !notification.isRead
                    ? (value) {
                        onCheckboxChanged?.call();
                      }
                    : null, // Disable checkbox nếu đã đọc hoặc enableCheckbox = false
                activeColor: AppColors.primary,
              ),
              SizedBox(width: 8.w),
            ],

            // Icon bên trái - circular background màu teal/blue
            Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: AppColors.primary, // Màu teal/blue
                shape: BoxShape.circle,
              ),
              child: Icon(
                notification.source == 'Document' ||
                        notification.source == 'DocumentIn' ||
                        notification.source == 'DocumentOut'
                    ? Icons.description_outlined
                    : Icons.assignment_outlined,
                color: Colors.white,
                size: 24.sp,
              ),
            ),

            SizedBox(width: 12.w),

            // Text content bên phải
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title - dòng 1
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 4.h),

                  // Content - dòng 2
                  if (notification.content.isNotEmpty)
                    Text(
                      notification.content,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                  SizedBox(height: 4.h),

                  // Date - dòng 3
                  Text(
                    _formatDate(notification.createdDate),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
}
