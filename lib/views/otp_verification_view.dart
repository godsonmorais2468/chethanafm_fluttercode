import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:chethanafm/utils/theme/app_colors.dart';
import 'package:chethanafm/widgets/common/custom_button.dart';
import 'package:chethanafm/widgets/common/custom_text_field.dart';
import 'package:chethanafm/widgets/common/custom_toast.dart';
import 'package:chethanafm/viewmodels/auth_viewmodel.dart';
import 'package:chethanafm/repo/api_state.dart';

class OtpVerificationView extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;

  const OtpVerificationView({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
  });

  @override
  State<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<OtpVerificationView> {
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  late String _verificationId;
  Timer? _timer;
  int _resendCountdown = 60;

  @override
  void initState() {
    super.initState();
    _verificationId = widget.verificationId;
    _startResendTimer();
  }

  void _startResendTimer() {
    _timer?.cancel();
    setState(() {
      _resendCountdown = 60;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo & Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.shadow,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            )
                          ],
                        ),
                        child: Icon(Icons.radio_rounded, size: 56, color: AppColors.primaryColor),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "CHETHANA FM 90.8",
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      Text(
                        "Voice of the Community",
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 35),

                // Container Card
                Card(
                  elevation: 8,
                  shadowColor: Colors.black.withOpacity(0.12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(color: AppColors.borderColor.withOpacity(0.5)),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Text(
                            "Reset Password",
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            "For phone: ${widget.phoneNumber}",
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // OTP Code Field
                        CustomTextField(
                          controller: _otpController,
                          label: "Verification Code",
                          hint: "Enter 6-digit OTP",
                          prefixIcon: Icons.security_rounded,
                          keyboardType: TextInputType.number,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return "Please enter the OTP code";
                            }
                            if (val.trim().length != 6) {
                              return "Verification code must be 6 digits";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: (_resendCountdown > 0 || authViewModel.isLoading)
                                ? null
                                : () {
                                    authViewModel.sendFirebaseOtp(
                                      widget.phoneNumber,
                                      (newVerificationId) {
                                        setState(() {
                                          _verificationId = newVerificationId;
                                        });
                                        _startResendTimer();
                                        CustomToast.show(
                                          context,
                                          "OTP code sent successfully.",
                                          isError: false,
                                        );
                                      },
                                      (String errorMsg) {
                                        CustomToast.show(
                                          context,
                                          errorMsg,
                                          isError: true,
                                        );
                                      },
                                    );
                                  },
                            child: Text(
                              _resendCountdown > 0
                                  ? "Resend OTP in ${_resendCountdown}s"
                                  : "Resend OTP",
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                color: _resendCountdown > 0
                                    ? AppColors.textSecondary
                                    : AppColors.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // New Password Field
                        CustomTextField(
                          controller: _passwordController,
                          label: "New Password",
                          hint: "Enter new password",
                          obscureText: _obscurePassword,
                          prefixIcon: Icons.lock_outline_rounded,
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
                              return "Please enter new password";
                            }
                            if (val.trim().length < 6) {
                              return "Password must be at least 6 characters";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Confirm Password Field
                        CustomTextField(
                          controller: _confirmPasswordController,
                          label: "Confirm Password",
                          hint: "Confirm new password",
                          obscureText: _obscureConfirmPassword,
                          prefixIcon: Icons.lock_outline_rounded,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return "Please confirm your password";
                            }
                            if (val.trim() != _passwordController.text.trim()) {
                              return "Passwords do not match";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        PrimaryButton(
                          text: "Submit",
                          isLoading: authViewModel.isLoading,
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              final otpCode = _otpController.text.trim();
                              final newPassword = _passwordController.text.trim();
                              final confirmPassword = _confirmPasswordController.text.trim();

                              // Step 1: Verify Firebase OTP
                              authViewModel.verifyFirebaseOtp(
                                _verificationId,
                                otpCode,
                                () {
                                  // OTP success, proceed to Step 2: Reset Password API
                                  authViewModel.resetPassword(
                                    "+91",
                                    widget.phoneNumber,
                                    "", // legacy otp flow
                                    newPassword,
                                    confirmPassword,
                                    (result) {
                                      if (result.status == Status.success) {
                                        CustomToast.show(
                                          context,
                                          "Password reset successfully. Please login again.",
                                          isError: false,
                                        );
                                        // Navigate back to login screen and clear history
                                        Navigator.of(context).popUntil((route) => route.isFirst);
                                      } else {
                                        CustomToast.show(
                                          context,
                                          result.error,
                                          isError: true,
                                        );
                                      }
                                    },
                                  );
                                },
                                (errorMsg) {
                                  CustomToast.show(
                                    context,
                                    errorMsg,
                                    isError: true,
                                  );
                                },
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
