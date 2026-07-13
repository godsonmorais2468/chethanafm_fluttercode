import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chethanafm/utils/theme/app_colors.dart';
import 'package:chethanafm/widgets/common/custom_button.dart';
import 'package:chethanafm/widgets/common/custom_text_field.dart';
import 'package:chethanafm/views/login_view.dart';
import 'package:chethanafm/widgets/common/custom_toast.dart';
import 'package:chethanafm/viewmodels/auth_viewmodel.dart';
import 'package:chethanafm/repo/api_state.dart';

class ResetPasswordView extends StatefulWidget {
  final String countryCode;
  final String phoneNumber;
  final String securityAnswer;

  const ResetPasswordView({
    super.key,
    required this.countryCode,
    required this.phoneNumber,
    required this.securityAnswer,
  });

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
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
                        child: Icon(Icons.lock_reset, size: 56, color: AppColors.primaryColor),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "CHETHANA FM 90.8",
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryColor,
                          letterSpacing: 1.2,
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
                        const SizedBox(height: 20),
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
                          validator: (val) =>
                              val != null && val.trim().length >= 6 ? null : "Password must be at least 6 characters",
                        ),
                        const SizedBox(height: 16),
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
                            if (val == null || val.trim().length < 6) {
                              return "Password must be at least 6 characters";
                            }
                            if (val != _passwordController.text) {
                              return "Passwords do not match";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        PrimaryButton(
                          text: "Reset Password",
                          isLoading: authViewModel.isLoading,
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              authViewModel.resetPassword(
                                widget.countryCode,
                                widget.phoneNumber,
                                widget.securityAnswer,
                                _passwordController.text.trim(),
                                _confirmPasswordController.text.trim(),
                                (result) {
                                  if (result.status == Status.success) {
                                    CustomToast.show(
                                      context,
                                      "Password reset successfully! Please login again.",
                                      isError: false,
                                    );
                                    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                                      MaterialPageRoute(builder: (_) => const LoginView()),
                                      (route) => false,
                                    );
                                  } else {
                                    CustomToast.show(
                                      context,
                                      result.error ?? 'Error resetting password.',
                                      isError: true,
                                    );
                                  }
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
