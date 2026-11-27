// ignore: deprecated_member_use
import 'dart:html' as html;

/// Web: there's no real filesystem, so trigger a direct browser download
/// instead of writing to a documents directory (which doesn't exist on web).
Future<String> saveExportBytes(List<int> bytes, String fileName) async {
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..style.display = 'none';
  html.document.body?.children.add(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);
  return fileName;
}

void openExportedFile(String path) {
  // The browser already downloaded the file; nothing to open separately.
}

void shareExportedFile(String path) {
  // No native share sheet on web; the browser's download is the delivery.
}
