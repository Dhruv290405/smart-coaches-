import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class FieldLabelTextView extends StatelessWidget {
  final String? labelText;
  final bool isRequired;

  const FieldLabelTextView(
      {super.key, required this.labelText, this.isRequired = false});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: labelText ?? '',
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w500,
          color: Colors.black
        ),
        children: isRequired
            ? [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
              ]
            : [],
      ),
    );
  }
}
