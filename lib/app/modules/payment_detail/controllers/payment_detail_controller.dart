import 'dart:async';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../data/models/midtrans_model.dart';
import '../../../../data/repositories/order_repository.dart';
import '../../../routes/app_pages.dart';

class PaymentDetailController extends GetxController {
  final OrderRepository _orderRepo = OrderRepository();

  late MidtransChargeData charge;
  late String orderId;
  int totalAmount = 0;

  Timer? _countdownTimer;
  Timer? _pollingTimer;
  static const Duration _pollingInterval = Duration(seconds: 4);

  Duration remainingTime = const Duration(hours: 24);
  bool isCheckingStatus = false;
  bool _hasNavigated = false;
  int selectedGuideTab = 0; // 0: m-Banking, 1: ATM, 2: Internet Banking

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      if (args['charge'] is MidtransChargeData) {
        charge = args['charge'] as MidtransChargeData;
      } else if (args['charge'] is Map<String, dynamic>) {
        charge = MidtransChargeData.fromJson(args['charge'] as Map<String, dynamic>);
      }
      orderId = args['orderId']?.toString() ?? charge.orderId;
      totalAmount = (args['totalAmount'] as num?)?.toInt() ?? int.tryParse(charge.grossAmount) ?? 0;
    }

    _initCountdown();
    _startPolling();
  }

  void _initCountdown() {
    if (charge.expiryTime != null && charge.expiryTime!.isNotEmpty) {
      try {
        final expiry = DateTime.parse(charge.expiryTime!);
        final diff = expiry.difference(DateTime.now());
        if (diff.isNegative) {
          remainingTime = Duration.zero;
        } else {
          remainingTime = diff;
        }
      } catch (_) {
        remainingTime = const Duration(hours: 24);
      }
    } else {
      remainingTime = const Duration(hours: 24);
    }

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime.inSeconds > 0) {
        remainingTime = remainingTime - const Duration(seconds: 1);
        update();
      } else {
        timer.cancel();
        _stopPolling();
      }
    });
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(_pollingInterval, (_) {
      if (!_hasNavigated && !isCheckingStatus && orderId.isNotEmpty) {
        checkStatus(isManual: false);
      }
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  String get formattedRemainingTime {
    final hours = remainingTime.inHours.toString().padLeft(2, '0');
    final minutes = (remainingTime.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (remainingTime.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  void setGuideTab(int index) {
    selectedGuideTab = index;
    update();
  }

  void copyToClipboard(String text, String label) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    AppSnackbar.info('$label berhasil disalin ke clipboard', title: 'Salin Berhasil');
  }

  Future<void> checkStatus({bool isManual = false}) async {
    if (_hasNavigated) return;

    if (isManual) {
      if (isCheckingStatus) return;
      isCheckingStatus = true;
      update();
    }

    try {
      final res = await _orderRepo.checkPaymentStatus(orderId);
      if (res.isPaid) {
        _hasNavigated = true;
        _stopPolling();
        _countdownTimer?.cancel();

        AppSnackbar.success(
          'Terima kasih! Pembayaran Anda telah kami terima.',
          title: 'Pembayaran Berhasil! 🎉',
        );

        // Redirect to invoice after short moment
        await Future.delayed(const Duration(milliseconds: 1200));
        Get.offNamed(Routes.invoice(orderId), arguments: {'orderId': orderId});
      } else if (res.status == 'cancel' || res.status == 'expire') {
        _stopPolling();
        _countdownTimer?.cancel();

        AppSnackbar.error(
          'Pesanan ini telah kadaluarsa atau dibatalkan.',
          title: 'Pembayaran Tidak Aktif',
        );
      } else {
        if (isManual) {
          AppSnackbar.warning(
            'Pembayaran belum terdeteksi. Silakan selesaikan transfer lalu klik cek status lagi.',
            title: 'Status Pembayaran',
          );
        }
      }
    } catch (e) {
      AppLogger.e('Check payment status error', e);
      if (isManual) {
        AppSnackbar.error(
          e,
          title: 'Gagal Memeriksa Status',
        );
      }
    } finally {
      if (isManual) {
        isCheckingStatus = false;
        update();
      }
    }
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    _stopPolling();
    super.onClose();
  }
}
