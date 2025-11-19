class DocumentDetailModel {
  final String id;
  final String title;
  final String documentTypeCode;
  final String documentType;
  final String issueDate;
  final String documentNo;
  final String? vDocumentNo;
  final String departmentCode;
  final String department;
  final String numberingCode;
  final String? issueUnit;
  final String? formCode;
  final String? form;
  final String signerCode;
  final String signer;
  final String receiveDate;
  final String? receiverCode;
  final String receiver;
  final String distributorCode;
  final String distributor;
  final String custodianCode;
  final String custodian;
  final String? storeAtRecord;
  final String? storeAtFolder;
  final int retentionYears;
  final String approveDate;
  final bool isReply;
  final bool isUrgent;
  final bool isSubmitForSign;
  final String note;
  final int status;
  final String createdDate;
  final String creator;
  final bool isInternal;
  final bool isMyFlow;
  final bool? isRead;
  final String source;
  final String? airline;
  final String? documentCode;
  final int category;
  final String categoryName;
  final List<WorkflowModel> workflows;
  final List<AttachmentModel> attachments;
  final List<CommentModel> comments;
  final List<DistributorModel> distributors;
  final List<DeploymentDetailModel> deploymentDetails;
  final List<HistoryModel> histories;

  DocumentDetailModel({
    required this.id,
    required this.title,
    required this.documentTypeCode,
    required this.documentType,
    required this.issueDate,
    required this.documentNo,
    this.vDocumentNo,
    required this.departmentCode,
    required this.department,
    required this.numberingCode,
    this.issueUnit,
    this.formCode,
    this.form,
    required this.signerCode,
    required this.signer,
    required this.receiveDate,
    this.receiverCode,
    required this.receiver,
    required this.distributorCode,
    required this.distributor,
    required this.custodianCode,
    required this.custodian,
    this.storeAtRecord,
    this.storeAtFolder,
    required this.retentionYears,
    required this.approveDate,
    required this.isReply,
    required this.isUrgent,
    required this.isSubmitForSign,
    required this.note,
    required this.status,
    required this.createdDate,
    required this.creator,
    required this.isInternal,
    required this.isMyFlow,
    this.isRead,
    required this.source,
    this.airline,
    this.documentCode,
    required this.category,
    required this.categoryName,
    required this.workflows,
    required this.attachments,
    required this.comments,
    required this.distributors,
    required this.deploymentDetails,
    required this.histories,
  });

  factory DocumentDetailModel.fromJson(Map<String, dynamic> json) {
    return DocumentDetailModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      documentTypeCode: json['documentTypeCode'] ?? '',
      documentType: json['documentType'] ?? '',
      issueDate: json['issueDate'] ?? '',
      documentNo: json['documentNo'] ?? '',
      vDocumentNo: json['vDocumentNo'],
      departmentCode: json['departmentCode'] ?? '',
      department: json['department'] ?? '',
      numberingCode: json['numberingCode'] ?? '',
      issueUnit: json['issueUnit'] ?? '',
      formCode: json['formCode'] ?? '',
      form: json['form'] ?? '',
      signerCode: json['signerCode'] ?? '',
      signer: json['signer'] ?? '',
      receiveDate: json['receiveDate'] ?? '',
      receiverCode: json['receiverCode'],
      receiver: json['receiver'] ?? '',
      distributorCode: json['distributorCode'] ?? '',
      distributor: json['distributor'] ?? '',
      custodianCode: json['custodianCode'] ?? '',
      custodian: json['custodian'] ?? '',
      storeAtRecord: json['storeAtRecord'],
      storeAtFolder: json['storeAtFolder'],
      retentionYears: json['retentionYears'] ?? 0,
      approveDate: json['approveDate'] ?? '',
      isReply: json['isReply'] ?? false,
      isUrgent: json['isUrgent'] ?? false,
      isSubmitForSign: json['isSubmitForSign'] ?? false,
      note: json['note'] ?? '',
      status: json['status'] ?? 0,
      createdDate: json['createdDate'] ?? '',
      creator: json['creator'] ?? '',
      isInternal: json['isInternal'] ?? false,
      isMyFlow: json['isMyFlow'] ?? false,
      isRead: json['isRead'],
      source: json['source'] ?? '',
      airline: json['airline'],
      documentCode: json['documentCode'],
      category: json['category'] ?? 0,
      categoryName: json['categoryName'] ?? '',
      workflows:
          (json['workflows'] as List<dynamic>?)
              ?.map((e) => WorkflowModel.fromJson(e))
              .toList() ??
          [],
      attachments:
          (json['attachments'] as List<dynamic>?)
              ?.map((e) => AttachmentModel.fromJson(e))
              .toList() ??
          [],
      comments:
          (json['comments'] as List<dynamic>?)
              ?.map((e) => CommentModel.fromJson(e))
              .toList() ??
          [],
      distributors:
          (json['distributors'] as List<dynamic>?)
              ?.map((e) => DistributorModel.fromJson(e))
              .toList() ??
          [],
      deploymentDetails:
          (json['deploymentDetails'] as List<dynamic>?)
              ?.map((e) => DeploymentDetailModel.fromJson(e))
              .toList() ??
          [],
      histories:
          (json['histories'] as List<dynamic>?)
              ?.map((e) => HistoryModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class WorkflowModel {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String jobTitle;
  final int step;
  final int status;
  final bool isCompleted;
  final String actionDate;
  final String createdDate;
  final String? note;

  WorkflowModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.jobTitle,
    required this.step,
    required this.status,
    required this.isCompleted,
    required this.actionDate,
    required this.createdDate,
    this.note,
  });

  factory WorkflowModel.fromJson(Map<String, dynamic> json) {
    return WorkflowModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      jobTitle: json['jobTitle'] ?? '',
      step: json['step'] ?? 0,
      status: json['status'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
      actionDate: json['actionDate'] ?? '',
      createdDate: json['createdDate'] ?? '',
      note: json['note'],
    );
  }
}

class AttachmentModel {
  final String id;
  final String name;
  final String url;
  final String type;
  final int size;

  AttachmentModel({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    required this.size,
  });

  factory AttachmentModel.fromJson(Map<String, dynamic> json) {
    return AttachmentModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      size: (json['size'] is num) ? (json['size'] as num).toInt() : 0,
    );
  }

  // Helper method để kiểm tra URL hợp lệ
  bool get hasValidUrl {
    if (url.isEmpty) return false;
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }
}

