import 'dart:typed_data';

import 'package:pdf/pdf.dart';

class PneumaticPdfReport {
  static const List<int> _widths = [5, 19, 17, 7, 12, 6, 6, 6, 6, 18, 8, 8, 8, 22];
  static const List<bool> _rightAligned = [
    true,
    false,
    false,
    false,
    false,
    true,
    true,
    true,
    true,
    false,
    true,
    true,
    true,
    false,
  ];
  static const List<String> _headers = [
    'SR',
    'TIMESTAMP',
    'DEVICE ID',
    'TRAIN',
    'LOCATION',
    'BP',
    'FP',
    'CR',
    'BC',
    'STATUS',
    'APPLIED',
    'RELEASED',
    'DURATION',
    'BRAKE FAULT',
  ];

  static const double _margin = 20;
  static const double _rowHeight = 9;
  static const double _fontSize = 7;
  static const double _bottomLimit = 30;

  static String get headerLine => _formatRow(_headers);

  static String formatRow(List<String> cells) => _formatRow(cells);

  static String _formatRow(List<String> cells) {
    final buffer = StringBuffer();
    for (var index = 0; index < _widths.length; index++) {
      var value = index < cells.length ? cells[index] : '';
      if (value.contains('\n') || value.contains('\r')) {
        value = value.replaceAll('\n', ' ').replaceAll('\r', ' ');
      }
      final width = _widths[index];
      if (value.length > width) value = value.substring(0, width);
      buffer.write(_rightAligned[index] ? value.padLeft(width) : value.padRight(width));
      if (index != _widths.length - 1) buffer.write(' ');
    }
    final line = buffer.toString();
    if (line.codeUnits.any((unit) => unit < 32 || unit > 126)) {
      return line.replaceAll(RegExp(r'[^\x20-\x7E]'), '?');
    }
    return line;
  }

  static Future<Uint8List> build({
    required List<String> rows,
    required String title,
    required String period,
    required String metadata,
    required String generated,
  }) async {
    final document = PdfDocument(compress: true);
    final regular = PdfFont.courier(document);
    final bold = PdfFont.courierBold(document);
    final sans = PdfFont.helvetica(document);
    final sansBold = PdfFont.helveticaBold(document);
    final format = PdfPageFormat.a4.landscape;
    final left = _margin;
    final right = format.width - _margin;
    final contentWidth = right - left;
    final pages = <PdfPage>[];

    (PdfGraphics, double) startPage({required bool first}) {
      final page = PdfPage(document, pageFormat: format);
      pages.add(page);
      final graphics = page.getGraphics();
      double y;

      if (first) {
        graphics.setFillColor(PdfColors.blue900);
        graphics.drawString(sansBold, 14, title, left, format.height - 28);
        graphics.setFillColor(PdfColors.grey700);
        graphics.drawString(sans, 8.5, period, left, format.height - 43);
        graphics.drawString(sans, 8.5, metadata, left, format.height - 54);
        graphics.setFillColor(PdfColors.grey600);
        graphics.drawString(sans, 7.5, generated, left, format.height - 65);
        y = format.height - 80;
      } else {
        y = format.height - 30;
      }

      graphics.setFillColor(PdfColors.blue900);
      graphics.drawRect(left, y - 2, contentWidth, 12);
      graphics.fillPath();
      graphics.setFillColor(PdfColors.white);
      graphics.drawString(bold, _fontSize, headerLine, left + 2, y + 1);

      return (graphics, y - 17);
    }

    var (graphics, y) = startPage(first: true);
    graphics.setFillColor(PdfColors.grey900);

    for (final row in rows) {
      if (y < _bottomLimit) {
        final page = startPage(first: false);
        graphics = page.$1;
        y = page.$2;
        graphics.setFillColor(PdfColors.grey900);
      }
      graphics.drawString(regular, _fontSize, row, left, y);
      y -= _rowHeight;
    }

    for (var index = 0; index < pages.length; index++) {
      final footer = pages[index].getGraphics();
      footer.setFillColor(PdfColors.grey600);
      footer.drawString(regular, 6.5, 'Page ${index + 1} of ${pages.length}', right - 78, 16);
    }

    return document.save();
  }
}
