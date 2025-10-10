import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TaskItemCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final int count;
  final Color countColor;
  final VoidCallback? onTap;

  const TaskItemCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.count,
    required this.countColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon - giảm kích thước
            Container(
              width: 32.w,
              height: 32.h,
              decoration: BoxDecoration(
                color: iconColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 16.sp),
            ),

            SizedBox(width: 10.w),

            // Title - giảm kích thước
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade800,
                ),
              ),
            ),

            // Count - giảm kích thước
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: countColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: countColor,
                ),
              ),
            ),

            SizedBox(width: 6.w),

            // Arrow icon - giảm kích thước
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 14.sp,
            ),
          ],
        ),
      ),
    );
  }
}
