/// Model cho Notification Detail Response từ API
class NotificationDetailModel {
  final String id;
  final String source; // AppTabTypes.DOCUMENT_IN, DOCUMENT_OUT, TASK_ASSIGN, TASK_RECEIVED, "DayOff"
  final String sourceId;
  final String title;
  final String content;
  final bool isRead;
  final bool isPinned;
  final bool isSaved;
  final DateTime createdDate;

  NotificationDetailModel({
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
  factory NotificationDetailModel.fromJson(Map<String, dynamic> json) {
    return NotificationDetailModel(
      id: json['id'] ?? '',
      source: json['source'] ?? '',
      sourceId: json['sourceId'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      isRead: json['isRead'] ?? false,
      isPinned: json['isPinned'] ?? false,
      isSaved: json['isSaved'] ?? false,
      createdDate: DateTime.parse(
        json['createdDate'] ?? DateTime.now().toIso8601String(),
      ),
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
}


