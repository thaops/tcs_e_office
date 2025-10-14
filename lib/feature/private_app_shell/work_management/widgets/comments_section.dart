import 'package:flutter/material.dart';
import 'package:tcs_e_office/core/configs/theme/app_colors.dart';
import 'package:tcs_e_office/common/widgets/empty_state_widget.dart';
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
          icon: Icons.chat_bubble_outline,
          trailing: IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCommentDialog(context),
          ),
        ),
        const SizedBox(height: 6), // Giảm spacing

        comments.isEmpty
            ? EmptyStatePresets.listEmpty(
                title: 'Chưa có thông tin trao đổi',
                onTap: () => _showCommentDialog(context),
              )
            : Column(
                children: comments.asMap().entries.map((entry) {
                  final index = entry.key;
                  final comment = entry.value;
                  final isLast = index == comments.length - 1;

                  return Container(
                    margin: EdgeInsets.only(
                      bottom: isLast ? 0 : 6, // Khoảng cách 6px giữa các items
                    ),
                    padding: const EdgeInsets.all(
                      8,
                    ), // Giảm padding từ 10 xuống 8
                    decoration: BoxDecoration(
                      color: Colors.white, // Background trắng cho mỗi comment
                      borderRadius: BorderRadius.circular(6), // Border radius
                      border: Border.all(
                        color: const Color(0xFFE8E8E8),
                        width: 0.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header với tên và thời gian
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              comment.creator,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12, // Giảm font size
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              _formatDateTime(comment.createdDate),
                              style: const TextStyle(
                                fontSize: 11, // Giảm font size
                                color: Color(0xFF666666),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 6,
                        ), // Khoảng cách giữa header và content
                        // Nội dung comment
                        Text(
                          comment.content,
                          style: const TextStyle(
                            fontSize: 12, // Giảm font size
                            color: Color(0xFF333333),
                            height: 1.4, // Line height
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
        const SizedBox(height: 12),
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
