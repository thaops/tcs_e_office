import 'package:flutter/material.dart';
import 'package:tcs_e_office/common/widgets/text_widget.dart';
import 'package:tcs_e_office/core/configs/theme/app_colors.dart';
import '../models/document_detail_model.dart';
import 'document_container.dart';
import 'package:tcs_e_office/common/constants/app_tab_types.dart';

class DocumentHeaderCard extends StatelessWidget {
  final DocumentDetailModel detail;
  final String? tabType;

  const DocumentHeaderCard({super.key, required this.detail, this.tabType});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12), // Đồng bộ với TaskHeaderCard
      child: DocumentContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6), // Đồng bộ với TaskHeaderCard

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        detail.title,
                        maxLines: 2,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF006884),
                          overflow: TextOverflow.ellipsis,
                          height: 1.3,
                        ),
                      ),
                      if (detail.documentNo.isNotEmpty)
                        Text(
                          detail.documentNo,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                    ],
                  ),
                ),
                if (tabType != AppTabTypes.DOCUMENT_IN) _buildStatusChip(),
              ],
            ),

            const SizedBox(height: 12), // Đồng bộ với TaskHeaderCard
            Divider(color: AppColors.colorBacklog, height: 1),
            const SizedBox(height: 6), // Đồng bộ với TaskHeaderCard
            // Info section với background nhạt
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                const SizedBox(height: 8),
                if (detail.issueDate.isNotEmpty)
                  _buildIconTextInfoRow(
                    Icons.calendar_month_sharp,
                    'Ngày văn bản',
                    _formatDate(detail.issueDate),
                  ),
                if (detail.receiveDate.isNotEmpty)
                  _buildIconTextInfoRow(
                    Icons.calendar_month_sharp,
                    'Ngày tiếp nhận công văn',
                    _formatDate(detail.receiveDate),
                  ),
                if (detail.distributor.isNotEmpty && tabType != AppTabTypes.DOCUMENT_IN)
                  _buildIconTextInfoRow(
                    Icons.person_outline,
                    'Người phân phối',
                    detail.distributor,
                  ),
                if (detail.issueUnit != null && detail.issueUnit!.isNotEmpty)
                  _buildIconTextInfoRow(
                    Icons.business_outlined,
                    'Đơn vị ban hành',
                    detail.issueUnit!,
                  ),

                _iconText(Icons.note_outlined, 'Nội dung TRIỂN KHAI THỰC HIỆN'),
                _buildInfoRow(detail.note),
              ],
            ),

            const SizedBox(height: 12), // Đồng bộ với TaskHeaderCard
          ],
        ),
      ),
    );
  }

  _buildIconTextInfoRow(IconData icon, String text, String note) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _iconText(icon, text),
        Expanded(
          child: TextWidget(
            text: note,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
  }

  _buildInfoRow(String note) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 24, height: 24),
        Expanded(
          child: TextWidget(
            text: note,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
  }

  Widget _iconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: const Color(0xFF006884),
        ), // Đồng bộ với TaskHeaderCard
        const SizedBox(width: 8), // Đồng bộ với TaskHeaderCard
        Text(
          '${text}: ',
          style: const TextStyle(
            fontSize: 14, // Đồng bộ với TaskHeaderCard
            color: Color(0xFF333333),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip() {
    final chipColor = _getStatusColor(detail.status);
    final statusText = _getStatusText(detail.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withOpacity(0.3)),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 11,
          color: chipColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Lấy text status bằng tiếng Việt - đồng bộ với DocumentCardWidget
  String _getStatusText(int status) {
    switch (status) {
      case 1:
        return 'Dự thảo';
      case 2:
        return 'Chờ duyệt';
      case 3:
        return 'Đã duyệt';
      case 4:
        return 'Ban hành';
      case 5:
        return 'Từ chối';
      default:
        return 'Không xác định';
    }
  }

  // Lấy màu sắc theo status - đồng bộ với DocumentCardWidget
  Color _getStatusColor(int status) {
    switch (status) {
      case 1: // Draft
        return const Color(0xFF898989); // Gray
      case 2: // Submitted
        return const Color(0xFFE39516); // Orange
      case 3: // Approved
        return const Color(0xFF339B00); // Green
      case 4: // Published
        return const Color(0xFF1B1FB8); // Blue
      case 5: // Rejected
        return const Color(0xFFFF2323); // Red
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (_) {
      return iso;
    }
  }
}
