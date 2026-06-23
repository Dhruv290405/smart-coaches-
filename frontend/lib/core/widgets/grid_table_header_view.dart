import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class GridTableHeaderView extends StatelessWidget {
  final String text;

  const GridTableHeaderView(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      alignment: Alignment.center,
      color: Colors.grey.shade100,
      child: Text(
        text.toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 10.2.sp,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }
}
