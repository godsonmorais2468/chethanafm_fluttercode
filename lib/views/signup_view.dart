import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chethanafm/utils/theme/app_colors.dart';
import 'package:chethanafm/utils/images.dart';
import 'package:chethanafm/widgets/common/custom_button.dart';
import 'package:chethanafm/widgets/common/custom_text_field.dart';

import 'package:chethanafm/utils/validations.dart';

import 'package:chethanafm/viewmodels/auth_viewmodel.dart';
import 'package:chethanafm/repo/api_state.dart';
import 'package:chethanafm/views/login_view.dart';
import 'package:chethanafm/views/dashboard_view.dart';
import 'package:chethanafm/widgets/common/custom_toast.dart';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _securityAnswerController = TextEditingController();
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _selectedSecurityQuestion;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVM = context.read<AuthViewModel>();
      authVM.loadCountryCodes();
      authVM.fetchSecurityQuestions();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _securityAnswerController.dispose();
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
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, anim1, anim2) => const LoginView(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
              child: Column(
                children: [
                  Text(
                    "Login",
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
          Expanded(
            child: Column(
              children: [
                Text(
                  "Signup",
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

                // Fields
                CustomTextField(
                  controller: _nameController,
                  label: "Full Name",
                  hint: "Full Name",
                  keyboardType: TextInputType.name,
                  showLabel: false,
                  showPrefixIcon: false,
                  borderRadius: 8,
                  borderColor: AppColors.borderColor.withOpacity(0.8),
                  validator: (val) => val != null && val.isNotEmpty ? null : "Please enter your name",
                ),
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
                DropdownButtonFormField<String>(
                  initialValue: _selectedSecurityQuestion,
                  hint: Text(
                    "Security Question",
                    style: GoogleFonts.outfit(
                      color: AppColors.textSecondary.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                  items: authViewModel.securityQuestions.map((q) {
                    return DropdownMenuItem<String>(
                      value: q['key'],
                      child: Text(
                        q['question'] ?? '',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedSecurityQuestion = val;
                    });
                  },
                  validator: (val) => val == null ? "Please select a security question" : null,
                  isExpanded: true,
                  dropdownColor: Colors.white,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _securityAnswerController,
                  label: "Security Answer",
                  hint: "Security Answer",
                  keyboardType: TextInputType.text,
                  showLabel: false,
                  showPrefixIcon: false,
                  borderRadius: 8,
                  borderColor: AppColors.borderColor.withOpacity(0.8),
                  validator: (val) => val != null && val.trim().isNotEmpty ? null : "Please enter a security answer",
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
                  validator: (val) =>
                      val != null && val.trim().length >= 6 ? null : "Password must be at least 6 characters",
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: "Confirm Password",
                  hint: "Confirm Password",
                  obscureText: _obscureConfirmPassword,
                  showLabel: false,
                  showPrefixIcon: false,
                  borderRadius: 8,
                  borderColor: AppColors.borderColor.withOpacity(0.8),
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
                const SizedBox(height: 32),

                // Main Submit Button (Gradient)
                PrimaryButton(
                  text: "Sign Up".toUpperCase(),
                  isLoading: authViewModel.isLoading,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1DA1D8), Color(0xFF0B2C7A)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Register flow
                      authViewModel.register(
                        _nameController.text.trim(),
                        authViewModel.selectedCountryCode ?? "+91",
                        _phoneController.text.trim(),
                        _passwordController.text.trim(),
                        _confirmPasswordController.text.trim(),
                        _selectedSecurityQuestion!,
                        _securityAnswerController.text.trim(),
                        (result) {
                          if (result.status == Status.success) {
                            CustomToast.show(
                              context,
                              "Account created successfully!",
                              isError: false,
                            );
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => const DashboardView()),
                              (route) => false,
                            );
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
                  },
                ),
                const SizedBox(height: 32),

                // Sign In Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textSecondary),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, anim1, anim2) => const LoginView(),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                      },
                      child: Text(
                        "Sign In",
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
}
