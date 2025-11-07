import 'package:flutter/material.dart';
import 'package:tcs_e_office/core/configs/theme/app_colors.dart';
import 'package:tcs_e_office/common/widgets/empty_state_widget.dart';
import 'package:tcs_e_office/common/share/cache/my_id.dart';
import '../models/document_detail_model.dart';
import '../services/document_comment_service.dart';
import 'section_header.dart';
import 'document_comment_dialog.dart';

class DocumentCommentsSection extends StatefulWidget {
  final List<CommentModel> comments;
  final String documentId;
  final VoidCallback? onAddComment;

  const DocumentCommentsSection({
    super.key,
    required this.comments,
    required this.documentId,
    this.onAddComment,
  });

  @override
  State<DocumentCommentsSection> createState() =>
      _DocumentCommentsSectionState();
}

class _DocumentCommentsSectionState extends State<DocumentCommentsSection> {
  List<CommentModel> _localComments = [];
  String? _currentUserName;

  @override
  void initState() {
    super.initState();
    _localComments = List.from(widget.comments);
    _loadCurrentUser();
  }

  @override
  void didUpdateWidget(DocumentCommentsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Cập nhật local comments khi comments từ parent thay đổi
    if (widget.comments != oldWidget.comments) {
      // Chỉ update nếu không có temporary comment đang pending
      final hasTemporary = _localComments.any((c) => c.id.isEmpty);
      if (!hasTemporary) {
        setState(() {
          _localComments = List.from(widget.comments);
        });
      }
    }
  }

  Future<void> _loadCurrentUser() async {
    try {
      final myId = await MyId.create();
      final userName = await myId.getMyName();
      if (mounted) {
        setState(() {
          _currentUserName = userName.isNotEmpty ? userName : 'Bạn';
        });
      }
    } catch (e) {
      print('Error loading current user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Ý kiến chỉ đạo (${_localComments.length})',
          icon: Icons.chat_bubble_outline,
          trailing: IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCommentDialog(context),
          ),
        ),
        const SizedBox(height: 6), // Giảm spacing

        _localComments.isEmpty
            ? EmptyStatePresets.listEmpty(
                title: 'Chưa có thông tin trao đổi',
                onTap: () => _showCommentDialog(context),
              )
            : Column(
                children: _localComments.asMap().entries.map((entry) {
                  final index = entry.key;
                  final comment = entry.value;
                  final isLast = index == _localComments.length - 1;

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
    DocumentCommentDialog.show(
      context,
      documentId: widget.documentId,
      onCommentAdded: (commentText) {
        // Dialog đã gọi API rồi, chỉ cần refresh comments list
        // Refresh để lấy comment mới từ server
        if (widget.onAddComment != null) {
          widget.onAddComment!();
        }
      },
    );
  }

  // Method này không còn được sử dụng nữa vì dialog đã gọi API
  // Giữ lại để tương thích nếu có nơi khác gọi
  @Deprecated('Use DocumentCommentDialog instead - it handles API call')
  void _addOptimisticComment(String commentText) {
    if (_currentUserName == null) return;

    // Tạo temporary comment với user hiện tại
    final now = DateTime.now().toIso8601String();
    final temporaryComment = CommentModel(
      id: '', // Empty ID để đánh dấu là temporary
      content: commentText,
      creator: _currentUserName!,
      createdDate: now,
    );

    // Add vào đầu list (mới nhất ở trên)
    setState(() {
      _localComments = [temporaryComment, ..._localComments];
    });

    // Gọi API trong background
    _submitCommentInBackground(commentText);
  }

  // Method này không còn được sử dụng nữa vì dialog đã gọi API
  @Deprecated('Use DocumentCommentDialog instead - it handles API call')
  Future<void> _submitCommentInBackground(String commentText) async {
    try {
      final result = await DocumentCommentService.addComment(
        comment: commentText,
        documentId: widget.documentId,
      );

      if (!mounted) return;

      final success = result['success'] as bool;
      final message = result['message'] as String;

      if (success) {
        // Thành công: Refresh để lấy comment thật từ server (không thông báo)
        if (widget.onAddComment != null) {
          widget.onAddComment!();
        }
        // Remove temporary comment sau khi refresh
        setState(() {
          _localComments = _localComments
              .where((c) => c.id.isNotEmpty)
              .toList();
        });
      } else {
        // Lỗi: Remove temporary comment và hiển thị lỗi
        setState(() {
          _localComments = _localComments
              .where((c) => c.id.isNotEmpty)
              .toList();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: const Color(0xFFFF2323),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      // Lỗi: Remove temporary comment và hiển thị lỗi
      setState(() {
        _localComments = _localComments.where((c) => c.id.isNotEmpty).toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi gửi ý kiến chỉ đạo: $e'),
          backgroundColor: const Color(0xFFFF2323),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
