import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';

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
    final isMacOS = Platform.isMacOS;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Group header - macOS optimized
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: isMacOS ? 16.w : 12.w, 
            vertical: isMacOS ? 12.h : 8.h,
          ),
          decoration: BoxDecoration(
            color: isMacOS ? const Color(0xFF006884) : const Color(0xFF006884),
            borderRadius: BorderRadius.circular(isMacOS ? 8.r : 6.r),
            boxShadow: isMacOS ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMacOS ? 16.sp : 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (isMacOS && totalCount > 0)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12.r),
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

        // Task items - macOS spacing
        if (children.isNotEmpty) ...[
          SizedBox(height: isMacOS ? 12.h : 8.h),
          ...children.map(
            (child) => Padding(
              padding: EdgeInsets.only(bottom: isMacOS ? 12.h : 8.h),
              child: child,
            ),
          ),
        ],
      ],
    );
  }
}
