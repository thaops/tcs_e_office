import 'package:flutter/material.dart';
import 'package:tcs_e_office/core/configs/theme/app_colors.dart';
import 'package:tcs_e_office/common/widgets/enhanced_text_widget.dart';
import '../model/document_model.dart';

class DocumentCardStyles {
  static TextStyle get documentTitle =>
      AppTextStyles.bodyLarge.copyWith(color: AppColors.primary, height: 1.3);

  static TextStyle get documentDescription => AppTextStyles.bodyMedium.copyWith(
    color: AppColors.colorBacklog,
    height: 1.4,
  );

  static TextStyle get infoLabel => AppTextStyles.labelMedium.copyWith(
    color: AppColors.colorBacklog,
    fontWeight: FontWeight.w400,
  );

  static TextStyle get infoValue => AppTextStyles.labelMedium.copyWith(
    color: AppColors.colorBacklog,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get footerText =>
      AppTextStyles.caption.copyWith(color: AppColors.colorBacklog);
}

class AppDecorations {
  static final cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: AppColors.bacgroundApp, width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static final innerDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(8),
    border: Border(left: BorderSide(color: AppColors.primary, width: 3)),
  );
}

class DocumentCardWidget extends StatelessWidget {
  final DocumentModel document;
  final String tabType;

  const DocumentCardWidget({
    super.key,
    required this.document,
    required this.tabType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppDecorations.cardDecoration,
      child: InkWell(
        onTap: () => _showDetailSnackbar(context),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: AppDecorations.innerDecoration,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDocumentTitle(),
                if (document.title.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildDocumentDescription(),
                ],
                const SizedBox(height: 5),

                Divider(color: AppColors.colorBacklog),
                const SizedBox(height: 5),

                _buildDocumentInfo(),
                const SizedBox(height: 14),
                _buildStatusAndType(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentTitle() {
    return Text(
      document.documentNo,
      style: DocumentCardStyles.documentTitle,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDocumentDescription() {
    return Text(
      document.title,
      style: DocumentCardStyles.documentDescription,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDocumentInfo() {
    return Column(
      children: [
        _buildInfoRow(
          Icons.description_outlined,
          'Loại văn bản: ',
          document.documentType,
        ),
        const SizedBox(height: 4),
        _buildInfoRow(
          Icons.calendar_today_outlined,
          'Ngày nhận: ',
          _formatDate(document.receiveDate),
        ),
        if (document.lastApproveDate.isNotEmpty) ...[
          const SizedBox(height: 4),
          _buildInfoRow(
            Icons.check_circle_outline,
            'Ngày duyệt: ',
            _formatDate(document.lastApproveDate),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.colorBacklog),
        const SizedBox(width: 8),
        Text(label, style: DocumentCardStyles.infoLabel),
        Text(value, style: DocumentCardStyles.infoValue),
      ],
    );
  }

  Widget _buildStatusAndType() {
    return Row(
      children: [
        _buildStatusChip(),
        const SizedBox(width: 8),
        _buildTypeChip(),
        const Spacer(),
        _buildFooter(),
      ],
    );
  }

  Widget _buildStatusChip() {
    final statusColor = _getStatusColor();
    final statusText = _getStatusText();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.4), width: 1),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 11,
          color: statusColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTypeChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 1),
      ),
      child: Text(
        document.documentType,
        style: TextStyle(
          fontSize: 11,
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildFooterIcon(
          Icons.description_outlined,
          '1', // Số lượng văn bản
        ),
        const SizedBox(width: 16),
        _buildFooterIcon(
          Icons.access_time_outlined,
          _formatDate(document.createdDate),
        ),
      ],
    );
  }

  Widget _buildFooterIcon(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(text, style: DocumentCardStyles.footerText),
      ],
    );
  }

  Color _getStatusColor() {
    switch (document.status) {
      case '1': // Chờ duyệt
        return Colors.orange;
      case '2': // Đang xử lý
        return Colors.blue;
      case '3': // Hoàn thành
        return Colors.green;
      case '4': // Từ chối
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText() {
    switch (document.status) {
      case '1':
        return 'Chờ duyệt';
      case '2':
        return 'Đang xử lý';
      case '3':
        return 'Hoàn thành';
      case '4':
        return 'Từ chối';
      default:
        return 'Không xác định';
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  void _showDetailSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chức năng xem chi tiết đang được phát triển'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
