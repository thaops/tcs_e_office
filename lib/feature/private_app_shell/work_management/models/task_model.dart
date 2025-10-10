class TaskModel {
  final String id;
  final String? documentId;
  final String taskName;
  final String assigner;
  final String startDate;
  final String dueDate;
  final String? completedDate;
  final String hostName;
  final int priority;
  final String priorityName;
  final int status;
  final String statusName;
  final int? roleId;
  final String roleName;
  final String note;
  final String creator;
  final String createdDate;
  final num totalAttachment;
  final num totalComment;

  TaskModel({
    required this.id,
    this.documentId,
    required this.taskName,
    required this.assigner,
    required this.startDate,
    required this.dueDate,
    this.completedDate,
    required this.hostName,
    required this.priority,
    required this.priorityName,
    required this.status,
    required this.statusName,
    this.roleId,
    required this.roleName,
    required this.note,
    required this.creator,
    required this.createdDate,
    required this.totalAttachment,
    required this.totalComment,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] ?? '',
      documentId: json['documentId'],
      taskName: json['taskName'] ?? '',
      assigner: json['assigner'] ?? '',
      startDate: json['startDate'] ?? '',
      dueDate: json['dueDate'] ?? '',
      completedDate: json['completedDate'],
      hostName: json['hostName'] ?? '',
      priority: (json['priority'] as int?) ?? 0,
      priorityName: json['priorityName'] ?? '',
      status: (json['status'] as int?) ?? 0,
      statusName: json['statusName'] ?? '',
      roleId: json['roleId'],
      roleName: json['roleName'] ?? '',
      note: json['note'] ?? '',
      creator: json['creator'] ?? '',
      createdDate: json['createdDate'] ?? '',
      totalAttachment: (json['totalAttachment'] as num?) ?? 0,
      totalComment: (json['totalComment'] as num?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documentId': documentId,
      'taskName': taskName,
      'assigner': assigner,
      'startDate': startDate,
      'dueDate': dueDate,
      'completedDate': completedDate,
      'hostName': hostName,
      'priority': priority,
      'priorityName': priorityName,
      'status': status,
      'statusName': statusName,
      'roleId': roleId,
      'roleName': roleName,
      'note': note,
      'creator': creator,
      'createdDate': createdDate,
      'totalAttachment': totalAttachment,
      'totalComment': totalComment,
    };
  }
}

class TaskResponse {
  final int statusCode;
  final String message;
  final int totalRecord;
  final List<TaskModel> data;

  TaskResponse({
    required this.statusCode,
    required this.message,
    required this.totalRecord,
    required this.data,
  });

  factory TaskResponse.fromJson(Map<String, dynamic> json) {
    return TaskResponse(
      statusCode: (json['statusCode'] as int?) ?? 0,
      message: json['message'] ?? '',
      totalRecord: (json['totalRecord'] as int?) ?? 0,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => TaskModel.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class TaskRequest {
  final int pageIndex;
  final int pageSize;
  final int type; // 1: Việc giao đến tôi, 2: Việc tôi giao
  final String? keyword; // Từ khóa tìm kiếm
  final String? startDate; // Ngày bắt đầu (format: yyyy-MM-dd)
  final String?
  dueDate; // Ngày kết thúc (format: yyyy-MM-ddTHH:mm:ss.000+07:00)

  TaskRequest({
    required this.pageIndex,
    required this.pageSize,
    required this.type,
    this.keyword,
    this.startDate,
    this.dueDate,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'pageIndex': pageIndex,
      'pageSize': pageSize,
      'type': type,
    };

    if (keyword != null && keyword!.isNotEmpty) {
      data['keyword'] = keyword;
    }

    if (startDate != null && startDate!.isNotEmpty) {
      data['startDate'] = startDate;
    }

    if (dueDate != null && dueDate!.isNotEmpty) {
      data['dueDate'] = dueDate;
    }

    return data;
  }
}
