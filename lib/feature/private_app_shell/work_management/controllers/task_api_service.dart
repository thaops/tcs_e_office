import 'package:dio/dio.dart' as dioLib;
import 'package:tcs_e_office/common/Services/api_endpoints.dart';
import 'package:tcs_e_office/common/repositoty/dio_api.dart';
import 'package:tcs_e_office/common/utils/api_response_handler.dart';
import '../models/task_detail_model.dart';

class TaskApiService {
  final DioApi _dioApi = DioApi();

  Future<List<DepartmentNode>> searchEmployeesByDepartment(
    String keyword,
  ) async {
    try {
      final res = await _dioApi.get(
        ApiEndpoints.searchEmployeesByDepartment(keyword),
      );

      final result = ApiResponseHandler.handleListResponse<DepartmentNode>(
        res,
        DepartmentNode.fromJson,
      );

      if (result.isError) {
        throw Exception('Lỗi tìm kiếm nhân viên: ${result.error}');
      }

      return result.data ?? <DepartmentNode>[];
    } catch (e) {
      throw Exception('Không thể tìm kiếm nhân viên: $e');
    }
  }

  Future<Map<String, dynamic>> loadMetadata() async {
    try {
      final prioFuture = _dioApi.get(ApiEndpoints.getPriorityOptions);
      final empFuture = _dioApi.get(ApiEndpoints.employees);
      final deptFuture = _dioApi.get(ApiEndpoints.employeesByDepartment);

      final results = await Future.wait([prioFuture, empFuture, deptFuture]);

      final prioResult = ApiResponseHandler.handleListResponse<PriorityOption>(
        results[0],
        PriorityOption.fromJson,
      );
      final empResult = ApiResponseHandler.handleListResponse<EmployeeSimple>(
        results[1],
        EmployeeSimple.fromJson,
      );
      final deptResult = ApiResponseHandler.handleListResponse<DepartmentNode>(
        results[2],
        DepartmentNode.fromJson,
      );

      if (prioResult.isError) {
        throw Exception('Lỗi tải danh sách độ ưu tiên: ${prioResult.error}');
      }
      if (empResult.isError) {
        throw Exception('Lỗi tải danh sách nhân viên: ${empResult.error}');
      }
      if (deptResult.isError) {
        throw Exception('Lỗi tải danh sách phòng ban: ${deptResult.error}');
      }

      return {
        'priorities': prioResult.data ?? <PriorityOption>[],
        'employees': empResult.data ?? <EmployeeSimple>[],
        'departments': deptResult.data ?? <DepartmentNode>[],
      };
    } catch (e) {
      throw Exception('Không thể tải dữ liệu danh mục: $e');
    }
  }

  Future<Map<String, dynamic>?> loadTaskData(String taskId) async {
    try {
      final res = await _dioApi.get(ApiEndpoints.getTaskById(taskId));

      final result = ApiResponseHandler.handleResponse<Map<String, dynamic>>(
        res,
        (data) => data,
      );

      if (result.isSuccess) {
        return result.data;
      } else {
        throw Exception('Lỗi tải thông tin công việc: ${result.error}');
      }
    } catch (e) {
      throw Exception('Không thể tải thông tin công việc: $e');
    }
  }

  Future<bool> updateTask({
    required String taskId,
    required Map<String, dynamic> payload,
    required List<String> attachmentPaths,
  }) async {
    try {
      final form = _buildFormData(payload, attachmentPaths);

      final res = await _dioApi.post(
        ApiEndpoints.updateTask(taskId),
        data: form,
        options: dioLib.Options(
          headers: {..._dioApi.header, 'Content-Type': 'multipart/form-data'},
        ),
      );

      if (res.data is Map<String, dynamic>) {
        final responseData = res.data as Map<String, dynamic>;

        final statusCode =
            responseData['statusCode'] ?? responseData['StatusCode'];
        final message =
            responseData['message'] ?? responseData['Message'] as String?;
        final data = responseData['data'];

        if (statusCode == 200) {
          return data == true;
        } else {
          throw message ?? statusCode.toString();
        }
      } else {
        throw Exception('Response format không hợp lệ');
      }
    } catch (e) {
      if (e is dioLib.DioException) {
        throw _handleDioException(e);
      }
      throw '$e';
    }
  }

  Future<bool> completeTask(String taskId) async {
    try {
      final res = await _dioApi.post(ApiEndpoints.completeTask(taskId));

      if (res.statusCode != 200) {
        throw Exception('HTTP Error: ${res.statusCode}');
      }

      if (res.data is Map<String, dynamic>) {
        final responseData = res.data as Map<String, dynamic>;

        final statusCode =
            responseData['statusCode'] ?? responseData['StatusCode'];
        final message =
            responseData['message'] ?? responseData['Message'] as String?;
        final data = responseData['data'];

        if (statusCode == 200) {
          return data == true;
        } else {
          throw message ?? statusCode.toString();
        }
      } else {
        throw Exception('Response format không hợp lệ');
      }
    } catch (e) {
      if (e is dioLib.DioException) {
        throw _handleDioException(e);
      }
      throw '$e';
    }
  }

