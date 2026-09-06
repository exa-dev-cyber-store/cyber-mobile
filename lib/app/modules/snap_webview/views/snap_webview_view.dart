import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../routes/app_pages.dart';
import '../controllers/snap_webview_controller.dart';

class SnapWebviewView extends GetView<SnapWebviewController> {
  const SnapWebviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final SnapWebviewController controller = Get.find<SnapWebviewController>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text('Pembayaran Midtrans', style: AppTextStyles.titleSmall),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, size: 22),
          onPressed: () {
            Get.offAllNamed(Routes.HOME);
            Get.toNamed(Routes.ORDER_HISTORY);
          },
        ),
      ),
      body: Column(
        children: [
          Obx(() {
            if (controller.progress.value < 1.0) {
              return LinearProgressIndicator(
                value: controller.progress.value,
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                minHeight: 2,
              );
            }
            return const SizedBox(height: 2);
          }),
          Expanded(
            child: controller.webViewController != null
                ? WebViewWidget(controller: controller.webViewController!)
                : const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }
}
