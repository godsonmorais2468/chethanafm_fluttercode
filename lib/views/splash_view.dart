import 'package:flutter/material.dart';
import 'package:chethanafm/utils/images.dart';
import 'package:chethanafm/utils/theme/app_colors.dart';

import 'package:chethanafm/views/login_view.dart';
import 'package:chethanafm/views/dashboard_view.dart';
import 'package:chethanafm/utils/helper.dart';
import 'package:chethanafm/services/secure_storage_service.dart';
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;

  @override
  void initState() {
    super.initState();

    // Animation Controllers for Logo overlay
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.elasticOut),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _fadeController.forward();
    
    // Ensure navigation happens if video doesn't play
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _navigateToDashboard();
      }
    });
  }

  void _navigateToDashboard() async {
    final prefs = await PrefHelper.getInstance();
    final secureStorage = SecureStorageService();
    
    bool isLoggedIn = prefs.getBoolean(PrefHelper.isLogin, false);
    String? token = await secureStorage.getToken();
    bool hasToken = token != null && token.isNotEmpty;

    bool hasLaunchedBefore = prefs.getBoolean("has_launched_before", false);
    bool isFirstLaunch = !hasLaunchedBefore;
    if (isFirstLaunch) {
      prefs.setBoolean("has_launched_before", true);
    }

    Widget nextScreen;
    if (!isLoggedIn) {
      nextScreen = LoginView(isFirstLaunch: isFirstLaunch);
    } else if (!hasToken) {
      nextScreen = LoginView(isFirstLaunch: isFirstLaunch);
    } else {
      nextScreen = const DashboardView();
    }

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _fadeController,
          builder: (context, child) {
            return Opacity(
              opacity: _logoOpacity.value,
              child: Transform.scale(
                scale: _logoScale.value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      Images.logo,
                      height: 220,
                    ),
                    const SizedBox(height: 24),
                    const SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                        strokeWidth: 3.0,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
