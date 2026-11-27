import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';

/// Mobile/desktop: write to the app's documents directory, same as the
/// existing OdourReportGenerator.
Future<String> saveExportBytes(List<int> bytes, String fileName) async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/$fileName');
  await file.writeAsBytes(bytes);
  return file.path;
}

void openExportedFile(String path) => OpenFile.open(path);

void shareExportedFile(String path) => Share.shareXFiles([XFile(path)]);
