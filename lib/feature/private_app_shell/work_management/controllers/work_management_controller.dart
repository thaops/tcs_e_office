import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tcs_e_office/common/repositoty/dio_api.dart';
import 'package:tcs_e_office/common/Services/api_endpoints.dart';
import '../models/task_model.dart';
import '../models/filter_model.dart';

class WorkManagementController extends GetxController {
  final DioApi _dioApi = DioApi();

  final RxInt currentTab = 0.obs;

  final RxList<TaskModel> tasksByMe = <TaskModel>[].obs;
  final RxBool isLoadingByMe = false.obs;
  final RxInt totalRecordByMe = 0.obs;

  final RxList<TaskModel> tasksToMe = <TaskModel>[].obs;
  final RxBool isLoadingToMe = false.obs;
  final RxInt totalRecordToMe = 0.obs;

  final RxString searchQueryByMe = ''.obs;
  final RxString searchQueryToMe = ''.obs;
  final TextEditingController searchControllerByMe = TextEditingController();
  final TextEditingController searchControllerToMe = TextEditingController();
  Timer? _searchDebounceByMe;
  Timer? _searchDebounceToMe;

  final RxInt currentPageByMe = 1.obs;
  final RxInt currentPageToMe = 1.obs;
  final int pageSize = 20;

  final Rx<FilterModel> filterByMe = FilterModel.empty().obs;
  final Rx<FilterModel> filterToMe = FilterModel.empty().obs;

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

