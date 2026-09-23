import 'package:get/get.dart';
import 'package:printing/printing.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/utils/invoice_pdf_service.dart';
import '../../../../data/models/invoice_model.dart';
import '../../../../data/repositories/invoice_repository.dart';

class InvoiceController extends GetxController {
  final InvoiceRepository _invoiceRepo = InvoiceRepository();

  InvoiceModel? invoice;
  bool loading = true;
  String invoiceId = '';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args['orderId'] != null) {
      invoiceId = args['orderId'].toString();
    } else {
      final paramId = Get.parameters['id']?.toString() ?? '';
      if (paramId.isNotEmpty && paramId != ':id') {
        invoiceId = paramId;
      }
    }
    getInvoice();
  }

  Future<void> getInvoice() async {
    if (invoiceId.isEmpty || invoiceId == ':id') {
      loading = false;
      update();
      AppSnackbar.error('Order ID is invalid or not found.', title: 'Invoice Not Found');
      return;
    }

    loading = true;
    update();

    try {
      invoice = await _invoiceRepo.getInvoice(invoiceId);
    } catch (e) {
      AppLogger.e('Error loading invoice', e);
      AppSnackbar.error(e, title: 'Failed to Load Invoice');
    } finally {
      loading = false;
      update();
    }
  }

  bool isPrinting = false;

  Future<void> printInvoice() async {
    if (invoice == null || isPrinting) return;

    isPrinting = true;
    update();

    try {
      await InvoicePdfService.printInvoice(invoice!);
    } catch (e) {
      AppLogger.e('Error printing invoice', e);
      AppSnackbar.error('Failed to process invoice print document.', title: 'Print Failed');
    } finally {
      isPrinting = false;
      update();
    }
  }

  Future<void> shareInvoice() async {
    if (invoice == null || isPrinting) return;

    isPrinting = true;
    update();

    try {
      final pdfBytes = await InvoicePdfService.generateInvoicePdf(invoice!);
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: 'Invoice_${invoice!.order.id}.pdf',
      );
    } catch (e) {
      AppLogger.e('Error sharing invoice', e);
      AppSnackbar.error('Failed to share invoice document.', title: 'Share Failed');
    } finally {
      isPrinting = false;
      update();
    }
  }
}
