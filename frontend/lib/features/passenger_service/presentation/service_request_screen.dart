import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/network/api_constants.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/routes/app_router.dart';
import 'package:smart_coach_new/core/utils/loader.dart';
import 'package:smart_coach_new/core/utils/toast_message_utils.dart';
import 'package:smart_coach_new/core/widgets/custom_button.dart';
import 'package:smart_coach_new/core/widgets/custom_text_field.dart';
import 'package:smart_coach_new/core/widgets/field_label_text_view.dart';

class ServiceRequestScreen extends StatefulWidget {
  const ServiceRequestScreen({super.key});

  @override
  State<ServiceRequestScreen> createState() => _ServiceRequestScreenState();
}

class _ServiceRequestScreenState extends State<ServiceRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final trainNoController = TextEditingController();
  final coachNoController = TextEditingController();
  final seatBerthController = TextEditingController();
  final descriptionController = TextEditingController();
  final passengerNameController = TextEditingController();
  final passengerPhoneController = TextEditingController();

  String? selectedServiceType;
  bool _isSubmitting = false;

  final List<Map<String, String>> serviceTypes = [
    {"value": "toilet_cleaning", "label": "Toilet Cleaning"},
    {"value": "linen_issue", "label": "Linen Issue"},
    {"value": "others", "label": "Others"},
  ];

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    Loader.show();

    try {
      final url = Uri.parse('${ApiConstants.devUrl}/service-requests');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "train_no": trainNoController.text.trim(),
          "coach_no": coachNoController.text.trim(),
          "seat_berth": seatBerthController.text.trim(),
          "service_type": selectedServiceType,
          "description": descriptionController.text.trim().isNotEmpty
              ? descriptionController.text.trim()
              : null,
          "passenger_name": passengerNameController.text.trim().isNotEmpty
              ? passengerNameController.text.trim()
              : null,
          "passenger_phone": passengerPhoneController.text.trim().isNotEmpty
              ? passengerPhoneController.text.trim()
              : null,
        }),
      );

      Loader.dismiss();
      setState(() => _isSubmitting = false);

      if (response.statusCode == 201) {
        final body = jsonDecode(response.body);
        final requestId = body['data']?['id'] ?? 'N/A';
        _showSuccessDialog(requestId.toString());
      } else {
        String msg = 'Something went wrong (Error ${response.statusCode})';
        try {
          final body = jsonDecode(response.body);
          msg = body['message'] ?? body['error'] ?? msg;
        } catch (_) {}
        ToastMessageUtils.showMessage(context, msg);
      }
    } catch (e) {
      Loader.dismiss();
      setState(() => _isSubmitting = false);
      ToastMessageUtils.showMessage(
          context, 'Network error: ${e.toString().length > 80 ? e.toString().substring(0, 80) : e.toString()}');
    }
  }

  void _showSuccessDialog(String requestId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.w)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 2.h),
            Container(
              width: 15.w,
              height: 15.w,
              decoration: BoxDecoration(
                color: ColorConstants.statusGood.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle,
                  color: ColorConstants.statusGood, size: 10.w),
            ),
            SizedBox(height: 2.h),
            Text("Request Submitted!",
                style:
                    TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700)),
            SizedBox(height: 0.5.h),
            Text("Request #$requestId",
                style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: ColorConstants.primary)),
            SizedBox(height: 0.5.h),
            Text(
              "The train operator has been notified.",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 11.sp, color: ColorConstants.textSecondary),
            ),
            SizedBox(height: 3.h),
            CustomButton(
              text: "Back to Login",
              onPressed: () {
                Navigator.of(ctx).pop();
                context.go(AppRouter.loginRoute);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    trainNoController.dispose();
    coachNoController.dispose();
    seatBerthController.dispose();
    descriptionController.dispose();
    passengerNameController.dispose();
    passengerPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.screenBgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black87, size: 5.w),
          onPressed: () => context.go(AppRouter.loginRoute),
        ),
        title: Text(
          "Service Request",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3.w),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              color: ColorConstants.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(2.w),
                            ),
                            child: Icon(Icons.support_agent,
                                color: ColorConstants.primary, size: 6.w),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Submit a Request",
                                    style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w700)),
                                Text(
                                    "We'll route it to the train operator",
                                    style: TextStyle(
                                        fontSize: 11.sp,
                                        color: ColorConstants.textSecondary)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 3.h),

                // Form card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3.w),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              hintText: "e.g. 12345",
                              labelText: "Train No.",
                              controller: trainNoController,
                              textInputType: TextInputType.number,
                              isRequired: true,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: CustomTextField(
                              hintText: "e.g. S5",
                              labelText: "Coach No.",
                              controller: coachNoController,
                              isRequired: true,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      CustomTextField(
                        hintText: "e.g. B3, S3, WS6",
                        labelText: "Seat / Berth",
                        controller: seatBerthController,
                        isRequired: true,
                      ),
                      SizedBox(height: 2.h),

                      // Service Type Dropdown
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FieldLabelTextView(
                            labelText: "Service Type",
                            isRequired: true,
                          ),
                          SizedBox(height: 0.5.h),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 3.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2.5.w),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 0.4.w,
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedServiceType,
                                isExpanded: true,
                                hint: Text("Select service type",
                                    style: TextStyle(
                                        fontSize: 12.5.sp,
                                        color: Colors.grey)),
                                items: serviceTypes
                                    .map((e) => DropdownMenuItem(
                                          value: e["value"],
                                          child: Text(e["label"]!,
                                              style: TextStyle(
                                                  fontSize: 12.5.sp)),
                                        ))
                                    .toList(),
                                onChanged: (val) {
                                  setState(() => selectedServiceType = val);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      CustomTextField(
                        hintText: "Describe your issue (optional)",
                        labelText: "Description",
                        controller: descriptionController,
                        maxLines: 3,
                      ),
                      SizedBox(height: 1.5.h),
                      CustomTextField(
                        hintText: "Your name (optional)",
                        labelText: "Passenger Name",
                        controller: passengerNameController,
                      ),
                      SizedBox(height: 2.h),
                      CustomTextField(
                        hintText: "Phone number (optional)",
                        labelText: "Passenger Phone",
                        controller: passengerPhoneController,
                        textInputType: TextInputType.phone,
                      ),
                      SizedBox(height: 3.h),
                      CustomButton(
                        text: "Submit Request",
                        onPressed: _isSubmitting ? null : _submitRequest,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 3.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
