import 'package:dio/dio.dart' as dioLib;
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
      // Tạo FormData cho multipart/form-data
      final form = dioLib.FormData();

      void addField(String key, String? value) {
        if (value != null && value.isNotEmpty) {
          form.fields.add(MapEntry(key, value));
        }
      }

      // Thêm các field với tên đúng (DocumentId, Comment)
      addField('DocumentId', documentId);
      addField('Comment', comment);
      addField('ParentId', parentId);
      addField('ReplyId', replyId);

      final response = await _dioApi.post(
        ApiEndpoints.addComment,
        data: form,
        options: dioLib.Options(
          headers: {..._dioApi.header, 'Content-Type': 'multipart/form-data'},
        ),
      );
      print("response.data: ${response.data}");

      // Kiểm tra HTTP status code
      if (response.statusCode != 200) {
        throw Exception('HTTP Error: ${response.statusCode}');
      }

      // Parse response data
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;

        // Kiểm tra API status code
        final statusCode =
            responseData['statusCode'] ?? responseData['StatusCode'];
        final message =
            responseData['message'] ?? responseData['Message'] as String?;
        final data = responseData['data'];

        if (statusCode == 200) {
          // API thành công, trả về giá trị boolean
          return data == true;
        } else {
          throw message ?? statusCode.toString();
        }
      } else {
        throw Exception('Response format không hợp lệ');
      }
    } catch (e) {
      if (e is dioLib.DioException) {
        final data = e.response?.data;
        String? serverMessage;

        if (data is Map) {
          serverMessage = (data['message'] as String?)?.trim();
        }

        throw Exception(
          serverMessage?.isNotEmpty == true
              ? serverMessage!
              : 'Lỗi khi gửi comment: $e',
        );
      }
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
