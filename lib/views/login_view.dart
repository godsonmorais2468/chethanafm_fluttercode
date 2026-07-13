import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chethanafm/utils/theme/app_colors.dart';
import 'package:chethanafm/widgets/common/custom_button.dart';
import 'package:chethanafm/widgets/common/custom_text_field.dart';

import 'package:chethanafm/utils/images.dart';
import 'package:chethanafm/utils/validations.dart';

import 'package:chethanafm/viewmodels/auth_viewmodel.dart';
import 'package:chethanafm/repo/api_state.dart';
import 'package:chethanafm/views/dashboard_view.dart';
// To reuse FullScreenWebView
// To show triggerRegisterDialog / OtpVerifyDialog
import 'package:chethanafm/views/signup_view.dart';
import 'package:chethanafm/views/forgot_password_view.dart';
import 'package:chethanafm/widgets/common/custom_toast.dart';

class LoginView extends StatefulWidget {
  final bool isFirstLaunch;
  const LoginView({super.key, this.isFirstLaunch = false});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final bool _isOtpMode = false;
  bool _isPhoneOtp = false; // toggle between Email OTP and Phone OTP
  bool _otpSent = false;
  final int _tempUserId = 999; // Mock user id for OTP flow
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthViewModel>().loadCountryCodes();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderColor,
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  "Login",
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 3,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF28F00), // Orange underline for active tab
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(3),
                      topRight: Radius.circular(3),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, anim1, anim2) => const SignupView(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
              child: Column(
                children: [
                  Text(
                    "Signup",
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 3,
                    color: Colors.transparent,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 50),
                // Logo
                Center(
                  child: Image.asset(
                    Images.logo,
                    height: 160,
                  ),
                ),
                const SizedBox(height: 60),

                // Custom Tab Bar
                _buildTabBar(context),
                const SizedBox(height: 60),

                // Welcome Header (Conditional)
                if (widget.isFirstLaunch || _isOtpMode) ...[
                  Text(
                    _isOtpMode ? "OTP Login" : "Welcome",
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isOtpMode
                        ? "Select verification method and enter the code."
                        : "Please sign in to continue using Chethana FM.",
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],

                // Form Fields Conditional Switch
                if (!_isOtpMode) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 120,
                        child: DropdownButtonFormField<String>(
                          initialValue: authViewModel.selectedCountryCode,
                          hint: Text(
                            "Code",
                            style: GoogleFonts.outfit(
                              color: AppColors.textSecondary.withOpacity(0.6),
                              fontSize: 14,
                            ),
                          ),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.borderColor.withOpacity(0.8)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.borderColor.withOpacity(0.8)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AppColors.secondaryColor, width: 2),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                            ),
                          ),
                          items: authViewModel.countryCodes.map((c) {
                            return DropdownMenuItem<String>(
                              value: c.code,
                              child: Text(
                                "${c.flagEmoji} ${c.country} (${c.code})",
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            );
                          }).toList(),
                          selectedItemBuilder: (BuildContext context) {
                            return authViewModel.countryCodes.map<Widget>((c) {
                              return Text(
                                "${c.flagEmoji} ${c.code}",
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              );
                            }).toList();
                          },
                          onChanged: (val) {
                            if (val != null) {
                              authViewModel.selectedCountryCode = val;
                            }
                          },
                          validator: (val) => val == null ? "Required" : null,
                          isExpanded: false,
                          dropdownColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          controller: _phoneController,
                          label: "Phone Number",
                          hint: "Phone Number",
                          keyboardType: TextInputType.phone,
                          showLabel: false,
                          showPrefixIcon: false,
                          borderRadius: 8,
                          borderColor: AppColors.borderColor.withOpacity(0.8),
                          validator: (val) => validatePhoneNumber(val, authViewModel.selectedCountryCode),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _passwordController,
                    label: "Password",
                    hint: "Password",
                    obscureText: _obscurePassword,
                    showLabel: false,
                    showPrefixIcon: false,
                    borderRadius: 8,
                    borderColor: AppColors.borderColor.withOpacity(0.8),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return "Please enter password";
                      }
                      if (val.trim().length < 6) {
                        return "Password must be at least 6 characters";
                      }
                      return null;
                    },
                  ),
                ] else ...[
                  // OTP Login Mode (Email or Phone number toggle)
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text("Email OTP"),
                        selected: !_isPhoneOtp,
                        selectedColor: AppColors.primaryColor,
                        backgroundColor: AppColors.lightGrey,
                        labelStyle: GoogleFonts.outfit(
                          color: !_isPhoneOtp ? Colors.white : AppColors.textPrimary,
                          fontSize: 13,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _isPhoneOtp = false;
                              _otpSent = false;
                            });
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text("Phone OTP"),
                        selected: _isPhoneOtp,
                        selectedColor: AppColors.primaryColor,
                        backgroundColor: AppColors.lightGrey,
                        labelStyle: GoogleFonts.outfit(
                          color: _isPhoneOtp ? Colors.white : AppColors.textPrimary,
                          fontSize: 13,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _isPhoneOtp = true;
                              _otpSent = false;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (!_isPhoneOtp) ...[
                    CustomTextField(
                      controller: _emailController,
                      label: "Email Address",
                      hint: "Email Address",
                      keyboardType: TextInputType.emailAddress,
                      showLabel: false,
                      showPrefixIcon: false,
                      borderRadius: 8,
                      borderColor: AppColors.borderColor.withOpacity(0.8),
                      validator: (val) => val.isValidEmail ? null : "Please enter a valid email",
                    ),
                  ] else ...[
                    CustomTextField(
                      controller: _phoneController,
                      label: "Phone Number",
                      hint: "Phone Number",
                      keyboardType: TextInputType.phone,
                      showLabel: false,
                      showPrefixIcon: false,
                      borderRadius: 8,
                      borderColor: AppColors.borderColor.withOpacity(0.8),
                      validator: (val) => validatePhoneNumber(val, authViewModel.selectedCountryCode),
                    ),
                  ],
                  if (_otpSent) ...[
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _otpController,
                      label: "OTP Code",
                      hint: "Enter 4-digit code",
                      keyboardType: TextInputType.number,
                      showLabel: false,
                      showPrefixIcon: false,
                      borderRadius: 8,
                      borderColor: AppColors.borderColor.withOpacity(0.8),
                      validator: (val) => val != null && val.trim().length == 4 ? null : "Enter 4 digit code",
                    ),
                  ],
                ],

                const SizedBox(height: 32),

                // Main Submit Button (Gradient)
                PrimaryButton(
                  text: (_isOtpMode ? (_otpSent ? "Verify & Log In" : "Send Verification Code") : "Login").toUpperCase(),
                  isLoading: authViewModel.isLoading,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1DA1D8), Color(0xFF0B2C7A)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (!_isOtpMode) {
                        // Phone Password login
                        authViewModel.login(
                          authViewModel.selectedCountryCode ?? "+91",
                          _phoneController.text.trim(),
                          _passwordController.text.trim(),
                          (result) {
                            if (result.status == Status.success) {
                              CustomToast.show(
                                context,
                                "Logged in successfully!",
                                isError: false,
                              );
                              _navigateToDashboard();
                            } else {
                              CustomToast.show(
                                context,
                                result.error,
                                isError: true,
                              );
                            }
                          },
                        );
                      } else {
                        // OTP login flow
                        if (!_otpSent) {
                          setState(() {
                            _otpSent = true;
                          });
                          CustomToast.show(
                            context,
                            "Verification OTP code sent!",
                            isError: false,
                          );
                        } else {
                          // Verify
                          final identifier = _isPhoneOtp
                              ? _phoneController.text
                              : _emailController.text;
                          authViewModel.verifyOtp(
                            _isPhoneOtp ? "phone@mock.com" : identifier,
                            _tempUserId,
                            _otpController.text.trim(),
                            "login",
                            (result) {
                              if (result.status == Status.success) {
                                CustomToast.show(
                                  context,
                                  "Logged in successfully!",
                                  isError: false,
                                );
                                _navigateToDashboard();
                              } else {
                                CustomToast.show(
                                  context,
                                  result.error,
                                  isError: true,
                                );
                              }
                            },
                          );
                        }
                      }
                    }
                  },
                ),
                const SizedBox(height: 20),

                // Center "Forgot Password?" link (if not in OTP mode)
                if (!_isOtpMode) ...[
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordView(),
                          ),
                        );
                      },
                      child: Text(
                        "Forgot Password?",
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFF28F00), // Orange accent color
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                const SizedBox(height: 32),

                // Register Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textSecondary),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, anim1, anim2) => const SignupView(),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                      },
                      child: Text(
                        "Sign Up",
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondaryColor,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }



  void _navigateToDashboard() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const DashboardView()),
      (route) => false,
    );
  }
}
