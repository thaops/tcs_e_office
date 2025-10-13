import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'section_header.dart';

class ContentSection extends StatelessWidget {
  final String? content;

  const ContentSection({super.key, this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 6,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        SectionHeader(
          title: 'Nội dung công việc',
          icon: Icons.article_outlined,
        ),
        const SizedBox(height: 6), // Giảm spacing
        Container(
          padding: const EdgeInsets.all(10), // Giảm padding
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA), // Background nhạt
            borderRadius: BorderRadius.circular(6), // Border radius nhỏ hơn
            border: Border.all(
              color: const Color(0xFFE8E8E8), // Border nhẹ hơn
              width: 0.5,
            ),
          ),
          child: _buildContent(),
        ),
        const SizedBox(height: 6),
      ],
    );
  }

  Widget _buildContent() {
    if (content == null || content!.isEmpty || content!.trim() == '<p></p>') {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          child: Text(
            'Không có nội dung công việc',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF757575),
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return Html(
      data: content!,
      style: {
        "body": Style(
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
          fontSize: FontSize(14),
          lineHeight: const LineHeight(1.5),
          color: const Color(0xFF333333),
        ),
        "p": Style(margin: Margins.only(bottom: 8), padding: HtmlPaddings.zero),
        "h1, h2, h3, h4, h5, h6": Style(
          margin: Margins.only(top: 12, bottom: 8),
          padding: HtmlPaddings.zero,
          fontWeight: FontWeight.bold,
        ),
        "ul, ol": Style(
          margin: Margins.only(bottom: 8),
          padding: HtmlPaddings.only(left: 20),
        ),
        "li": Style(margin: Margins.only(bottom: 4)),
        "strong, b": Style(fontWeight: FontWeight.bold),
        "em, i": Style(fontStyle: FontStyle.italic),
      },
    );
  }
}
