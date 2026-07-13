import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chethanafm/utils/theme/app_colors.dart';
import 'package:chethanafm/utils/images.dart';
import 'package:chethanafm/widgets/common/custom_button.dart';
import 'package:chethanafm/widgets/common/custom_text_field.dart';
import 'package:chethanafm/views/security_question_view.dart';
import 'package:chethanafm/widgets/common/custom_toast.dart';
import 'package:chethanafm/utils/validations.dart';
import 'package:chethanafm/viewmodels/auth_viewmodel.dart';
import 'package:chethanafm/repo/api_state.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthViewModel>().loadCountryCodes();
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
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
                const SizedBox(height: 40),
                // Logo
                Center(
                  child: Image.asset(
                    Images.logo,
                    height: 160,
                  ),
                ),
                const SizedBox(height: 60),

                // Centered Title & Subtext
                Center(
                  child: Text(
                    "Forgot Password",
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    "Enter your phone number to recover your password.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 55),

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
                const SizedBox(height: 28),

                // Main Submit Button (Gradient)
                PrimaryButton(
                  text: "Continue".toUpperCase(),
                  isLoading: authViewModel.isLoading,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1DA1D8), Color(0xFF0B2C7A)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final countryCode = authViewModel.selectedCountryCode ?? "+91";
                      final phone = _phoneController.text.trim();
                      
                      authViewModel.getSecurityQuestion(countryCode, phone, (result) {
                        if (result.status == Status.success) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SecurityQuestionView(
                                countryCode: countryCode,
                                phoneNumber: phone,
                                questionText: result.data['question_text'] ?? '',
                              ),
                            ),
                          );
                        } else {
                          CustomToast.show(
                            context,
                            result.error ?? 'Error retrieving security question',
                            isError: true,
                          );
                        }
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
