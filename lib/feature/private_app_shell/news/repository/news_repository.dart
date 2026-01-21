import 'package:tcs_e_office/feature/private_app_shell/news/models/news_models.dart';
import 'package:tcs_e_office/feature/private_app_shell/news/services/news_service.dart';

class NewsRepository {
  final NewsService _service;
  NewsRepository({NewsService? service})
    : _service = service ?? NewsService();

  Future<NewsResponse> getListNews({
    String keyword = '',
    int pageIndex = 1,
    int pageSize = 10,
  }) {
    return _service.getListNews(
      NewsRequest(keyword: keyword, pageIndex: pageIndex, pageSize: pageSize),
    );
  }
}
