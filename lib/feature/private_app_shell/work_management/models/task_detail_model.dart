class TaskAttachment {
  final String id;
  final String name;
  final String url;
  final String type;
  final int size;

  TaskAttachment({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    required this.size,
  });

  factory TaskAttachment.fromJson(Map<String, dynamic> json) => TaskAttachment(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    url: json['url'] ?? '',
    type: json['type'] ?? '',
    size: json['size'] ?? 0,
  );
}

class TaskComment {
  final String id;
  final String content;
  final String createdDate;
  final String creator;

  TaskComment({
    required this.id,
    required this.content,
    required this.createdDate,
    required this.creator,
  });

  factory TaskComment.fromJson(Map<String, dynamic> json) => TaskComment(
    id: json['id'] ?? '',
    content: json['content'] ?? '',
    createdDate: json['createdDate'] ?? '',
    creator: json['creator'] ?? '',
  );
}

class TaskAssignee {
  final String id;
  final String code;
  final String name;
  final int roleId;
  final String roleName;
  final String? completedDate;
  final String? assignerId;
  final int statusCode;
  final String status;
  final String dueDate;
  final List<TaskAssignee> children;

  TaskAssignee({
    required this.id,
    required this.code,
    required this.name,
    required this.roleId,
    required this.roleName,
    this.completedDate,
    this.assignerId,
    required this.statusCode,
    required this.status,
    required this.dueDate,
    required this.children,
  });

  factory TaskAssignee.fromJson(Map<String, dynamic> json) => TaskAssignee(
    id: json['id'] ?? '',
    code: json['code'] ?? '',
    name: json['name'] ?? '',
    roleId: json['roleId'] ?? 0,
    roleName: json['roleName'] ?? '',
    completedDate: json['completedDate'],
    assignerId: json['assignerId'],
    statusCode: json['statusCode'] ?? 1,
    status: json['status'] ?? 'Đang thực hiện',
    dueDate: json['dueDate'] ?? '',
    children:
        (json['children'] as List<dynamic>?)
            ?.map((e) => TaskAssignee.fromJson(e))
            .toList() ??
        [],
  );
}

class TaskHistory {
  final String id;
  final String actionCode;
  final String action;
  final String actor;
  final String actorDepartment;
  final String actionDate;
  final String? note;

  TaskHistory({
    required this.id,
    required this.actionCode,
    required this.action,
    required this.actor,
    required this.actorDepartment,
    required this.actionDate,
    this.note,
  });

  factory TaskHistory.fromJson(Map<String, dynamic> json) => TaskHistory(
    id: json['id'] ?? '',
    actionCode: json['actionCode'] ?? '',
    action: json['action'] ?? '',
    actor: json['actor'] ?? '',
    actorDepartment: json['actorDepartment'] ?? '',
    actionDate: json['actionDate'] ?? '',
    note: json['note'],
  );
}

class TaskGroupTargets {
  final List<String> departmentCodes;
  final List<String> employeeCodes;

  TaskGroupTargets({
    required this.departmentCodes,
    required this.employeeCodes,
  });

