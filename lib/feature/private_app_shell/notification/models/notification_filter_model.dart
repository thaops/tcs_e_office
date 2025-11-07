class NotificationFilterModel {
  final String? notificationType; // "DocumentIn", "DocumentOut", "TaskAssign", "TaskReceived"
  final bool? readStatus; // true: Đã đọc, false: Chưa đọc, null: Tất cả

  NotificationFilterModel({
    this.notificationType,
    this.readStatus,
  });

  // Tạo filter rỗng
  factory NotificationFilterModel.empty() {
    return NotificationFilterModel();
  }

  // Copy với các thay đổi
  NotificationFilterModel copyWith({
    String? notificationType,
    bool? readStatus,
  }) {
    return NotificationFilterModel(
      notificationType: notificationType ?? this.notificationType,
      readStatus: readStatus ?? this.readStatus,
    );
  }

  // Tạo từ NotificationFilterModel khác
  factory NotificationFilterModel.fromFilterModel(
    NotificationFilterModel other,
  ) {
    return NotificationFilterModel(
      notificationType: other.notificationType,
      readStatus: other.readStatus,
    );
  }

  // Kiểm tra có filter nào được áp dụng không
  bool get hasActiveFilter {
    return notificationType != null || readStatus != null;
  }

  // Kiểm tra filter có thay đổi không
  bool isDifferentFrom(NotificationFilterModel other) {
    return notificationType != other.notificationType ||
        readStatus != other.readStatus;
  }

  // Lấy tên loại thông báo
  String getNotificationTypeName() {
    switch (notificationType) {
      case 'DocumentIn':
        return 'Văn bản đến';
      case 'DocumentOut':
        return 'Văn bản đi';
      case 'TaskAssign':
        return 'Việc tôi giao';
      case 'TaskReceived':
        return 'Việc giao đến tôi';
      default:
        return 'Tất cả';
    }
  }

  // Lấy tên trạng thái đọc
  String getReadStatusName() {
    if (readStatus == null) return 'Tất cả';
    return readStatus! ? 'Đã đọc' : 'Chưa đọc';
  }

  // Lấy mô tả filter hiện tại
  String getFilterDescription() {
    List<String> parts = [];

    if (notificationType != null) {
      parts.add('Loại: ${getNotificationTypeName()}');
    }

    if (readStatus != null) {
      parts.add('Trạng thái: ${getReadStatusName()}');
    }

    if (parts.isEmpty) {
      return 'Không có bộ lọc';
    }

    return parts.join(', ');
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationType': notificationType,
      'readStatus': readStatus,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationFilterModel &&
        other.notificationType == notificationType &&
        other.readStatus == readStatus;
  }

  @override
  int get hashCode {
    return notificationType.hashCode ^ readStatus.hashCode;
  }

  @override
  String toString() {
    return 'NotificationFilterModel(notificationType: $notificationType, readStatus: $readStatus)';
  }
}

