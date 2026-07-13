import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chethanafm/utils/theme/app_colors.dart';
import 'package:chethanafm/widgets/common/custom_app_bar.dart';

class TermsView extends StatelessWidget {
  const TermsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          CustomSliverAppBar(
            title: "Terms & Conditions",
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 28),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Terms & Conditions",
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Last Updated: January 1, 2026",
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildText("Welcome to our application. By accessing or using this app, you agree to comply with and be bound by the following Terms & Conditions. Please read them carefully before using the services."),
                  const SizedBox(height: 24),
                  _buildSectionTitle("1. Acceptance of Terms"),
                  _buildText("By creating an account, accessing, or using this application, you acknowledge that you have read, understood, and agreed to these Terms & Conditions. If you do not agree with any part of these terms, please discontinue using the application."),
                  const SizedBox(height: 24),
                  _buildSectionTitle("2. User Account"),
                  _buildText("You are responsible for maintaining the confidentiality of your account credentials. You agree to provide accurate and complete information during registration and to update your information whenever necessary."),
                  const SizedBox(height: 24),
                  _buildSectionTitle("3. Acceptable Use"),
                  _buildText("You agree to use this application only for lawful purposes. You must not:"),
                  const SizedBox(height: 8),
                  _buildBulletPoint("Violate any applicable laws or regulations."),
                  _buildBulletPoint("Attempt to gain unauthorized access to any part of the application."),
                  _buildBulletPoint("Upload malicious software or harmful content."),
                  _buildBulletPoint("Interfere with the security or functionality of the application."),
                  _buildBulletPoint("Misuse or abuse the services provided."),
                  const SizedBox(height: 24),
                  _buildSectionTitle("4. Privacy"),
                  _buildText("Your personal information is collected and processed in accordance with our Privacy Policy. By using the application, you consent to the collection, storage, and processing of your information as described therein."),
                  const SizedBox(height: 24),
                  _buildSectionTitle("5. Intellectual Property"),
                  _buildText("All content, including text, graphics, logos, icons, software, and other materials within this application, is the property of the application owner unless otherwise stated and is protected by applicable intellectual property laws."),
                  const SizedBox(height: 24),
                  _buildSectionTitle("6. Service Availability"),
                  _buildText("We strive to provide uninterrupted access to our services; however, we do not guarantee continuous availability. Services may be temporarily unavailable due to maintenance, updates, or unforeseen technical issues."),
                  const SizedBox(height: 24),
                  _buildSectionTitle("7. Limitation of Liability"),
                  _buildText("To the maximum extent permitted by law, we shall not be liable for any direct, indirect, incidental, or consequential damages resulting from your use or inability to use the application."),
                  const SizedBox(height: 24),
                  _buildSectionTitle("8. Third-Party Services"),
                  _buildText("The application may contain links to third-party services or integrate third-party features. We are not responsible for the content, policies, or practices of any third-party services."),
                  const SizedBox(height: 24),
                  _buildSectionTitle("9. Account Suspension"),
                  _buildText("We reserve the right to suspend or terminate user accounts that violate these Terms & Conditions, engage in fraudulent activity, or misuse the application in any manner."),
                  const SizedBox(height: 24),
                  _buildSectionTitle("10. Updates to the Terms"),
                  _buildText("These Terms & Conditions may be updated periodically. Continued use of the application after changes become effective constitutes acceptance of the revised terms."),
                  const SizedBox(height: 24),
                  _buildSectionTitle("11. Governing Law"),
                  _buildText("These Terms & Conditions shall be governed by and interpreted in accordance with the applicable laws of your jurisdiction."),
                  const SizedBox(height: 24),
                  _buildSectionTitle("12. Contact Information"),
                  _buildText("If you have any questions regarding these Terms & Conditions, please contact our support team through the application's Help & Support section."),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Acknowledgement"),
                  _buildText("By continuing to use this application, you acknowledge that you have read, understood, and agreed to these Terms & Conditions."),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildText(String text) {
    return Text(
      text,
      style: GoogleFonts.outfit(
        fontSize: 14,
        color: AppColors.textSecondary,
        height: 1.6,
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: AppColors.secondaryColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
