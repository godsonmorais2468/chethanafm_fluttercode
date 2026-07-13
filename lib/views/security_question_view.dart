import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chethanafm/utils/theme/app_colors.dart';
import 'package:chethanafm/widgets/common/custom_button.dart';
import 'package:chethanafm/widgets/common/custom_text_field.dart';
import 'package:chethanafm/views/reset_password_view.dart';
import 'package:chethanafm/widgets/common/custom_toast.dart';
import 'package:chethanafm/viewmodels/auth_viewmodel.dart';
import 'package:chethanafm/repo/api_state.dart';

class SecurityQuestionView extends StatefulWidget {
  final String countryCode;
  final String phoneNumber;
  final String questionText;

  const SecurityQuestionView({
    super.key,
    required this.countryCode,
    required this.phoneNumber,
    required this.questionText,
  });

  @override
  State<SecurityQuestionView> createState() => _SecurityQuestionViewState();
}

class _SecurityQuestionViewState extends State<SecurityQuestionView> {
  final _answerController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _answerController.dispose();
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
                        child: Icon(Icons.security, size: 56, color: AppColors.primaryColor),
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
                            "Security Question",
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.questionText,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          controller: _answerController,
                          label: "Your Answer",
                          hint: "Enter security answer",
                          prefixIcon: Icons.lock_outline,
                          keyboardType: TextInputType.text,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return "Please enter your answer";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        PrimaryButton(
                          text: "Verify",
                          isLoading: authViewModel.isLoading,
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              final answer = _answerController.text.trim();
                              authViewModel.verifySecurityAnswer(
                                widget.countryCode,
                                widget.phoneNumber,
                                answer,
                                (result) {
                                  if (result.status == Status.success) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ResetPasswordView(
                                          countryCode: widget.countryCode,
                                          phoneNumber: widget.phoneNumber,
                                          securityAnswer: answer,
                                        ),
                                      ),
                                    );
                                  } else {
                                    CustomToast.show(
                                      context,
                                      result.error ?? 'Security answer is incorrect.',
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
