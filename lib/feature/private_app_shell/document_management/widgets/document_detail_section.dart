import 'package:flutter/material.dart';
import 'package:tcs_e_office/core/configs/theme/app_colors.dart';
import 'document_container.dart';

/// Reusable widget for document detail sections
class DocumentDetailSection extends StatelessWidget {
  final Widget child;
  final bool showDivider;
  final EdgeInsets? padding;

  const DocumentDetailSection({
    super.key,
    required this.child,
    this.showDivider = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12), // Giảm margin từ 16 xuống 12
      child: DocumentContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            child,
            if (showDivider) ...[
              const SizedBox(height: 4),
              Divider(color: AppColors.colorBacklog, height: 1),
            ],
          ],
        ),
      ),
    );
  }
}
