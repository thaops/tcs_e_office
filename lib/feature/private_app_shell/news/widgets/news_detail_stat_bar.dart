import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tcs_e_office/core/configs/theme/app_colors.dart';

class NewsDetailStatBar extends StatelessWidget {
  final int totalViewed;
  final int totalLike;
  final int totalComment;
  final bool isLiked;
  final VoidCallback? onLikeTap;
  final VoidCallback? onCommentTap;

  const NewsDetailStatBar({
    super.key,
    required this.totalViewed,
    required this.totalLike,
    required this.totalComment,
    this.isLiked = false,
    this.onLikeTap,
    this.onCommentTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(color: Colors.grey[200], height: 1),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.remove_red_eye_outlined,
                value: '$totalViewed',
                label: 'Lượt xem',
              ),
              _buildStatItem(
                icon: isLiked
                    ? Icons.thumb_up
                    : Icons.thumb_up_off_alt_outlined,
                value: '$totalLike',
                label: 'Thích',
                isActive: isLiked,
                activeColor: AppColors.primary,
                onTap: onLikeTap,
              ),
              _buildStatItem(
                icon: Icons.chat_bubble_outline_rounded,
                value: '$totalComment',
                label: 'Bình luận',
                onTap: onCommentTap,
              ),
            ],
          ),
        ),
        Divider(color: Colors.grey[200], height: 1),
      ],
    );
  }

  // Bỏ _buildDivider dọc vì style mới không dùng

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    bool isActive = false,
    Color? activeColor,
    VoidCallback? onTap,
  }) {
    final color = isActive
        ? (activeColor ?? AppColors.primary)
        : AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22.sp, color: color),
            SizedBox(height: 4.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}
