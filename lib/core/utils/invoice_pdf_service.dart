import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../data/models/invoice_model.dart';
import 'currency_formatter.dart';
import 'date_formatter.dart';

class InvoicePdfService {
  InvoicePdfService._();

  /// Prints the invoice or opens the system "Save as PDF" spooler dialog
  static Future<void> printInvoice(InvoiceModel invoice) async {
    final pdfBytes = await generateInvoicePdf(invoice);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'Invoice_${invoice.order.id}.pdf',
    );
  }

  /// Generates the raw PDF bytes for an invoice
  static Future<Uint8List> generateInvoicePdf(InvoiceModel invoice) async {
    final doc = pw.Document(
      title: 'Invoice #${invoice.order.id}',
      author: 'Cyber Store Indonesia',
    );

    final fontRegular = await PdfGoogleFonts.interRegular();
    final fontBold = await PdfGoogleFonts.interBold();
    final fontSemiBold = await PdfGoogleFonts.interSemiBold();

    final isPaid = invoice.statusPayment.toLowerCase() == 'settlement' ||
        invoice.statusPayment.toLowerCase() == 'paid' ||
        invoice.statusPayment.toLowerCase() == 'success' ||
        invoice.statusPayment.toLowerCase() == 'completed' ||
        invoice.statusPayment.toLowerCase() == 'selesai';

    final invoiceNum = 'INV-${invoice.order.id.length > 8 ? invoice.order.id.substring(invoice.order.id.length - 8).toUpperCase() : invoice.order.id}';
    final orderNum = 'ORD-${invoice.order.id.length > 8 ? invoice.order.id.substring(0, 8).toUpperCase() : invoice.order.id}';

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        theme: pw.ThemeData.withFont(
          base: fontRegular,
          bold: fontBold,
          fontFallback: [fontRegular, fontSemiBold],
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // 1. Header: Apple Branding & Company Info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'CYBER STORE',
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 20,
                          color: PdfColors.black,
                        ),
                      ),
                      pw.Text(
                        'AUTHORIZED APPLE PREMIUM RESELLER',
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 8,
                          color: PdfColors.grey700,
                          letterSpacing: 1.0,
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        'PT Cyber Store Indonesia\nMenara Cyber Lt. 18, Jakarta Selatan 12950\nNPWP: 01.345.678.9-012.000\nCS: cs@cyberstore.id',
                        style: const pw.TextStyle(
                          fontSize: 8.5,
                          color: PdfColors.grey700,
                          lineSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'FAKTUR PENJUALAN',
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 16,
                          color: PdfColors.black,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'No. Faktur: $invoiceNum',
                        style: pw.TextStyle(font: fontBold, fontSize: 10, color: PdfColors.black),
                      ),
                      pw.Text(
                        'Ref. Pesanan: $orderNum',
                        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                      ),
                      pw.Text(
                        'Tanggal: ${DateFormatter.formatFull(invoice.order.createdAt)}',
                        style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700),
                      ),
                      pw.SizedBox(height: 6),
                      // Status Badge
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: pw.BoxDecoration(
                          color: isPaid ? PdfColors.green50 : PdfColors.amber50,
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
                          border: pw.Border.all(
                            color: isPaid ? PdfColors.green600 : PdfColors.amber600,
                            width: 1,
                          ),
                        ),
                        child: pw.Text(
                          isPaid ? 'LUNAS (PAID)' : 'MENUNGGU PEMBAYARAN',
                          style: pw.TextStyle(
                            font: fontBold,
                            fontSize: 9,
                            color: isPaid ? PdfColors.green800 : PdfColors.amber800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 16),
              pw.Divider(thickness: 1.5, color: PdfColors.black),
              pw.SizedBox(height: 12),

              // 2. Customer & Shipping Info
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'INFORMASI PELANGGAN',
                          style: pw.TextStyle(font: fontBold, fontSize: 9, color: PdfColors.grey700),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(invoice.user.name, style: pw.TextStyle(font: fontBold, fontSize: 10)),
                        pw.Text(invoice.user.email, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800)),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 20),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'ALAMAT PENGIRIMAN',
                          style: pw.TextStyle(font: fontBold, fontSize: 9, color: PdfColors.grey700),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(invoice.deliveryAddress.name, style: pw.TextStyle(font: fontBold, fontSize: 10)),
                        pw.Text(
                          invoice.deliveryAddress.fullAddress,
                          style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 18),

              // 3. Itemized Products Table
              pw.Text(
                'RINCIAN PRODUK',
                style: pw.TextStyle(font: fontBold, fontSize: 9, color: PdfColors.grey700),
              ),
              pw.SizedBox(height: 6),
              pw.Table(
                border: pw.TableBorder(
                  horizontalInside: const pw.BorderSide(color: PdfColors.grey200, width: 0.8),
                  bottom: const pw.BorderSide(color: PdfColors.grey400, width: 1),
                ),
                columnWidths: {
                  0: const pw.FlexColumnWidth(4),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(2),
                },
                children: [
                  // Table Header
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('Deskripsi Item', style: pw.TextStyle(font: fontBold, fontSize: 8.5)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('Qty', textAlign: pw.TextAlign.center, style: pw.TextStyle(font: fontBold, fontSize: 8.5)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('Harga', textAlign: pw.TextAlign.right, style: pw.TextStyle(font: fontBold, fontSize: 8.5)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('Subtotal', textAlign: pw.TextAlign.right, style: pw.TextStyle(font: fontBold, fontSize: 8.5)),
                      ),
                    ],
                  ),
                  // Table Rows
                  ...invoice.order.orderItems.map((item) {
                    final itemTotal = item.price * item.quantity;
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(item.name, style: const pw.TextStyle(fontSize: 8.5)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text('${item.quantity}', textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 8.5)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(CurrencyFormatter.format(item.price), textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 8.5)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(CurrencyFormatter.format(itemTotal), textAlign: pw.TextAlign.right, style: pw.TextStyle(font: fontBold, fontSize: 8.5)),
                        ),
                      ],
                    );
                  }),
                ],
              ),

              pw.SizedBox(height: 14),

              // 4. Financial Calculation Summary
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 220,
                    child: pw.Column(
                      children: [
                        _buildSummaryRow('Subtotal', CurrencyFormatter.format(invoice.subtotal), fontRegular, fontBold),
                        pw.SizedBox(height: 3),
                        _buildSummaryRow('PPN (11%)', CurrencyFormatter.format(invoice.tax), fontRegular, fontBold),
                        pw.SizedBox(height: 3),
                        _buildSummaryRow('Ongkos Kirim', CurrencyFormatter.format(invoice.shipping), fontRegular, fontBold),
                        if (invoice.discount > 0) ...[
                          pw.SizedBox(height: 3),
                          _buildSummaryRow('Diskon', '- ${CurrencyFormatter.format(invoice.discount)}', fontRegular, fontBold, isDiscount: true),
                        ],
                        pw.Divider(thickness: 1, color: PdfColors.grey400),
                        pw.SizedBox(height: 2),
                        _buildSummaryRow('TOTAL BAYAR', CurrencyFormatter.format(invoice.total), fontBold, fontBold, isTotal: true),
                      ],
                    ),
                  ),
                ],
              ),

              pw.Spacer(),

              // 5. Official Guarantee & Footer Notes
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  border: pw.Border.all(color: PdfColors.grey300, width: 0.8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'KETENTUAN GARANSI & PENGIRIMAN',
                      style: pw.TextStyle(font: fontBold, fontSize: 8, color: PdfColors.black),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      '• Semua unit produk Apple bergaransi resmi Apple Indonesia / iBox selama 1 (satu) tahun.\n• Simpan faktur penjualan ini sebagai bukti kepemilikan dan klaim garansi resmi.\n• Faktur ini diterbitkan secara sah oleh sistem elektronik Cyber Store.',
                      style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700, lineSpacing: 1.8),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(
                  'Terima kasih telah berbelanja di Cyber Store Indonesia',
                  style: pw.TextStyle(font: fontBold, fontSize: 8, color: PdfColors.grey600),
                ),
              ),
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  static pw.Widget _buildSummaryRow(
    String label,
    String value,
    pw.Font labelFont,
    pw.Font valueFont, {
    bool isTotal = false,
    bool isDiscount = false,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            font: labelFont,
            fontSize: isTotal ? 10 : 8.5,
            color: isTotal ? PdfColors.black : PdfColors.grey700,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            font: valueFont,
            fontSize: isTotal ? 11 : 8.5,
            color: isDiscount
                ? PdfColors.green700
                : isTotal
                    ? PdfColors.black
                    : PdfColors.grey800,
          ),
        ),
      ],
    );
  }
}
