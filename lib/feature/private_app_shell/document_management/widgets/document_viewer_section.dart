import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tcs_e_office/core/configs/theme/app_colors.dart';
import 'package:tcs_e_office/common/widgets/enhanced_text_widget.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:http/http.dart' as http;
import '../utils/pdf_loader_isolate.dart';
import 'section_header.dart';

class DocumentViewerSection extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const DocumentViewerSection({super.key, required this.pdfUrl, required this.title});

  // Validation method để kiểm tra URL hợp lệ
  static bool isValidPdfUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  @override
  State<DocumentViewerSection> createState() => _DocumentViewerSectionState();
}

class _DocumentViewerSectionState extends State<DocumentViewerSection> {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  int _retryCount = 0;
  static const int _maxRetries = 3;
  bool _isExpanded = true;
  Timer? _timeoutTimer;
  Uint8List? _pdfBytes;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    _hasError = false;
    _preloadPdf();
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  Future<void> _preloadPdf() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
      _pdfBytes = null;
    });

    // Timeout mechanism
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(const Duration(seconds: 40), () {
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Hết thời gian chờ. Vui lòng thử lại hoặc mở trong trình duyệt.';
        });
      }
    });

    try {
      // Tải PDF trong isolate để không block UI
      final bytes = await PdfLoaderIsolate.loadPdfBytes(widget.pdfUrl);

      if (mounted) {
        setState(() {
          _pdfBytes = bytes;
          _isLoading = false;
          _hasError = false;
          _retryCount = 0;
        });
        _timeoutTimer?.cancel();
      }
    } on TimeoutException {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Kết nối quá lâu. Vui lòng thử lại hoặc mở trong trình duyệt.';
        });
      }
      _timeoutTimer?.cancel();
    } on SocketException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          if (e.osError?.errorCode == 110) {
            _errorMessage = 'Hết thời gian kết nối. Vui lòng kiểm tra mạng và thử lại.';
          } else if (e.osError?.errorCode == 104) {
            _errorMessage = 'Kết nối bị ngắt. Vui lòng thử lại.';
          } else {
            _errorMessage = 'Lỗi kết nối: ${e.message}';
          }
        });
      }
      _timeoutTimer?.cancel();
    } on http.ClientException {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Không thể tải PDF. Vui lòng thử lại hoặc mở trong trình duyệt.';
        });
      }
      _timeoutTimer?.cancel();
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Lỗi: ${e.toString().replaceAll('Exception: ', '')}';
        });
      }
      _timeoutTimer?.cancel();
    }
  }

  void _retryLoad() {
    if (_retryCount < _maxRetries) {
      setState(() {
        _retryCount++;
      });
      _preloadPdf();
    } else {
      setState(() {
        _hasError = true;
        _errorMessage = 'Đã thử lại nhiều lần. Vui lòng mở trong trình duyệt.';
      });
    }
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Kiểm tra URL hợp lệ trước khi render
    if (!DocumentViewerSection.isValidPdfUrl(widget.pdfUrl)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          SectionHeader(title: widget.title, icon: Icons.visibility_outlined),
          const SizedBox(height: 8),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.bacgroundApp,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.grey),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.link_off,
                    size: 48,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'URL không hợp lệ',
                    style: AppTextStyles.h4.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Không thể hiển thị tài liệu với URL này',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        SectionHeader(
          title: widget.title,
          icon: Icons.attachment,
          trailing: IconButton(
            icon: Icon(
              _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: const Color(0xFF006884),
            ),
            onPressed: _toggleExpansion,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          crossFadeState: _isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: SizedBox.shrink(),
          secondChild: _hasError ? _buildErrorState() : _buildDocumentViewer(),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: AppColors.bacgroundApp,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.colorRed),
              const SizedBox(height: 16),
              Text(
                'Không thể tải tài liệu',
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.colorRed,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage.isNotEmpty
                    ? _errorMessage
                    : 'Vui lòng kiểm tra kết nối mạng',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_retryCount < _maxRetries) ...[
                    ElevatedButton.icon(
                      onPressed: _retryLoad,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Thử lại'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  TextButton.icon(
                    onPressed: () async {
                      try {
                        final uri = Uri.parse(widget.pdfUrl);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Không thể mở PDF trong trình duyệt',
                              ),
                              backgroundColor: AppColors.colorRed,
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Lỗi: $e'),
                            backgroundColor: AppColors.colorRed,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.open_in_browser),
                    label: const Text('Mở trong trình duyệt'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentViewer() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE8E8E8), width: 0.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            // Chỉ hiển thị khi đã tải được bytes
            if (_pdfBytes != null)
              SfPdfViewer.memory(
                _pdfBytes!,
                key: ValueKey('pdf_viewer_memory_${widget.pdfUrl}'),
                enableDoubleTapZooming: true,
                enableTextSelection: true,
                initialZoomLevel: 1.0,
                onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                      _hasError = true;
                      _errorMessage = 'Không thể hiển thị PDF. Vui lòng thử lại.';
                      _pdfBytes = null;
                    });
                  }
                },
                onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                      _hasError = false;
                      _retryCount = 0;
                    });
                  }
                },
              ),
            // Loading overlay
            if (_isLoading)
              Container(
                color: Colors.white.withOpacity(0.8),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF006884),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _retryCount > 0
                            ? 'Đang tải lại tài liệu... (Lần ${_retryCount + 1}/$_maxRetries)'
                            : 'Đang tải tài liệu...',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
