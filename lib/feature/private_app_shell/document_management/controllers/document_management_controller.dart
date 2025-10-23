import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tcs_e_office/common/repositoty/dio_api.dart';
import 'package:tcs_e_office/common/Services/api_endpoints.dart';
import '../model/document_model.dart';
import '../models/document_filter_model.dart';

class DocumentManagementController extends GetxController {
  // DioApi instance
  final DioApi _dioApi = DioApi();

  // Tab hiện tại (0: Văn bản đến, 1: Văn bản đi)
  final RxInt currentTab = 0.obs;

  // Danh sách văn bản đến
  final RxList<DocumentModel> documentsIncoming = <DocumentModel>[].obs;
  final RxBool isLoadingIncoming = false.obs;
  final RxInt totalRecordIncoming = 0.obs;

  // Danh sách văn bản đi
  final RxList<DocumentModel> documentsOutgoing = <DocumentModel>[].obs;
  final RxBool isLoadingOutgoing = false.obs;
  final RxInt totalRecordOutgoing = 0.obs;

  // Tìm kiếm riêng biệt cho từng tab
  final RxString searchQueryIncoming = ''.obs;
  final RxString searchQueryOutgoing = ''.obs;
  final TextEditingController searchControllerIncoming =
      TextEditingController();
  final TextEditingController searchControllerOutgoing =
      TextEditingController();
  Timer? _searchDebounceIncoming;
  Timer? _searchDebounceOutgoing;

  // Phân trang
  final RxInt currentPageIncoming = 1.obs;
  final RxInt currentPageOutgoing = 1.obs;
  final int pageSize = 20;

  // Filter cho từng tab
  final Rx<DocumentFilterModel> filterIncoming =
      DocumentFilterModel.empty().obs;
  final Rx<DocumentFilterModel> filterOutgoing =
      DocumentFilterModel.empty().obs;

