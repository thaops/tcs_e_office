import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tcs_e_office/common/widgets/empty_state_widget.dart';
import '../models/document_detail_model.dart';
import 'section_header.dart';

class DocumentAttachmentsSection extends StatefulWidget {
  final List<AttachmentModel> attachments;

  const DocumentAttachmentsSection({super.key, required this.attachments});

  @override
  State<DocumentAttachmentsSection> createState() =>
      _DocumentAttachmentsSectionState();
}

class _DocumentAttachmentsSectionState
    extends State<DocumentAttachmentsSection> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Tệp đính kèm (${widget.attachments.length})',
          icon: Icons.attachment,
          trailing: IconButton(
            icon: Icon(
              _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: const Color(0xFF006884),
            ),
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
          ),
        ),
        const SizedBox(height: 6), // Chuẩn hóa spacing
        if (_isExpanded)
          widget.attachments.isEmpty
              ? EmptyStatePresets.listEmpty(title: 'Chưa có tệp đính kèm')
              : Column(
                  children: widget.attachments.map((attachment) {
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _handleAttachmentTap(attachment),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          margin: const EdgeInsets.only(
                            bottom: 6,
                          ), // Giảm margin
                          padding: const EdgeInsets.all(
                            8,
                          ), // Giảm padding từ 10 xuống 8
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAFAFA), // Background nhạt
                            borderRadius: BorderRadius.circular(
                              6,
                            ), // Border radius nhỏ hơn
                            border: Border.all(
                              color: const Color(0xFFE8E8E8), // Border nhẹ hơn
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              _getFileIcon(attachment.type),
                              const SizedBox(width: 8), // Giảm spacing
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      attachment.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize:
                                            12, // Thêm font size cho title
                                        color: Color(0xFF333333),
                                      ),
                                    ),
                                    const SizedBox(height: 3), // Giảm spacing
                                    Text(
                                      _formatSize(attachment.size),
                                      style: const TextStyle(
                                        fontSize: 11, // Giảm font size
                                        color: Color(0xFF757575),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: Color(0xFF006884),
                                size: 18, // Giảm icon size
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
        const SizedBox(height: 12),
      ],
    );
  }

  void _handleAttachmentTap(AttachmentModel attachment) async {
    try {
      // Với các file khác, mở bằng external app
      final Uri url = Uri.parse(attachment.url);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('Không thể mở tệp đính kèm');
      }
    } catch (e) {
      _showErrorSnackBar('Lỗi khi mở tệp: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _getFileIcon(String fileType) {
    final type = fileType.toLowerCase();

    if (type.contains('jpg') ||
        type.contains('jpeg') ||
        type.contains('png') ||
        type.contains('gif')) {
      return const Icon(
        Icons.image,
        color: Color(0xFF006884),
        size: 20,
      ); // Giảm từ 24 xuống 20
    } else if (type.contains('pdf')) {
      return const Icon(
        Icons.picture_as_pdf,
        color: Colors.red,
        size: 20,
      ); // Giảm từ 24 xuống 20
    } else if (type.contains('doc') || type.contains('docx')) {
      return const Icon(
        Icons.description,
        color: Colors.blue,
        size: 20,
      ); // Giảm từ 24 xuống 20
    } else if (type.contains('xls') || type.contains('xlsx')) {
      return const Icon(
        Icons.table_chart,
        color: Colors.green,
        size: 20,
      ); // Giảm từ 24 xuống 20
    } else if (type.contains('ppt') || type.contains('pptx')) {
      return const Icon(
        Icons.slideshow,
        color: Colors.orange,
        size: 20,
      ); // Giảm từ 24 xuống 20
    } else if (type.contains('zip') ||
        type.contains('rar') ||
        type.contains('7z')) {
      return const Icon(
        Icons.archive,
        color: Color(0xFF006884),
        size: 20,
      ); // Giảm từ 24 xuống 20
    } else {
      return const Icon(
        Icons.insert_drive_file,
        color: Color(0xFF006884),
        size: 20, // Giảm từ 24 xuống 20
      );
    }
  }

  String _formatSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const units = ['B', 'KB', 'MB', 'GB'];
    int i = 0;
    double size = bytes.toDouble();
    while (size >= 1024 && i < units.length - 1) {
      size /= 1024;
      i++;
    }
    return '${size.toStringAsFixed(1)} ${units[i]}';
  }
}
