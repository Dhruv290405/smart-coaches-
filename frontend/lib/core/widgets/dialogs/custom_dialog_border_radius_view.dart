import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class CustomDialogBorderRadiusView extends StatelessWidget {
  final Widget child;

  const CustomDialogBorderRadiusView({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(5.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.w)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 5.w, horizontal: 8.w),
        child: child,
      ),
    );
  }
}
