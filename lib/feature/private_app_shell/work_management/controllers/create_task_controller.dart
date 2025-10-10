import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart' as dioLib;
import 'package:tcs_e_office/common/Services/api_endpoints.dart';
import 'package:tcs_e_office/common/repositoty/dio_api.dart';
import '../models/task_detail_model.dart';

class CreateTaskController extends GetxController {
  final DioApi _dioApi = DioApi();
  String? documentId; // optional: set từ nơi gọi nếu có

  // Form state
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

  // Assignees
  final RxList<String> primaryEmployeeCodes = <String>[].obs;
  final RxList<String> primaryDepartmentCodes = <String>[].obs;
  final RxList<String> collabEmployeeCodes = <String>[].obs;
  final RxList<String> collabDepartmentCodes = <String>[].obs;
  final RxList<String> followEmployeeCodes = <String>[].obs;
  final RxList<String> followDepartmentCodes = <String>[].obs;

  final RxBool loading = false.obs;
  final RxBool searching = false.obs; // Thêm state cho search
  final RxString error = ''.obs;
  final RxString success = ''.obs;

  // Attachments (lưu tên hiển thị đơn giản)
  final RxList<String> attachmentFileNames = <String>[].obs;
  final RxList<String> attachmentPaths = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadMeta();
    // Mặc định ưu tiên: Bình thường (thường có value 3)
    selectedPriority.value ??= PriorityOption(value: 3, label: 'Bình thường');
  }

  Future<void> _loadMeta({bool isSearchReset = false}) async {
    // Chỉ set loading = true nếu không phải search reset
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
        // Set default là item cuối (bình thường) thay vì item đầu (khẩn cấp)
        if (priorities.isNotEmpty) {
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

  /// Search employees by department with keyword
  Future<void> searchEmployees(String keyword) async {
    final trimmedKeyword = keyword.trim();

    if (trimmedKeyword.isEmpty) {
      // Nếu keyword rỗng, load lại dữ liệu gốc
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

  // removed: _mergeDateTime (không còn dùng vì bỏ chọn giờ)

  DateTime _startOfDayLocal(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime _endOfDayLocal(DateTime d) =>
      DateTime(d.year, d.month, d.day, 23, 59, 59);

  /// Sanitize HTML content để tránh lỗi database
  String _sanitizeHtmlContent(String content) {
    if (content.isEmpty) return content;

    // Loại bỏ các ký tự đặc biệt có thể gây lỗi database
    String sanitized =
        content
            .replaceAll(
              RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'),
              '',
            ) // Control characters
            .replaceAll(
              RegExp(r'[\u0000-\u001F\u007F-\u009F]'),
              '',
            ) // Unicode control characters
            .trim();

    // Đảm bảo HTML hợp lệ
    if (sanitized.isNotEmpty && !sanitized.startsWith('<')) {
      sanitized = '<p>$sanitized</p>';
    }

    return sanitized;
  }

  /// Kiểm tra nội dung có thực sự có text không (bỏ qua HTML tags và whitespace)
  bool _hasRealContent(String htmlContent) {
    if (htmlContent.isEmpty) return false;

    // Loại bỏ HTML tags
    String textOnly = htmlContent.replaceAll(RegExp(r'<[^>]*>'), '');

    // Loại bỏ các HTML entities và whitespace
    textOnly =
        textOnly
            .replaceAll(RegExp(r'&nbsp;'), ' ')
            .replaceAll(RegExp(r'&amp;'), '&')
            .replaceAll(RegExp(r'&lt;'), '<')
            .replaceAll(RegExp(r'&gt;'), '>')
            .replaceAll(RegExp(r'&quot;'), '"')
            .replaceAll(RegExp(r'&#39;'), "'")
            .replaceAll(RegExp(r'\s+'), ' ') // Nhiều space thành 1 space
            .trim();

    return textOnly.isNotEmpty;
  }

  Future<bool> submit({required String assignerCode}) async {
    error.value = '';
    success.value = '';
    final name = titleController.text.trim();
    final content = contentController.text.trim();

    // Sanitize HTML content để tránh lỗi database
    final sanitizedContent = _sanitizeHtmlContent(content);
    if (name.isEmpty) {
      error.value = 'Tên việc là bắt buộc';
      return false;
    }
    // Kiểm tra nội dung có thực sự có text không (bỏ qua HTML tags)
    final hasContent = _hasRealContent(sanitizedContent);

    if (!hasContent) {
      error.value = 'Nội dung công việc là bắt buộc';
      return false;
    }

    // Chuẩn hóa thời gian theo yêu cầu API:
    // StartDate = đầu ngày local (-> 17:00Z hôm trước)
    // DueDate = cuối ngày local (-> 16:59:59Z)
    final now = DateTime.now();
    final startLocal = _startOfDayLocal(startDate.value ?? now);
    final dueLocal =
        dueDate.value != null ? _endOfDayLocal(dueDate.value!) : null;

    final payload = CreateTaskRequestPayload(
      documentId: documentId,
      assignerCode: assignerCode,
      taskName: name,
      startDate: startLocal,
      dueDate: dueLocal,
      priority: selectedPriority.value?.value ?? 3,
      note: "", // Sử dụng sanitized HTML content cho note
      content: sanitizedContent, // Sử dụng sanitized HTML content cho content
      primary: CreateTaskGroupPayload(
        departmentCodes: primaryDepartmentCodes.toList(),
        employeeCodes: primaryEmployeeCodes.toList(),
      ),
      collab:
          (collabDepartmentCodes.isEmpty && collabEmployeeCodes.isEmpty)
              ? null
              : CreateTaskGroupPayload(
                departmentCodes: collabDepartmentCodes.toList(),
                employeeCodes: collabEmployeeCodes.toList(),
              ),
      follow:
          (followDepartmentCodes.isEmpty && followEmployeeCodes.isEmpty)
              ? null
              : CreateTaskGroupPayload(
                departmentCodes: followDepartmentCodes.toList(),
                employeeCodes: followEmployeeCodes.toList(),
              ),
    );

    print('payload: ${payload.toJson()}');

    try {
      loading.value = true;

      // Sử dụng FormData cho cả 2 trường hợp để đảm bảo format nhất quán
      final res = await _postMultipart(payload);

      print('resssssssss: ${res.data}');
      Map<String, dynamic>? map;
      if (res.data is Map) {
        final raw = Map<String, dynamic>.from(res.data as Map);
        map = {
          for (final e in raw.entries) e.key.toString().toLowerCase(): e.value,
        };
      }
      final status = map?['statuscode'] ?? res.statusCode;
      final dataOk = map?['data'] == true;
      final serverMessage = (map?['message'] as String?)?.trim();
      if (status == 200 && dataOk) {
        success.value = 'Tạo việc thành công';
        return true;
      }
      error.value =
          (serverMessage != null && serverMessage.isNotEmpty)
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
        error.value =
            (serverMessage != null && serverMessage.isNotEmpty)
                ? serverMessage
                : 'Lỗi khi tạo việc';
      } else {
        error.value = 'Lỗi khi tạo việc';
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
        // Thêm file mới vào danh sách hiện có
        final newFileNames = result.files.map((f) => f.name).toList();
        final newPaths =
            result.files
                .where((f) => f.path != null)
                .map((f) => f.path!)
                .toList();

        attachmentFileNames.addAll(newFileNames);
        attachmentPaths.addAll(newPaths);
      }
    } catch (_) {
      // bỏ qua lỗi, không log thừa
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

  Future<dioLib.Response> _postMultipart(
    CreateTaskRequestPayload payload,
  ) async {
    final map = payload.toJson();
    final form = dioLib.FormData();
    // Trường phẳng
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

    // Nhóm Primary/Collab/Follow (nhiều giá trị -> lặp key)
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

    // Files
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
        headers: {..._dioApi.header, 'Content-Type': 'multipart/form-data'},
      ),
    );
  }
}
