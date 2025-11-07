import 'package:flutter/material.dart';

class DocumentRejectDialog extends StatefulWidget {
  final Function(String note) onConfirm;

  const DocumentRejectDialog({super.key, required this.onConfirm});

  static void show(
    BuildContext context, {
    required Function(String note) onConfirm,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => DocumentRejectDialog(onConfirm: onConfirm),
    );
  }

  @override
  State<DocumentRejectDialog> createState() => _DocumentRejectDialogState();
}

class _DocumentRejectDialogState extends State<DocumentRejectDialog> {
  final TextEditingController _noteController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? _errorMessage;

  @override
  void dispose() {
    _noteController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _confirm() {
    final note = _noteController.text.trim();

    // Validation: kiểm tra nếu chưa nhập lý do
    if (note.isEmpty) {
      setState(() {
        _errorMessage = 'Vui lòng nhập lý do';
      });
      return;
    }

    // Xóa lỗi nếu có
    setState(() {
      _errorMessage = null;
    });

    Navigator.of(context).pop();
    widget.onConfirm(note);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 360, // ~340-380px
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header với title (center) và nút đóng
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 16),
                const Text(
                  'Từ chối',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0094AA),
                  ),
                ),
                // Nút đóng ở góc trên phải
                IconButton(
                  icon: const Icon(Icons.close, size: 24),
                  color: const Color(0xFF757575),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16), // Spacing tiêu đề ↔ TextField
            // TextField nhập lý do
            TextFormField(
              controller: _noteController,
              focusNode: _focusNode,
              maxLines: 4,
              onChanged: (value) {
                // Xóa lỗi khi user bắt đầu nhập
                if (_errorMessage != null) {
                  setState(() {
                    _errorMessage = null;
                  });
                }
              },
              decoration: InputDecoration(
                hintText: 'Nhập lý do từ chối…',
                hintStyle: const TextStyle(
                  color: Color(0xFFBDBDBD),
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _errorMessage != null
                        ? const Color(0xFFFF4D4F)
                        : const Color(0xFFE0E0E0),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _errorMessage != null
                        ? const Color(0xFFFF4D4F)
                        : const Color(0xFF0094AA),
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFFFF4D4F),
                    width: 1,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFFFF4D4F),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.all(12),
                errorText: _errorMessage,
                errorStyle: const TextStyle(
                  color: Color(0xFFFF4D4F),
                  fontSize: 12,
                ),
              ),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20), // Spacing TextField ↔ Button
            // Nút Xác nhận
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFE5E5),
                  foregroundColor: const Color(0xFFFF4D4F),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  side: const BorderSide(color: Color(0xFFFF4D4F), width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Xác nhận',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
