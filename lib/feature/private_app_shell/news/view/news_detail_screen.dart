import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tcs_e_office/core/configs/theme/app_colors.dart';
import '../controllers/news_detail_controller.dart';
import '../widgets/news_detail_header.dart';
import '../widgets/news_detail_content.dart';
import '../widgets/news_detail_stat_bar.dart';
import '../widgets/news_comments_section.dart';
import '../widgets/news_comment_input.dart';

class NewsDetailScreen extends StatelessWidget {
  final int newsId;
  final String? thumbUrl;

  const NewsDetailScreen({super.key, required this.newsId, this.thumbUrl});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      NewsDetailController(newsId: newsId, thumbUrl: thumbUrl),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildBody(controller)),
          _buildCommentInput(controller),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: Icon(Icons.arrow_back_ios, size: 20.sp, color: Colors.white),
      ),
      title: Text(
        'Chi tiết tin tức',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildBody(NewsDetailController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.error.value != null) {
        return _buildErrorState(controller);
      }

      if (controller.newsDetail.value == null) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        onRefresh: controller.refresh,
        color: AppColors.primary,
        child: _buildContent(controller),
      );
    });
  }

  Widget _buildErrorState(NewsDetailController controller) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.sp, color: Colors.red[300]),
            SizedBox(height: 16.h),
            Obx(
              () => Text(
                controller.error.value ?? '',
                style: TextStyle(fontSize: 15.sp, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: controller.loadNewsDetail,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text(
                'Thử lại',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.article_outlined, size: 64.sp, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text(
            'Không tìm thấy tin tức',
            style: TextStyle(fontSize: 15.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(NewsDetailController controller) {
    return Obx(() {
      final detail = controller.newsDetail.value!;
      final basic = controller.newsBasic.value;
      final thumbUrl = controller.displayThumbUrl;

      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NewsDetailHeader(
              thumbUrl: thumbUrl.isNotEmpty ? thumbUrl : null,
              newsId: newsId,
              categoryCode: basic?.categoryCode,
              title: detail.title,
              createdDate: detail.createdDate,
              creator: basic?.creator,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  NewsDetailContent(content: detail.content),
                  SizedBox(height: 24.h),
                  NewsDetailStatBar(
                    totalViewed: detail.totalViewed,
                    totalLike: detail.totalLike,
                    totalComment: controller.comments.length,
                    isLiked: detail.isLiked,
                    onLikeTap: controller.toggleLike,
                    onCommentTap: () {},
                  ),
                  SizedBox(height: 24.h),
                  Divider(color: Colors.grey[200], thickness: 1),
                  SizedBox(height: 16.h),
                  NewsCommentsSection(
                    comments: controller.comments,
                    isLoading: controller.isLoadingComments.value,
                    onAddComment: () {},
                  ),
                  SizedBox(height: 100.h),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCommentInput(NewsDetailController controller) {
    return Obx(
      () => NewsCommentInput(
        replyToName: controller.replyingTo.value?.creator,
        isLoading: controller.isSendingComment.value,
        onCancelReply: controller.cancelReply,
        onSubmit: controller.submitComment,
      ),
    );
  }
}
