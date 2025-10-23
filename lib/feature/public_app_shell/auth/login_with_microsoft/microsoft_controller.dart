import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MicrosoftController extends GetxController {
  final String urlMicrosoft = Get.arguments['url'] ?? '';
  late final WebViewController webViewController;

  @override
  void onInit() async {
    super.onInit();
    print("🌐 Microsoft WebView initializing...");
    print("🔗 URL: $urlMicrosoft");

    if (urlMicrosoft.isEmpty) {
      print("❌ URL is empty, closing WebView");
      Get.back();
      return;
    }

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
          onWebResourceError: (error) => print('Web error: ${error.description}'),
        ),
      );

    print("🧹 Clearing cookies and cache...");
    await WebViewCookieManager().clearCookies();
    await webViewController.clearCache();

    print("🚀 Loading Microsoft login page...");
    await webViewController.loadRequest(
      Uri.parse(urlMicrosoft),
      headers: {"Cache-Control": "no-cache"}, 
    );
    print("✅ WebView loaded successfully");
  }

  @override
  void onClose() {
    Get.delete<MicrosoftController>();
    super.onClose();
  }
}