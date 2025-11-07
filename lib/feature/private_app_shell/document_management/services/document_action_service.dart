import 'package:dio/dio.dart' as dioLib;
import 'package:tcs_e_office/common/repositoty/dio_api.dart';
import 'package:tcs_e_office/common/Services/api_endpoints.dart';

class DocumentActionService {
  final DioApi _dioApi = DioApi();


  Future<bool> markAsRead(List<String> documentIds) async {
    try {
      final response = await _dioApi.post(
        ApiEndpoints.finishDocuments,
        data: {'documentIds': documentIds},
      );

      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
   
        final statusCode =
            responseData['statusCode'] ?? responseData['StatusCode'];
        if (statusCode == 200) {
          final data = responseData['data'] ?? responseData['Data'];
          if (data is bool) {
            return data;
          }
          return true;
        } else {
          return false;
        }
      }

      if (response.statusCode == 200) {
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> markSingleAsRead(String documentId) async {
    return await markAsRead([documentId]);
  }

  Future<Map<String, dynamic>> forwardDocument(
    String documentId,
    String employeeCode,
  ) async {
    try {
      final payload = {'id': documentId, 'employeeCode': employeeCode};

      final response = await _dioApi.post(
        ApiEndpoints.forwardDocument,
        data: payload,
      );

      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        final bool success =
            (responseData['data'] ?? responseData['Data']) == true;
        final String message =
            responseData['message'] ??
            responseData['Message'] ??
            'Unknown error';
        return {'success': success, 'message': message};
      }

      return {'success': false, 'message': 'Invalid response format'};
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }


  Future<Map<String, dynamic>> approveDocuments(
    List<String> documentIds,
    bool isApprove, {
    String? note,
  }) async {
    try {
      final payload = {
        'documentIds': documentIds,
        'isApprove': isApprove,
      };

      if (note != null && note.isNotEmpty) {
        payload['note'] = note;
      }

      final response = await _dioApi.post(
        ApiEndpoints.approveDocuments,
        data: payload,
      );

      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        final bool success =
            (responseData['data'] ?? responseData['Data']) == true ||
            response.statusCode == 200;
        final String message =
            responseData['message'] ??
            responseData['Message'] ??
            (success ? 'Successful.' : 'Unknown error');
        return {'success': success, 'message': message};
      }

      return {'success': false, 'message': 'Invalid response format'};
    } catch (e) {
     
      String errorMessage = 'Lỗi kết nối: $e';
      if (e is dioLib.DioException && e.response != null) {
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message'] as String? ?? errorMessage;
        }
      }
      
      return {'success': false, 'message': errorMessage};
    }
  }
}
