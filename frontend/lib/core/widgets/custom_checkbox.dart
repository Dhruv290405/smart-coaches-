import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';

class CustomCheckbox extends StatelessWidget {
  final bool? value;
  final String? text;
  final Function(bool?) onChange;
  final String? richText;
  final double fontSize;

  const CustomCheckbox({
    super.key,
    required this.value,
    required this.text,
    required this.onChange,
    this.richText,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Checkbox(
          value: value,
          onChanged: (value) {
            onChange.call(value);
          },
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        SizedBox(
          width: 0.6.w,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              onChange.call(!(value ?? false));
            },
            child: richText != null
                ? RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: text ?? '',
                          style: TextStyle(
                            fontSize: fontSize.sp,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: richText ?? '',
                          style: TextStyle(
                            color: ColorConstants.blueColorDark,
                            fontSize: fontSize.sp,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  )
                : Text(
                    text ?? '',
                    style: TextStyle(
                      fontSize: fontSize.sp,
                      color: Colors.black,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
