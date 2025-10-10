import '../models/task_detail_model.dart';

class TaskValidationService {
  /// Kiểm tra nội dung có thực sự có text không (bỏ qua HTML tags và whitespace)
  static bool hasRealContent(String htmlContent) {
    if (htmlContent.isEmpty) return false;

    String textOnly = htmlContent.replaceAll(RegExp(r'<[^>]*>'), '');
    textOnly =
        textOnly
            .replaceAll(RegExp(r'&nbsp;'), ' ')
            .replaceAll(RegExp(r'&amp;'), '&')
            .replaceAll(RegExp(r'&lt;'), '<')
            .replaceAll(RegExp(r'&gt;'), '>')
            .replaceAll(RegExp(r'&quot;'), '"')
            .replaceAll(RegExp(r'&#39;'), "'")
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim();

    return textOnly.isNotEmpty;
  }

  /// Sanitize HTML content để tránh lỗi database
  static String sanitizeHtmlContent(String content) {
    if (content.isEmpty) return content;

    String sanitized =
        content
            .replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'), '')
            .replaceAll(RegExp(r'[\u0000-\u001F\u007F-\u009F]'), '')
            .replaceAll(RegExp(r'[\u200B-\u200D\uFEFF]'), '')
            .replaceAll(RegExp(r'[\u2028\u2029]'), '')
            .replaceAll(RegExp(r'[\u2060-\u2064\u206A-\u206F]'), '')
            .trim();

    if (sanitized.isNotEmpty) {
      if (!sanitized.startsWith('<')) {
        sanitized = '<p>$sanitized</p>';
      }

      sanitized = sanitized
          .replaceAll(RegExp(r'[\x00-\x1F\x7F-\x9F]'), '')
          .replaceAll(RegExp(r'[\uFEFF\u200B-\u200D]'), '')
          .replaceAll(RegExp(r'[\u2028\u2029]'), ' ');
    }

    return sanitized;
  }

  /// Validate form data trước khi submit
  static String? validateFormData({
    required String taskName,
    required String content,
    required List<String> primaryEmployeeCodes,
    required List<EmployeeSimple> allEmployees,
    DateTime? startDate,
    DateTime? dueDate,
  }) {
    if (taskName.trim().isEmpty) {
      return 'Tên việc là bắt buộc';
    }

    final sanitizedContent = sanitizeHtmlContent(content);
    if (!hasRealContent(sanitizedContent)) {
      return 'Nội dung công việc là bắt buộc';
    }

    if (primaryEmployeeCodes.isEmpty) {
      return 'Vui lòng chọn ít nhất một nhân viên xử lý chính';
    }

    final validEmployeeCodes =
        primaryEmployeeCodes.where((code) {
          return allEmployees.any((e) => e.employeeCode == code);
        }).toList();

    if (validEmployeeCodes.isEmpty) {
      return 'Không tìm thấy nhân viên hợp lệ trong danh sách xử lý chính';
    }

    // Validate ngày tháng
    if (startDate != null && dueDate != null) {
      if (dueDate.isBefore(startDate)) {
        return 'Ngày hết hạn không được nhỏ hơn ngày bắt đầu';
      }
    }

    return null;
  }
}
