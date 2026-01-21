import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tcs_e_office/core/configs/theme/app_colors.dart';
import '../models/news_models.dart';

class NewsCardWidget extends StatelessWidget {
  final NewsModel news;
  final VoidCallback? onTap;
  final bool isCompact;

  const NewsCardWidget({
    super.key,
    required this.news,
    this.onTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final marginH = isCompact ? 8.0 : 16.0;
    final marginV = isCompact ? 6.0 : 8.0;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: marginH, vertical: marginV),
      elevation: 2,
      color: Colors.white,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildBannerImage(), _buildContent()],
        ),
      ),
    );
  }

  Widget _buildBannerImage() {
    final hasImage = news.thumbAttachmentUrl.isNotEmpty;
    final imageHeight = isCompact ? 140.0 : 180.0;

    return Container(
      width: double.infinity,
      height: imageHeight,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.r),
          topRight: Radius.circular(12.r),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.r),
          topRight: Radius.circular(12.r),
        ),
        child: hasImage
            ? CachedNetworkImage(
                imageUrl: news.thumbAttachmentUrl,
                width: double.infinity,
                height: imageHeight,
                fit: BoxFit.cover,
                fadeInDuration: Duration.zero,
                fadeOutDuration: Duration.zero,
                memCacheHeight: 400,
                maxHeightDiskCache: 400,
                placeholder: (_, __) => Container(
                  color: Colors.grey.shade200,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => _buildPlaceholder(),
              )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.primary.withOpacity(0.1),
      child: Center(
        child: Icon(
          Icons.newspaper,
          size: 48.sp,
          color: AppColors.primary.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBadges(),
          SizedBox(height: 8.h),
          _buildTitle(),
          SizedBox(height: 8.h),
          _buildMeta(),
        ],
      ),
    );
  }

  Widget _buildBadges() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            news.categoryCode.isNotEmpty ? news.categoryCode : 'Tin tức',
            style: TextStyle(
              fontSize: 10.sp,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (news.isNew) ...[
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              'NEW',
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      news.title,
      style: TextStyle(
        fontSize: isCompact ? 14.sp : 16.sp,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
        height: 1.3,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildMeta() {
    return Row(
      children: [
        Icon(Icons.access_time, size: 14.sp, color: Colors.grey),
        SizedBox(width: 4.w),
        Text(
          news.createdDate,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
        ),
        const Spacer(),
        Icon(Icons.visibility, size: 14.sp, color: Colors.grey),
        SizedBox(width: 4.w),
        Text(
          '${news.totalViewed}',
          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
        ),
        SizedBox(width: 12.w),
        Icon(Icons.thumb_up_outlined, size: 14.sp, color: Colors.grey),
        SizedBox(width: 4.w),
        Text(
          '${news.totalLike}',
          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
        ),
      ],
    );
  }
}
