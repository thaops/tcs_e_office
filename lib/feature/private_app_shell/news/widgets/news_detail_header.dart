import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tcs_e_office/core/configs/theme/app_colors.dart';

class NewsDetailHeader extends StatelessWidget {
  final String? thumbUrl;
  final int newsId;
  final String? categoryCode;
  final String title;
  final String createdDate;
  final String? creator;

  const NewsDetailHeader({
    super.key,
    this.thumbUrl,
    required this.newsId,
    this.categoryCode,
    required this.title,
    required this.createdDate,
    this.creator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (thumbUrl?.isNotEmpty == true) _buildHeroImage(),
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCategoryBadge(),
              SizedBox(height: 12.h),
              _buildTitle(),
              SizedBox(height: 12.h),
              _buildMeta(),
              SizedBox(height: 16.h),
              Divider(color: Colors.grey[200], thickness: 1),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroImage() {
    return Hero(
      tag: 'news_image_$newsId',
      child: CachedNetworkImage(
        imageUrl: thumbUrl!,
        width: double.infinity,
        height: 220.h,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          height: 220.h,
          color: Colors.grey[200],
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        ),
        errorWidget: (_, __, ___) => Container(
          height: 220.h,
          color: Colors.grey[200],
          child: Icon(
            Icons.image_not_supported,
            size: 48.sp,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBadge() {
    if (categoryCode?.isNotEmpty != true) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(25),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        categoryCode!,
        style: TextStyle(
          fontSize: 12.sp,
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      title,
      style: TextStyle(
        fontSize: 22.sp,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
        height: 1.3,
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _buildMeta() {
    return Row(
      children: [
        Icon(Icons.access_time, size: 16.sp, color: Colors.grey[500]),
        SizedBox(width: 4.w),
        Text(
          createdDate,
          style: TextStyle(fontSize: 13.sp, color: Colors.grey[500]),
        ),
        if (creator?.isNotEmpty == true) ...[
          SizedBox(width: 16.w),
          Icon(Icons.person_outline, size: 16.sp, color: Colors.grey[500]),
          SizedBox(width: 4.w),
          Expanded(
            child: Text(
              creator!,
              style: TextStyle(fontSize: 13.sp, color: Colors.grey[500]),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }
}
