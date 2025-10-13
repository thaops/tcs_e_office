class FilterModel {
  final int? status; // Trạng thái công việc
  final int? priority; // Mức độ ưu tiên
  final int? role; // Vai trò
  final String?
  dueDate; // Ngày kết thúc (format: yyyy-MM-ddTHH:mm:ss.000+07:00)

  FilterModel({this.status, this.priority, this.role, this.dueDate});

  // Tạo filter rỗng
  factory FilterModel.empty() {
    return FilterModel();
  }

  // Copy với các thay đổi
  FilterModel copyWith({
    int? status,
    int? priority,
    int? role,
    String? startDate,
    String? dueDate,
  }) {
    return FilterModel(
      status: status, // Fix: Không dùng ?? để có thể set null
      priority: priority, // Fix: Không dùng ?? để có thể set null
      role: role, // Fix: Không dùng ?? để có thể set null
      dueDate: dueDate, // Fix: Không dùng ?? để có thể set null
    );
  }

  // Tạo từ FilterModel khác
  factory FilterModel.fromFilterModel(FilterModel other) {
    return FilterModel(
      status: other.status,
      priority: other.priority,
      role: other.role,
      // startDate: other.startDate,
      dueDate: other.dueDate,
    );
  }

  // Kiểm tra có filter nào được áp dụng không
  bool get hasActiveFilter {
    return status != null ||
        priority != null ||
        role != null ||
        dueDate != null;
  }

  // Kiểm tra filter có thay đổi không
  bool isDifferentFrom(FilterModel other) {
    return status != other.status ||
        priority != other.priority ||
        role != other.role ||
        dueDate != other.dueDate;
  }

  // Lấy tên trạng thái
  String getStatusName() {
    switch (status) {
      case 1:
        return 'Đang thực hiện';
      case 2:
        return 'Đã hoàn thành';
      case 3:
        return 'Quá hạn';
      default:
        return 'Tất cả';
    }
  }

  // Lấy tên mức độ ưu tiên
  String getPriorityName() {
    switch (priority) {
      case 0:
        return 'Khẩn cấp';
      case 1:
        return 'Cao';
      case 2:
        return 'Trung bình';
      case 3:
        return 'Bình thường';
      case 4:
        return 'Thấp';
      default:
        return 'Tất cả';
    }
  }

  // Lấy tên vai trò
  String getRoleName() {
    switch (role) {
      case 1:
        return 'Xử lý chính';
      case 2:
        return 'Phối hợp';
      case 3:
        return 'Theo dõi';
      default:
        return 'Tất cả';
    }
  }

  // Lấy mô tả filter hiện tại
  String getFilterDescription() {
    List<String> parts = [];

    if (status != null) {
      parts.add('Trạng thái: ${getStatusName()}');
    }

    if (priority != null) {
      parts.add('Ưu tiên: ${getPriorityName()}');
    }

    if (role != null) {
      parts.add('Vai trò: ${getRoleName()}');
    }

    if (parts.isEmpty) {
      return 'Không có bộ lọc';
    }

    return parts.join(', ');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FilterModel &&
        other.status == status &&
        other.priority == priority &&
        other.role == role;
  }

  @override
  int get hashCode {
    return status.hashCode ^ priority.hashCode ^ role.hashCode;
  }

  @override
  String toString() {
    return 'FilterModel(status: $status, priority: $priority, role: $role)';
  }
}