  Future<bool> forwardTask(ForwardTaskRequest request) async {
    try {
      final res = await _dioApi.post(
        ApiEndpoints.forwardTask,
        data: request.toJson(),
      );

      if (res.statusCode != 200) {
        throw Exception('HTTP Error: ${res.statusCode}');
      }

      if (res.data is Map<String, dynamic>) {
        final responseData = res.data as Map<String, dynamic>;

        final statusCode =
            responseData['statusCode'] ?? responseData['StatusCode'];
        final message =
            responseData['message'] ?? responseData['Message'] as String?;
        final data = responseData['data'];

        if (statusCode == 200) {
          return data == true;
        } else {
          throw message ?? statusCode.toString();
        }
      } else {
        throw Exception('Response format không hợp lệ');
      }
    } catch (e) {
      if (e is dioLib.DioException) {
        throw _handleDioException(e);
      }
      throw '$e';
    }
  }

  Future<bool> forwardTaskWithEmployees({
    required String taskId,
    required String dueDate,
    required List<String> selectedEmployeeCodes,
  }) async {
    final request = ForwardTaskRequest(
      id: taskId,
      dueDate: dueDate,
      primary: AssigneeGroup(
        departmentCodes: [],
        employeeCodes: selectedEmployeeCodes,
      ),
      collab: AssigneeGroup(departmentCodes: [], employeeCodes: []),
      follow: AssigneeGroup(departmentCodes: [], employeeCodes: []),
    );

    return await forwardTask(request);
  }

  Future<bool> reprocessTask({
    required String taskId,
    required String note,
  }) async {
    try {
      final res = await _dioApi.post(
        ApiEndpoints.reprocessTask,
        data: {'id': taskId, 'note': note},
      );

      if (res.statusCode != 200) {
        throw Exception('HTTP Error: ${res.statusCode}');
      }

      if (res.data is Map<String, dynamic>) {
        final responseData = res.data as Map<String, dynamic>;

        final statusCode =
            responseData['statusCode'] ?? responseData['StatusCode'];
        final message =
            responseData['message'] ?? responseData['Message'] as String?;
        final data = responseData['data'];

        if (statusCode == 200) {
          return data == true;
        } else {
          throw message ?? statusCode.toString();
        }
      } else {
        throw Exception('Response format không hợp lệ');
      }
    } catch (e) {
      if (e is dioLib.DioException) {
        throw _handleDioException(e);
      }
      throw '$e';
    }
  }

  dioLib.FormData _buildFormData(
    Map<String, dynamic> payload,
    List<String> attachmentPaths,
  ) {
    final form = dioLib.FormData();

    void addField(String key, String? value) {
      if (value != null && value.isNotEmpty) {
        form.fields.add(MapEntry(key, value));
      }
    }

    addField('DocumentId', payload['DocumentId'] as String?);
    addField('AssignerCode', payload['AssignerCode'] as String?);
    addField('TaskName', payload['TaskName'] as String?);
    addField('StartDate', payload['StartDate'] as String?);
    addField('DueDate', payload['DueDate'] as String?);
    addField('Priority', payload['Priority']?.toString());
    addField('Note', payload['Note'] as String?);
    addField('Content', payload['Content'] as String?);

    _addAssigneeGroup(form, 'Primary', payload['Primary']);
    _addAssigneeGroup(form, 'Collab', payload['Collab']);
    _addAssigneeGroup(form, 'Follow', payload['Follow']);

    for (final path in attachmentPaths) {
      form.files.add(
        MapEntry(
          'Attachments',
          dioLib.MultipartFile.fromFileSync(
            path,
            filename: path.split('/').last,
          ),
        ),
      );
    }

    return form;
  }

  void _addAssigneeGroup(
    dioLib.FormData form,
    String groupName,
    dynamic groupData,
  ) {
    if (groupData is Map<String, dynamic>) {
      final deps = (groupData['DepartmentCodes'] as List? ?? []);
      final emps = (groupData['EmployeeCodes'] as List? ?? []);

      for (final code in deps) {
        form.fields.add(
          MapEntry('$groupName.DepartmentCodes', code.toString()),
        );
      }
      for (final code in emps) {
        form.fields.add(MapEntry('$groupName.EmployeeCodes', code.toString()));
      }
    }
  }

  Exception _handleDioException(dioLib.DioException e) {
    final data = e.response?.data;
    String? serverMessage;

    if (data is Map) {
      serverMessage = (data['message'] as String?)?.trim();
    }

    switch (e.response?.statusCode) {
      case 500:
        return Exception(
          'Lỗi server: ${serverMessage ?? 'An error occurred while saving the entity changes'}',
        );
      case 400:
        return Exception(
          'Dữ liệu không hợp lệ: ${serverMessage ?? 'Bad request'}',
        );
      case 404:
        return Exception(
          'Không tìm thấy task: ${serverMessage ?? 'Task not found'}',
        );
      default:
        return Exception(
          serverMessage?.isNotEmpty == true
              ? serverMessage!
              : 'Lỗi khi cập nhật việc (${e.response?.statusCode})',
        );
    }
  }
}
