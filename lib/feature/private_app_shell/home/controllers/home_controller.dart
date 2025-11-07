import 'package:get/get.dart';
import 'package:tcs_e_office/feature/private_app_shell/home/models/task_count_model.dart';
import 'package:tcs_e_office/feature/private_app_shell/home/services/task_count_service.dart';
import 'package:tcs_e_office/feature/private_app_shell/home/models/document_count_model.dart';
import 'package:tcs_e_office/feature/private_app_shell/home/services/document_count_service.dart';
import 'package:tcs_e_office/common/utils/api_response_handler.dart';

/// Controller cho Home Screen
class HomeController extends GetxController {
  final TaskCountService _taskCountService = TaskCountService();
  final DocumentCountService _documentCountService = DocumentCountService();

  // Observable state
  final _taskCount = Rxn<TaskCountModel>();
  final _documentCount = Rxn<DocumentCountModel>();
  final _isLoading = false.obs;
  final _error = RxnString();

  // Getters
  TaskCountModel? get taskCount => _taskCount.value;
  DocumentCountModel? get documentCount => _documentCount.value;
  bool get isLoading => _isLoading.value;
  String? get error => _error.value;

  // Task count getters cho UI
  TaskCountData? get assignedToMe => _taskCount.value?.assignedToMe;
  TaskCountData? get assignedByMe => _taskCount.value?.assignedByMe;

  @override
  void onInit() {
    super.onInit();
    // Tự động load data ngầm khi khởi tạo (không hiển thị loading)
    loadAllData(silent: true);
  }

  /// Load tất cả data (task count và document count)
  /// [silent] = true: load ngầm không hiển thị loading indicator
  Future<void> loadAllData({bool silent = false}) async {
    try {
      if (!silent) {
        _isLoading.value = true;
      }
      _error.value = null;

      // Load cả 2 API song song
      final results = await Future.wait([
        _taskCountService.getTaskCount(),
        _documentCountService.getDocumentCount(),
      ]);

      final taskResult = results[0] as ApiResult<TaskCountModel>;
      final documentResult = results[1] as ApiResult<DocumentCountModel>;

      // Xử lý task count result
      if (taskResult.isSuccess) {
        _taskCount.value = taskResult.data;
      } else {
        _taskCount.value = null;
      }

      // Xử lý document count result
      if (documentResult.isSuccess) {
        _documentCount.value = documentResult.data;
      } else {
        _documentCount.value = null;
      }

      // Nếu cả 2 đều fail thì mới set error
      if (!taskResult.isSuccess && !documentResult.isSuccess) {
        _error.value =
            'Không thể lấy dữ liệu thống kê. Vui lòng thử lại sau.';
      } else {
        _error.value = null;
      }
    } catch (e) {
      _error.value = 'Lỗi không mong muốn: $e';
      _taskCount.value = null;
      _documentCount.value = null;
    } finally {
      if (!silent) {
        _isLoading.value = false;
      }
    }
  }

  /// Load task count từ API (giữ lại để tương thích)
  Future<void> loadTaskCount() async {
    await loadAllData();
  }

  /// Refresh data (hiển thị loading khi refresh)
  Future<void> refresh() async {
    await loadAllData(silent: false);
  }

  /// Kiểm tra có data không
  bool get hasData => _taskCount.value != null;

  /// Kiểm tra có lỗi không
  bool get hasError => _error.value != null;
}
