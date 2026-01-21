import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class NewsDetailContent extends StatefulWidget {
  final String content;

  const NewsDetailContent({super.key, required this.content});

  @override
  State<NewsDetailContent> createState() => _NewsDetailContentState();
}

class _NewsDetailContentState extends State<NewsDetailContent> {
  late final WebViewController _controller;
  double _contentHeight = 1.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) async {
            // Đợi thêm 1 chút để render ổn định
            await Future.delayed(const Duration(milliseconds: 300));
            _updateContentHeight();
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
        ),
      )
      ..loadHtmlString(_processHtmlContent(widget.content));
  }

  /// Xử lý HTML trước khi load vào WebView
  String _processHtmlContent(String rawContent) {
    // 1. Xử lý ảnh lazy load: thay thế src placeholder bằng data-original
    String content = rawContent.replaceAllMapped(
      RegExp(r'<img[^>]+data-original="([^"]+)"[^>]*>'),
      (match) {
        final originalUrl = match.group(1);
        final fullTag = match.group(0) ?? '';
        if (originalUrl != null && originalUrl.isNotEmpty) {
          return fullTag.replaceAll(
            RegExp(r'src="[^"]+"'),
            'src="$originalUrl"',
          );
        }
        return fullTag;
      },
    );

    // 2. Wrap trong khung HTML chuẩn
    return """
      <!DOCTYPE html>
      <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
          <style>
            @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;700&display=swap');
            body { 
              margin: 0; 
              padding: 0; 
              font-family: 'Inter', sans-serif;
              overflow-y: hidden; /* Disable scroll dọc để WebView không bị cuộn bên trong */
            }
            img { 
              max-width: 100% !important; 
              height: auto !important; 
              display: block; 
              margin: 16px auto;
            }
            p {
              font-size: 16px;
              line-height: 1.6;
              margin-bottom: 16px;
              color: #333;
            }
            h1, h2, h3, h4, h5, h6 { margin-top: 24px; margin-bottom: 16px; line-height: 1.3; }
            figure { margin: 0; }
            figcaption { font-size: 13px; color: #666; font-style: italic; text-align: center; margin-top: 8px; margin-bottom: 16px; }
          </style>
        </head>
        <body>
          $content
        </body>
      </html>
    """;
  }

  /// Lấy chiều cao thực tế của nội dung HTML
  Future<void> _updateContentHeight() async {
    try {
      final height = await _controller.runJavaScriptReturningResult(
        "document.documentElement.scrollHeight",
      );
      if (height is num) {
        setState(() {
          // Thêm một chút padding bottom an toàn
          _contentHeight = height.toDouble() + 20;
        });
      }
    } catch (e) {
      debugPrint('Error getting WebView height: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.content.isEmpty) {
      return _buildEmptyContent();
    }

    return Stack(
      children: [
        SizedBox(
          height: _contentHeight,
          child: WebViewWidget(controller: _controller),
        ),
        if (_isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: _buildShimmerLoading(),
            ),
          ),
      ],
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer(
      duration: const Duration(seconds: 2),
      interval: const Duration(milliseconds: 500),
      color: Colors.grey,
      colorOpacity: 0.3,
      enabled: true,
      direction: const ShimmerDirection.fromLTRB(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          SizedBox(height: 24.h),
          Container(
            height: 20.h,
            width: double.infinity,
            color: Colors.grey[300],
          ),
          SizedBox(height: 12.h),
          Container(
            height: 20.h,
            width: double.infinity,
            color: Colors.grey[300],
          ),
          SizedBox(height: 12.h),
          Container(height: 20.h, width: 200.w, color: Colors.grey[300]),
          SizedBox(height: 24.h),
          Container(
            height: 150.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyContent() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.grey[500], size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Nội dung đang được cập nhật...',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
