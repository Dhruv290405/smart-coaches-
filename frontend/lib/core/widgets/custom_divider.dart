import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class CustomDivider extends StatelessWidget {
  const CustomDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 2.h),
      height: 1,
      color: Colors.grey.shade200,
    );
  }
}
