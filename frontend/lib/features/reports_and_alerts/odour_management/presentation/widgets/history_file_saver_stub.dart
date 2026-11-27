/// Fallback implementation; the conditional import in odour_history_exporter.dart
/// always resolves to the io or web variant instead on a real Flutter build.
Future<String> saveExportBytes(List<int> bytes, String fileName) async {
  throw UnsupportedError('No file saver implementation for this platform.');
}

void openExportedFile(String path) {}

void shareExportedFile(String path) {}
