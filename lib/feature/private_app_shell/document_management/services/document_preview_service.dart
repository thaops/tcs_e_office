import 'package:tcs_e_office/common/repositoty/dio_api.dart';
import 'package:tcs_e_office/common/Services/api_endpoints.dart';

class DocumentPreviewService {
  final DioApi _dioApi = DioApi();

  static final Map<String, String> _previewUrlCache = {};

  Future<String?> getPreviewUrl(String documentId) async {
    if (_previewUrlCache.containsKey(documentId)) {
      return _previewUrlCache[documentId];
    }

    try {
      final url = ApiEndpoints.previewDocument(documentId);
      final response = await _dioApi.get(url);

      if (response.statusCode == 200) {
        final responseData = response.data;
        String? previewUrl;

        if (responseData is String) {
          previewUrl = responseData;
        } else if (responseData is Map<String, dynamic>) {
          previewUrl = responseData['data'] as String?;
        }

        if (previewUrl != null) {
          _previewUrlCache[documentId] = previewUrl;
          return previewUrl;
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  static void clearCacheForDocument(String documentId) {
    _previewUrlCache.remove(documentId);
  }

  static void clearAllCache() {
    _previewUrlCache.clear();
  }
}
