import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/task_detail_model.dart';
import 'image_viewer_dialog.dart';
import 'section_header.dart';

class AttachmentsSection extends StatefulWidget {
  final List<TaskAttachment> attachments;

  const AttachmentsSection({super.key, required this.attachments});

  @override
  State<AttachmentsSection> createState() => _AttachmentsSectionState();
}

class _AttachmentsSectionState extends State<AttachmentsSection> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Tệp đính kèm',
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
        const SizedBox(height: 8),
        if (_isExpanded)
          Column(
            children:
                widget.attachments.map((f) {
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _handleAttachmentTap(f),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFE0E0E0),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            _getFileIcon(f.type),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    f.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatSize(f.size),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF757575),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: Color(0xFF006884),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
      ],
    );
  }

  void _handleAttachmentTap(TaskAttachment attachment) async {
    try {
      // Kiểm tra nếu là ảnh thì hiển thị trong dialog
      if (_isImageFile(attachment.type)) {
        ImageViewerDialog.show(context, attachment.url, attachment.name);
        return;
      }

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

  bool _isImageFile(String fileType) {
    final type = fileType.toLowerCase();
    return type.contains('jpg') ||
        type.contains('jpeg') ||
        type.contains('png') ||
        type.contains('gif') ||
        type.contains('bmp') ||
        type.contains('webp');
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
      return const Icon(Icons.image, color: Color(0xFF006884), size: 24);
    } else if (type.contains('pdf')) {
      return const Icon(Icons.picture_as_pdf, color: Colors.red, size: 24);
    } else if (type.contains('doc') || type.contains('docx')) {
      return const Icon(Icons.description, color: Colors.blue, size: 24);
    } else if (type.contains('xls') || type.contains('xlsx')) {
      return const Icon(Icons.table_chart, color: Colors.green, size: 24);
    } else if (type.contains('ppt') || type.contains('pptx')) {
      return const Icon(Icons.slideshow, color: Colors.orange, size: 24);
    } else if (type.contains('zip') ||
        type.contains('rar') ||
        type.contains('7z')) {
      return const Icon(Icons.archive, color: Color(0xFF006884), size: 24);
    } else {
      return const Icon(
        Icons.insert_drive_file,
        color: Color(0xFF006884),
        size: 24,
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
