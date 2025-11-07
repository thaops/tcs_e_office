import 'package:flutter/material.dart';
import 'package:tcs_e_office/core/configs/theme/app_colors.dart';
import 'package:tcs_e_office/common/widgets/enhanced_text_widget.dart';
import '../models/document_detail_model.dart';

class DocumentDistributorsSection extends StatelessWidget {
  final List<DistributorModel> distributors;

  const DocumentDistributorsSection({super.key, required this.distributors});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Danh sách người nhận (${distributors.length})',
          style: AppTextStyles.h4.copyWith(
            color: AppColors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        if (distributors.isEmpty)
          _buildEmptyState()
        else
          _buildDistributorsList(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.bacgroundApp,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey),
      ),
      child: Column(
        children: [
          Icon(Icons.people_outline, size: 48, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(
            'Chưa có người nhận',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistributorsList() {
    return Column(
      children: distributors
          .map((distributor) => _buildDistributorItem(distributor))
          .toList(),
    );
  }

  Widget _buildDistributorItem(DistributorModel distributor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bacgroundApp,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: distributor.isRead
                ? AppColors.success.withOpacity(0.1)
                : AppColors.yellow.withOpacity(0.1),
            child: Icon(
              distributor.isRead ? Icons.check_circle : Icons.pending,
              size: 20,
              color: distributor.isRead ? AppColors.success : AppColors.yellow,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  distributor.employeeName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Mã NV: ${distributor.employeeCode}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(distributor.distributeDate),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildStatusChip(distributor),
        ],
      ),
    );
  }

  Widget _buildStatusChip(DistributorModel distributor) {
    Color chipColor;
    String statusText;
    IconData statusIcon;

    if (distributor.isRead) {
      chipColor = AppColors.success;
      statusText = 'Đã đọc';
      statusIcon = Icons.check_circle;
    } else {
      chipColor = AppColors.yellow;
      statusText = 'Chưa đọc';
      statusIcon = Icons.pending;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 14, color: chipColor),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: AppTextStyles.caption.copyWith(
              color: chipColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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
}
