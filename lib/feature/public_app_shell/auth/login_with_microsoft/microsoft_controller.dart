import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MicrosoftController extends GetxController {
  final String urlMicrosoft = Get.arguments['url'] ?? '';
  WebViewController? webViewController;

  @override
  void onInit() async {
    super.onInit();
    print("🌐 Microsoft WebView initializing...");
    print("🔗 URL: $urlMicrosoft");

    if (urlMicrosoft.isEmpty) {
      print("❌ URL is empty, closing WebView");
      Get.back(result: false);
      return;
    }

    try {
      webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (url) => print('Loading URL: $url'),
            onPageFinished: (url) => print('Current URL: $url'),
            onNavigationRequest: (request) {
              print('Navigation request: ${request.url}');
              if (request.url.contains('code=')) {
                final uri = Uri.parse(request.url);
                final code = uri.queryParameters['code'];
                if (code != null) {
                  print('Received code: $code');
                  Get.back(result: {'code': code});
                  return NavigationDecision.prevent;
                }
              }
              return NavigationDecision.navigate;
            },
            onWebResourceError: (error) {
              print('❌ Web resource error: ${error.description}');
              print('Error code: ${error.errorCode}');
              // Nếu WebView crash, đóng và báo lỗi
              if (error.errorCode == -1 || error.errorCode == -2) {
                print('⚠️ WebView renderer crash detected');
                Future.delayed(Duration(milliseconds: 500), () {
                  if (Get.isRegistered<MicrosoftController>()) {
                    Get.back(result: false);
                  }
                });
              }
            },
          ),
        );

      print("🧹 Clearing cookies and cache...");
      await WebViewCookieManager().clearCookies();
      await webViewController!.clearCache();

      print("🚀 Loading Microsoft login page...");
      await webViewController!.loadRequest(
        Uri.parse(urlMicrosoft),
        headers: {"Cache-Control": "no-cache"},
      );
      print("✅ WebView loaded successfully");
      update(); // Cập nhật UI để hiển thị WebView
    } catch (e) {
      print("❌ Error initializing WebView: $e");
      Get.back(result: false);
    }
  }

  @override
  void onClose() {
    try {
      // Cleanup WebView resources nếu đã được khởi tạo
      if (webViewController != null) {
        webViewController!.clearCache();
        WebViewCookieManager().clearCookies();
      }
    } catch (e) {
      print("Error cleaning up WebView: $e");
    }
    Get.delete<MicrosoftController>();
    super.onClose();
  }
}
