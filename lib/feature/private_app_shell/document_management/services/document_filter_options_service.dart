import 'package:tcs_e_office/common/repositoty/dio_api.dart';
import 'package:tcs_e_office/common/Services/api_endpoints.dart';
import '../models/document_filter_option_model.dart';

class DocumentFilterOptionsService {
  final DioApi _dioApi = DioApi();

  static List<DocumentFilterOption>? _cachedStatusOptions;
  static List<DocumentFilterOption>? _cachedDocumentTypeOptions;
  static bool _isStatusOptionsLoaded = false;
  static bool _isDocumentTypeOptionsLoaded = false;

  Future<List<DocumentFilterOption>> getStatusOptions() async {
    if (_isStatusOptionsLoaded && _cachedStatusOptions != null) {
      return _cachedStatusOptions!;
    }

    try {
      final response = await _dioApi.get(ApiEndpoints.getDocumentStatusOptions);

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        if (responseData['statusCode'] == 200) {
          final dataList = responseData['data'] as List<dynamic>? ?? [];
          final options = dataList
              .where((item) => item is Map<String, dynamic>)
              .map(
                (item) =>
                    DocumentFilterOption.fromJson(item as Map<String, dynamic>),
              )
              .toList();

          _cachedStatusOptions = options;
          _isStatusOptionsLoaded = true;

          return options;
        } else {
          throw Exception(
            'API Error: ${responseData['message'] ?? 'Unknown error'}',
          );
        }
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      return _getDefaultStatusOptions();
    }
  }

  Future<List<DocumentFilterOption>> getDocumentTypeOptions({
    String? code,
  }) async {
    if (_isDocumentTypeOptionsLoaded && _cachedDocumentTypeOptions != null) {
      return _cachedDocumentTypeOptions!;
    }

    try {
      final response = await _dioApi.get(
        ApiEndpoints.getDocumentTypeOptions,
        params: {if (code != null) 'code': code},
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        if (responseData['statusCode'] == 200) {
          final dataList = responseData['data'] as List<dynamic>? ?? [];
          final options = dataList
              .where((item) => item is Map<String, dynamic>)
              .map(
                (item) =>
                    DocumentFilterOption.fromJson(item as Map<String, dynamic>),
              )
              .toList();

          _cachedDocumentTypeOptions = options;
          _isDocumentTypeOptionsLoaded = true;

          return options;
        } else {
          throw Exception(
            'API Error: ${responseData['message'] ?? 'Unknown error'}',
          );
        }
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      return _getDefaultDocumentTypeOptions();
    }
  }

  List<DocumentFilterOption> _getDefaultStatusOptions() {
    return [
      DocumentFilterOption(value: '1', label: 'Draft', color: '#898989'),
      DocumentFilterOption(value: '2', label: 'Submitted', color: '#E39516'),
      DocumentFilterOption(value: '3', label: 'Approved', color: '#339B00'),
      DocumentFilterOption(value: '4', label: 'Published', color: '#1B1FB8'),
      DocumentFilterOption(value: '5', label: 'Rejected', color: '#FF2323'),
    ];
  }

  List<DocumentFilterOption> _getDefaultDocumentTypeOptions() {
    return [
      DocumentFilterOption(
        value: 'CV',
        label:
            'Công văn công ty ban hành gửi ra ngoài cty (giấy mời, báo cáo, phúc đáp,…)',
      ),
      DocumentFilterOption(value: 'BC', label: 'Báo cáo'),
      DocumentFilterOption(value: 'GUQ', label: 'Giấy ủy quyền'),
      DocumentFilterOption(value: 'TB', label: 'Thông báo (gửi KH và nội bộ)'),
      DocumentFilterOption(value: 'GDD', label: 'Giấy đi đường'),
      DocumentFilterOption(value: 'HD', label: 'Hướng dẫn'),
      DocumentFilterOption(value: 'KH', label: 'Kế hoạch'),
      DocumentFilterOption(value: 'HOPD', label: 'Hợp đồng'),
      DocumentFilterOption(value: 'TT', label: 'Tờ trình'),
      DocumentFilterOption(value: 'BB', label: 'Biên bản'),
      DocumentFilterOption(value: 'CT', label: 'Chương trình'),
      DocumentFilterOption(value: 'NQ', label: 'Nghị quyết'),
      DocumentFilterOption(value: 'DA', label: 'Đề án'),
      DocumentFilterOption(value: 'QD', label: 'Quyết định'),
    ];
  }

  static void clearCache() {
    _cachedStatusOptions = null;
    _cachedDocumentTypeOptions = null;
    _isStatusOptionsLoaded = false;
    _isDocumentTypeOptionsLoaded = false;
  }
}
