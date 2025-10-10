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

class _HtmlContentEditorState extends State<HtmlContentEditor> {
  late HtmlEditorController controller;
  bool _hasSetInitialContent = false; // Track xem đã set initial content chưa

  @override
  void initState() {
    super.initState();
    controller = HtmlEditorController();
  }

  @override
  void dispose() {
    // HtmlEditorController không có dispose method
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
              spellCheck: true,
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

                // Khi editor được focus, đảm bảo initial content được set
                if (!_hasSetInitialContent &&
                    widget.initialContent != null &&
                    widget.initialContent!.isNotEmpty) {
                  Future.delayed(const Duration(milliseconds: 200), () {
                    try {
                      controller.setText(widget.initialContent!);
                      _hasSetInitialContent = true;
                    } catch (e) {
                      print(
                        'HtmlContentEditor onFocus: Không thể set text: $e',
                      );
                    }
                  });
                }
              },
              onKeyUp: (int? keyCode) {
                // Khi có key event, đảm bảo initial content được set
                if (!_hasSetInitialContent &&
                    widget.initialContent != null &&
                    widget.initialContent!.isNotEmpty) {
                  Future.delayed(const Duration(milliseconds: 100), () {
                    try {
                      controller.setText(widget.initialContent!);
                      _hasSetInitialContent = true;
                    } catch (e) {
                      print(
                        'HtmlContentEditor onKeyUp: Không thể set text: $e',
                      );
                    }
                  });
                }
              },
              onInit: () {
                // Set initial content với delay để đảm bảo editor sẵn sàng
                if (!_hasSetInitialContent &&
                    widget.initialContent != null &&
                    widget.initialContent!.isNotEmpty) {
                  Future.delayed(const Duration(milliseconds: 500), () {
                    try {
                      controller.setText(widget.initialContent!);
                      _hasSetInitialContent = true;
                    } catch (e) {
                      // Nếu vẫn chưa sẵn sàng, thử lại sau
                      Future.delayed(const Duration(milliseconds: 1000), () {
                        try {
                          controller.setText(widget.initialContent!);
                          _hasSetInitialContent = true;
                        } catch (e) {
                          print('HtmlContentEditor: Không thể set text: $e');
                        }
                      });
                    }
                  });
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
