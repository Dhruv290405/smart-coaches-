import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/core/widgets/custom_checkbox.dart';
import 'package:smart_coach_new/core/widgets/custom_text_field.dart';
import 'package:smart_coach_new/features/auth/register/presentation/bloc/register_bloc.dart';
import 'package:smart_coach_new/features/auth/register/presentation/bloc/register_state.dart';

class IdentityVerificationStep extends StatefulWidget {
  final TextEditingController? panAadhaarController;
  final bool isConfirmed;
  final bool isAgreedToTerms;
  final Function(bool) onCheckConfirm;
  final Function(bool) onCheckAgreedToTerms;
  final Function onChangeSelectedIdType;

  const IdentityVerificationStep(
      {super.key,
      required this.panAadhaarController,
      required this.isConfirmed,
      required this.isAgreedToTerms,
      required this.onCheckConfirm,
      required this.onCheckAgreedToTerms,
      required this.onChangeSelectedIdType});

  @override
  State<IdentityVerificationStep> createState() =>
      _IdentityVerificationStepState();
}

class _IdentityVerificationStepState extends State<IdentityVerificationStep> {
  String _selectedIdType = 'PAN';
  File? _idDocument;
  File? _profilePhoto;

  Future<void> _pickFile(bool isIdDoc) async {
    try {
      FilePickerResult? result;

      if (isIdDoc) {
        // For ID docs, we allow PDF, JPG, PNG.
        // Some Android devices fail with FileType.custom when mixing image and pdf.
        // We use FileType.any and filter in Dart for better compatibility.
        result = await FilePicker.platform.pickFiles(
          type: FileType.any,
        );

        if (result != null && result.files.isNotEmpty) {
          final extension = result.files.single.extension?.toLowerCase();
          final allowed = ['jpg', 'jpeg', 'png', 'pdf'];
          if (!allowed.contains(extension)) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Invalid file type. Please select JPG, PNG or PDF.")),
              );
            }
            return;
          }
        }
      } else {
        // For profile photos, use FileType.image for a better experience
        result = await FilePicker.platform.pickFiles(
          type: FileType.image,
        );
      }

      if (result != null && result.files.isNotEmpty) {
        final path = result.files.single.path;
        if (path == null) return;
        final file = File(path);
        setState(() {
          if (isIdDoc) {
            _idDocument = file;
          } else {
            _profilePhoto = file;
          }
        });
      }
    } catch (e) {
      debugPrint("Error picking file: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Could not open file picker: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
      builder: (context, state) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Select ID Type",
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 0.5.h),
              Row(
                children: [
                  Radio<String>(
                    value: 'PAN',
                    groupValue: _selectedIdType,
                    onChanged: (value) {
                      _selectedIdType = value.toString();
                      widget.onChangeSelectedIdType.call();
                    },
                    visualDensity: VisualDensity.compact,
                    // less space
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  GestureDetector(
                    onTap: () {
                      _selectedIdType = 'PAN';
                      widget.onChangeSelectedIdType.call();
                    },
                    child: Text(
                      'PAN Card',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(width: 1.2.w),
                  Radio<String>(
                    value: 'AADHAAR',
                    groupValue: _selectedIdType,
                    onChanged: (value) {
                      _selectedIdType = value.toString();
                      widget.onChangeSelectedIdType.call();
                    },
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  GestureDetector(
                    onTap: () {
                      _selectedIdType = 'AADHAAR';
                      widget.onChangeSelectedIdType.call();
                    },
                    child: Text(
                      'Aadhaar Card',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 0.5.h),
              CustomTextField(
                labelText:
                    state.isIdTypeIsPan ? "PAN Number" : "Aadhaar Number",
                hintText: state.isIdTypeIsPan ? 'ABCDE1234F' : 'XXXX-XXXX-XXXX',
                controller: widget.panAadhaarController,
              ),
              SizedBox(height: 2.h),
              _uploadField(
                  title: "Upload ID Document",
                  file: _idDocument,
                  onTap: () => _pickFile(true),
                  sizeNote: "JPG, PNG or PDF (max. 5MB)",
                  isIdDoc: true),
              SizedBox(height: 2.h),
              _uploadField(
                  title: "Upload Profile Photo",
                  file: _profilePhoto,
                  onTap: () => _pickFile(false),
                  sizeNote: "JPG or PNG only (max. 2MB)",
                  isIdDoc: false),
              SizedBox(height: 2.h),
              CustomCheckbox(
                value: widget.isConfirmed,
                text: 'I confirm that the above information is accurate',
                onChange: (bool? value) {
                  widget.onCheckConfirm.call(value ?? false);
                },
              ),
              CustomCheckbox(
                value: widget.isAgreedToTerms,
                text: 'I agree to the ',
                richText: 'Terms & Conditions',
                onChange: (bool? value) {
                  widget.onCheckAgreedToTerms.call(value ?? false);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _uploadField({
    required String title,
    required File? file,
    required VoidCallback onTap,
    required String sizeNote,
    required bool isIdDoc,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600)),
        SizedBox(height: 0.8.h),
        GestureDetector(
          onTap: onTap,
          child: DottedBorder(
            // color: Colors.grey.shade400,
            // strokeWidth: 1,
            // dashPattern: [6, 4],
            // borderType: BorderType.RRect,
            // radius: Radius.circular(4.w),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 2.5.h),
              width: double.infinity,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    file != null
                        ? Icons.check_circle
                        : isIdDoc
                            ? Icons.ios_share_outlined
                            : Icons.person_add_outlined,
                    size: 7.2.w,
                    color: file != null
                        ? ColorConstants.blueColorDark
                        : Colors.grey,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    file != null ? "File selected" : "Click to upload",
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    sizeNote,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
