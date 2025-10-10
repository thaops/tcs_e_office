import 'package:tcs_e_office/common/repositoty/dio_api.dart';
import 'package:tcs_e_office/common/Services/api_endpoints.dart';

class CommentService {
  static final DioApi _dioApi = DioApi();

  /// Gửi comment mới
  static Future<bool> addComment({
    required String comment,
    required String documentId,
    String? parentId,
    String? replyId,
  }) async {
    try {
      final response = await _dioApi.post(
        ApiEndpoints.addComment,
        data: {
          'comment': comment,
          'documentId': documentId,
          'parentId': parentId,
          'replyId': replyId,
        },
      );

      if (response.statusCode == 200) {
        return response.data['data'] == true;
      } else {
        throw Exception('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi khi gửi comment: $e');
    }
  }

  /// Lấy danh sách comment của document
  static Future<List<Map<String, dynamic>>> getComments(
    String documentId,
  ) async {
    try {
      final response = await _dioApi.get(ApiEndpoints.getComments(documentId));

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['data'] ?? []);
      } else {
        throw Exception('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi khi lấy comment: $e');
    }
  }
}
