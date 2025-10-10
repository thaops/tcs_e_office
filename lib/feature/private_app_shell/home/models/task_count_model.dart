/// Model cho Task Count Response từ API
class TaskCountModel {
  final TaskCountData assignedToMe;
  final TaskCountData assignedByMe;

  TaskCountModel({required this.assignedToMe, required this.assignedByMe});

  /// Parse từ JSON response
  factory TaskCountModel.fromJson(Map<String, dynamic> json) {
    return TaskCountModel(
      assignedToMe: TaskCountData.fromJson(json['assignedToMe']),
      assignedByMe: TaskCountData.fromJson(json['assignedByMe']),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'assignedToMe': assignedToMe.toJson(),
      'assignedByMe': assignedByMe.toJson(),
    };
  }
}

/// Model cho Task Count Data (assignedToMe/assignedByMe)
class TaskCountData {
  final int doingCount; // Công việc đang xử lý
  final int inDateCount; // Công việc trong ngày
  final int latedCount; // Công việc trễ hạn

  TaskCountData({
    required this.doingCount,
    required this.inDateCount,
    required this.latedCount,
  });

  /// Parse từ JSON response
  factory TaskCountData.fromJson(Map<String, dynamic> json) {
    return TaskCountData(
      doingCount: json['doingCount'] ?? 0,
      inDateCount: json['inDateCount'] ?? 0,
      latedCount: json['latedCount'] ?? 0,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'doingCount': doingCount,
      'inDateCount': inDateCount,
      'latedCount': latedCount,
    };
  }

  /// Tính tổng số task
  int get totalCount => doingCount + inDateCount + latedCount;
}
