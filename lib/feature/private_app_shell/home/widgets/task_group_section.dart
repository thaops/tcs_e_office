import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TaskGroupSection extends StatelessWidget {
  final String title;
  final int totalCount;
  final List<Widget> children;

  const TaskGroupSection({
    super.key,
    required this.title,
    required this.totalCount,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Group header - giảm kích thước
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: const Color(0xFF006884), // Màu xanh đậm
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  totalCount.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Task items
        if (children.isNotEmpty) ...[
          SizedBox(height: 8.h),
          ...children.map(
            (child) =>
                Padding(padding: EdgeInsets.only(bottom: 8.h), child: child),
          ),
        ],
      ],
    );
  }
}
