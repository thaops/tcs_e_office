import 'package:tcs_e_office/common/Services/api_endpoints.dart';
import 'package:tcs_e_office/common/repositoty/dio_api.dart';
import '../models/news_comment_model.dart';

class NewsCommentService {
  final DioApi _dioApi = DioApi();

  Future<NewsCommentsResponse> getComments(String newsId) async {
    try {
      final request = GetNewsCommentsRequest(newsId: newsId);
      final response = await _dioApi.post(
        ApiEndpoints.getNewsComments,
        data: request.toJson(),
      );
      return NewsCommentsResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Lỗi khi lấy bình luận: $e');
    }
  }

  Future<String?> addComment(AddNewsCommentRequest request) async {
    try {
      final response = await _dioApi.post(
        ApiEndpoints.addNewsComment,
        data: request.toJson(),
      );

      if (response.data is Map<String, dynamic>) {
        final statusCode =
            response.data['statusCode'] ?? response.data['StatusCode'];
        if (statusCode == 200) {
          return response.data['data']?.toString() ?? 'Thành công';
        }
      }
      return null;
    } catch (e) {
      throw Exception('Lỗi khi gửi bình luận: $e');
    }
  }
}
