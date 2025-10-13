import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:html_editor_enhanced/html_editor.dart';

/// Widget HTML editor cho nội dung công việc
class HtmlContentEditor extends StatefulWidget {
  final String? initialContent;
  final String hintText;
  final double? height;
  final TextEditingController?
  contentController; // Thêm controller để cập nhật nội dung
  final VoidCallback? onFocus; // Callback khi editor được focus

  const HtmlContentEditor({
    super.key,
    this.initialContent,
    this.hintText = 'Nhập nội dung công việc',
    this.height,
    this.contentController,
    this.onFocus,
  });

  @override
  State<HtmlContentEditor> createState() => _HtmlContentEditorState();
}

class _HtmlContentEditorState extends State<HtmlContentEditor>
    with AutomaticKeepAliveClientMixin {
  late HtmlEditorController controller;
  bool _hasSetInitialContent = false; // Track xem đã set initial content chưa
  bool _isDisposed = false; // Track dispose state

  @override
  bool get wantKeepAlive => true; // Giữ trạng thái widget khi navigate

  @override
  void initState() {
    super.initState();
    controller = HtmlEditorController();
  }

  @override
  void dispose() {
    // Đánh dấu đã dispose để tránh gọi controller sau khi dispose
    _isDisposed = true;
    // Không gọi controller.clear() vì có thể gây lỗi disposed WebView
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(
      context,
    ); // Quan trọng: phải gọi super.build() cho AutomaticKeepAliveClientMixin

    return RepaintBoundary(
      child: Container(
        height: widget.height ?? 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              // Ngăn scroll notification bubble up để tránh conflict với parent scroll
              return true;
            },
            child: HtmlEditor(
              controller: controller,
              htmlEditorOptions: HtmlEditorOptions(
                hint: widget.hintText,
                shouldEnsureVisible: false, // Tắt auto ensure visible
                initialText: widget.initialContent ?? '',
                adjustHeightForKeyboard:
                    false, // Tắt auto adjust height khi keyboard xuất hiện
                autoAdjustHeight: false,
                spellCheck: false, // Tắt spell check để tăng performance
                darkMode: false, // Tắt dark mode
                mobileLongPressDuration: const Duration(milliseconds: 500),
              ),
              htmlToolbarOptions: HtmlToolbarOptions(
                toolbarPosition: ToolbarPosition.aboveEditor,
                toolbarType: ToolbarType.nativeScrollable,
                defaultToolbarButtons: [
                  const StyleButtons(),
                  const FontSettingButtons(fontSizeUnit: false),
                  const FontButtons(clearAll: false),
                  const ColorButtons(),
                  const ListButtons(listStyles: false),
                  const ParagraphButtons(
                    textDirection: false,
                    lineHeight: false,
                    caseConverter: false,
                  ),
                  const InsertButtons(
                    video: false,
                    audio: false,
                    table: true,
                    hr: true,
                    otherFile: false,
                  ),
                  const OtherButtons(
                    copy: true,
                    paste: true,
                    codeview: false, // Tắt codeview để tránh modal đen
                    fullscreen: false, // Tắt fullscreen để tránh background đen
                  ),
                ],
                renderBorder: true,
                buttonColor: const Color(0xFF006884),
                buttonSelectedColor: const Color(0xFF004A5C),
                buttonFocusColor: const Color(0xFF006884),
                toolbarItemHeight: 40,
              ),
              otherOptions: OtherOptions(
                height: widget.height ?? 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                // Tắt các tùy chọn có thể gây background đen
              ),
              callbacks: Callbacks(
                onChangeContent: (String? content) {
                  // Cập nhật nội dung HTML vào controller nếu có
                  if (content != null && widget.contentController != null) {
                    widget.contentController!.text = content;
                  }
                },
                onFocus: () {
                  // Callback để parent có thể handle focus behavior
                  widget.onFocus?.call();
                },
                onInit: () {
                  // Chỉ set initial content một lần duy nhất khi khởi tạo
                  if (!_hasSetInitialContent &&
                      widget.initialContent != null &&
                      widget.initialContent!.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted || _isDisposed) return;
                      try {
                        controller.setText(widget.initialContent!);
                        _hasSetInitialContent = true;
                      } catch (e) {
                        print(
                          'HtmlContentEditor onInit: Không thể set text: $e',
                        );
                      }
                    });
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
