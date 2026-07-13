import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chethanafm/utils/theme/app_colors.dart';
import 'package:chethanafm/widgets/common/custom_button.dart';
import 'package:chethanafm/widgets/common/custom_text_field.dart';

import 'package:chethanafm/utils/validations.dart';

import 'package:chethanafm/viewmodels/auth_viewmodel.dart';
import 'package:chethanafm/repo/api_state.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:chethanafm/views/login_view.dart';
import 'package:chethanafm/views/signup_view.dart';

class LoginDialog extends StatefulWidget {
  final VoidCallback onRegisterRequested;
  const LoginDialog({super.key, required this.onRegisterRequested});

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 10,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome back!",
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Sign in to interact with RJs and send requests.",
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _emailController,
                label: "Email Address",
                hint: "Enter your email",
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (val) =>
                    val.isValidEmail ? null : "Please enter a valid email",
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: "Send OTP",
                isLoading: authViewModel.isLoading,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final email = _emailController.text.trim();
                    authViewModel.login("+91", "", "", (result) {
                      if (result.status == Status.success) {
                        final data = jsonDecode(result.data);
                        final userId = data['data']['id'];
                        Navigator.of(context).pop(); // Close Login
                        _showOtpDialog(context, email, userId, "login");
                      } else {
                        _showSnackBar(context, result.error.isNotEmpty ? result.error : "Login failed");
                      }
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "New to Chethana FM? ",
                    style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      widget.onRegisterRequested();
                    },
                    child: Text(
                      "Register Now",
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondaryColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterDialog extends StatefulWidget {
  final VoidCallback onLoginRequested;
  const RegisterDialog({super.key, required this.onLoginRequested});

  @override
  State<RegisterDialog> createState() => _RegisterDialogState();
}

class _RegisterDialogState extends State<RegisterDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 10,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Create Account",
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Sign up to set program favorites and request songs.",
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _nameController,
                label: "Full Name",
                hint: "Enter your full name",
                prefixIcon: Icons.person_outline,
                validator: (val) =>
                    val != null && val.trim().length >= 3 ? null : "Enter valid name (min 3 chars)",
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _emailController,
                label: "Email Address",
                hint: "Enter your email",
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (val) =>
                    val.isValidEmail ? null : "Please enter a valid email",
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: "Register",
                isLoading: authViewModel.isLoading,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final name = _nameController.text.trim();
                    final email = _emailController.text.trim();
                    authViewModel.signup(email, name, (result) {
                      if (result.status == Status.success) {
                        final data = jsonDecode(result.data);
                        final userId = data['data']['id'];
                        Navigator.of(context).pop(); // Close Register
                        _showOtpDialog(context, email, userId, "register");
                      } else {
                        _showSnackBar(context, result.error.isNotEmpty ? result.error : "Registration failed");
                      }
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      widget.onLoginRequested();
                    },
                    child: Text(
                      "Login",
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondaryColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class OtpVerifyDialog extends StatefulWidget {
  final String email;
  final int tempUserId;
  final String type; // login or register

  const OtpVerifyDialog({
    super.key,
    required this.email,
    required this.tempUserId,
    required this.type,
  });

  @override
  State<OtpVerifyDialog> createState() => _OtpVerifyDialogState();
}

class _OtpVerifyDialogState extends State<OtpVerifyDialog> {
  final TextEditingController _otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 10,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Verify Email",
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "We've sent a 4-digit code to ${widget.email}. Please check spam if not received.",
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PinCodeTextField(
                  autofocus: true,
                  controller: _otpController,
                  highlight: true,
                  highlightColor: AppColors.primaryColor,
                  defaultBorderColor: AppColors.borderColor,
                  maxLength: 4,
                  pinBoxWidth: 46,
                  pinBoxHeight: 46,
                  pinBoxDecoration: ProvidedPinBoxDecoration.defaultPinBoxDecoration,
                  pinBoxRadius: 10,
                  pinTextStyle: GoogleFonts.outfit(fontSize: 18.0, fontWeight: FontWeight.bold),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              text: "Verify",
              isLoading: authViewModel.isLoading,
              onPressed: () {
                final otp = _otpController.text.trim();
                if (otp.length == 4) {
                  authViewModel.verifyOtp(widget.email, widget.tempUserId, otp, widget.type, (result) {
                    if (result.status == Status.success) {
                      Navigator.of(context).pop(); // Close OTP
                      _showSnackBar(
                        context,
                        widget.type == "register"
                            ? "Account created successfully!"
                            : "Signed in successfully!",
                        isError: false,
                      );
                    } else {
                      _showSnackBar(context, result.error.isNotEmpty ? result.error : "Invalid OTP");
                    }
                  });
                } else {
                  _showSnackBar(context, "Please enter a 4-digit code");
                }
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Didn't receive code? ",
                  style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary),
                ),
                GestureDetector(
                  onTap: () {
                    authViewModel.resendOtp(widget.email, (result) {
                      _showSnackBar(context, "Code resent successfully!", isError: false);
                    });
                  },
                  child: Text(
                    "Resend Code",
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondaryColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// --- Helper Functions to show Dialogs ---

void _showOtpDialog(BuildContext context, String email, int tempUserId, String type) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => OtpVerifyDialog(
      email: email,
      tempUserId: tempUserId,
      type: type,
    ),
  );
}

void triggerLoginDialog(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const LoginView()),
  );
}

void triggerRegisterDialog(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const SignupView()),
  );
}

void _showSnackBar(BuildContext context, String message, {bool isError = true}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.redAccent : Colors.green,
    ),
  );
}
