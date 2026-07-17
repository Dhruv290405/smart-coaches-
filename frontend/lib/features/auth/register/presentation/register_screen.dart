import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/core/utils/image_utils.dart';
import 'package:smart_coach_new/core/utils/loader.dart';
import 'package:smart_coach_new/core/utils/toast_message_utils.dart';
import 'package:smart_coach_new/core/utils/utils.dart';
import 'package:smart_coach_new/core/utils/validators.dart';
import 'package:smart_coach_new/core/widgets/custom_button.dart';
import 'package:smart_coach_new/core/widgets/custom_text_field.dart';
import 'package:smart_coach_new/features/auth/register/presentation/bloc/register_bloc.dart';
import 'package:smart_coach_new/features/auth/register/presentation/bloc/register_event.dart';
import 'package:smart_coach_new/features/auth/register/presentation/bloc/register_state.dart';
import 'package:smart_coach_new/features/auth/register/presentation/registration_steps/identity_verification_step.dart';
import 'package:smart_coach_new/features/auth/register/presentation/registration_steps/personal_details_step.dart';
import 'package:smart_coach_new/features/auth/register/presentation/registration_steps/work_details_step.dart';
import 'package:smart_coach_new/routes/app_router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _step = 1;
  final _formKey = GlobalKey<FormState>();
  final _employeeIdController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _organizationNameController = TextEditingController();
  final _panAadhaarController = TextEditingController();
  final _companyIdController = TextEditingController();
  final _otpController = TextEditingController();
  String? selectedGender;
  bool isConfirmed = false;
  bool isAgreedToTerms = false;
  bool _isOtpSent = false;
  bool _isOtpVerified = false;
  bool _isSendingOtp = false;
  late RegisterBloc registerBloc;
  @override
  void initState() {
    super.initState();
    registerBloc = context.read<RegisterBloc>()
      ..add(LoadZonesDropdowns())
      ..add(LoadAllRoles());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 3.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6.w),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: Offset(2, 8),
              ),
            ],
          ),
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child:               BlocConsumer<RegisterBloc, RegisterState>(
                listener: (context, state) {
                  if (state.isSubmitting || state.isLoading) {
                    Loader.show();
                  } else {
                    Loader.dismiss();
                  }
                  if (state.errorList != null || state.errorMessage != null) {
                    Utils.showApiErrorMessageOrList(
                      context,
                      message: state.errorMessage,
                      errorList: state.errorList,
                    );
                  } else if (state.isOtpSent &&
                      !state.isOtpVerified &&
                      _step == 4) {
                    if (!_isOtpSent) {
                      _isOtpSent = true;
                      ToastMessageUtils.showMessage(
                        context,
                        'OTP sent to ${_mobileController.text}',
                      );
                    }
                  } else if (state.isOtpVerified && _step == 4) {
                    _isOtpVerified = true;
                    setState(() {});
                    ToastMessageUtils.showMessage(
                      context,
                      'OTP verified successfully',
                    );
                  } else if (!state.isSubmitting &&
                      (_step == 3 || _step == 4) &&
                      state.submissionSuccess) {
                    ToastMessageUtils.showMessage(
                      context,
                      state.successMessage,
                    );
                    Utils.showSimpleMessageDialog(
                      context,
                      'Registration Successful',
                      'Your registration has been submitted successfully. You will receive a confirmation email shortly.',
                      onTapButton: () {
                        if (registerBloc.prefs.token != null) {
                          context.go(AppRouter.dashboardRoute);
                        } else {
                          context.go(AppRouter.loginRoute);
                        }
                      },
                    );
                  }
                },
                builder: (context, state) {
                  return Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFE8F5FE),
                          ),
                          padding: EdgeInsets.all(1.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: 6.5.h,
                                width: 6.5.h,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(ImageUtils.pisolve),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Container(
                                // height: 1.5.h,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(ImageUtils.pisolveName),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          "Registration",
                          style: TextStyle(
                            fontSize: 19.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 2.5.h),
                          child: Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 1.5.h,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                    child: LinearProgressIndicator(
                                      value: (_step) / 4,
                                      backgroundColor: Color(0xFFE6E7EB),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        ColorConstants.blueColorDark,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                "$_step/4",
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Color(0xFF7F868E),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: ColorConstants.blueColorDark,
                              ),
                              padding: EdgeInsets.all(2.1.w),
                              child: Text(
                                "$_step",
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 1.5.w),
                            Text(
                              _getTitleText(),
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.h),
                        Expanded(child: _buildStep(context, state)),
                        SizedBox(height: 3.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _step > 1
                                ? SizedBox(
                                    height: 6.h,
                                    child: CustomButton(
                                      text: 'Previous',
                                      color: Color(0xFFF3F3F5),
                                      textColor: Colors.black,
                                      prefixIcon: Icons.arrow_back_ios_sharp,
                                      onPressed: () {
                                        setState(() {
                                          _step--;
                                        });
                                      },
                                    ),
                                  )
                                : Container(),
                            SizedBox(
                              child: CustomButton(
                                text: state.isSubmitting ? "Registering..." : (_step < 3 ? "Next" : (_step == 3 ? "Send OTP" : (_isOtpVerified ? "Register" : "Verify OTP"))),
                                suffixIcon: _step < 3
                                    ? Icons.arrow_forward_ios_sharp
                                    : null,
                                isDisabled: state.isSubmitting,
                                onPressed: state.isSubmitting ? null : () {
                                  if (_step == 1) {
                                    _doProcessForStep1(state);
                                  } else if (_step == 2) {
                                    _doProcessForStep2(state);
                                  } else if (_step == 3) {
                                    _doProcessForStep3(state);
                                  } else if (_step == 4 && _isOtpVerified) {
                                    _doSubmitRegistration();
                                  } else if (_step == 4 && !_isOtpVerified) {
                                    _doVerifyOtp();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getTitleText() {
    if (_step == 1) {
      return "Personal Details";
    } else if (_step == 2) {
      return "Work Details";
    } else if (_step == 3) {
      return "Identity Verification";
    } else {
      return "OTP Verification";
    }
  }

  Widget _buildStep(BuildContext context, RegisterState state) {
    switch (_step) {
      case 1:
        return PersonalDetailsStep(
          firstNameController: _firstNameController,
          lastNameController: _lastNameController,
          mobileController: _mobileController,
          emailController: _emailController,
          passwordController: _passwordController,
          selectedGender: selectedGender,
          registerRequest: registerBloc.state.registerRequest,
          onSelectGender: (String? mSelectedGender) {
            selectedGender = mSelectedGender;
          },
        );
      case 2:
        return WorkDetailsStep(
          state: state,
          organizationNameController: _organizationNameController,
          employeeIdController: _employeeIdController,
          companyIdController: _companyIdController,
        );
      case 3:
        return IdentityVerificationStep(
          panAadhaarController: _panAadhaarController,
          isConfirmed: isConfirmed,
          isAgreedToTerms: isAgreedToTerms,
          onChangeSelectedIdType: () {
            registerBloc.add(IdTypeToggled(!(state.isIdTypeIsPan)));
          },
          onCheckConfirm: (bool value) {
            isConfirmed = value;
            setState(() {});
          },
          onCheckAgreedToTerms: (bool value) {
            isAgreedToTerms = value;
            setState(() {});
          },
        );
      case 4:
        return _buildOtpStep();
      default:
        return Container();
    }
  }

  Widget _buildOtpStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'An OTP has been sent to ${_mobileController.text}',
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          if (registerBloc.state.otpCode != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(children: [
                const Text('Your OTP', style: TextStyle(fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 4),
                Text(
                  registerBloc.state.otpCode!,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                    letterSpacing: 4,
                  ),
                ),
              ]),
            ),
          ],
          const SizedBox(height: 24),
          const Text('Enter OTP', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          CustomTextField(
            controller: _otpController,
            hintText: 'Enter 6-digit OTP',
            textInputType: TextInputType.number,
            maxLength: 6,
          ),
          const SizedBox(height: 16),
          if (_isOtpVerified)
            const Row(children: [
              Icon(Icons.check_circle, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Text('OTP Verified', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
            ])
          else if (!_isOtpSent)
            const SizedBox()
          else
            Row(children: [
              const Icon(Icons.info_outline, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              const Text('Enter the OTP and tap Verify', style: TextStyle(color: Colors.orange)),
            ]),
        ],
      ),
    );
  }

  bool _doValidateStep1(
    String fName,
    String lName,
    String email,
    String password,
    String mobileNumber,
  ) {
    if (fName.isEmpty) {
      ToastMessageUtils.showMessage(context, 'Please enter first name');
      return false;
    } else if (lName.isEmpty) {
      ToastMessageUtils.showMessage(context, 'Please enter last name');
      return false;
    } else if (email.isEmpty || !Validators.isEmailValid(email)) {
      ToastMessageUtils.showMessage(
        context,
        'Please enter valid email address',
      );
      return false;
    } else if (Validators.validatePassword(password) != null) {
      ToastMessageUtils.showMessage(
        context,
        Validators.validatePassword(password),
      );
      return false;
    } else if (mobileNumber.isEmpty) {
      ToastMessageUtils.showMessage(context, 'Please enter mobile number');
      return false;
    } else if ((registerBloc.state.registerRequest.gender ?? '').isEmpty) {
      ToastMessageUtils.showMessage(context, 'Please select your gender');
      return false;
    } else {
      return true;
    }
  }

  bool _doValidateStep2(
    bool isOrganisationTypeIsContractor,
    String organizationName,
  ) {
    if (isOrganisationTypeIsContractor && organizationName.isEmpty) {
      ToastMessageUtils.showMessage(context, 'Please enter organization name');
      return false;
    } else if (registerBloc.state.registerRequest.organisationType == null) {
      ToastMessageUtils.showMessage(
        context,
        'Please select your organisation type',
      );
      return false;
    } else if (registerBloc.state.registerRequest.roleId == null) {
      ToastMessageUtils.showMessage(context, 'Please select your job role');
      return false;
    } else if (registerBloc.state.registerRequest.zoneId == null) {
      ToastMessageUtils.showMessage(context, 'Please select your zone');
      return false;
    } else if (registerBloc.state.registerRequest.divisionId == null) {
      ToastMessageUtils.showMessage(context, 'Please select your division');
      return false;
    } else if ((registerBloc.state.registerRequest.regionIdList ?? [])
        .isEmpty) {
      ToastMessageUtils.showMessage(context, 'Please select your region');
      return false;
    } else if (_isTrainOperatorRole() &&
        (registerBloc.state.registerRequest.trainIdList ?? []).isEmpty) {
      ToastMessageUtils.showMessage(context, 'Please select your train');
      return false;
    } else {
      return true;
    }
  }

  bool _isTrainOperatorRole() {
    final roleId = registerBloc.state.registerRequest.roleId;
    if (roleId == null) return false;

    final selectedRole = registerBloc.state.jobRoles.firstWhere(
      (role) => role.roleId == roleId,
      orElse: () => registerBloc.state.jobRoles.first,
    );

    return selectedRole.name?.toLowerCase() == 'train operator';
  }

  bool _doValidateStep3() {
    if (!isConfirmed) {
      ToastMessageUtils.showMessage(context, 'Please confirm your information');
      return false;
    } else if (!isAgreedToTerms) {
      ToastMessageUtils.showMessage(
        context,
        'Please confirm Terms & Condition',
      );
      return false;
    } else {
      return true;
    }
  }

  void _doProcessForStep1(RegisterState state) {
    String fName = _firstNameController.text.trim();
    String lName = _lastNameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String mobileNumber = _mobileController.text.trim();
    if (_doValidateStep1(fName, lName, email, password, mobileNumber)) {
      state.registerRequest.firstName = fName;
      state.registerRequest.lastName = lName;
      state.registerRequest.email = email;
      state.registerRequest.mobileNumber = mobileNumber;
      state.registerRequest.password = password;
      setState(() => _step++);
    }
  }

  void _doProcessForStep2(RegisterState state) {
    String organizationName = _organizationNameController.text.trim();
    String employeeId = _employeeIdController.text.trim();
    String companyId = _companyIdController.text.trim();
    bool isOrganisationTypeIsContractor = state.registerRequest
        .isOrganisationTypeIsContractor();
    if (_doValidateStep2(isOrganisationTypeIsContractor, organizationName)) {
      state.registerRequest.organisationName = organizationName;
      state.registerRequest.employeeId = employeeId;
      state.registerRequest.companyId = companyId;
      setState(() => _step++);
    }
  }

  void _doProcessForStep3(RegisterState state) {
    String panAadhaar = _panAadhaarController.text.trim();
    if (_doValidateStep3()) {
      if (panAadhaar.isNotEmpty) {
        if ((state.isIdTypeIsPan)) {
          state.registerRequest.panCardNo = panAadhaar;
          state.registerRequest.aadharNo = '';
        } else {
          state.registerRequest.aadharNo = panAadhaar;
          state.registerRequest.panCardNo = '';
        }
      }
      setState(() { _step = 4; _isOtpSent = false; _isOtpVerified = false; _otpController.clear(); });
      _sendOtp();
    }
  }

  void _sendOtp() async {
    final mobile = _mobileController.text.trim();
    registerBloc.add(SendOtp(mobile));
  }

  void _doVerifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      ToastMessageUtils.showMessage(context, 'Please enter a valid 6-digit OTP');
      return;
    }
    final mobile = _mobileController.text.trim();
    registerBloc.add(VerifyOtp(mobile, otp));
  }

  void _doSubmitRegistration() {
    registerBloc.add(SubmitRegister());
  }
}
