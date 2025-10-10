import 'package:flutter/material.dart';
import '../../../../core/configs/theme/app_colors.dart';
import '../services/comment_service.dart';

class CommentDialog extends StatefulWidget {
  final String documentId;
  final String? parentId;
  final String? replyId;
  final Function(String comment) onCommentAdded;

  const CommentDialog({
    super.key,
    required this.documentId,
    this.parentId,
    this.replyId,
    required this.onCommentAdded,
  });

  static void show(
    BuildContext context, {
    required String documentId,
    String? parentId,
    String? replyId,
    required Function(String comment) onCommentAdded,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder:
          (context) => CommentDialog(
            documentId: documentId,
            parentId: parentId,
            replyId: replyId,
            onCommentAdded: onCommentAdded,
          ),
    );
  }

  @override
  State<CommentDialog> createState() => _CommentDialogState();
}

class _CommentDialogState extends State<CommentDialog>
    with TickerProviderStateMixin {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSubmitting = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();

    // Auto focus vào text field khi mở dialog
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final comment = _commentController.text.trim();

    if (comment.isEmpty) {
      _showErrorSnackBar('Vui lòng nhập nội dung trao đổi');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Gọi API comment-document
      final success = await CommentService.addComment(
        comment: comment,
        documentId: widget.documentId,
        parentId: widget.parentId,
        replyId: widget.replyId,
      );

      if (success) {
        // Gọi callback để thông báo comment đã được thêm
        widget.onCommentAdded(comment);

        // Đóng dialog
        Navigator.of(context).pop();
      } else {
        _showErrorSnackBar('Không thể gửi trao đổi');
      }
    } catch (e) {
      _showErrorSnackBar('Lỗi khi gửi trao đổi: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 380,
                  maxHeight: 480,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header iOS style
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.withOpacity(0.2),
                            width: 0.5,
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
                      child: Row(
                        children: [
                          // Icon nhỏ hơn
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.chat_bubble_outline,
                              color: AppColors.primary,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Title nhỏ hơn
                          Expanded(
                            child: Text(
                              'Thông tin trao đổi',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          // Close button nhỏ hơn
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => Navigator.of(context).pop(),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.grey[500],
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content iOS style
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // TextField iOS style
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[25],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    _focusNode.hasFocus
                                        ? AppColors.primary.withOpacity(0.4)
                                        : Colors.grey.withOpacity(0.15),
                                width: 1,
                              ),
                            ),
                            child: TextField(
                              controller: _commentController,
                              focusNode: _focusNode,
                              maxLines: 5,
                              minLines: 3,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.4,
                                letterSpacing: -0.1,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Nhập nội dung trao đổi...',
                                hintStyle: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 15,
                                  letterSpacing: -0.1,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(16),
                              ),
                              textInputAction: TextInputAction.newline,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Action buttons iOS style
                          Row(
                            children: [
                              // Nút Hủy bỏ iOS style
                              Expanded(
                                child: Container(
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.grey.withOpacity(0.2),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap:
                                          _isSubmitting
                                              ? null
                                              : () =>
                                                  Navigator.of(context).pop(),
                                      borderRadius: BorderRadius.circular(10),
                                      child: Center(
                                        child: Text(
                                          'Hủy bỏ',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15,
                                            letterSpacing: -0.1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Nút Gửi iOS style
                              Expanded(
                                child: Container(
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(
                                          0.2,
                                        ),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap:
                                          _isSubmitting ? null : _submitComment,
                                      borderRadius: BorderRadius.circular(10),
                                      child: Center(
                                        child:
                                            _isSubmitting
                                                ? const SizedBox(
                                                  width: 18,
                                                  height: 18,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(Colors.white),
                                                  ),
                                                )
                                                : const Text(
                                                  'Gửi',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 15,
                                                    letterSpacing: -0.1,
                                                  ),
                                                ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
