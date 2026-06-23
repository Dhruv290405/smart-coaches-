import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/widgets/field_label_text_view.dart';

class CustomDropDown<T> extends StatelessWidget {
  final String label;
  final String hintText;
  final dynamic value;
  final List<T> items;
  final ValueChanged<dynamic> onChanged;
  final bool isRequired;
  final String Function(T)? displayText;
  final dynamic Function(T)? getValue;

  const CustomDropDown({
    super.key,
    required this.label,
    required this.hintText,
    required this.value,
    required this.items,
    required this.onChanged,
    this.isRequired = false,
    this.displayText,
    this.getValue,
  });

  T? _getSelectedItem() {
    if (getValue == null || value == null) return value as T?;
    try {
      return items.firstWhere(
            (item) => getValue!(item) == value,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final T? selectedItem = _getSelectedItem();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabelTextView(
          labelText: label,
          isRequired: isRequired,
        ),
        SizedBox(height: 1.h),
        Container(
          height: 6.2.h,
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 0.4.w),
            borderRadius: BorderRadius.circular(2.5.w),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: selectedItem,
              hint: Text(
                hintText,
                style: TextStyle(fontSize: 12.sp),
                overflow: TextOverflow.ellipsis,
              ),
              isExpanded: true,
              onChanged: (item) {
                if (item != null) {
                  final newValue = getValue != null ? getValue!(item) : item;
                  onChanged(newValue);
                } else {
                  onChanged(null);
                }
              },
              items: items.map((item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    displayText != null ? displayText!(item) : item.toString(),
                    style: TextStyle(fontSize: 12.sp),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}