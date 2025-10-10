import 'package:get/get.dart';
import 'package:tcs_e_office/feature/private_app_shell/home/models/task_count_model.dart';
import 'package:tcs_e_office/feature/private_app_shell/home/services/task_count_service.dart';

/// Controller cho Home Screen
class HomeController extends GetxController {
  final TaskCountService _taskCountService = TaskCountService();

  // Observable state
  final _taskCount = Rxn<TaskCountModel>();
  final _isLoading = false.obs;
  final _error = RxnString();

  // Getters
  TaskCountModel? get taskCount => _taskCount.value;
  bool get isLoading => _isLoading.value;
  String? get error => _error.value;

  // Task count getters cho UI
  TaskCountData? get assignedToMe => _taskCount.value?.assignedToMe;
  TaskCountData? get assignedByMe => _taskCount.value?.assignedByMe;

  @override
  void onInit() {
    super.onInit();
    // Tự động load data khi khởi tạo
    loadTaskCount();
  }

  /// Load task count từ API
  Future<void> loadTaskCount() async {
    try {
      _isLoading.value = true;
      _error.value = null;

      final result = await _taskCountService.getTaskCount();

      if (result.isSuccess) {
        _taskCount.value = result.data;
        _error.value = null;
      } else {
        _error.value = result.error ?? 'Không thể lấy dữ liệu task count';
        _taskCount.value = null;
      }
    } catch (e) {
      _error.value = 'Lỗi không mong muốn: $e';
      _taskCount.value = null;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Refresh data
  Future<void> refresh() async {
    await loadTaskCount();
  }

  /// Kiểm tra có data không
  bool get hasData => _taskCount.value != null;

  /// Kiểm tra có lỗi không
  bool get hasError => _error.value != null;
}
