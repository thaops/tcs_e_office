import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../models/task_detail_model.dart';
import 'task_api_service.dart';
import 'task_form_handler.dart';
import 'task_validation_service.dart';

class UpdateTaskController extends GetxController {
  final TaskApiService _apiService = TaskApiService();
  final TaskFormHandler _formHandler = TaskFormHandler();

  String? documentId;
  String? taskId;

  final RxList<EmployeeSimple> allEmployees = <EmployeeSimple>[].obs;
  final RxList<DepartmentNode> departmentTree = <DepartmentNode>[].obs;
  final RxList<PriorityOption> priorities = <PriorityOption>[].obs;

  final RxBool loading = false.obs;
  final RxBool searching = false.obs; // Thêm state cho search
  final RxString error = ''.obs;
  final RxString success = ''.obs;

  // Getters để access form data
  TextEditingController get titleController => _formHandler.titleController;
  TextEditingController get noteController => _formHandler.noteController;
  TextEditingController get contentController => _formHandler.contentController;

  Rx<DateTime?> get startDate => _formHandler.startDate;
  Rx<TimeOfDay?> get startTime => _formHandler.startTime;
  Rx<DateTime?> get dueDate => _formHandler.dueDate;
  Rx<TimeOfDay?> get dueTime => _formHandler.dueTime;

  RxList<String> get primaryEmployeeCodes => _formHandler.primaryEmployeeCodes;
  RxList<String> get primaryDepartmentCodes =>
      _formHandler.primaryDepartmentCodes;
  RxList<String> get collabEmployeeCodes => _formHandler.collabEmployeeCodes;
  RxList<String> get collabDepartmentCodes =>
      _formHandler.collabDepartmentCodes;
  RxList<String> get followEmployeeCodes => _formHandler.followEmployeeCodes;
  RxList<String> get followDepartmentCodes =>
      _formHandler.followDepartmentCodes;

  RxList<String> get attachmentFileNames => _formHandler.attachmentFileNames;
  RxList<String> get attachmentPaths => _formHandler.attachmentPaths;

  Rxn<PriorityOption> get selectedPriority => _formHandler.selectedPriority;

  @override
  void onInit() {
    super.onInit();
    _loadMeta();
    selectedPriority.value ??= PriorityOption(value: 3, label: 'Bình thường');
  }

  /// Test method để kiểm tra hiển thị lỗi
  void testErrorDisplay() {
    error.value = 'Anh/Chị không thể giao công việc cho chính mình.';
  }

  Future<void> _loadMeta({bool isSearchReset = false}) async {
    // Chỉ set loading = true nếu không phải search reset
    if (!isSearchReset) {
      loading.value = true;
    }
    error.value = '';
    try {
      final metadata = await _apiService.loadMetadata();

      priorities.assignAll(metadata['priorities'] as List<PriorityOption>);
      allEmployees.assignAll(metadata['employees'] as List<EmployeeSimple>);
      departmentTree.assignAll(metadata['departments'] as List<DepartmentNode>);

      if (priorities.isNotEmpty) {
        // Set default là item cuối (bình thường) thay vì item đầu (khẩn cấp)
        selectedPriority.value = priorities.last;
      }
    } catch (e) {
      error.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (!isSearchReset) {
        loading.value = false;
      }
    }
  }

  /// Search employees by department with keyword
  Future<void> searchEmployees(String keyword) async {
    final trimmedKeyword = keyword.trim();

    if (trimmedKeyword.isEmpty) {
      // Nếu keyword rỗng, load lại dữ liệu gốc
      searching.value = true;
      try {
        await _loadMeta(isSearchReset: true);
      } catch (e) {
        error.value = e.toString().replaceFirst('Exception: ', '');
      } finally {
        searching.value = false;
      }
      return;
    }

    searching.value = true;
    error.value = '';
    try {
      final searchResults = await _apiService.searchEmployeesByDepartment(
        trimmedKeyword,
      );
      departmentTree.assignAll(searchResults);
    } catch (e) {
      error.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      searching.value = false;
    }
  }

  Future<void> loadTaskData(String taskId) async {
    this.taskId = taskId;
    loading.value = true;
    error.value = '';

    try {
      final data = await _apiService.loadTaskData(taskId);
      if (data != null) {
        _formHandler.populateFromTaskData(data);
        _formHandler.setPriorityFromValue(data['priority'], priorities);

        // Trigger rebuild cho HTML content editor
        update(['html_content_editor']);
      }
    } catch (e) {
      error.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      loading.value = false;
    }
  }