  // Danh sách gốc (trước khi filter)
  final RxList<DocumentModel> _originalDocumentsIncoming =
      <DocumentModel>[].obs;
  final RxList<DocumentModel> _originalDocumentsOutgoing =
      <DocumentModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDocumentsIncoming();
    loadDocumentsOutgoing();
  }

  @override
  void onClose() {
    _searchDebounceIncoming?.cancel();
    _searchDebounceOutgoing?.cancel();
    searchControllerIncoming.dispose();
    searchControllerOutgoing.dispose();
    super.onClose();
  }

  // Chuyển tab
  void changeTab(int index) {
    currentTab.value = index;
  }

  // Tải danh sách văn bản đến
  Future<void> loadDocumentsIncoming({bool refresh = false}) async {
    if (refresh) {
      currentPageIncoming.value = 1;
      documentsIncoming.clear();
    }

    dynamic response;
    try {
      isLoadingIncoming.value = true;

      response = await _dioApi.get(
        ApiEndpoints.getDocuments,
        params: {
          'pageIndex': currentPageIncoming.value,
          'pageSize': pageSize,
          'status': 10, // Văn bản đến
        },
      );

      // Parse response data trực tiếp với null safety
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;

        // Kiểm tra status code
        if (responseData['statusCode'] == 200) {
          final dataList = responseData['data'] as List<dynamic>? ?? [];
          final documents = dataList
              .where((item) => item is Map<String, dynamic>)
              .map(
                (item) => DocumentModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();

          final documentResponse = DocumentListResponse(
            statusCode: responseData['statusCode'] ?? 0,
            message: responseData['message'] ?? '',
            totalRecord: responseData['totalRecord'] ?? 0,
            data: documents,
          );

          if (refresh) {
            _originalDocumentsIncoming.value = documentResponse.data;
            _applyFilterIncoming();
          } else {
            _originalDocumentsIncoming.addAll(documentResponse.data);
            _applyFilterIncoming();
          }

          totalRecordIncoming.value = documentResponse.totalRecord;
        } else {
          throw Exception(
            'API Error: ${responseData['message'] ?? 'Unknown error'}',
          );
        }
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      // Không sử dụng Get.snackbar
      print('Error loading documents incoming: $e');
      print('Response data type: ${response.data.runtimeType}');
      print('Response data: ${response.data}');
    } finally {
      isLoadingIncoming.value = false;
    }
  }

  // Tải danh sách văn bản đi
  Future<void> loadDocumentsOutgoing({bool refresh = false}) async {
    if (refresh) {
      currentPageOutgoing.value = 1;
      documentsOutgoing.clear();
    }

    dynamic response;
    try {
      isLoadingOutgoing.value = true;

      response = await _dioApi.get(
        ApiEndpoints.getDocuments,
        params: {
          'pageIndex': currentPageOutgoing.value,
          'pageSize': pageSize,
          'status': 20, // Văn bản đi
        },
      );

      // Parse response data trực tiếp với null safety
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;

        // Kiểm tra status code
        if (responseData['statusCode'] == 200) {
          final dataList = responseData['data'] as List<dynamic>? ?? [];
          final documents = dataList
              .where((item) => item is Map<String, dynamic>)
              .map(
                (item) => DocumentModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();

          final documentResponse = DocumentListResponse(
            statusCode: responseData['statusCode'] ?? 0,
            message: responseData['message'] ?? '',
            totalRecord: responseData['totalRecord'] ?? 0,
            data: documents,
          );

          if (refresh) {
            _originalDocumentsOutgoing.value = documentResponse.data;
            _applyFilterOutgoing();
          } else {
            _originalDocumentsOutgoing.addAll(documentResponse.data);
            _applyFilterOutgoing();
          }

          totalRecordOutgoing.value = documentResponse.totalRecord;
        } else {
          throw Exception(
            'API Error: ${responseData['message'] ?? 'Unknown error'}',
          );
        }
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      // Không sử dụng Get.snackbar
      print('Error loading documents outgoing: $e');
      print('Response data type: ${response.data.runtimeType}');
      print('Response data: ${response.data}');
    } finally {
      isLoadingOutgoing.value = false;
    }
  }

  // Tải thêm dữ liệu (phân trang)
  Future<void> loadMore() async {
    if (currentTab.value == 0) {
      if (documentsIncoming.length < totalRecordIncoming.value) {
        currentPageIncoming.value++;
        await loadDocumentsIncoming();
      }
    } else {
      if (documentsOutgoing.length < totalRecordOutgoing.value) {
        currentPageOutgoing.value++;
        await loadDocumentsOutgoing();
      }
    }
  }

  // Làm mới dữ liệu
  Future<void> refresh() async {
    if (currentTab.value == 0) {
      await loadDocumentsIncoming(refresh: true);
    } else {
      await loadDocumentsOutgoing(refresh: true);
    }
  }

  // Tìm kiếm cho tab "Văn bản đến"
  void onSearchChangedIncoming(String query) {
    searchQueryIncoming.value = query;
    _searchDebounceIncoming?.cancel();

    if (query.isEmpty) {
      loadDocumentsIncoming(refresh: true);
      return;
    }

    _searchDebounceIncoming = Timer(const Duration(milliseconds: 500), () {
      loadDocumentsIncoming(refresh: true);
    });
  }

  // Tìm kiếm cho tab "Văn bản đi"
  void onSearchChangedOutgoing(String query) {
    searchQueryOutgoing.value = query;
    _searchDebounceOutgoing?.cancel();

    if (query.isEmpty) {
      loadDocumentsOutgoing(refresh: true);
      return;
    }

    _searchDebounceOutgoing = Timer(const Duration(milliseconds: 500), () {
      loadDocumentsOutgoing(refresh: true);
    });
  }

  // Clear search cho tab "Văn bản đến"
  void clearSearchIncoming() {
    _searchDebounceIncoming?.cancel();
    searchControllerIncoming.clear();
    searchQueryIncoming.value = '';
    loadDocumentsIncoming(refresh: true);
  }

  // Clear search cho tab "Văn bản đi"
  void clearSearchOutgoing() {
    _searchDebounceOutgoing?.cancel();
    searchControllerOutgoing.clear();
    searchQueryOutgoing.value = '';
    loadDocumentsOutgoing(refresh: true);
  }

  // Lấy danh sách đã filter
  List<DocumentModel> get filteredDocumentsIncoming => documentsIncoming;
  List<DocumentModel> get filteredDocumentsOutgoing => documentsOutgoing;

  // Lấy màu sắc theo trạng thái
  Color getStatusColor(String status) {
    switch (status) {
      case '1': // Chờ duyệt
        return Colors.orange;
      case '2': // Đang xử lý
        return Colors.blue;
      case '3': // Hoàn thành
        return Colors.green;
      case '4': // Từ chối
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Áp dụng filter cho tab "Văn bản đến"
  void _applyFilterIncoming() {
    final filteredDocuments = _filterDocuments(
      _originalDocumentsIncoming,
      filterIncoming.value,
    );
    documentsIncoming.value = filteredDocuments;
  }

  // Áp dụng filter cho tab "Văn bản đi"
  void _applyFilterOutgoing() {
    final filteredDocuments = _filterDocuments(
      _originalDocumentsOutgoing,
      filterOutgoing.value,
    );
    documentsOutgoing.value = filteredDocuments;
  }

  // Logic filter chung
  List<DocumentModel> _filterDocuments(
    List<DocumentModel> originalDocuments,
    DocumentFilterModel filter,
  ) {
    final hasClientSideFilter =
        filter.status != null || filter.documentType != null;

    if (!hasClientSideFilter) {
      return originalDocuments;
    }

    return originalDocuments.where((document) {
      if (filter.status != null && document.status != filter.status) {
        return false;
      }
      if (filter.documentType != null &&
          document.documentType != filter.documentType) {
        return false;
      }
      return true;
    }).toList();
  }

  // Áp dụng filter mới cho tab hiện tại
  void applyFilter(DocumentFilterModel newFilter) {
    if (currentTab.value == 0) {
      filterIncoming.value = newFilter;
      _applyFilterIncoming();
    } else {
      filterOutgoing.value = newFilter;
      _applyFilterOutgoing();
    }
  }

  // Reset filter cho tab hiện tại
  void resetFilter() {
    if (currentTab.value == 0) {
      filterIncoming.value = DocumentFilterModel.empty();
      _applyFilterIncoming();
    } else {
      filterOutgoing.value = DocumentFilterModel.empty();
      _applyFilterOutgoing();
    }
  }

  // Lấy filter hiện tại của tab
  DocumentFilterModel getCurrentFilter() {
    return currentTab.value == 0 ? filterIncoming.value : filterOutgoing.value;
  }
}
