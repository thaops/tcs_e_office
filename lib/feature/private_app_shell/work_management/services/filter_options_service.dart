import 'package:tcs_e_office/common/repositoty/dio_api.dart';
import 'package:tcs_e_office/common/Services/api_endpoints.dart';

class FilterOption {
  final int? value;
  final String label;

  FilterOption({this.value, required this.label});

  factory FilterOption.fromJson(Map<String, dynamic> json) {
    return FilterOption(
      value: json['value'] as int?,
      label: json['label'] ?? '',
    );
  }
}

class FilterOptionsResponse {
  final int statusCode;
  final String message;
  final int totalRecord;
  final List<FilterOption> data;

  FilterOptionsResponse({
    required this.statusCode,
    required this.message,
    required this.totalRecord,
    required this.data,
  });

  factory FilterOptionsResponse.fromJson(Map<String, dynamic> json) {
    return FilterOptionsResponse(
      statusCode: json['statusCode'] ?? 0,
      message: json['message'] ?? '',
      totalRecord: json['totalRecord'] ?? 0,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => FilterOption.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class FilterOptionsService {
  final DioApi _dioApi = DioApi();

  // Lấy danh sách trạng thái
  Future<List<FilterOption>> getStatusOptions() async {
    try {
      final response = await _dioApi.get(ApiEndpoints.getStatusOptions);

      if (response.statusCode == 200) {
        final statusResponse = FilterOptionsResponse.fromJson(response.data);
        return statusResponse.data;
      } else {
        throw Exception(
          'Failed to load status options: ${response.statusCode}',
        );
      }
    } catch (e) {
      // Fallback về options mặc định nếu API lỗi
      return [
        FilterOption(value: 1, label: 'Đang thực hiện'),
        FilterOption(value: 2, label: 'Hoàn thành'),
        FilterOption(value: 3, label: 'Quá hạn'),
      ];
    }
  }

  // Lấy danh sách mức độ ưu tiên
  Future<List<FilterOption>> getPriorityOptions() async {
    try {
      final response = await _dioApi.get(ApiEndpoints.getPriorityOptions);

      if (response.statusCode == 200) {
        final priorityResponse = FilterOptionsResponse.fromJson(response.data);
        return priorityResponse.data;
      } else {
        throw Exception(
          'Failed to load priority options: ${response.statusCode}',
        );
      }
    } catch (e) {
      // Fallback về options mặc định nếu API lỗi
      return [
        FilterOption(value: 0, label: 'Khẩn cấp'),
        FilterOption(value: 1, label: 'Ưu tiên cao'),
        FilterOption(value: 2, label: 'Trung bình'),
        FilterOption(value: 3, label: 'Bình thường'),
        FilterOption(value: 4, label: 'Thấp'),
      ];
    }
  }

  // Lấy danh sách vai trò
  Future<List<FilterOption>> getRoleOptions() async {
    try {
      final response = await _dioApi.get(ApiEndpoints.getRoleOptions);

      if (response.statusCode == 200) {
        final roleResponse = FilterOptionsResponse.fromJson(response.data);
        return roleResponse.data;
      } else {
        throw Exception('Failed to load role options: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback về options mặc định nếu API lỗi
      return [
        FilterOption(value: 1, label: 'Xử lý chính'),
        FilterOption(value: 2, label: 'Phối hợp'),
        FilterOption(value: 3, label: 'Theo dõi'),
      ];
    }
  }
}