  /// Populate form data từ TaskDetailModel có sẵn (tối ưu hơn loadTaskData)
  void populateFromTaskData(TaskDetailModel taskData) {
    this.taskId = taskData.id;
    error.value = '';

    // Populate form data từ TaskDetailModel
    _formHandler.populateFromTaskDetailModel(taskData);

    // Set priority từ value
    _formHandler.setPriorityFromValue(taskData.priority, priorities);

    // Trigger rebuild cho HTML content editor
    update(['html_content_editor']);

    print('🔍 UpdateTaskController: Populated from existing task data');
  }

  DateTime _startOfDayLocal(DateTime d) => DateTime(d.year, d.month, d.day);
  DateTime _endOfDayLocal(DateTime d) =>
      DateTime(d.year, d.month, d.day, 23, 59);

  Future<bool> submit({required String assignerCode}) async {
    if (taskId == null) {
      error.value = 'Không tìm thấy ID công việc';
      return false;
    }

    error.value = '';
    success.value = '';

    final name = titleController.text.trim();
    final content = contentController.text.trim();
    final sanitizedContent = TaskValidationService.sanitizeHtmlContent(content);

    final validationError = TaskValidationService.validateFormData(
      taskName: name,
      content: content,
      primaryEmployeeCodes: primaryEmployeeCodes.toList(),
      allEmployees: allEmployees.toList(),
      startDate: startDate.value,
      dueDate: dueDate.value,
    );

    if (validationError != null) {
      error.value = validationError;
      return false;
    }

    final validEmployeeCodes = primaryEmployeeCodes.where((code) {
      return allEmployees.any((e) => e.employeeCode == code);
    }).toList();

    final now = DateTime.now();
    final startLocal = _startOfDayLocal(startDate.value ?? now);
    final dueLocal = dueDate.value != null
        ? _endOfDayLocal(dueDate.value!)
        : null;

    final updatePayload = {
      if (documentId != null) 'DocumentId': documentId,
      'AssignerCode': assignerCode,
      'TaskName': name,
      'StartDate': startLocal.toUtc().toIso8601String(),
      if (dueLocal != null) 'DueDate': dueLocal.toUtc().toIso8601String(),
      'Priority': selectedPriority.value?.value ?? 3,
      'Note': "",
      'Content': sanitizedContent,
      'Primary': {
        'EmployeeCodes': validEmployeeCodes,
        'DepartmentCodes': primaryDepartmentCodes.toList(),
      },
      if (collabDepartmentCodes.isNotEmpty || collabEmployeeCodes.isNotEmpty)
        'Collab': {
          'DepartmentCodes': collabDepartmentCodes.toList(),
          'EmployeeCodes': collabEmployeeCodes.toList(),
        },
      if (followDepartmentCodes.isNotEmpty || followEmployeeCodes.isNotEmpty)
        'Follow': {
          'DepartmentCodes': followDepartmentCodes.toList(),
          'EmployeeCodes': followEmployeeCodes.toList(),
        },
    };

    try {
      loading.value = true;
      final success = await _apiService.updateTask(
        taskId: taskId!,
        payload: updatePayload,
        attachmentPaths: attachmentPaths.toList(),
      );

      if (success) {
        this.success.value = 'Cập nhật việc thành công';
        return true;
      } else {
        error.value = 'Cập nhật việc thất bại';
        return false;
      }
    } catch (e) {
      print('Error in update task: $e');
      error.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      loading.value = false;
    }
  }

  Future<void> pickAttachments() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: const ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
      );
      if (result != null && result.files.isNotEmpty) {
        final newFileNames = result.files.map((f) => f.name).toList();
        final newPaths = result.files
            .where((f) => f.path != null)
            .map((f) => f.path!)
            .toList();

        attachmentFileNames.addAll(newFileNames);
        attachmentPaths.addAll(newPaths);
      }
    } catch (_) {
      // Ignore errors
    }
  }

  void removeAttachment(int index) {
    _formHandler.removeAttachment(index);
  }

  void clearAllAttachments() {
    _formHandler.clearAllAttachments();
  }

  @override
  void onClose() {
    _formHandler.dispose();
    super.onClose();
  }
}
