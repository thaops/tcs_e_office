class DocumentFilterModel {
  final String? status;
  final String? documentType;
  final DateTime? fromDate;
  final DateTime? toDate;

  DocumentFilterModel({
    this.status,
    this.documentType,
    this.fromDate,
    this.toDate,
  });

  factory DocumentFilterModel.empty() {
    return DocumentFilterModel();
  }

  bool get hasActiveFilter {
    return status != null ||
        documentType != null ||
        fromDate != null ||
        toDate != null;
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'documentType': documentType,
      'fromDate': fromDate?.toIso8601String(),
      'toDate': toDate?.toIso8601String(),
    };
  }
}
