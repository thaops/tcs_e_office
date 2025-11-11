/// Constants cho các loại tab và navigation keys trong ứng dụng
class AppTabTypes {
  AppTabTypes._(); // Private constructor

  // ========== Detail Navigation Keys (Dùng chung cho navigate vào detail) ==========
  
  /// Văn bản đến - Key dùng cho notification và navigate vào detail
  static const String DOCUMENT_IN = "DocumentIn"; // Văn bản đến
  
  /// Văn bản đi - Key dùng cho notification và navigate vào detail
  static const String DOCUMENT_OUT = "DocumentOut"; // Văn bản đi
  
  /// Việc tôi giao - Key dùng cho notification và navigate vào detail
  static const String TASK_ASSIGN = "TaskAssign"; // Việc tôi giao
  
  /// Việc giao đến tôi - Key dùng cho notification và navigate vào detail
  static const String TASK_RECEIVED = "TaskReceived"; // Việc giao đến tôi

  // ========== Document Tab Types (Dùng cho tab index và labels) ==========
  
  static const int documentIncomingTab = 0;
  static const int documentOutgoingTab = 1;
  static const String documentIncomingLabel = 'Văn bản đến';
  static const String documentOutgoingLabel = 'Văn bản đi';

  // ========== Task Tab Types (Dùng cho tab index, type values và labels) ==========
  
  static const int taskAssignedByMeTab = 0;
  static const int taskAssignedToMeTab = 1;
  static const int taskAssignedByMeType = 2;
  static const int taskAssignedToMeType = 1;
  static const String taskAssignedByMeLabel = 'Việc tôi giao';
  static const String taskAssignedToMeLabel = 'Việc giao đến tôi';

  // ========== Helper Methods ==========
  
  /// Lấy label từ detail key
  static String getLabelFromDetailKey(String? detailKey) {
    switch (detailKey) {
      case DOCUMENT_IN:
        return documentIncomingLabel;
      case DOCUMENT_OUT:
        return documentOutgoingLabel;
      case TASK_ASSIGN:
        return taskAssignedByMeLabel;
      case TASK_RECEIVED:
        return taskAssignedToMeLabel;
      default:
        return 'Tất cả';
    }
  }
}

