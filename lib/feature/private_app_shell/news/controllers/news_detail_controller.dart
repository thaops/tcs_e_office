import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/news_models.dart';
import '../models/news_comment_model.dart';
import '../services/news_service.dart';
import '../services/news_comment_service.dart';
import 'package:tcs_e_office/common/utils/app_snackbar.dart';
import 'news_controller.dart';

class NewsDetailController extends GetxController {
  final NewsService _newsService;
  final NewsCommentService _commentService;
  final int newsId;
  final String? thumbUrl;

  NewsDetailController({
    required this.newsId,
    this.thumbUrl,
    NewsService? newsService,
    NewsCommentService? commentService,
  }) : _newsService = newsService ?? NewsService(),
       _commentService = commentService ?? NewsCommentService();

  final isLoading = true.obs;
  final isLoadingComments = false.obs;
  final isSendingComment = false.obs;

  final error = RxnString();
  final newsDetail = Rxn<NewsDetailModel>();
  final newsBasic = Rxn<NewsModel>();
  final comments = <NewsCommentModel>[].obs;
  final replyingTo = Rxn<NewsCommentModel>();

  String get displayThumbUrl =>
      thumbUrl ?? newsBasic.value?.thumbAttachmentUrl ?? '';

  @override
  void onInit() {
    super.onInit();
    loadNewsDetail();
  }

  Future<void> loadNewsDetail() async {
    try {
      isLoading.value = true;
      error.value = null;

      if (Get.isRegistered<NewsController>()) {
        final controller = Get.find<NewsController>();
        newsBasic.value = controller.state.newsList.firstWhereOrNull(
          (n) => n.id == newsId,
        );
      }

      final response = await _newsService.getNewsById(newsId.toString());

      if (response.statusCode == 200 && response.data != null) {
        newsDetail.value = response.data;
        loadComments();
      } else {
        error.value = 'Không thể tải chi tiết tin tức';
      }
    } catch (e) {
      error.value = 'Đã xảy ra lỗi: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadComments() async {
    isLoadingComments.value = true;
    try {
      final response = await _commentService.getComments(newsId.toString());
      if (response.statusCode == 200) {
        comments.assignAll(response.data);
      }
    } catch (e) {
      // Silent fail for comments
    } finally {
      isLoadingComments.value = false;
    }
  }

  Future<void> submitComment(String content) async {
    isSendingComment.value = true;
    try {
      final request = AddNewsCommentRequest(
        newsId: newsId.toString(),
        commentText: content,
        parentId: replyingTo.value?.id,
      );

      final message = await _commentService.addComment(request);
      if (message != null) {
        replyingTo.value = null;
        _showCommentSuccessDialog(message);
      }
    } catch (e) {
      AppSnackbar.error('Không thể gửi bình luận');
    } finally {
      isSendingComment.value = false;
    }
  }

  void _showCommentSuccessDialog(String message) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('Thành công'),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 15)),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Đóng')),
        ],
      ),
    );
  }

  void handleReply(NewsCommentModel comment) {
    replyingTo.value = comment;
  }

  void cancelReply() {
    replyingTo.value = null;
  }

  Future<void> refresh() async {
    await loadNewsDetail();
  }

  Future<void> toggleLike() async {
    if (newsDetail.value?.isLiked == true) return;

    try {
      final success = await _newsService.toggleLike(newsId.toString());
      if (success && newsDetail.value != null) {
        final current = newsDetail.value!;
        newsDetail.value = NewsDetailModel(
          id: current.id,
          title: current.title,
          content: current.content,
          createdDate: current.createdDate,
          totalViewed: current.totalViewed,
          totalLike: current.totalLike + 1,
          totalComment: current.totalComment,
          isLiked: true,
        );
      }
    } catch (e) {
      AppSnackbar.error('Không thể thực hiện');
    }
  }
}
