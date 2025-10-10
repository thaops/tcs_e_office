import 'package:flutter/material.dart';
import 'package:tcs_e_office/core/configs/theme/app_colors.dart';
import '../models/task_detail_model.dart';
import 'comment_dialog.dart';
import 'section_header.dart';

class CommentsSection extends StatelessWidget {
  final List<TaskComment> comments;
  final String documentId;
  final VoidCallback? onAddComment;

  const CommentsSection({
    super.key,
    required this.comments,
    required this.documentId,
    this.onAddComment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Thông tin trao đổi',
          icon: Icons.forum_outlined,
          trailing: IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCommentDialog(context),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Column(
            children:
                comments.map((c) {
                  return Column(
                    children: [
                      ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              c.creator,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              _formatDateTime(c.createdDate),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF666666),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          c.content,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFE0E0E0)),
                    ],
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(String iso) {
    try {
      final d = DateTime.parse(iso);
      final hh = d.hour.toString().padLeft(2, '0');
      final mm = d.minute.toString().padLeft(2, '0');
      return '$hh:$mm - ${_formatDate(iso)} ';
    } catch (_) {
      return iso;
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

  void _showCommentDialog(BuildContext context) {
    CommentDialog.show(
      context,
      documentId: documentId,
      onCommentAdded: (comment) {
        // TODO: Refresh comments list hoặc thêm comment mới vào danh sách
        if (onAddComment != null) {
          onAddComment!();
        }
      },
    );
  }
}
