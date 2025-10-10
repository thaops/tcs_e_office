import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'section_header.dart';

class ContentSection extends StatelessWidget {
  final String? content;

  const ContentSection({super.key, this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Nội dung công việc',
          icon: Icons.article_outlined,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: _buildContent(),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (content == null || content!.isEmpty || content!.trim() == '<p></p>') {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          'Không có nội dung công việc',
          style: TextStyle(
            color: Color(0xFF757575),
            fontSize: 14,
            fontStyle: FontStyle.italic,
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
