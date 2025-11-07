/// Model cho Document Count Response từ API
class DocumentCountModel {
  final int draftCount; // Văn bản đi dự thảo (status 1)
  final int pendingApprovalCount; // Văn bản đi chờ duyệt (status 2)
  final int rejectedCount; // Văn bản đi bị từ chối (status 5)
  final int approvedCount; // Văn bản đi đã duyệt (status 3)
  final int issuedCount; // Văn bản đi ban hành (status 4)
  final int incomingCount; // Văn bản đến (status 10)

  DocumentCountModel({
    required this.draftCount,
    required this.pendingApprovalCount,
    required this.rejectedCount,
    required this.approvedCount,
    required this.issuedCount,
    required this.incomingCount,
  });

  /// Parse từ JSON response
  /// API trả về mảng các object {status: int, count: int}
  /// ApiResponseHandler sẽ truyền data array trực tiếp vào fromJson
  /// Signature cần nhận Map<String, dynamic> để tương thích với ApiResponseHandler
  factory DocumentCountModel.fromJson(Map<String, dynamic> json) {
    // Nếu json có key 'data' và data là List
    if (json['data'] != null && json['data'] is List) {
      return DocumentCountModel._fromDataArray(json['data'] as List);
    }
    // Fallback: parse từ object trực tiếp (nếu data là object)
    if (json.containsKey('status') && json.containsKey('count')) {
      return DocumentCountModel._fromDataArray([json]);
    }
    // Default: return empty counts
    return DocumentCountModel(
      draftCount: 0,
      pendingApprovalCount: 0,
      rejectedCount: 0,
      approvedCount: 0,
      issuedCount: 0,
      incomingCount: 0,
    );
  }

  /// Parse từ List (dùng khi data là List trực tiếp)
  /// Method này được gọi khi ApiResponseHandler truyền List vào fromJson
  factory DocumentCountModel.fromList(List<dynamic> dataList) {
    return DocumentCountModel._fromDataArray(dataList);
  }

  /// Parse từ mảng data
  factory DocumentCountModel._fromDataArray(List<dynamic> dataList) {
    int draft = 0;
    int pendingApproval = 0;
    int rejected = 0;
    int approved = 0;
    int issued = 0;
    int incoming = 0;

    for (var item in dataList) {
      // Cast item thành Map để truy cập các field
      if (item is! Map<String, dynamic>) continue;

      final status = item['status'] as int?;
      final count = item['count'] as int? ?? 0;

      switch (status) {
        case 1:
          draft = count;
          break;
        case 2:
          pendingApproval = count;
          break;
        case 3:
          approved = count;
          break;
        case 4:
          issued = count;
          break;
        case 5:
          rejected = count;
          break;
        case 10:
          incoming = count;
          break;
      }
    }

    return DocumentCountModel(
      draftCount: draft,
      pendingApprovalCount: pendingApproval,
      rejectedCount: rejected,
      approvedCount: approved,
      issuedCount: issued,
      incomingCount: incoming,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'draftCount': draftCount,
      'pendingApprovalCount': pendingApprovalCount,
      'rejectedCount': rejectedCount,
      'approvedCount': approvedCount,
      'issuedCount': issuedCount,
      'incomingCount': incomingCount,
    };
  }

  /// Tính tổng số văn bản đi
  int get totalOutgoingCount =>
      draftCount +
      pendingApprovalCount +
      rejectedCount +
      approvedCount +
      issuedCount;

  /// Tính tổng số văn bản đến
  int get totalIncomingCount => incomingCount;

  /// Tính tổng số văn bản
  int get totalCount => totalOutgoingCount + totalIncomingCount;
}
