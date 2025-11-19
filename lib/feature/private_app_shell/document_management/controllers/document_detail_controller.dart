import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tcs_e_office/common/repositoty/dio_api.dart';
import 'package:tcs_e_office/common/Services/api_endpoints.dart';
import 'package:tcs_e_office/common/utils/api_response_handler.dart';
import '../models/document_detail_model.dart';

class DocumentDetailController extends GetxController {
  final String documentId;
  final String? tabType;
  DocumentDetailController(this.documentId, {this.tabType});

  final DioApi _dioApi = DioApi();

  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final Rxn<DocumentDetailModel> detail = Rxn<DocumentDetailModel>();
  final RxString error = ''.obs;
  final RxList<DistributorDeptModel> distributors =
      <DistributorDeptModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDetail();
  }

  Future<void> fetchDetail() async {
    try {
      isLoading.value = true;
      error.value = '';

      if (documentId.isEmpty) {
        error.value = 'Document ID không được để trống';
        isLoading.value = false;
        return;
      }

      if (documentId.startsWith('http')) {
        error.value =
            'Document ID không hợp lệ. Vui lòng sử dụng ID thay vì URL.\n\nURL được cung cấp: $documentId\n\nVui lòng sử dụng document ID thực tế từ danh sách văn bản.';
        isLoading.value = false;
        return;
      }

      String url = ApiEndpoints.getDocumentById4Mobile(documentId);

      if (tabType != null) {
        final uri = Uri.parse(url);
        url = uri.replace(queryParameters: {'source': tabType}).toString();
      }

      final response = await _dioApi.get(url);

      debugPrint('responseDocumentDetail: ${response.data}');

      final result = ApiResponseHandler.handleResponse<DocumentDetailModel>(
        response,
        DocumentDetailModel.fromJson,
      );

      if (result.isSuccess) {
        detail.value = result.data!;
      } else {
        error.value = result.error ?? 'Lỗi không xác định';
      }
    } catch (e) {
      error.value = 'Đã xảy ra lỗi khi tải chi tiết: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshDetail() async {
    try {
      isRefreshing.value = true;
      error.value = '';

      String url = ApiEndpoints.getDocumentById4Mobile(documentId);

      if (tabType != null) {
        final uri = Uri.parse(url);
        url = uri.replace(queryParameters: {'source': tabType}).toString();
      }

      final response = await _dioApi.get(url);

      final result = ApiResponseHandler.handleResponse<DocumentDetailModel>(
        response,
        DocumentDetailModel.fromJson,
      );

      if (result.isSuccess) {
        detail.value = result.data!;
      } else {
        error.value = result.error ?? 'Lỗi không xác định';
      }
    } catch (e) {
      error.value = 'Đã xảy ra lỗi khi tải chi tiết: $e';
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> fetchDistributors() async {
    try {
      final url = ApiEndpoints.getDocumentById4Mobile(documentId);
      final response = await _dioApi.get(url);

      final result = ApiResponseHandler.handleResponse<Map<String, dynamic>>(
        response,
        (data) => data,
      );

      if (result.isSuccess && result.data != null) {
        final data = result.data!;
        final distributorsList =
            (data['distributors'] as List<dynamic>?)
                ?.map((e) => DistributorDeptModel.fromJson(e))
                .toList() ??
            [];

        distributors.value = distributorsList;
      }
    } catch (e) {
      distributors.value = [];
    }
  }
}
