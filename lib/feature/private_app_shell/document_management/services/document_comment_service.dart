import 'package:dio/dio.dart' as dioLib;
import 'package:tcs_e_office/common/repositoty/dio_api.dart';
import 'package:tcs_e_office/common/Services/api_endpoints.dart';

class DocumentCommentService {
  static final DioApi _dioApi = DioApi();

  static Future<Map<String, dynamic>> addComment({
    required String comment,
    required String documentId,
  }) async {
    try {
      final formData = dioLib.FormData.fromMap({
        'DocumentId': documentId,
        'Comment': comment,
      });

      final response = await _dioApi.post(
        ApiEndpoints.addComment,
        data: formData,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        final isSuccess = responseData['data'] == true;
        final message =
            responseData['message'] as String? ??
            (isSuccess ? 'Successful.' : 'Có lỗi xảy ra');

        return {'success': isSuccess, 'message': message};
      }

      final responseData = response.data;
      final message =
          responseData['message'] as String? ??
          'Lỗi server: ${response.statusCode}';

      return {'success': false, 'message': message};
    } catch (e) {
      String errorMessage = 'Lỗi khi gửi comment: $e';

      if (e is dioLib.DioException && e.response != null) {
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message'] as String? ?? errorMessage;
        }
      }

      return {'success': false, 'message': errorMessage};
    }
  }
}
