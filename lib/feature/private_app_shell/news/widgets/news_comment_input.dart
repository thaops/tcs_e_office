import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tcs_e_office/core/configs/theme/app_colors.dart';

class NewsCommentInput extends StatefulWidget {
  final String? replyToName;
  final bool isLoading;
  final VoidCallback? onCancelReply;
  final Function(String content) onSubmit;

  const NewsCommentInput({
    super.key,
    this.replyToName,
    this.isLoading = false,
    this.onCancelReply,
    required this.onSubmit,
  });

  @override
  State<NewsCommentInput> createState() => _NewsCommentInputState();
}

class _NewsCommentInputState extends State<NewsCommentInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _submit() {
    final content = _controller.text.trim();
    if (content.isNotEmpty && !widget.isLoading) {
      widget.onSubmit(content);
      _controller.clear();
      _focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.replyToName != null) _buildReplyIndicator(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: _buildTextField()),
                SizedBox(width: 8.w),
                _buildSendButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyIndicator() {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7), // iOS grouped background style
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 3.w,
            height: 32.h,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đang trả lời ${widget.replyToName}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: widget.onCancelReply,
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, size: 14.sp, color: Colors.grey[400]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField() {
    return Container(
      constraints: BoxConstraints(maxHeight: 100.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F7), // iOS light grey input
        borderRadius: BorderRadius.circular(
          20.r,
        ), // Standard rounded corners for input
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 0.5),
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        maxLines: null, // Allow expanding
        minLines: 1,
        textCapitalization: TextCapitalization.sentences,
        style: TextStyle(
          fontSize: 15.sp,
          color: Colors.black,
          height: 1.3,
          fontWeight: FontWeight.w400,
        ),
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          hintText: widget.replyToName != null
              ? 'Trả lời...'
              : 'Thêm bình luận...',
          hintStyle: TextStyle(
            fontSize: 15.sp,
            color: Colors.grey[500],
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 10.h,
          ),
        ),
        onSubmitted: (_) => _submit(),
      ),
    );
  }

  Widget _buildSendButton() {
    final canSend = _hasText && !widget.isLoading;

    return GestureDetector(
      onTap: canSend ? _submit : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36.w,
        height: 36.w,
        margin: EdgeInsets.only(bottom: 2.h), // Align with input text
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: canSend ? AppColors.primary : Colors.grey[300],
        ),
        child: Center(
          child: widget.isLoading
              ? SizedBox(
                  width: 16.w,
                  height: 16.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Icon(
                  Icons.arrow_upward_rounded,
                  size: 20.sp,
                  color: Colors.white,
                ),
        ),
      ),
    );
  }
}
