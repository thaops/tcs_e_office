class DocumentFilterModel {
  final String? status; // Trạng thái văn bản (1-5) - dùng cho văn bản đi
  final String? documentType; // Loại văn bản (CV, BC, GUQ, etc.)
  final bool? isRead; // Trạng thái đọc (true: Đã đọc, false: Chưa đọc) - dùng cho văn bản đến
  final DateTime? fromDate; // Từ ngày
  final DateTime? toDate; // Đến ngày

  DocumentFilterModel({
    this.status,
    this.documentType,
    this.isRead,
    this.fromDate,
    this.toDate,
  });

  // Tạo filter rỗng
  factory DocumentFilterModel.empty() {
    return DocumentFilterModel();
  }

  // Copy với các thay đổi
  DocumentFilterModel copyWith({
    String? status,
    String? documentType,
    bool? isRead,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    return DocumentFilterModel(
      status: status ?? this.status,
      documentType: documentType ?? this.documentType,
      isRead: isRead ?? this.isRead,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
    );
  }

  // Tạo từ DocumentFilterModel khác
  factory DocumentFilterModel.fromFilterModel(DocumentFilterModel other) {
    return DocumentFilterModel(
      status: other.status,
      documentType: other.documentType,
      isRead: other.isRead,
      fromDate: other.fromDate,
      toDate: other.toDate,
    );
  }

  // Kiểm tra có filter nào được áp dụng không
  bool get hasActiveFilter {
    return status != null ||
        documentType != null ||
        isRead != null ||
        fromDate != null ||
        toDate != null;
  }

  // Kiểm tra filter có thay đổi không
  bool isDifferentFrom(DocumentFilterModel other) {
    return status != other.status ||
        documentType != other.documentType ||
        isRead != other.isRead ||
        fromDate != other.fromDate ||
        toDate != other.toDate;
  }

  // Lấy tên trạng thái
  String getStatusName() {
    switch (status) {
      case '1':
        return 'Draft';
      case '2':
        return 'Submitted';
      case '3':
        return 'Approved';
      case '4':
        return 'Published';
      case '5':
        return 'Rejected';
      default:
        return 'Tất cả';
    }
  }

  // Lấy tên loại văn bản
  String getDocumentTypeName() {
    switch (documentType) {
      case 'CV':
        return 'Công văn';
      case 'BC':
        return 'Báo cáo';
      case 'GUQ':
        return 'Giấy ủy quyền';
      case 'TB':
        return 'Thông báo';
      case 'GDD':
        return 'Giấy đi đường';
      case 'HD':
        return 'Hướng dẫn';
      case 'KH':
        return 'Kế hoạch';
      case 'HOPD':
        return 'Hợp đồng';
      case 'TT':
        return 'Tờ trình';
      case 'BB':
        return 'Biên bản';
      case 'CT':
        return 'Chương trình';
      case 'NQ':
        return 'Nghị quyết';
      case 'DA':
        return 'Đề án';
      case 'QD':
        return 'Quyết định';
      default:
        return 'Tất cả';
    }
  }

  // Lấy mô tả filter hiện tại
  String getFilterDescription() {
    List<String> parts = [];

    if (status != null) {
      parts.add('Trạng thái: ${getStatusName()}');
    }

    if (documentType != null) {
      parts.add('Loại: ${getDocumentTypeName()}');
    }

    if (fromDate != null) {
      parts.add('Từ: ${fromDate!.day}/${fromDate!.month}/${fromDate!.year}');
    }

    if (toDate != null) {
      parts.add('Đến: ${toDate!.day}/${toDate!.month}/${toDate!.year}');
    }

    if (parts.isEmpty) {
      return 'Không có bộ lọc';
    }

    return parts.join(', ');
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'documentType': documentType,
      'isRead': isRead,
      'fromDate': fromDate?.toIso8601String(),
      'toDate': toDate?.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DocumentFilterModel &&
        other.status == status &&
        other.documentType == documentType &&
        other.isRead == isRead &&
        other.fromDate == fromDate &&
        other.toDate == toDate;
  }

  @override
  int get hashCode {
    return status.hashCode ^
        documentType.hashCode ^
        isRead.hashCode ^
        fromDate.hashCode ^
        toDate.hashCode;
  }

  @override
  String toString() {
    return 'DocumentFilterModel(status: $status, documentType: $documentType, isRead: $isRead, fromDate: $fromDate, toDate: $toDate)';
  }
}
