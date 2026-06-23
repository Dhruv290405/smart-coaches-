import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/core/widgets/field_label_text_view.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final String? labelText;
  final TextEditingController? controller;
  final dynamic prefixIcon;
  final Widget? suffixIcon;
  final bool isPassword;
  final TextInputAction? textInputAction;
  final TextInputType? textInputType;
  final bool isMobileNumberFieldAndShowCountryCode;
  final bool showShadowOnTextField;
  final bool showBgColorOnFocusedField;
  final bool isRequired;
  final int? maxLength;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final double fontSize;
  final bool digitsOnly;
  final bool allowNegativeNumbers;
  final List<TextInputFormatter>? inputFormatters;
  final bool isDisabled;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.labelText,
    this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.textInputAction,
    this.textInputType,
    this.isMobileNumberFieldAndShowCountryCode = false,
    this.showShadowOnTextField = true,
    this.showBgColorOnFocusedField = false,
    this.isRequired = false,
    this.maxLength,
    this.maxLines = 1,
    this.onChanged,
    this.fontSize = 12.5,
    this.digitsOnly = false,
    this.allowNegativeNumbers = true,
    this.inputFormatters,
    this.isDisabled = false,
  });

  @override
  State<CustomTextField> createState() => CustomTextFieldState();
}

class CustomTextFieldState extends State<CustomTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _obscureText = true;
  bool _hasFocus = false;
  Country _selectedCountry = Country.parse('IN');

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _hasFocus = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _openCountryPicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (Country country) {
        setState(() {
          _selectedCountry = country;
        });
      },
    );
  }

  String getFullPhoneNumber() {
    final number = widget.controller?.text.trim() ?? '';
    return '+${_selectedCountry.phoneCode}$number';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null)
          FieldLabelTextView(
            labelText: widget.labelText,
            isRequired: widget.isRequired,
          ),
        if (widget.labelText != null) SizedBox(height: 0.5.h),
        Container(
          padding: EdgeInsets.zero,
          decoration: BoxDecoration(
            color: widget.isDisabled
                ? ColorConstants.disabledTextFieldBgColor
                : Colors.white,
            borderRadius: BorderRadius.circular(2.5.w),
            border: Border.all(
              color: _hasFocus ? Colors.blue : Colors.grey.shade300,
              width: 0.4.w,
            ),
            boxShadow: widget.showShadowOnTextField && _hasFocus
                ? [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              if (widget.isMobileNumberFieldAndShowCountryCode)
                Container(
                  margin: EdgeInsets.only(left: 3.w),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _openCountryPicker,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(2.5.w),
                              bottomLeft: Radius.circular(2.5.w),
                            ),
                          ),
                          child: Text(
                            '+${_selectedCountry.phoneCode}',
                            style: TextStyle(
                              fontSize: widget.fontSize.sp,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 2.w),
                        height: 4.5.h,
                        width: 1,
                        color: Colors.grey.shade300,
                      ),
                    ],
                  ),
                ),
              if (widget.prefixIcon != null)
                Padding(
                  padding: EdgeInsets.only(left: 3.w),
                  child: widget.prefixIcon is String
                      ? SvgPicture.asset(
                          widget.prefixIcon!,
                          width: 5.w,
                          height: 5.w,
                        )
                      : Icon(
                          widget.prefixIcon,
                          size: 6.w,
                          color: ColorConstants.iconColor,
                        ),
                ),
              // SizedBox(
              //   width: 2.w,
              // ),
              Expanded(
                child: Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 2.w),
                      color: widget.isDisabled
                          ? ColorConstants.disabledTextFieldBgColor
                          : widget.isMobileNumberFieldAndShowCountryCode
                              ? Colors.white
                              : Colors.transparent,
                      child: TextField(
                        enabled: !widget.isDisabled,
                        focusNode: _focusNode,
                        controller: widget.controller,
                        obscureText: widget.isPassword ? _obscureText : false,
                        style: TextStyle(fontSize: widget.fontSize.sp),
                        textInputAction: widget.textInputAction,
                        keyboardType: widget.textInputType,
                        maxLength: widget.maxLength,
                        onChanged: widget.onChanged,
                        autofocus: false,
                        maxLines: widget.maxLines,
                        inputFormatters: widget.inputFormatters,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          counterText: "",
                          hintText: widget.hintText,
                          hintStyle: TextStyle(
                              fontSize: widget.fontSize.sp, color: Colors.grey),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 1.6.h,
                            horizontal: 0,
                          ),
                        ),
                      ),
                    ),
                    if (widget.suffixIcon != null)
                      Padding(
                        padding: EdgeInsets.only(right: 2.w),
                        child: widget.suffixIcon!,
                      ),
                  ],
                ),
              ),
              SizedBox(
                width: 2.w,
              ),
              if (widget.isPassword)
                Padding(
                  padding: EdgeInsets.only(right: 3.w),
                  child: GestureDetector(
                    onTap: () => setState(() => _obscureText = !_obscureText),
                    child: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      size: 6.w,
                      color: ColorConstants.iconColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
