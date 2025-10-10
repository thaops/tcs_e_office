import 'package:get/get.dart';
import 'package:tcs_e_office/common/repositoty/dio_api.dart';
import 'package:tcs_e_office/common/Services/api_endpoints.dart';
import 'package:tcs_e_office/common/utils/api_response_handler.dart';
import '../models/task_detail_model.dart';
import 'task_api_service.dart';
// Controller chi tiết

class TaskDetailController extends GetxController {
  final String taskId;
  TaskDetailController(this.taskId);

  final DioApi _dioApi = DioApi();
  final TaskApiService _taskApiService = TaskApiService();

  final RxBool isLoading = false.obs;
  final RxBool isCompleting = false.obs;
  final RxBool isForwarding = false.obs;
  final Rxn<TaskDetailModel> detail = Rxn<TaskDetailModel>();
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDetail();
  }

  Future<void> fetchDetail() async {
    try {
      isLoading.value = true;
      error.value = '';

      final url = ApiEndpoints.getTaskById(taskId);
      final response = await _dioApi.get(url);
      print('🔍 TaskDetailController: Response: ${response.data}');

      // Sử dụng ApiResponseHandler để parse response
      final result = ApiResponseHandler.handleResponse<TaskDetailModel>(
        response,
        TaskDetailModel.fromJson,
      );

      if (result.isSuccess) {
        detail.value = result.data!;
      } else {
        error.value = result.error ?? 'Lỗi không xác định';
      }
    } catch (e) {
      error.value = 'Đã xảy ra lỗi khi tải chi tiết: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Hoàn thành task
  Future<bool> completeTask() async {
    try {
      isCompleting.value = true;
      error.value = '';

      final success = await _taskApiService.completeTask(taskId);
      print('🔍 TaskDetailController: Complete task success: $success');

      if (success) {
        await fetchDetail();
        return true;
      } else {
        error.value = 'Không thể hoàn thành công việc';
        return false;
      }
    } catch (e) {
      error.value = 'Lỗi khi hoàn thành công việc: $e';
      return false;
    } finally {
      isCompleting.value = false;
    }
  }

  /// Chuyển tiếp task
  Future<bool> forwardTask({
    required List<String> selectedEmployeeCodes,
    required String dueDate,
  }) async {
    try {
      isForwarding.value = true;
      error.value = '';

      final success = await _taskApiService.forwardTaskWithEmployees(
        taskId: taskId,
        dueDate: dueDate,
        selectedEmployeeCodes: selectedEmployeeCodes,
      );
      print('🔍 TaskDetailController: Forward task success: $success');

      if (success) {
        await fetchDetail();
        return true;
      } else {
        error.value = 'Không thể chuyển tiếp công việc';
        return false;
      }
    } catch (e) {
      print('🔍 TaskDetailController: Forward task error: $e');
      error.value = 'Lỗi khi chuyển tiếp công việc: $e';
      return false;
    } finally {
      isForwarding.value = false;
    }
  }
}
