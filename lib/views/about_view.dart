import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:chethanafm/utils/theme/app_colors.dart';
import 'package:chethanafm/widgets/common/custom_app_bar.dart';

import 'package:chethanafm/utils/images.dart';

import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';
import 'package:chethanafm/viewmodels/auth_viewmodel.dart';
import 'package:chethanafm/views/login_view.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  void _openWebView(BuildContext context, String url, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenWebView(url: url, title: title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          CustomSliverAppBar(
            title: "About Us",
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 28),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Station Header Hero
                  FadeInDown(
                    duration: const Duration(milliseconds: 500),
                    child: Center(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: const [
                                BoxShadow(
                                  color: AppColors.shadow,
                                  blurRadius: 15,
                                  offset: Offset(0, 8),
                                )
                              ],
                            ),
                            child: Image.asset(Images.logo, height: 90),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "CHETHANA FM 90.8",
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          Text(
                            "Community Radio Station",
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // About Section Card
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    child: _buildInfoCard(
                      context,
                      title: "About Us",
                      icon: Icons.info_outline_rounded,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Chethana FM 90.8 is a prominent community radio station based in Kayamkulam, Alappuzha district, Kerala, India. It is operated and managed by the Chethana Integrated Development Society.",
                            style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "The station acts as a powerful local voice with a strong focus on community empowerment and social development.",
                            style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Key Highlights Card
                  FadeInUp(
                    delay: const Duration(milliseconds: 100),
                    child: _buildInfoCard(
                      context,
                      title: "Key Highlights",
                      icon: Icons.stars_rounded,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Local Coverage",
                            style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Operating in the heart of Kayamkulam, the station effectively covers a 24 km radius. This footprint allows them to stay directly connected with 25 schools, 15 health centers, and 26 government offices.",
                            style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Target Audience",
                            style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "The programming is specifically curated to serve and enrich the lives of diverse, local community groups, including:",
                            style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                          ),
                          const SizedBox(height: 8),
                          _buildBulletPoint("Farmers and Fishermen"),
                          _buildBulletPoint("Housewives"),
                          _buildBulletPoint("Students and children"),
                          _buildBulletPoint("Unemployed youth"),
                          _buildBulletPoint("The general public"),
                          const SizedBox(height: 16),
                          Text(
                            "Social Mission",
                            style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "As a community radio station, Chethana FM 90.8 is dedicated to uplifting marginalized groups, providing crucial real-time disaster updates, spreading anti-drug awareness, and delivering valuable educational knowledge to its listeners.",
                            style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, {required String title, required IconData icon, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 15,
            offset: Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryColor, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const Divider(color: AppColors.borderColor, height: 24),
          child,
        ],
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
              style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.secondaryColor, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPortalButton(BuildContext context, {required IconData icon, required String label, required String url}) {
    return Column(
      children: [
        InkWell(
          onTap: () => _openWebView(context, url, label),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.secondaryColor, size: 24),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
        )
      ],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    return Drawer(
      child: Container(
        color: AppColors.backgroundColor,
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: AppColors.primaryColor,
                image: DecorationImage(
                  image: NetworkImage(
                    "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?q=80&w=1000&auto=format&fit=crop",
                  ),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black54,
                    BlendMode.darken,
                  ),
                ),
              ),
              accountName: Text(
                authViewModel.name,
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              accountEmail: Text(
                authViewModel.email,
                style: GoogleFonts.outfit(fontSize: 14),
              ),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: AppColors.accentColor),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.black),
              title: Text('Settings', style: GoogleFonts.outfit()),
              onTap: () {
                Navigator.pop(context); // Close drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: Text('Logout', style: GoogleFonts.outfit(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              onTap: () async {
                Navigator.pop(context); // Close drawer
                await authViewModel.logout();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginView()),
                    (route) => false,
                  );
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class FullScreenWebView extends StatefulWidget {
  final String url;
  final String title;

  const FullScreenWebView({super.key, required this.url, required this.title});

  @override
  State<FullScreenWebView> createState() => _FullScreenWebViewState();
}

class _FullScreenWebViewState extends State<FullScreenWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.secondaryColor),
            ),
        ],
      ),
    );
  }
}
