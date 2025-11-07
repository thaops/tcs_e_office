import 'package:tcs_e_office/common/Services/api_endpoints.dart';
import 'package:tcs_e_office/common/repositoty/dio_api.dart';
import 'package:tcs_e_office/common/utils/api_response_handler.dart';
import 'package:tcs_e_office/feature/private_app_shell/home/models/document_count_model.dart';

/// Service để call API lấy document count
class DocumentCountService {
  final DioApi _dioApi = DioApi();

  /// Lấy document count từ API
  Future<ApiResult<DocumentCountModel>> getDocumentCount() async {
    try {
      final response = await _dioApi.get(ApiEndpoints.getDocumentCountByStatus);

      // Parse response thủ công vì ApiResponseHandler expect Map nhưng data là List
      if (response.statusCode != 200) {
        return ApiResult<DocumentCountModel>.error(
          'HTTP Error: ${response.statusCode}',
          response.statusCode,
        );
      }

      if (response.data == null) {
        return ApiResult<DocumentCountModel>.error('Response data is null');
      }

      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        final statusCode = responseData['statusCode'] ?? responseData['StatusCode'];
        final message = responseData['message'] ?? responseData['Message'] as String?;

        if (statusCode == 200) {
          final data = responseData['data'];
          if (data != null && data is List) {
            try {
              final documentCount = DocumentCountModel.fromList(data);
              return ApiResult<DocumentCountModel>.success(documentCount, message);
            } catch (e) {
              return ApiResult<DocumentCountModel>.error('Parse error: $e');
            }
          } else {
            return ApiResult<DocumentCountModel>.error('No data found in response');
          }
        } else {
          return ApiResult<DocumentCountModel>.error(
            message ?? 'API Error: $statusCode',
            statusCode,
          );
        }
      } else {
        return ApiResult<DocumentCountModel>.error('Response is not a valid format');
      }
    } catch (e) {
      return ApiResult<DocumentCountModel>.error(
          'Lỗi khi lấy document count: $e');
    }
  }
}

