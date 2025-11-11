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

  void changeTab(int index) {
    currentTab.value = index;
  }

  Future<void> loadDocumentsIncoming({bool refresh = false}) async {
    if (refresh) {
      currentPageIncoming.value = 1;
      documentsIncoming.clear();
    }

    dynamic response;
    try {
      isLoadingIncoming.value = true;

      final params = <String, dynamic>{
        'pageIndex': currentPageIncoming.value,
        'pageSize': pageSize,
        'status': 10,
      };

      if (searchQueryIncoming.value.isNotEmpty) {
        params['keyword'] = searchQueryIncoming.value;
      }

      if (filterIncoming.value.status != null) {
        params['status'] = filterIncoming.value.status;
      }

      if (filterIncoming.value.isRead != null) {
        params['read'] = filterIncoming.value.isRead;
        print('📖 Filter isRead: ${filterIncoming.value.isRead}');
        print('📖 Params read: ${params['read']}');
      }

      print('📋 All params: $params');
      response = await _dioApi.get(ApiEndpoints.getDocuments, params: params);
      print('📡 Response: ${response.data}');

      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;

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
    } finally {
      isLoadingIncoming.value = false;
    }
  }

  Future<void> loadDocumentsOutgoing({
    bool refresh = false,
    int? customStatus,
  }) async {
    if (refresh) {
      currentPageOutgoing.value = 1;
      documentsOutgoing.clear();
    }

    dynamic response;
    try {
      isLoadingOutgoing.value = true;

      final params = <String, dynamic>{
        'pageIndex': currentPageOutgoing.value,
        'pageSize': pageSize,
      };

      if (searchQueryOutgoing.value.isNotEmpty) {
        params['keyword'] = searchQueryOutgoing.value;
      }

      if (filterOutgoing.value.status != null) {
        params['status'] = filterOutgoing.value.status;
      }

      response = await _dioApi.get(ApiEndpoints.getDocuments, params: params);

      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;

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
    } finally {
      isLoadingOutgoing.value = false;
    }
  }

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

  Future<void> refresh() async {
    if (currentTab.value == 0) {
      await loadDocumentsIncoming(refresh: true);
    } else {
      await loadDocumentsOutgoing(refresh: true);
    }
  }

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
      case '1': // Draft
        return const Color(0xFF898989); // Gray
      case '2': // Submitted
        return const Color(0xFFE39516); // Orange
      case '3': // Approved
        return const Color(0xFF339B00); // Green
      case '4': // Published
        return const Color(0xFF1B1FB8); // Blue
      case '5': // Rejected
        return const Color(0xFFFF2323); // Red
      default:
        return Colors.grey;
    }
  }

  // Lấy text theo trạng thái
  String getStatusText(String status) {
    switch (status) {
      case '1':
        return 'Bản nháp';
      case '2':
        return 'Đã gửi';
      case '3':
        return 'Đã duyệt';
      case '4':
        return 'Đã xuất bản';
      case '5':
        return 'Đã từ chối';
      default:
        return 'Không xác định';
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
  // Lưu ý: isRead được filter ở server-side qua API, không filter ở client
  List<DocumentModel> _filterDocuments(
    List<DocumentModel> originalDocuments,
    DocumentFilterModel filter,
  ) {
    final hasClientSideFilter =
        filter.status != null || filter.documentType != null;
    // isRead được filter ở server-side, không filter ở client

    if (!hasClientSideFilter) {
      return originalDocuments;
    }

    return originalDocuments.where((document) {
      if (filter.status != null && document.status != filter.status) {
        return false;
      }
      if (filter.documentType != null) {
        final category = int.tryParse(filter.documentType!);
        if (category == null || document.category != category) {
          return false;
        }
      }
      // isRead được filter ở server-side qua API param 'read'
      return true;
    }).toList();
  }

  DocumentFilterModel getCurrentFilter() {
    return currentTab.value == 0 ? filterIncoming.value : filterOutgoing.value;
  }

  void applyFilter(DocumentFilterModel newFilter) {
    if (currentTab.value == 0) {
      filterIncoming.value = newFilter;
      loadDocumentsIncoming(refresh: true);
    } else {
      filterOutgoing.value = newFilter;
      loadDocumentsOutgoing(refresh: true);
    }
  }

  void applyFilterForTab(DocumentFilterModel newFilter, int targetTab) {
    if (targetTab == 0) {
      filterIncoming.value = newFilter;
      loadDocumentsIncoming(refresh: true);
    } else {
      filterOutgoing.value = newFilter;
      loadDocumentsOutgoing(refresh: true);
    }
  }

  void resetFilter() {
    if (currentTab.value == 0) {
      filterIncoming.value = DocumentFilterModel.empty();
      loadDocumentsIncoming(refresh: true);
    } else {
      filterOutgoing.value = DocumentFilterModel.empty();
      loadDocumentsOutgoing(refresh: true);
    }
  }

  Future<void> refreshWithStatus(int? status) async {
    await loadDocumentsOutgoing(refresh: true, customStatus: status);
  }

  Future<void> loadMoreWithStatus(int? status) async {
    if (documentsOutgoing.length < totalRecordOutgoing.value) {
      currentPageOutgoing.value++;
      await loadDocumentsOutgoing(customStatus: status);
    }
  }
}
