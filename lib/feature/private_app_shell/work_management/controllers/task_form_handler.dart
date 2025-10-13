import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/task_detail_model.dart';

class TaskFormHandler {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController contentController = TextEditingController(
    text: '',
  );

  final Rx<DateTime?> startDate = Rx<DateTime?>(DateTime.now());
  final Rx<TimeOfDay?> startTime = Rx<TimeOfDay?>(null);
  final Rx<DateTime?> dueDate = Rx<DateTime?>(DateTime.now());
  final Rx<TimeOfDay?> dueTime = Rx<TimeOfDay?>(null);

  final RxList<String> primaryEmployeeCodes = <String>[].obs;
  final RxList<String> primaryDepartmentCodes = <String>[].obs;
  final RxList<String> collabEmployeeCodes = <String>[].obs;
  final RxList<String> collabDepartmentCodes = <String>[].obs;
  final RxList<String> followEmployeeCodes = <String>[].obs;
  final RxList<String> followDepartmentCodes = <String>[].obs;

  final RxList<String> attachmentFileNames = <String>[].obs;
  final RxList<String> attachmentPaths = <String>[].obs;

  final Rxn<PriorityOption> selectedPriority = Rxn<PriorityOption>();

  /// Clear tất cả form data
  void clearForm() {
    titleController.clear();
    noteController.clear();
    contentController.clear();

    startDate.value = DateTime.now();
    startTime.value = null;
    dueDate.value = DateTime.now();
    dueTime.value = null;

    primaryEmployeeCodes.clear();
    primaryDepartmentCodes.clear();
    collabEmployeeCodes.clear();
    collabDepartmentCodes.clear();
    followEmployeeCodes.clear();
    followDepartmentCodes.clear();

    attachmentFileNames.clear();
    attachmentPaths.clear();

    selectedPriority.value = null;
  }

  /// Populate form với data từ API
  void populateFromTaskData(Map<String, dynamic> data) {
    clearForm();

    titleController.text = data['taskName'] ?? '';
    contentController.text = data['content'] ?? '';

    if (data['startDate'] != null) {
      final startDateTime = DateTime.tryParse(data['startDate'] as String);
      if (startDateTime != null) {
        startDate.value = startDateTime;
      }
    }

    if (data['dueDate'] != null) {
      final dueDateTime = DateTime.tryParse(data['dueDate'] as String);
      if (dueDateTime != null) {
        dueDate.value = dueDateTime;
      }
    }

    _populateAssignees(data);
    _populateAttachments(data);
  }

  /// Populate form với data từ TaskDetailModel (tối ưu hơn)
  void populateFromTaskDetailModel(TaskDetailModel taskData) {
    clearForm();

    titleController.text = taskData.taskName;
    contentController.text = taskData.content ?? '';

    print('🔍 TaskFormHandler: Populated content: "${taskData.content}"');
    print(
      '🔍 TaskFormHandler: ContentController text: "${contentController.text}"',
    );

    // Set dates từ String
    if (taskData.startDate.isNotEmpty) {
      final startDateTime = DateTime.tryParse(taskData.startDate);
      if (startDateTime != null) {
        startDate.value = startDateTime;
      }
    }

    if (taskData.dueDate.isNotEmpty) {
      final dueDateTime = DateTime.tryParse(taskData.dueDate);
      if (dueDateTime != null) {
        dueDate.value = dueDateTime;
      }
    }

    // Populate assignees từ TaskDetailModel
    _populateAssigneesFromTaskDetail(taskData);

    // Populate attachments từ TaskDetailModel
    _populateAttachmentsFromTaskDetail(taskData);
  }

  void _populateAssignees(Map<String, dynamic> data) {
    _populateAssigneeGroup(
      data['primary'],
      primaryEmployeeCodes,
      primaryDepartmentCodes,
    );
    _populateAssigneeGroup(
      data['collab'],
      collabEmployeeCodes,
      collabDepartmentCodes,
    );
    _populateAssigneeGroup(
      data['follow'],
      followEmployeeCodes,
      followDepartmentCodes,
    );
  }

  void _populateAssigneeGroup(
    dynamic groupData,
    RxList<String> employeeCodes,
    RxList<String> departmentCodes,
  ) {
    if (groupData is Map<String, dynamic>) {
      if (groupData['employeeCodes'] is List) {
        final codes = (groupData['employeeCodes'] as List)
            .map((e) => e.toString())
            .toList();
        employeeCodes.assignAll(codes);
      }

      if (groupData['departmentCodes'] is List) {
        final codes = (groupData['departmentCodes'] as List)
            .map((e) => e.toString())
            .toList();
        departmentCodes.assignAll(codes);
      }
    }
  }

  void _populateAttachments(Map<String, dynamic> data) {
    if (data['attachments'] is List) {
      final attachments = data['attachments'] as List;
      for (final attachment in attachments) {
        final fileName = attachment['name'];
        if (fileName != null) {
          attachmentFileNames.add(fileName);
        }
      }
    }
  }

  /// Populate assignees từ TaskDetailModel
  void _populateAssigneesFromTaskDetail(TaskDetailModel taskData) {
    // Primary assignees
    primaryEmployeeCodes.assignAll(taskData.primary.employeeCodes);
    primaryDepartmentCodes.assignAll(taskData.primary.departmentCodes);

    // Collaborators
    collabEmployeeCodes.assignAll(taskData.collab.employeeCodes);
    collabDepartmentCodes.assignAll(taskData.collab.departmentCodes);

    // Followers
    followEmployeeCodes.assignAll(taskData.follow.employeeCodes);
    followDepartmentCodes.assignAll(taskData.follow.departmentCodes);
  }

  /// Populate attachments từ TaskDetailModel
  void _populateAttachmentsFromTaskDetail(TaskDetailModel taskData) {
    attachmentFileNames.assignAll(
      taskData.attachments.map((a) => a.name).toList(),
    );
  }

  /// Set priority từ value
  void setPriorityFromValue(
    int? priorityValue,
    List<PriorityOption> priorities,
  ) {
    if (priorityValue != null) {
      final priority = priorities.firstWhereOrNull(
        (p) => p.value == priorityValue,
      );
      if (priority != null) {
        selectedPriority.value = priority;
      }
    }
  }

  /// Xóa file đính kèm theo index
  void removeAttachment(int index) {
    if (index >= 0 && index < attachmentFileNames.length) {
      attachmentFileNames.removeAt(index);
      if (index < attachmentPaths.length) {
        attachmentPaths.removeAt(index);
      }
    }
  }

  /// Xóa tất cả file đính kèm
  void clearAllAttachments() {
    attachmentFileNames.clear();
    attachmentPaths.clear();
  }

  void dispose() {
    titleController.dispose();
    noteController.dispose();
    contentController.dispose();
  }
}