  factory TaskGroupTargets.fromJson(Map<String, dynamic>? json) =>
      TaskGroupTargets(
        departmentCodes:
            (json?['departmentCodes'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        employeeCodes:
            (json?['employeeCodes'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      );
}

class TaskDetailModel {
  final String id;
  final String? documentId;
  final String taskName;
  final String assignerCode;
  final String assignerName;
  final String startDate;
  final String dueDate;
  final int priority; // 1: Normal ...
  final String creator;
  final String createdDate;
  final String note;
  final String? content; // HTML
  final int status; // 1: In progress ...
  final bool allowUpdate;
  final List<TaskAttachment> attachments;
  final List<TaskComment> comments;
  final List<TaskAssignee> assignees;
  final List<TaskHistory> histories;
  final TaskGroupTargets primary;
  final TaskGroupTargets collab;
  final TaskGroupTargets follow;

  TaskDetailModel({
    required this.id,
    this.documentId,
    required this.taskName,
    required this.assignerCode,
    required this.assignerName,
    required this.startDate,
    required this.dueDate,
    required this.priority,
    required this.creator,
    required this.createdDate,
    required this.note,
    this.content,
    required this.status,
    required this.allowUpdate,
    required this.attachments,
    required this.comments,
    required this.assignees,
    required this.histories,
    required this.primary,
    required this.collab,
    required this.follow,
  });

  factory TaskDetailModel.fromJson(Map<String, dynamic> json) =>
      TaskDetailModel(
        id: json['id'] ?? '',
        documentId: json['documentId'],
        taskName: json['taskName'] ?? '',
        assignerCode: json['assignerCode'] ?? '',
        assignerName: json['assignerName'] ?? '',
        startDate: json['startDate'] ?? '',
        dueDate: json['dueDate'] ?? '',
        priority: json['priority'] ?? 0,
        creator: json['creator'] ?? '',
        createdDate: json['createdDate'] ?? '',
        note: json['note'] ?? '',
        content: json['content'],
        status: json['status'] ?? 0,
        allowUpdate: json['allowUpdate'] ?? false,
        attachments:
            (json['attachments'] as List<dynamic>?)
                ?.map((e) => TaskAttachment.fromJson(e))
                .toList() ??
            [],
        comments:
            (json['comments'] as List<dynamic>?)
                ?.map((e) => TaskComment.fromJson(e))
                .toList() ??
            [],
        assignees:
            (json['assignees'] as List<dynamic>?)
                ?.map((e) => TaskAssignee.fromJson(e))
                .toList() ??
            [],
        histories:
            (json['histories'] as List<dynamic>?)
                ?.map((e) => TaskHistory.fromJson(e))
                .toList() ??
            [],
        primary: TaskGroupTargets.fromJson(json['primary']),
        collab: TaskGroupTargets.fromJson(json['collab']),
        follow: TaskGroupTargets.fromJson(json['follow']),
      );
}

class TaskDetailResponse {
  final int statusCode;
  final String message;
  final int totalRecord;
  final TaskDetailModel data;

  TaskDetailResponse({
    required this.statusCode,
    required this.message,
    required this.totalRecord,
    required this.data,
  });

  factory TaskDetailResponse.fromJson(Map<String, dynamic> json) =>
      TaskDetailResponse(
        statusCode: json['statusCode'] ?? 0,
        message: json['message'] ?? '',
        totalRecord: json['totalRecord'] ?? 0,
        data: TaskDetailModel.fromJson(json['data'] ?? {}),
      );
}

// Create Task payload models
class CreateTaskGroupPayload {
  final List<String> departmentCodes;
  final List<String> employeeCodes;

  CreateTaskGroupPayload({
    required this.departmentCodes,
    required this.employeeCodes,
  });

  Map<String, dynamic> toJson() => {
    'DepartmentCodes': departmentCodes,
    'EmployeeCodes': employeeCodes,
  };
}

class CreateTaskRequestPayload {
  final String? documentId;
  final String assignerCode;
  final String taskName;
  final DateTime startDate;
  final DateTime? dueDate;
  final int priority;
  final String note;
  final String content; // HTML
  final CreateTaskGroupPayload primary;
  final CreateTaskGroupPayload? collab;
  final CreateTaskGroupPayload? follow;

  CreateTaskRequestPayload({
    this.documentId,
    required this.assignerCode,
    required this.taskName,
    required this.startDate,
    this.dueDate,
    required this.priority,
    required this.note,
    required this.content,
    required this.primary,
    this.collab,
    this.follow,
  });

  Map<String, dynamic> toJson() {
    return {
      if (documentId != null) 'DocumentId': documentId,
      'AssignerCode': assignerCode,
      'TaskName': taskName,
      'StartDate': startDate.toUtc().toIso8601String(),
      if (dueDate != null) 'DueDate': dueDate!.toUtc().toIso8601String(),
      'Priority': priority,
      'Note': note,
      'Content': content,
      'Primary': primary.toJson(),
      if (collab != null) 'Collab': collab!.toJson(),
      if (follow != null) 'Follow': follow!.toJson(),
    };
  }
}

class PriorityOption {
  final int value;
  final String label;
  PriorityOption({required this.value, required this.label});
  factory PriorityOption.fromJson(Map<String, dynamic> json) =>
      PriorityOption(value: json['value'] ?? 0, label: json['label'] ?? '');
}

class EmployeeSimple {
  final String employeeCode;
  final String employeeName;
  final String departmentCode;
  final String departmentName;
  EmployeeSimple({
    required this.employeeCode,
    required this.employeeName,
    required this.departmentCode,
    required this.departmentName,
  });
  factory EmployeeSimple.fromJson(Map<String, dynamic> j) => EmployeeSimple(
    employeeCode: j['employeeCode'] ?? '',
    employeeName: j['employeeName'] ?? '',
    departmentCode: j['departmentCode'] ?? '',
    departmentName: j['departmentName'] ?? '',
  );
}

// Tree DTO cho bottom sheet chọn người
class DepartmentNode {
  final String id;
  final String name;
  final String code;
  final List<EmployeeSimple>
  employees; // flattened from children when leaf-type employees appear
  final List<DepartmentNode> children;

  DepartmentNode({
    required this.id,
    required this.name,
    required this.code,
    required this.employees,
    required this.children,
  });

  factory DepartmentNode.fromJson(Map<String, dynamic> json) {
    final rawChildren = (json['children'] as List<dynamic>? ?? []);
    // API có thể trả về:
    // - node phòng ban: { id, name, code, children: [...] }
    // - node nhân viên (leaf): { id, name, code, children: null }
    // Hoặc dạng nhân viên có key employeeCode/employeeName.
    final employees = <EmployeeSimple>[];
    final nodes = <DepartmentNode>[];

    for (final item in rawChildren) {
      if (item is! Map<String, dynamic>) continue;

      // Trường hợp JSON đã là employee chuẩn
      if (item.containsKey('employeeCode')) {
        employees.add(EmployeeSimple.fromJson(item));
        continue;
      }

      // Trường hợp leaf theo mẫu: chỉ có id, name, code và children == null
      final hasIdNameCode =
          item.containsKey('name') && item.containsKey('code');
      final isLeaf = !item.containsKey('children') || item['children'] == null;
      if (hasIdNameCode && isLeaf) {
        // Map sang EmployeeSimple, lấy thông tin phòng ban từ node hiện tại
        employees.add(
          EmployeeSimple(
            employeeCode: (item['code'] ?? '').toString(),
            employeeName: (item['name'] ?? '').toString(),
            departmentCode: (json['code'] ?? '').toString(),
            departmentName: (json['name'] ?? '').toString(),
          ),
        );
        continue;
      }

      // Còn lại coi như node phòng ban con
      nodes.add(DepartmentNode.fromJson(item));
    }

    return DepartmentNode(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      employees: employees,
      children: nodes,
    );
  }
}

/// Model cho forward task request
class ForwardTaskRequest {
  final String id;
  final String dueDate;
  final AssigneeGroup primary;
  final AssigneeGroup collab;
  final AssigneeGroup follow;

  ForwardTaskRequest({
    required this.id,
    required this.dueDate,
    required this.primary,
    required this.collab,
    required this.follow,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dueDate': dueDate,
      'primary': primary.toJson(),
      'collab': collab.toJson(),
      'follow': follow.toJson(),
    };
  }
}

/// Model cho assignee group trong forward task
class AssigneeGroup {
  final List<String> departmentCodes;
  final List<String> employeeCodes;

  AssigneeGroup({required this.departmentCodes, required this.employeeCodes});

  Map<String, dynamic> toJson() {
    return {'departmentCodes': departmentCodes, 'employeeCodes': employeeCodes};
  }
}
