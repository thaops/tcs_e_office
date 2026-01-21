import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:tcs_e_office/core/configs/theme/app_colors.dart';

class NewsDetailContent extends StatelessWidget {
  final String content;

  const NewsDetailContent({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    if (content.isEmpty) {
      return _buildEmptyContent();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          child: Html(
            data: content,
            shrinkWrap: true,
            style: {
              "body": Style(
                fontSize: FontSize(16.sp),
                lineHeight: const LineHeight(1.8),
                padding: HtmlPaddings.zero,
                margin: Margins.zero,
                color: Colors.grey[900],
                fontFamily: 'Inter', // Hoặc font mặc định hệ thống đẹp hơn
              ),
              "img": Style(
                width: Width(constraints.maxWidth),
                margin: Margins.symmetric(vertical: 16),
                display: Display.block,
              ),
              "p": Style(
                margin: Margins.only(bottom: 16),
                textAlign: TextAlign.justify,
              ),
              "h1": Style(
                fontSize: FontSize(22.sp),
                fontWeight: FontWeight.bold,
                margin: Margins.only(bottom: 16, top: 24),
                lineHeight: const LineHeight(1.3),
              ),
              "h2": Style(
                fontSize: FontSize(20.sp),
                fontWeight: FontWeight.bold,
                margin: Margins.only(bottom: 14, top: 20),
                lineHeight: const LineHeight(1.3),
              ),
              "h3": Style(
                fontSize: FontSize(18.sp),
                fontWeight: FontWeight.w600,
                margin: Margins.only(bottom: 12, top: 16),
              ),
              "figcaption": Style(
                fontSize: FontSize(13.sp),
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
                textAlign: TextAlign.center,
                margin: Margins.only(top: 8, bottom: 16),
              ),
              "figure": Style(margin: Margins.zero),
              "blockquote": Style(
                padding: HtmlPaddings.symmetric(horizontal: 16, vertical: 8),
                border: Border(
                  left: BorderSide(color: AppColors.primary, width: 3),
                ),
                backgroundColor: Colors.grey[50],
                fontStyle: FontStyle.italic,
                margin: Margins.symmetric(vertical: 16),
              ),
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyContent() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.grey[500], size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Nội dung đang được cập nhật...',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
