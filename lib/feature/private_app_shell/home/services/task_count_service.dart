import 'package:tcs_e_office/common/Services/api_endpoints.dart';
import 'package:tcs_e_office/common/repositoty/dio_api.dart';
import 'package:tcs_e_office/common/utils/api_response_handler.dart';
import 'package:tcs_e_office/feature/private_app_shell/home/models/task_count_model.dart';

/// Service để call API lấy task count
class TaskCountService {
  final DioApi _dioApi = DioApi();

  /// Lấy task count từ API
  Future<ApiResult<TaskCountModel>> getTaskCount() async {
    try {
      final response = await _dioApi.get(ApiEndpoints.getTaskCount);

      return ApiResponseHandler.handleResponse<TaskCountModel>(
        response,
        TaskCountModel.fromJson,
      );
    } catch (e) {
      return ApiResult<TaskCountModel>.error('Lỗi khi lấy task count: $e');
    }
  }
}
