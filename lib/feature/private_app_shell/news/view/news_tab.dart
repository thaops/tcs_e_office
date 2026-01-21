import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tcs_e_office/common/widgets/common_app_bar.dart';
import 'package:tcs_e_office/core/configs/theme/app_colors.dart';
import '../binding/news_binding.dart';
import '../controllers/news_controller.dart';
import '../widgets/news_card_widget.dart';
import 'news_detail_screen.dart';

class NewsTab extends StatefulWidget {
  const NewsTab({super.key});

  @override
  State<NewsTab> createState() => _NewsTabState();
}

class _NewsTabState extends State<NewsTab> {
  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<NewsController>()) {
      NewsBinding().dependencies();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NewsController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: CommonAppBar(title: 'Tin tức'),
      body: Column(
        children: [
          _buildSearchBar(controller),
          Expanded(child: _buildNewsList(controller)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(NewsController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      color: Colors.white,
      child: TextField(
        controller: controller.state.searchController,
        onChanged: controller.onSearchChanged,
        style: TextStyle(fontSize: 14.sp),
        decoration: InputDecoration(
          hintText: 'Tìm kiếm tin tức...',
          hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          prefixIcon: Obx(() {
            if (controller.state.isSearching.value) {
              return Padding(
                padding: EdgeInsets.all(12.w),
                child: SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              );
            }
            return Icon(Icons.search, size: 20.sp, color: Colors.grey[600]);
          }),
          suffixIcon: Obx(() {
            if (controller.state.keyword.value.isNotEmpty) {
              return IconButton(
                icon: Icon(Icons.clear, size: 20.sp, color: Colors.grey[600]),
                onPressed: controller.clearSearch,
              );
            }
            return const SizedBox.shrink();
          }),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: AppColors.primary, width: 1.5),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
        ),
      ),
    );
  }

  Widget _buildNewsList(NewsController controller) {
    return Obx(() {
      if (controller.state.isInitialLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.state.newsList.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.article_outlined,
                size: 64.sp,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16.h),
              Text(
                controller.state.keyword.value.isNotEmpty
                    ? 'Không tìm thấy kết quả'
                    : 'Không có tin tức',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
              ),
              SizedBox(height: 16.h),
              ElevatedButton.icon(
                onPressed: controller.refresh,
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text(
                  'Thử lại',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refresh,
        color: AppColors.primary,
        child: NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            if (scrollInfo.metrics.pixels ==
                scrollInfo.metrics.maxScrollExtent) {
              controller.loadMore();
            }
            return false;
          },
          child: ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            itemCount:
                controller.state.newsList.length +
                (controller.state.hasMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.state.newsList.length) {
                return Padding(
                  padding: EdgeInsets.all(16.w),
                  child: const Center(child: CircularProgressIndicator()),
                );
              }

              final news = controller.state.newsList[index];
              return NewsCardWidget(
                news: news,
                onTap: () => _showNewsDetail(news.id, news.thumbAttachmentUrl),
              );
            },
          ),
        ),
      );
    });
  }

  void _showNewsDetail(int newsId, String? thumbUrl) {
    Get.to(
      () => NewsDetailScreen(newsId: newsId, thumbUrl: thumbUrl),
      transition: Transition.cupertino,
    );
  }
}
