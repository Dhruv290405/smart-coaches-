import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/utils/toast_message_utils.dart';
import 'package:smart_coach_new/core/widgets/dialogs/common_success_dialog.dart';
import 'package:smart_coach_new/core/widgets/dialogs/common_yes_no_dialog.dart';
import 'package:smart_coach_new/core/widgets/grid_table_header_view.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class Utils {
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      // For Android
      if (await Permission.storage.request().isGranted) {
        return true;
      }
      // For Android 13 and above
      if (await Permission.photos.request().isGranted &&
          await Permission.videos.request().isGranted) {
        return true;
      }
    } else if (Platform.isIOS) {
      // For iOS
      if (await Permission.photos.request().isGranted) {
        return true;
      }
    }
    return false;
  }

  static Future<void> showYesNoDialog({
    required BuildContext context,
    required String message,
    String? title,
    String positiveButtonText = 'Yes',
    String negativeButtonText = 'Cancel',
    VoidCallback? onYes,
    VoidCallback? onCancel,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return CommonYesNoDialog(
          message: message,
          title: title,
          positiveButtonText: positiveButtonText,
          negativeButtonText: negativeButtonText,
          onYes: onYes,
          onCancel: onCancel,
        );
      },
    );
  }

  static void showSimpleMessageDialog(
      BuildContext context, String title, String message,
      {String buttonText = 'Done', Function? onTapButton}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => CommonSuccessDialog(
        title: title,
        message: message,
        buttonText: buttonText,
        onPressed: () {
          // Navigator.pop();
          context.pop();
          onTapButton?.call();
          // Navigate or perform another action here
        },
      ),
    );
  }

  static void showMultiErrorMessageDialog(
      BuildContext context, List<String>? errorList) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Validation Errors"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: errorList!
              .map(
                (e) => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("• "),
                    Expanded(child: Text(e)),
                  ],
                ),
              )
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  static void showApiErrorMessageOrList(BuildContext context,
      {String? message, List<String>? errorList}) {
    if (errorList != null && errorList.isNotEmpty) {
      showMultiErrorMessageDialog(context, errorList);
    } else {
      ToastMessageUtils.showMessage(context, message);
    }
  }

  static String? getFormattedDate(DateTime? date, String format) {
    if (date == null) return null;
    return DateFormat(format).format(date);
  }

  static String? formatReadableDate(String? date, {String dateFormat = 'dd-MM-yyyy'}) {
    if (date == null) {
      return date;
    }
    try {
      final DateTime parsedDate = DateTime.parse(date).toLocal();
      final DateFormat formatter = DateFormat(dateFormat);
      return formatter.format(parsedDate);
    } catch (_) {
      return date;
    }
  }

  static String? setTextInOneLine(String? text) {
    if (text == null) {
      return text;
    }
    return Characters(text).toList().join('\u{200B}');
  }

  static bool isValidDropDownSelectedItem(
      List<dynamic> items, dynamic selectedValue) {
    if (selectedValue != null && items.contains(selectedValue)) {
      // if ((selectedValue ?? '').isNotEmpty && items.contains(selectedValue)) {
      return true;
    }
    return false;
  }

  static String? normalizeDropDownValue(
      String? input, List<String> validValues) {
    if (input == null) return null;

    return validValues
        .where((val) => val.toLowerCase() == input.toLowerCase())
        .cast<String?>()
        .firstWhere((_) => true, orElse: () => null);
  }

  static String convertToIsoDate(String inputDate) {
    try {
      if (!inputDate.contains('-')) {
        return inputDate;
      }
      final parts = inputDate.split('-');
      if (parts.length != 3) return '';
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      return DateTime(year, month, day).toIso8601String().split('T').first;
    } catch (_) {
      return '';
    }
  }

  static String convertToIsoDateTime(String inputDate) {
    try {
      if (!inputDate.contains('-')) {
        return inputDate;
      }
      final parts = inputDate.split('-');
      if (parts.length != 3) return '';
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      return DateTime(year, month, day, 14, 30).toIso8601String();
    } catch (_) {
      return '';
    }
  }

  static GridColumn gridColumn(
      {required String label,
      String? columnName,
      bool allowSorting = true,
      double? width}) {
    return GridColumn(
      columnName: columnName ?? label,
      width: width ?? double.nan,
      allowSorting: allowSorting,
      minimumWidth: 30.w,
      label: GridTableHeaderView(
        label,
      ),
    );
  }
}