  void changeTab(int index) {
    currentTab.value = index;
  }

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
        type: 1,
        keyword: searchQueryToMe.value.isNotEmpty
            ? searchQueryToMe.value
            : null,
        dueDate: filterToMe.value.dueDate,
      );

      final response = await _dioApi.post(
        ApiEndpoints.getTasks,
        data: request.toJson(),
      );

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

  Future<void> refresh() async {
    if (currentTab.value == 0) {
      await loadTasksByMe(refresh: true);
    } else {
      await loadTasksToMe(refresh: true);
    }
  }

  Future<void> silentRefresh() async {
    try {
      if (currentTab.value == 0) {
        currentPageByMe.value = 1;

        final request = TaskRequest(
          pageIndex: currentPageByMe.value,
          pageSize: pageSize,
          type: 2,
          keyword: searchQueryByMe.value.isNotEmpty
              ? searchQueryByMe.value
              : null,
          dueDate: filterByMe.value.dueDate,
        );

        final response = await _dioApi.post(
          ApiEndpoints.getTasks,
          data: request.toJson(),
        );

        if (response.statusCode == 200) {
          final taskResponse = TaskResponse.fromJson(response.data);
          _originalTasksByMe.value = taskResponse.data;
          _applyFilterByMe();
          totalRecordByMe.value = taskResponse.totalRecord;
        }
      } else {
        currentPageToMe.value = 1;

        final request = TaskRequest(
          pageIndex: currentPageToMe.value,
          pageSize: pageSize,
          type: 1,
          keyword: searchQueryToMe.value.isNotEmpty
              ? searchQueryToMe.value
              : null,
          dueDate: filterToMe.value.dueDate,
        );

        final response = await _dioApi.post(
          ApiEndpoints.getTasks,
          data: request.toJson(),
        );

        if (response.statusCode == 200) {
          final taskResponse = TaskResponse.fromJson(response.data);
          _originalTasksToMe.value = taskResponse.data;
          _applyFilterToMe();
          totalRecordToMe.value = taskResponse.totalRecord;
        }
      }
    } catch (e) {}
  }

  void onSearchChangedByMe(String query) {
    searchQueryByMe.value = query;

    _searchDebounceByMe?.cancel();

    if (query.isEmpty) {
      loadTasksByMe(refresh: true);
      return;
    }

    _searchDebounceByMe = Timer(const Duration(milliseconds: 500), () {
      loadTasksByMe(refresh: true);
    });
  }

  void onSearchChangedToMe(String query) {
    searchQueryToMe.value = query;

    _searchDebounceToMe?.cancel();

    if (query.isEmpty) {
      loadTasksToMe(refresh: true);
      return;
    }

    _searchDebounceToMe = Timer(const Duration(milliseconds: 500), () {
      loadTasksToMe(refresh: true);
    });
  }

  void clearSearchByMe() {
    _searchDebounceByMe?.cancel();
    searchControllerByMe.clear();
    searchQueryByMe.value = '';
    loadTasksByMe(refresh: true);
  }

  void clearSearchToMe() {
    _searchDebounceToMe?.cancel();
    searchControllerToMe.clear();
    searchQueryToMe.value = '';
    loadTasksToMe(refresh: true);
  }

  List<TaskModel> get filteredTasksByMe {
    return tasksByMe;
  }

  List<TaskModel> get filteredTasksToMe {
    return tasksToMe;
  }

  Color getStatusColor(int status) {
    switch (status) {
      case 1:
        return Colors.orange;
      case 2:
        return Colors.green;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color getPriorityColor(int priority) {
    switch (priority) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.orange;
      case 2:
        return const Color(0xFF006884);
      case 3:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  void _applyFilterByMe() {
    final filteredTasks = _filterTasks(_originalTasksByMe, filterByMe.value);
    tasksByMe.value = filteredTasks;
  }

  void _applyFilterToMe() {
    final filteredTasks = _filterTasks(_originalTasksToMe, filterToMe.value);
    tasksToMe.value = filteredTasks;
  }

  List<TaskModel> _filterTasks(
    List<TaskModel> originalTasks,
    FilterModel filter,
  ) {
    final hasClientSideFilter =
        filter.status != null || filter.priority != null || filter.role != null;

    if (!hasClientSideFilter) {
      return originalTasks;
    }

    return originalTasks.where((task) {
      if (filter.status != null && task.status != filter.status) {
        return false;
      }

      if (filter.priority != null && task.priority != filter.priority) {
        return false;
      }

      if (filter.role != null && task.roleId != filter.role) {
        return false;
      }

      return true;
    }).toList();
  }

  void applyFilter(FilterModel newFilter) {
    if (currentTab.value == 0) {
      filterByMe.value = newFilter;
      if (newFilter.dueDate != null) {
        loadTasksByMe(refresh: true);
      } else {
        _applyFilterByMe();
      }
    } else {
      filterToMe.value = newFilter;
      if (newFilter.dueDate != null) {
        loadTasksToMe(refresh: true);
      } else {
        _applyFilterToMe();
      }
    }
  }

  void applyFilterForTab(FilterModel newFilter, int targetTab) {
    if (targetTab == 0) {
      filterByMe.value = newFilter;
      if (newFilter.dueDate != null) {
        loadTasksByMe(refresh: true);
      } else {
        _applyFilterByMe();
      }
    } else {
      filterToMe.value = newFilter;
      if (newFilter.dueDate != null) {
        loadTasksToMe(refresh: true);
      } else {
        _applyFilterToMe();
      }
    }
  }

  void resetFilter() {
    if (currentTab.value == 0) {
      filterByMe.value = FilterModel(
        status: null,
        priority: null,
        role: null,
        dueDate: null,
      );
      _loadTasksByMeWithoutFilter(refresh: true);
    } else {
      filterToMe.value = FilterModel(
        status: null,
        priority: null,
        role: null,
        dueDate: null,
      );
      _loadTasksToMeWithoutFilter(refresh: true);
    }
  }

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
        type: 2,
        keyword: searchQueryByMe.value.isNotEmpty
            ? searchQueryByMe.value
            : null,
        startDate: null,
        dueDate: null,
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
      Get.snackbar(
        'Lỗi',
        'Không thể tải danh sách công việc: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingByMe.value = false;
    }
  }

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
        type: 1,
        keyword: searchQueryToMe.value.isNotEmpty
            ? searchQueryToMe.value
            : null,
        startDate: null,
        dueDate: null,
      );

      final response = await _dioApi.post(
        ApiEndpoints.getTasks,
        data: request.toJson(),
      );

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

  FilterModel getCurrentFilter() {
    return currentTab.value == 0 ? filterByMe.value : filterToMe.value;
  }

  bool get hasActiveFilter {
    return getCurrentFilter().hasActiveFilter;
  }
}
