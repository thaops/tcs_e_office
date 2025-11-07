/// Model cho Notification Response từ API
class NotificationListModel {
  final int totalRecord;
  final List<NotificationItem> data;

  NotificationListModel({
    required this.totalRecord,
    required this.data,
  });

  /// Parse từ JSON response
  factory NotificationListModel.fromJson(Map<String, dynamic> json) {
    return NotificationListModel(
      totalRecord: json['totalRecord'] ?? 0,
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => NotificationItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'totalRecord': totalRecord,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

/// Model cho Notification Item
class NotificationItem {
  final String id;
  final String source; // "Document" hoặc "Task"
  final String sourceId;
  final String title;
  final String content;
  final bool isRead;
  final bool isPinned;
  final bool isSaved;
  final DateTime createdDate;

  NotificationItem({
    required this.id,
    required this.source,
    required this.sourceId,
    required this.title,
    required this.content,
    required this.isRead,
    required this.isPinned,
    required this.isSaved,
    required this.createdDate,
  });

  /// Parse từ JSON response
  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] ?? '',
      source: json['source'] ?? '',
      sourceId: json['sourceId'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      isRead: json['isRead'] ?? false,
      isPinned: json['isPinned'] ?? false,
      isSaved: json['isSaved'] ?? false,
      createdDate: DateTime.parse(json['createdDate'] ?? DateTime.now().toIso8601String()),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'source': source,
      'sourceId': sourceId,
      'title': title,
      'content': content,
      'isRead': isRead,
      'isPinned': isPinned,
      'isSaved': isSaved,
      'createdDate': createdDate.toIso8601String(),
    };
  }

  /// Tạo copy với isRead được cập nhật
  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      source: source,
      sourceId: sourceId,
      title: title,
      content: content,
      isRead: isRead ?? this.isRead,
      isPinned: isPinned,
      isSaved: isSaved,
      createdDate: createdDate,
    );
  }
}

