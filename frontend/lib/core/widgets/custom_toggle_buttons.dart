import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';

class CustomToggleButtons extends StatelessWidget {
  final int selectedIndex;
  final List<String> labels;
  final void Function(int index) onTap;

  const CustomToggleButtons({
    super.key,
    required this.selectedIndex,
    required this.labels,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final isSelected = selectedIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(index),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? ColorConstants.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(4.w),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                      : [],
                ),
                padding: EdgeInsets.symmetric(vertical: 1.h),
                alignment: Alignment.center,
                child: Text(
                  labels[index],
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.normal,
                    color: isSelected ? Colors.white: Colors.black,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}