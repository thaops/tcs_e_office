import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tcs_e_office/common/repositoty/dio_api.dart';
import 'package:tcs_e_office/common/Services/api_endpoints.dart';
import '../models/task_model.dart';
import '../models/filter_model.dart';

class WorkManagementController extends GetxController {
  // DioApi instance
  final DioApi _dioApi = DioApi();

  // Tab hiện tại (0: Việc tôi giao, 1: Việc giao đến tôi)
  final RxInt currentTab = 0.obs;

  // Danh sách công việc tôi giao
  final RxList<TaskModel> tasksByMe = <TaskModel>[].obs;
  final RxBool isLoadingByMe = false.obs;
  final RxInt totalRecordByMe = 0.obs;

  // Danh sách công việc giao đến tôi
  final RxList<TaskModel> tasksToMe = <TaskModel>[].obs;
  final RxBool isLoadingToMe = false.obs;
  final RxInt totalRecordToMe = 0.obs;

  // Tìm kiếm riêng biệt cho từng tab
  final RxString searchQueryByMe = ''.obs;
  final RxString searchQueryToMe = ''.obs;
  final TextEditingController searchControllerByMe = TextEditingController();
  final TextEditingController searchControllerToMe = TextEditingController();
  Timer? _searchDebounceByMe;
  Timer? _searchDebounceToMe;

  // Phân trang
  final RxInt currentPageByMe = 1.obs;
  final RxInt currentPageToMe = 1.obs;
  final int pageSize = 20;

  // Filter cho từng tab
  final Rx<FilterModel> filterByMe = FilterModel.empty().obs;
  final Rx<FilterModel> filterToMe = FilterModel.empty().obs;

