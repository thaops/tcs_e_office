import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tcs_e_office/core/configs/theme/app_colors.dart';
import 'package:tcs_e_office/common/widgets/enhanced_text_widget.dart';
import '../model/document_model.dart';
import '../views/document_detail_view.dart';
import '../controllers/document_management_controller.dart';

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
        onTap: () => _navigateToDetail(context),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: AppDecorations.innerDecoration,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDocumentTitle(),
                          if (document.vDocumentNo.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            _buildDocumentDescription(),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    _buildTypeChip(),
                  ],
                ),
                Divider(color: AppColors.colorBacklog),
                const SizedBox(height: 5),

                _buildDocumentInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentTitle() {
    return Text(
      document.title,
      style: DocumentCardStyles.documentTitle,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDocumentDescription() {
    return Text(
      document.vDocumentNo,
      style: DocumentCardStyles.documentDescription,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDocumentInfo() {
    return Column(
      spacing: 8,
      children: [
        _buildInfoRow(
          Icons.date_range_outlined,
          tabType != "outgoing"
              ? 'Ngày văn bản: '
              : 'Ngày tiếp nhận công văn: ',
          tabType != "outgoing"
              ? _formatDate(document.createdDate)
              : _formatDate(document.receiveDate),
        ),
        _buildInfoRow(
          Icons.person_outline_rounded,
          'Đơn vị ban hành: ',
          document.issueUnit,
        ),
        _buildInfoRow(
          Icons.person_outline_rounded,
          'Đơn vị liên quan: ',
          document.relatedUnits,
        ),
        if (tabType != "outgoing")
          _buildInfoRow(
            Icons.person_outline_rounded,
            'Người phân phối: ',
            document.distributor,
          ),
        _buildFooter(),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.colorBacklog),
        const SizedBox(width: 8),
        Text(label, style: DocumentCardStyles.infoLabel),
        Expanded(
          child: Text(
            value,
            style: DocumentCardStyles.infoValue,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeChip() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (tabType != 'incoming') ...[
          _buildTypeChipIcon(document.status, isSource: false),
          const SizedBox(width: 8),
        ],
        _buildTypeChipIcon(document.source, isSource: true),
      ],
    );
  }

  Widget _buildTypeChipIcon(String type, {required bool isSource}) {
    String displayText;
    Color chipColor;

    if (isSource) {
      displayText = _getSourceText(type);
      chipColor = _getSourceColor(type);
    } else {
      displayText = _getStatusText(type);
      chipColor = _getStatusColor(type);
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 100),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withOpacity(0.4), width: 1),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: 11,
          color: chipColor,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // Lấy text status bằng tiếng Việt
  String _getStatusText(String status) {
    switch (status) {
      case '1':
        return 'Dự thảo';
      case '2':
        return 'Chờ duyệt';
      case '3':
        return 'Đã duyệt';
      case '4':
        return 'Ban hành';
      case '5':
        return 'Từ chối';
      default:
        return status; // Fallback to original value
    }
  }

  // Lấy màu sắc theo status
  Color _getStatusColor(String status) {
    switch (status) {
      case '1': // Draft
        return const Color(0xFF898989); // Gray
      case '2': // Submitted
        return const Color(0xFFE39516); // Orange
      case '3': // Approved
        return const Color(0xFF339B00); // Green
      case '4': // Published
        return const Color(0xFF1B1FB8); // Blue
      case '5': // Rejected
        return const Color(0xFFFF2323); // Red
      default:
        return AppColors.primary; // Fallback to primary color
    }
  }

  // Lấy text source bằng tiếng Việt
  String _getSourceText(String source) {
    final sourceLower = source.toLowerCase().trim();
    if (sourceLower.contains('bên ngoài') ||
        sourceLower.contains('ben ngoai')) {
      return 'Bên ngoài';
    } else if (sourceLower.contains('nội bộ') ||
        sourceLower.contains('noi bo')) {
      return 'Nội bộ';
    }
    return source; // Fallback to original value
  }

  // Lấy màu sắc theo source
  Color _getSourceColor(String source) {
    final sourceLower = source.toLowerCase().trim();
    if (sourceLower.contains('bên ngoài') ||
        sourceLower.contains('ben ngoai')) {
      return const Color(0xFF007BFF); // Blue for external
    } else if (sourceLower.contains('nội bộ') ||
        sourceLower.contains('noi bo')) {
      return const Color(0xFF28A745); // Green for internal
    }
    return AppColors.primary; // Fallback to primary color
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildFooterIcon(
          Icons.comment_outlined,
          document.totalComment.toString(), // Số lượng văn bản
        ),
        const SizedBox(width: 16),
        _buildFooterIcon(
          Icons.file_present_outlined,
          document.totalAttachment.toString(), // Số lượng văn bản
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

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  void _navigateToDetail(BuildContext context) async {
    final result = await Get.to(
      () => DocumentDetailView(documentId: document.id, tabType: tabType),
    );

    // Nếu có result và cần refresh, gọi refresh data
    if (result != null && result is Map && result['refresh'] == true) {
      // Tìm DocumentManagementController và refresh data
      try {
        final documentController = Get.find<DocumentManagementController>();
        documentController.refresh();
      } catch (e) {
        print('Error refreshing document list: $e');
      }
    }
  }
}
