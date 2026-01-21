import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart' as dioLib;
import 'package:tcs_e_office/common/Services/api_endpoints.dart';
import 'package:tcs_e_office/common/repositoty/dio_api.dart';
import '../models/task_detail_model.dart';

class CreateTaskController extends GetxController {
  final DioApi _dioApi = DioApi();
  String? documentId;

  final titleController = TextEditingController();
  final noteController = TextEditingController();
  final contentController = TextEditingController(text: '');

  final Rx<DateTime?> startDate = Rx<DateTime?>(DateTime.now());
  final Rx<TimeOfDay?> startTime = Rx<TimeOfDay?>(null);
  final Rx<DateTime?> dueDate = Rx<DateTime?>(DateTime.now());
  final Rx<TimeOfDay?> dueTime = Rx<TimeOfDay?>(null);

  final RxList<EmployeeSimple> allEmployees = <EmployeeSimple>[].obs;
  final RxList<DepartmentNode> departmentTree = <DepartmentNode>[].obs;
  final RxList<PriorityOption> priorities = <PriorityOption>[].obs;

  final Rxn<PriorityOption> selectedPriority = Rxn<PriorityOption>();

  final RxList<String> primaryEmployeeCodes = <String>[].obs;
  final RxList<String> primaryDepartmentCodes = <String>[].obs;
  final RxList<String> collabEmployeeCodes = <String>[].obs;
  final RxList<String> collabDepartmentCodes = <String>[].obs;
  final RxList<String> followEmployeeCodes = <String>[].obs;
  final RxList<String> followDepartmentCodes = <String>[].obs;

  final RxBool loading = false.obs;
  final RxBool searching = false.obs;
  final RxString error = ''.obs;
  final RxString success = ''.obs;

