class DocumentModel {
  final String id;
  final String documentType;
  final String documentNo;
  final String vDocumentNo;
  final String? departmentCode;
  final String? numberingCode;
  final String title;
  final String form;
  final String lastApproveDate;
  final String receiveDate;
  final String issueUnit;
  final String status;
  final bool remark;
  final String source;
  final String airline;
  final String documentCode;
  final int category;
  final String createdDate;
  final num totalAttachment;
  final num totalComment;
  final String relatedUnits;
  final String distributor;

  DocumentModel({
    required this.id,
    required this.documentType,
    required this.documentNo,
    required this.vDocumentNo,
    this.departmentCode,
    this.numberingCode,
    required this.title,
    required this.form,
    required this.lastApproveDate,
    required this.receiveDate,
    required this.issueUnit,
    required this.status,
    required this.remark,
    required this.source,
    required this.airline,
    required this.documentCode,
    required this.category,
    required this.createdDate,
    required this.totalAttachment,
    required this.totalComment,
    required this.relatedUnits,
    required this.distributor,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] ?? '',
      documentType: json['documentType'] ?? '',
      documentNo: json['documentNo'] ?? '',
      vDocumentNo: json['vDocumentNo'] ?? '',
      departmentCode: json['departmentCode'],
      numberingCode: json['numberingCode'],
      title: json['title'] ?? '',
      form: json['form'] ?? '',
      lastApproveDate: json['lastApproveDate'] ?? '',
      receiveDate: json['receiveDate'] ?? '',
      issueUnit: json['issueUnit'] ?? '',
      status: json['status'] ?? '',
      remark: json['remark'] ?? false,
      source: json['source'] ?? '',
      airline: json['airline'] ?? '',
      documentCode: json['documentCode'] ?? '',
      category: json['category'] ?? 0,
      createdDate: json['createdDate'] ?? '',
      totalAttachment: (json['totalAttachment'] as num?) ?? 0,
      totalComment: (json['totalComment'] as num?) ?? 0,
      relatedUnits: json['relatedUnits'] ?? '',
      distributor: json['distributor'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documentType': documentType,
      'documentNo': documentNo,
      'vDocumentNo': vDocumentNo,
      'departmentCode': departmentCode,
      'numberingCode': numberingCode,
      'title': title,
      'form': form,
      'lastApproveDate': lastApproveDate,
      'receiveDate': receiveDate,
      'issueUnit': issueUnit,
      'status': status,
      'remark': remark,
      'source': source,
      'airline': airline,
      'documentCode': documentCode,
      'category': category,
      'createdDate': createdDate,
      'totalAttachment': totalAttachment,
      'totalComment': totalComment,
      'relatedUnits': relatedUnits,
      'distributor': distributor,
    };
  }
}

class DocumentListResponse {
  final int statusCode;
  final String message;
  final int totalRecord;
  final List<DocumentModel> data;

  DocumentListResponse({
    required this.statusCode,
    required this.message,
    required this.totalRecord,
    required this.data,
  });

  factory DocumentListResponse.fromJson(Map<String, dynamic> json) {
    return DocumentListResponse(
      statusCode: json['statusCode'] ?? 0,
      message: json['message'] ?? '',
      totalRecord: json['totalRecord'] ?? 0,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => DocumentModel.fromJson(item))
              .toList() ??
          [],
    );
  }
}
