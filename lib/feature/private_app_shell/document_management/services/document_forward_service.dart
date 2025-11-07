import 'package:tcs_e_office/common/repositoty/dio_api.dart';
import 'package:tcs_e_office/common/Services/api_endpoints.dart';
import 'package:tcs_e_office/common/utils/api_response_handler.dart';
import '../models/issue_unit_model.dart';
import '../models/employee_forward_model.dart';

class DocumentForwardService {
  final DioApi _dioApi = DioApi();

  Future<List<IssueUnitModel>> getIssueUnitOptions() async {
    try {
      final response = await _dioApi.get(ApiEndpoints.getIssueUnitOptions);

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic>) {
          final data = responseData['data'];
          if (data is List) {
            final List<IssueUnitModel> result = [];
            for (final item in data) {
              if (item is Map<String, dynamic>) {
                result.add(IssueUnitModel.fromJson(item));
              }
            }
            return result;
          }
        }
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<EmployeeForwardModel>> getEmployeesByDepartment(
    String departmentCode,
  ) async {
    try {
      final url =
          '${ApiEndpoints.getEmployeesByDepartment}?departmentCode=$departmentCode';
      final response = await _dioApi.get(url);

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic>) {
          final data = responseData['data'];
          if (data is List) {
            final List<EmployeeForwardModel> result = [];
            for (final item in data) {
              if (item is Map<String, dynamic>) {
                result.add(EmployeeForwardModel.fromJson(item));
              }
            }
            return result;
          }
        }
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> forwardDocument(String documentId, String employeeCode) async {
    try {
      final payload = {'id': documentId, 'employeeCode': employeeCode};

      final response = await _dioApi.post(
        ApiEndpoints.forwardDocument,
        data: payload,
      );

      final result = ApiResponseHandler.handleResponse<bool>(
        response,
        (data) => data as bool,
      );

      if (result.isSuccess) {
        return result.data ?? false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