  final RxList<String> attachmentFileNames = <String>[].obs;
  final RxList<String> attachmentPaths = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadMeta();
    selectedPriority.value ??= PriorityOption(value: 3, label: 'Bình thường');
  }

  void testErrorDisplay() {
    error.value = 'Anh/Chị không thể giao công việc cho chính mình.';
  }

  Future<void> _loadMeta({bool isSearchReset = false}) async {
    if (!isSearchReset) {
      loading.value = true;
    }
    error.value = '';
    try {
      final prioFuture = _dioApi.get(ApiEndpoints.getPriorityOptions);
      final empFuture = _dioApi.get(ApiEndpoints.employees);
      final deptFuture = _dioApi.get(ApiEndpoints.employeesByDepartment);
      final results = await Future.wait([prioFuture, empFuture, deptFuture]);

      final prioRes = results[0];
      if (prioRes.statusCode == 200) {
        final data = prioRes.data['data'] as List<dynamic>? ?? [];
        priorities.assignAll(data.map((e) => PriorityOption.fromJson(e)));
        if (priorities.isNotEmpty && selectedPriority.value == null) {
          selectedPriority.value = priorities.last;
        }
      }

      final empRes = results[1];
      if (empRes.statusCode == 200) {
        final data = empRes.data['data'] as List<dynamic>? ?? [];
        allEmployees.assignAll(
          data.map((e) => EmployeeSimple.fromJson(e)).toList(),
        );
      }

      final deptRes = results[2];
      if (deptRes.statusCode == 200) {
        final data = deptRes.data['data'] as List<dynamic>? ?? [];
        departmentTree.assignAll(
          data.map((e) => DepartmentNode.fromJson(e)).toList(),
        );
      }
    } catch (_) {
      error.value = 'Không thể tải dữ liệu danh mục';
    } finally {
      if (!isSearchReset) {
        loading.value = false;
      }
    }
  }

  Future<void> searchEmployees(String keyword) async {
    final trimmedKeyword = keyword.trim();

    if (trimmedKeyword.isEmpty) {
      searching.value = true;
      try {
        await _loadMeta(isSearchReset: true);
      } catch (e) {
        error.value = 'Không thể tải lại dữ liệu: $e';
      } finally {
        searching.value = false;
      }
      return;
    }

    searching.value = true;
    error.value = '';
    try {
      final res = await _dioApi.get(
        ApiEndpoints.searchEmployeesByDepartment(trimmedKeyword),
      );

      if (res.statusCode == 200) {
        final data = res.data['data'] as List<dynamic>? ?? [];
        departmentTree.assignAll(
          data.map((e) => DepartmentNode.fromJson(e)).toList(),
        );
      }
    } catch (e) {
      error.value = 'Không thể tìm kiếm nhân viên: $e';
    } finally {
      searching.value = false;
    }
  }

  DateTime _startOfDayLocal(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime _endOfDayLocal(DateTime d) =>
      DateTime(d.year, d.month, d.day, 23, 59, 59);

  String _sanitizeHtmlContent(String content) {
    if (content.isEmpty) return content;

    String sanitized = content
        .replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '')
        .replaceAll(RegExp(r'[\u0000-\u001F\u007F-\u009F]'), '')
        .trim();

    if (sanitized.isNotEmpty && !sanitized.startsWith('<')) {
      sanitized = '<p>$sanitized</p>';
    }

    return sanitized;
  }

  bool _hasRealContent(String htmlContent) {
    if (htmlContent.isEmpty) return false;

    String textOnly = htmlContent.replaceAll(RegExp(r'<[^>]*>'), '');

    textOnly = textOnly
        .replaceAll(RegExp(r'&nbsp;'), ' ')
        .replaceAll(RegExp(r'&amp;'), '&')
        .replaceAll(RegExp(r'&lt;'), '<')
        .replaceAll(RegExp(r'&gt;'), '>')
        .replaceAll(RegExp(r'&quot;'), '"')
        .replaceAll(RegExp(r'&#39;'), "'")
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    return textOnly.isNotEmpty;
  }

  Future<bool> submit({required String assignerCode}) async {
    error.value = '';
    success.value = '';
    final name = titleController.text.trim();
    final content = contentController.text.trim();

    final sanitizedContent = _sanitizeHtmlContent(content);
    if (name.isEmpty) {
      error.value = 'Tên việc là bắt buộc';
      return false;
    }
    final hasContent = _hasRealContent(sanitizedContent);

    if (!hasContent) {
      error.value = 'Nội dung công việc là bắt buộc';
      return false;
    }

    final now = DateTime.now();
    final startLocal = _startOfDayLocal(startDate.value ?? now);
    final dueLocal = dueDate.value != null
        ? _endOfDayLocal(dueDate.value!)
        : null;

    final payload = CreateTaskRequestPayload(
      documentId: documentId,
      assignerCode: assignerCode,
      taskName: name,
      startDate: startLocal,
      dueDate: dueLocal,
      priority: selectedPriority.value?.value ?? 3,
      note: "",
      content: sanitizedContent,
      primary: CreateTaskGroupPayload(
        departmentCodes: primaryDepartmentCodes.toList(),
        employeeCodes: primaryEmployeeCodes.toList(),
      ),
      collab: (collabDepartmentCodes.isEmpty && collabEmployeeCodes.isEmpty)
          ? null
          : CreateTaskGroupPayload(
              departmentCodes: collabDepartmentCodes.toList(),
              employeeCodes: collabEmployeeCodes.toList(),
            ),
      follow: (followDepartmentCodes.isEmpty && followEmployeeCodes.isEmpty)
          ? null
          : CreateTaskGroupPayload(
              departmentCodes: followDepartmentCodes.toList(),
              employeeCodes: followEmployeeCodes.toList(),
            ),
    );

    try {
      loading.value = true;

      final res = await _postMultipart(payload);
      Map<String, dynamic>? map;
      if (res.data is Map) {
        final raw = Map<String, dynamic>.from(res.data as Map);
        map = {
          for (final e in raw.entries) e.key.toString().toLowerCase(): e.value,
        };
      }

      final statusCode = map?['statuscode'];
      final data = map?['data'];
      final serverMessage = (map?['message'] as String?)?.trim();

      final dataOk =
          data != null && (data == true || (data is String && data.isNotEmpty));

      if (statusCode == 200 && dataOk) {
        error.value = '';
        success.value = 'Tạo việc thành công';
        return true;
      }

      error.value = (serverMessage != null && serverMessage.isNotEmpty)
          ? serverMessage
          : 'Tạo việc thất bại';
      return false;
    } catch (e) {
      if (e is dioLib.DioException) {
        final data = e.response?.data;
        String? serverMessage;
        if (data is Map) {
          final raw = Map<String, dynamic>.from(data);
          final lower = {
            for (final ent in raw.entries)
              ent.key.toString().toLowerCase(): ent.value,
          };
          serverMessage = (lower['message'] as String?)?.trim();
        }
        error.value = (serverMessage != null && serverMessage.isNotEmpty)
            ? serverMessage
            : 'Lỗi khi tạo việc';
      } else {
        error.value = 'Lỗi khi tạo việc: ${e.toString()}';
      }
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
    } catch (_) {}
  }

  void removeAttachment(int index) {
    if (index >= 0 && index < attachmentFileNames.length) {
      attachmentFileNames.removeAt(index);
      if (index < attachmentPaths.length) {
        attachmentPaths.removeAt(index);
      }
    }
  }

  void clearAllAttachments() {
    attachmentFileNames.clear();
    attachmentPaths.clear();
  }

  Future<dioLib.Response> _postMultipart(
    CreateTaskRequestPayload payload,
  ) async {
    final map = payload.toJson();
    final form = dioLib.FormData();
    void addField(String key, String? value) {
      if (value != null && value.isNotEmpty) {
        form.fields.add(MapEntry(key, value));
      }
    }

    addField('DocumentId', map['DocumentId'] as String?);
    addField('AssignerCode', map['AssignerCode'] as String?);
    addField('TaskName', map['TaskName'] as String?);
    addField('StartDate', map['StartDate'] as String?);
    addField('DueDate', map['DueDate'] as String?);
    addField('Priority', (map['Priority']?.toString()));
    addField('Note', map['Note'] as String?);
    addField('Content', map['Content'] as String?);

    final primary = map['Primary'] as Map<String, dynamic>;
    final List depsP = (primary['DepartmentCodes'] as List? ?? []);
    final List empsP = (primary['EmployeeCodes'] as List? ?? []);
    for (final c in depsP) {
      addField('Primary.DepartmentCodes', c.toString());
    }
    for (final c in empsP) {
      addField('Primary.EmployeeCodes', c.toString());
    }

    if (map['Collab'] is Map<String, dynamic>) {
      final collab = map['Collab'] as Map<String, dynamic>;
      final List depsC = (collab['DepartmentCodes'] as List? ?? []);
      final List empsC = (collab['EmployeeCodes'] as List? ?? []);
      for (final c in depsC) {
        addField('Collab.DepartmentCodes', c.toString());
      }
      for (final c in empsC) {
        addField('Collab.EmployeeCodes', c.toString());
      }
    }

    if (map['Follow'] is Map<String, dynamic>) {
      final follow = map['Follow'] as Map<String, dynamic>;
      final List depsF = (follow['DepartmentCodes'] as List? ?? []);
      final List empsF = (follow['EmployeeCodes'] as List? ?? []);
      for (final c in depsF) {
        addField('Follow.DepartmentCodes', c.toString());
      }
      for (final c in empsF) {
        addField('Follow.EmployeeCodes', c.toString());
      }
    }

    for (final p in attachmentPaths) {
      form.files.add(
        MapEntry(
          'Attachments',
          await dioLib.MultipartFile.fromFile(p, filename: p.split('/').last),
        ),
      );
    }

    return _dioApi.post(
      ApiEndpoints.createTask,
      data: form,
      options: dioLib.Options(
        headers: {
          ...await _dioApi.getHeader(),
          'Content-Type': 'multipart/form-data',
        },
      ),
    );
  }
}
