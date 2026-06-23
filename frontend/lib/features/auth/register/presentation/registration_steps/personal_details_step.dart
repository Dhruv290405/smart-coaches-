import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/utils/constants.dart';
import 'package:smart_coach_new/core/widgets/custom_text_field.dart';
import 'package:smart_coach_new/core/widgets/field_label_text_view.dart';
import 'package:smart_coach_new/features/auth/register/data/models/register_request.dart';
import 'package:smart_coach_new/features/auth/register/presentation/bloc/register_bloc.dart';
import 'package:smart_coach_new/features/auth/register/presentation/bloc/register_event.dart';

class PersonalDetailsStep extends StatelessWidget {
  final TextEditingController? firstNameController;
  final TextEditingController? lastNameController;
  final TextEditingController? mobileController;
  final TextEditingController? emailController;
  final TextEditingController? passwordController;
  final String? selectedGender;
  final Function(String?) onSelectGender;
  final RegisterRequest registerRequest;

  const PersonalDetailsStep(
      {super.key,
      required this.firstNameController,
      required this.lastNameController,
      required this.mobileController,
      required this.emailController,
      required this.passwordController,
      required this.selectedGender,
      required this.onSelectGender,
      required this.registerRequest});

  @override
  Widget build(BuildContext context) {
    RegisterBloc bloc = context.read<RegisterBloc>();
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  labelText: "First Name",
                  hintText: "Enter your first name",
                  controller: firstNameController,
                  showShadowOnTextField: false,
                  showBgColorOnFocusedField: true,
                  textInputAction: TextInputAction.next,
                  isRequired: true,
                ),
              ),
              SizedBox(width: 1.5.h),
              Expanded(
                child: CustomTextField(
                  labelText: "Last Name",
                  hintText: "Enter your last name",
                  controller: lastNameController,
                  showShadowOnTextField: false,
                  showBgColorOnFocusedField: true,
                  textInputAction: TextInputAction.next,
                  isRequired: true,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          CustomTextField(
            labelText: "Mobile Number",
            hintText: "Enter your mobile number",
            controller: mobileController,
            textInputType: TextInputType.phone,
            isMobileNumberFieldAndShowCountryCode: true,
            showShadowOnTextField: false,
            showBgColorOnFocusedField: true,
            textInputAction: TextInputAction.next,
            isRequired: true,
          ),
          SizedBox(height: 2.h),
          CustomTextField(
            labelText: "Email Address",
            hintText: "Enter your email address",
            controller: emailController,
            textInputType: TextInputType.emailAddress,
            showShadowOnTextField: false,
            showBgColorOnFocusedField: true,
            textInputAction: TextInputAction.next,
            isRequired: true,
          ),
          SizedBox(height: 2.h),
          CustomTextField(
            labelText: "Password",
            hintText: "Enter your password",
            controller: passwordController,
            textInputType: TextInputType.text,
            showShadowOnTextField: false,
            showBgColorOnFocusedField: true,
            textInputAction: TextInputAction.done,
            isRequired: true,
          ),
          SizedBox(height: 2.h),
          FieldLabelTextView(
            labelText: 'Gender',
            isRequired: true,
          ),
          SizedBox(height: 0.5.h),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.blue,
                ),
                borderRadius: BorderRadius.circular(
                  2.5.w,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 4.w,
                vertical: 1.5.h,
              ),
            ),
            isDense: true,
            hint: Text(
              "Select gender",
              style: TextStyle(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
            ),
            validator: (v) => v == null ? 'Required' : null,
            initialValue: bloc.state.registerRequest.gender,
            items: Constants.genderList
                .map(
                  (g) => DropdownMenuItem(
                    value: g,
                    child: Text(
                      g,
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) {
              bloc.add(UpdateDropdownValue(key: bloc.genderDropDownKey, value: v));
              onSelectGender.call(v);
            },
          ),
        ],
      ),
    );
  }
}