class CommentModel {
  final String id;
  final String content;
  final String creator;
  final String createdDate;

  CommentModel({
    required this.id,
    required this.content,
    required this.creator,
    required this.createdDate,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      creator: json['creator'] ?? '',
      createdDate: json['createdDate'] ?? '',
    );
  }
}

class DistributorModel {
  final String id;
  final String documentId;
  final String employeeCode;
  final String employeeName;
  final String distributorCode;
  final String distributorName;
  final String distributeDate;
  final bool isRead;
  final bool isForward;
  final String note;
  final String? updatedDate;

  DistributorModel({
    required this.id,
    required this.documentId,
    required this.employeeCode,
    required this.employeeName,
    required this.distributorCode,
    required this.distributorName,
    required this.distributeDate,
    required this.isRead,
    required this.isForward,
    required this.note,
    this.updatedDate,
  });

  factory DistributorModel.fromJson(Map<String, dynamic> json) {
    return DistributorModel(
      id: json['id'] ?? '',
      documentId: json['documentId'] ?? '',
      employeeCode: json['employeeCode'] ?? '',
      employeeName: json['employeeName'] ?? '',
      distributorCode: json['distributorCode'] ?? '',
      distributorName: json['distributorName'] ?? '',
      distributeDate: json['distributeDate'] ?? '',
      isRead: json['isRead'] ?? false,
      isForward: json['isForward'] ?? false,
      note: json['note'] ?? '',
      updatedDate: json['updatedDate'],
    );
  }
}

class DeploymentDetailModel {
  final String id;
  final String name;
  final String description;

  DeploymentDetailModel({
    required this.id,
    required this.name,
    required this.description,
  });

  factory DeploymentDetailModel.fromJson(Map<String, dynamic> json) {
    return DeploymentDetailModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

/// Model cho distributors từ API get-document-by-id-4-mobile
/// Chỉ có departmentCode và departmentName
class DistributorDeptModel {
  final String departmentCode;
  final String departmentName;

  DistributorDeptModel({
    required this.departmentCode,
    required this.departmentName,
  });

  factory DistributorDeptModel.fromJson(Map<String, dynamic> json) {
    return DistributorDeptModel(
      departmentCode: json['departmentCode'] ?? '',
      departmentName: json['departmentName'] ?? '',
    );
  }
}

class HistoryModel {
  final String id;
  final String actionCode;
  final String action;
  final String actor;
  final String actorDepartment;
  final String actionDate;
  final String? note;

  HistoryModel({
    required this.id,
    required this.actionCode,
    required this.action,
    required this.actor,
    required this.actorDepartment,
    required this.actionDate,
    this.note,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      id: json['id'] ?? '',
      actionCode: json['actionCode'] ?? '',
      action: json['action'] ?? '',
      actor: json['actor'] ?? '',
      actorDepartment: json['actorDepartment'] ?? '',
      actionDate: json['actionDate'] ?? '',
      note: json['note'],
    );
  }
}