  // Danh sách gốc (trước khi filter)
  final RxList<TaskModel> _originalTasksByMe = <TaskModel>[].obs;
  final RxList<TaskModel> _originalTasksToMe = <TaskModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadTasksByMe();
    loadTasksToMe();
  }

  @override
  void onClose() {
    _searchDebounceByMe?.cancel();
    _searchDebounceToMe?.cancel();
    searchControllerByMe.dispose();
    searchControllerToMe.dispose();
    super.onClose();
  }

  // Chuyển tab
  void changeTab(int index) {
    currentTab.value = index;
  }

  // Tải danh sách công việc tôi giao
  Future<void> loadTasksByMe({bool refresh = false}) async {
    if (refresh) {
      currentPageByMe.value = 1;
      tasksByMe.clear();
    }

    try {
      isLoadingByMe.value = true;

      final request = TaskRequest(
        pageIndex: currentPageByMe.value,
        pageSize: pageSize,
        type: 2,
        keyword: searchQueryByMe.value.isNotEmpty
            ? searchQueryByMe.value
            : null,
        // startDate: filterByMe.value.startDate,
        dueDate: filterByMe.value.dueDate,
      );

      final response = await _dioApi.post(
        ApiEndpoints.getTasks,
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final taskResponse = TaskResponse.fromJson(response.data);

        if (refresh) {
          _originalTasksByMe.value = taskResponse.data;
          _applyFilterByMe();
        } else {
          _originalTasksByMe.addAll(taskResponse.data);
          _applyFilterByMe();
        }

        totalRecordByMe.value = taskResponse.totalRecord;
      } else {
        throw Exception('Failed to load tasks: ${response.statusCode}');
      }
    } catch (e) {
    } finally {
      isLoadingByMe.value = false;
    }
  }

  // Tải danh sách công việc giao đến tôi
  Future<void> loadTasksToMe({bool refresh = false}) async {
    if (refresh) {
      currentPageToMe.value = 1;
      tasksToMe.clear();
    }

    try {
      isLoadingToMe.value = true;

      final request = TaskRequest(
        pageIndex: currentPageToMe.value,
        pageSize: pageSize,
        type: 1, // Việc giao đến tôi
        keyword: searchQueryToMe.value.isNotEmpty
            ? searchQueryToMe.value
            : null,
        // startDate: filterToMe.value.startDate,
        dueDate: filterToMe.value.dueDate,
      );

      final response = await _dioApi.post(
        ApiEndpoints.getTasks,
        data: request.toJson(),
      );
      print('responsesss: ${response.data}');

      if (response.statusCode == 200) {
        final taskResponse = TaskResponse.fromJson(response.data);

        if (refresh) {
          _originalTasksToMe.value = taskResponse.data;
          _applyFilterToMe();
        } else {
          _originalTasksToMe.addAll(taskResponse.data);
          _applyFilterToMe();
        }

        totalRecordToMe.value = taskResponse.totalRecord;
      } else {
        throw Exception('Failed to load tasks: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể tải danh sách công việc: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingToMe.value = false;
    }
  }

  // Tải thêm dữ liệu (phân trang)
  Future<void> loadMore() async {
    if (currentTab.value == 0) {
      if (tasksByMe.length < totalRecordByMe.value) {
        currentPageByMe.value++;
        await loadTasksByMe();
      }
    } else {
      if (tasksToMe.length < totalRecordToMe.value) {
        currentPageToMe.value++;
        await loadTasksToMe();
      }
    }
  }

  // Làm mới dữ liệu
  Future<void> refresh() async {
    if (currentTab.value == 0) {
      await loadTasksByMe(refresh: true);
    } else {
      await loadTasksToMe(refresh: true);
    }
  }

  // Tìm kiếm cho tab "Việc tôi giao"
  void onSearchChangedByMe(String query) {
    searchQueryByMe.value = query;

    // Hủy timer cũ nếu có
    _searchDebounceByMe?.cancel();

    // Nếu query rỗng, thực hiện search ngay lập tức
    if (query.isEmpty) {
      loadTasksByMe(refresh: true);
      return;
    }

    // Tạo timer mới với delay 500ms chỉ khi có query
    _searchDebounceByMe = Timer(const Duration(milliseconds: 500), () {
      loadTasksByMe(refresh: true);
    });
  }

  // Tìm kiếm cho tab "Việc giao đến tôi"
  void onSearchChangedToMe(String query) {
    searchQueryToMe.value = query;

    // Hủy timer cũ nếu có
    _searchDebounceToMe?.cancel();

    // Nếu query rỗng, thực hiện search ngay lập tức
    if (query.isEmpty) {
      loadTasksToMe(refresh: true);
      return;
    }

    // Tạo timer mới với delay 500ms chỉ khi có query
    _searchDebounceToMe = Timer(const Duration(milliseconds: 500), () {
      loadTasksToMe(refresh: true);
    });
  }

  // Clear search cho tab "Việc tôi giao"
  void clearSearchByMe() {
    _searchDebounceByMe?.cancel();
    searchControllerByMe.clear();
    searchQueryByMe.value = '';
    loadTasksByMe(refresh: true);
  }

  // Clear search cho tab "Việc giao đến tôi"
  void clearSearchToMe() {
    _searchDebounceToMe?.cancel();
    searchControllerToMe.clear();
    searchQueryToMe.value = '';
    loadTasksToMe(refresh: true);
  }

  // Lọc danh sách theo từ khóa tìm kiếm (không cần nữa vì search đã được thực hiện ở server)
  List<TaskModel> get filteredTasksByMe {
    return tasksByMe;
  }

  List<TaskModel> get filteredTasksToMe {
    return tasksToMe;
  }

  // Lấy màu sắc theo trạng thái
  Color getStatusColor(int status) {
    switch (status) {
      case 1: // Đang thực hiện
        return Colors.orange;
      case 2: // Hoàn thành
        return Colors.green;
      case 3: // Trễ hạn
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Lấy màu sắc theo độ ưu tiên
  Color getPriorityColor(int priority) {
    switch (priority) {
      case 0: // Khẩn cấp
        return Colors.red;
      case 1: // Ưu tiên cao
        return Colors.orange;
      case 2: // Trung bình
        return const Color(0xFF006884);
      case 3: // Bình thường
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  // Áp dụng filter cho tab "Việc tôi giao"
  void _applyFilterByMe() {
    final filteredTasks = _filterTasks(_originalTasksByMe, filterByMe.value);
    tasksByMe.value = filteredTasks;
  }

  // Áp dụng filter cho tab "Việc giao đến tôi"
  void _applyFilterToMe() {
    final filteredTasks = _filterTasks(_originalTasksToMe, filterToMe.value);
    tasksToMe.value = filteredTasks;
  }

  // Logic filter chung (chỉ filter client-side cho status, priority, role)
  // Date filtering được thực hiện ở server
  List<TaskModel> _filterTasks(
    List<TaskModel> originalTasks,
    FilterModel filter,
  ) {
    // Chỉ filter client-side nếu có status, priority, hoặc role
    // Date filtering được thực hiện ở server nên không cần filter client-side
    final hasClientSideFilter =
        filter.status != null || filter.priority != null || filter.role != null;

    if (!hasClientSideFilter) {
      return originalTasks;
    }

    return originalTasks.where((task) {
      // Filter theo trạng thái
      if (filter.status != null && task.status != filter.status) {
        return false;
      }

      // Filter theo mức độ ưu tiên
      if (filter.priority != null && task.priority != filter.priority) {
        return false;
      }

      // Filter theo vai trò (chỉ áp dụng cho tab "Việc giao đến tôi")
      if (filter.role != null && task.roleId != filter.role) {
        return false;
      }

      return true;
    }).toList();
  }

  // Áp dụng filter mới cho tab hiện tại
  void applyFilter(FilterModel newFilter) {
    if (currentTab.value == 0) {
      filterByMe.value = newFilter;
      // Nếu có date filter, reload data từ server
      if (newFilter.dueDate != null) {
        loadTasksByMe(refresh: true);
      } else {
        _applyFilterByMe();
      }
    } else {
      filterToMe.value = newFilter;
      // Nếu có date filter, reload data từ server
      if (newFilter.dueDate != null) {
        loadTasksToMe(refresh: true);
      } else {
        _applyFilterToMe();
      }
    }
  }

  // Áp dụng filter cho tab cụ thể (dùng khi navigation từ home)
  void applyFilterForTab(FilterModel newFilter, int targetTab) {
    if (targetTab == 0) {
      // Áp dụng cho tab "Việc tôi giao"
      filterByMe.value = newFilter;
      // Nếu có date filter, reload data từ server
      if (newFilter.dueDate != null) {
        loadTasksByMe(refresh: true);
      } else {
        _applyFilterByMe();
      }
    } else {
      // Áp dụng cho tab "Việc giao đến tôi"
      filterToMe.value = newFilter;
      // Nếu có date filter, reload data từ server
      if (newFilter.dueDate != null) {
        loadTasksToMe(refresh: true);
      } else {
        _applyFilterToMe();
      }
    }
  }

  // Reset filter cho tab hiện tại
  void resetFilter() {
    if (currentTab.value == 0) {
      // Reset filter về empty state - force tất cả về null
      filterByMe.value = FilterModel(
        status: null,
        priority: null,
        role: null,
        dueDate: null,
      );
      // Reload data từ server với filter empty
      _loadTasksByMeWithoutFilter(refresh: true);
    } else {
      // Reset filter về empty state - force tất cả về null
      filterToMe.value = FilterModel(
        status: null,
        priority: null,
        role: null,
        dueDate: null,
      );
      // Reload data từ server với filter empty
      _loadTasksToMeWithoutFilter(refresh: true);
    }
  }

  // Load tasks by me với filter empty (để reset)
  Future<void> _loadTasksByMeWithoutFilter({bool refresh = false}) async {
    if (refresh) {
      currentPageByMe.value = 1;
      tasksByMe.clear();
    }

    try {
      isLoadingByMe.value = true;

      final request = TaskRequest(
        pageIndex: currentPageByMe.value,
        pageSize: pageSize,
        type: 2, // Việc tôi giao
        keyword: searchQueryByMe.value.isNotEmpty
            ? searchQueryByMe.value
            : null,
        startDate: null, // Không có date filter
        dueDate: null, // Không có date filter
      );

      final response = await _dioApi.post(
        ApiEndpoints.getTasks,
        data: request.toJson(),
      );
      print('responsesss: ${response.data}');

      if (response.statusCode == 200) {
        final taskResponse = TaskResponse.fromJson(response.data);

        if (refresh) {
          _originalTasksByMe.value = taskResponse.data;
          _applyFilterByMe();
        } else {
          _originalTasksByMe.addAll(taskResponse.data);
          _applyFilterByMe();
        }

        totalRecordByMe.value = taskResponse.totalRecord;
      } else {
        throw Exception('Failed to load tasks: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể tải danh sách công việc: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingByMe.value = false;
    }
  }

  // Load tasks to me với filter empty (để reset)
  Future<void> _loadTasksToMeWithoutFilter({bool refresh = false}) async {
    if (refresh) {
      currentPageToMe.value = 1;
      tasksToMe.clear();
    }

    try {
      isLoadingToMe.value = true;

      final request = TaskRequest(
        pageIndex: currentPageToMe.value,
        pageSize: pageSize,
        type: 1, // Việc giao đến tôi
        keyword: searchQueryToMe.value.isNotEmpty
            ? searchQueryToMe.value
            : null,
        startDate: null, // Không có date filter
        dueDate: null, // Không có date filter
      );

      final response = await _dioApi.post(
        ApiEndpoints.getTasks,
        data: request.toJson(),
      );
      print('responsesss: ${response.data}');

      if (response.statusCode == 200) {
        final taskResponse = TaskResponse.fromJson(response.data);

        if (refresh) {
          _originalTasksToMe.value = taskResponse.data;
          _applyFilterToMe();
        } else {
          _originalTasksToMe.addAll(taskResponse.data);
          _applyFilterToMe();
        }

        totalRecordToMe.value = taskResponse.totalRecord;
      } else {
        throw Exception('Failed to load tasks: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể tải danh sách công việc: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingToMe.value = false;
    }
  }

  // Lấy filter hiện tại của tab
  FilterModel getCurrentFilter() {
    return currentTab.value == 0 ? filterByMe.value : filterToMe.value;
  }

  // Kiểm tra có filter active không - CHỈ cho tab hiện tại
  bool get hasActiveFilter {
    return getCurrentFilter().hasActiveFilter;
  }
}
