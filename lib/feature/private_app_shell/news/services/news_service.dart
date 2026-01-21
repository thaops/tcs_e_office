import 'package:tcs_e_office/common/Services/api_endpoints.dart';
import 'package:tcs_e_office/common/repositoty/dio_api.dart';
import 'package:tcs_e_office/feature/private_app_shell/news/models/news_models.dart';

class NewsService {
  final DioApi _dioApi = DioApi();

  Future<NewsResponse> getListNews(NewsRequest request) async {
    try {
      final response = await _dioApi.post(
        ApiEndpoints.getListNews,
        data: request.toJson(),
      );
      return NewsResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<NewsDetailResponse> getNewsById(String newsId) async {
    try {
      final request = NewsDetailRequest(id: newsId);
      final response = await _dioApi.post(
        ApiEndpoints.getNewsDetail,
        data: request.toJson(),
      );
      return NewsDetailResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<bool> toggleLike(String newsId) async {
    try {
      final response = await _dioApi.post(
        ApiEndpoints.doReaction,
        data: {'Id': newsId, 'Reaction': 1},
      );
      if (response.data is Map<String, dynamic>) {
        final statusCode =
            response.data['statusCode'] ?? response.data['StatusCode'];
        return statusCode == 200;
      }
      return false;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
