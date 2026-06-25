// Export utility for CSV files
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';

class ExportUtils {
  static Future<void> saveFile(String filename, String csvContent, {String delimiter = ',', int pageSize = 10000}) async {
    final directory = await getExternalStorageDirectory();
    final file = File(path.join(directory!.path, filename));
    // If data exceeds pageSize, split into multiple files
    if (csvContent.length > pageSize) {
      final parts = csvContent.split('\n');
      int part = 1;
      StringBuffer buffer = StringBuffer();
      for (var line in parts) {
        buffer.writeln(line);
        if (buffer.length > pageSize) {
          final partFile = File('${file.path}_part$part.csv');
          await partFile.writeAsString(buffer.toString());
          buffer.clear();
          part++;
        }
      }
      if (buffer.isNotEmpty) {
        final partFile = File('${file.path}_part$part.csv');
        await partFile.writeAsString(buffer.toString());
      }
    } else {
      await file.writeAsString(csvContent);
    }
  }

  // data: list of maps where keys are column names
  static Future<String> exportToCsv(List<Map<String, dynamic>> data, String fileName) async {
    if (data.isEmpty) return '';
    final headers = data.first.keys.toList();
    final csvBuffer = StringBuffer();
    csvBuffer.writeln(headers.map((h) => '"$h"').join(','));
    for (var row in data) {
      final line = headers.map((h) => '"${row[h] ?? ''}"').join(',');
      csvBuffer.writeln(line);
    }
    final directory = await getExternalStorageDirectory();
    final path = '${directory!.path}/$fileName.csv';
    final file = File(path);
    await file.writeAsString(csvBuffer.toString(), encoding: utf8);
    return path;
  }
}
