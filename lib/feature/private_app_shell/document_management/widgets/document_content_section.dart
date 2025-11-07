import 'package:flutter/material.dart';
import 'package:tcs_e_office/core/configs/theme/app_colors.dart';
import 'package:tcs_e_office/common/widgets/enhanced_text_widget.dart';

class DocumentContentSection extends StatelessWidget {
  final String content;

  const DocumentContentSection({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (content.isNotEmpty) ...[
          Row(
            children: [
              Icon(
                Icons.description_outlined,
                size: 14, // Giảm icon size từ 20 xuống 18
                color: AppColors.primary,
              ),
              const SizedBox(width: 6), // Giảm spacing từ 8 xuống 6
              Text(
                'Nội dung văn bản',
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14, // Giảm font size
                ),
              ),
            ],
          ),
          const SizedBox(height: 8), // Giảm spacing
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10), // Giảm padding từ 16 xuống 10
            decoration: BoxDecoration(
              color: AppColors.bacgroundApp,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.grey),
            ),
            child: Text(
              content,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.black,
                height: 1.4, // Giảm line height từ 1.5 xuống 1.4
                fontSize: 13, // Giảm font size
              ),
            ),
          ),
        ] else ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20), // Giảm padding từ 32 xuống 20
            decoration: BoxDecoration(
              color: AppColors.bacgroundApp,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.grey),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.description_outlined,
                  size: 40, // Giảm icon size từ 48 xuống 40
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 8), // Giảm spacing
                Text(
                  'Không có nội dung',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 13, // Giảm font size
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
