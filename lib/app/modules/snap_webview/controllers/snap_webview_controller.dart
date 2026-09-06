import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../routes/app_pages.dart';

class SnapWebviewController extends GetxController {
  WebViewController? webViewController;
  final progress = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    final redirectUrl = Get.arguments?['redirectUrl']?.toString() ?? '';
    _initWebview(redirectUrl);
  }

  void _initWebview(String redirectUrl) {
    if (redirectUrl.isEmpty) {
      Get.back();
      return;
    }

    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int p) {
            progress.value = p / 100.0;
          },
          onPageStarted: (String url) {
            AppLogger.d('Webview page started: $url');
            if (url.contains('/finish') || url.contains('/success')) {
              Get.offAllNamed(Routes.HOME);
              Get.toNamed(Routes.ORDER_HISTORY);
            }
          },
          onPageFinished: (String url) {
            AppLogger.d('Webview page finished: $url');
          },
          onWebResourceError: (WebResourceError error) {
            AppLogger.w('Webview resource error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(redirectUrl));
  }
}
