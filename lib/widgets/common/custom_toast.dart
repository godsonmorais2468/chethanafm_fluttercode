import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomToast extends StatefulWidget {
  final String message;
  final bool isError;
  final bool isWarning;
  final VoidCallback onDismiss;

  const CustomToast({
    super.key,
    required this.message,
    this.isError = false,
    this.isWarning = false,
    required this.onDismiss,
  });

  static void show(
    BuildContext context,
    String message, {
    bool isError = false,
    bool isWarning = false,
  }) {
    final overlayState = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16.h,
        left: 20.w,
        right: 20.w,
        child: Material(
          color: Colors.transparent,
          child: CustomToast(
            message: message,
            isError: isError,
            isWarning: isWarning,
            onDismiss: () {
              overlayEntry.remove();
            },
          ),
        ),
      ),
    );

    overlayState.insert(overlayEntry);
  }

  @override
  State<CustomToast> createState() => _CustomToastState();
}

class _CustomToastState extends State<CustomToast> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _yAnimation;
  late Animation<double> _opacityAnimation;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _yAnimation = Tween<double>(begin: -50, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    _dismissTimer = Timer(const Duration(seconds: 4), () {
      _dismiss();
    });
  }

  void _dismiss() {
    if (_controller.isAnimating) return;
    _controller.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color startColor;
    Color endColor;
    IconData icon;
    String title;

    if (widget.isError) {
      startColor = const Color(0xFFE11D48); // Crimson
      endColor = const Color(0xFFF43F5E); // Coral
      icon = Icons.error_outline_rounded;
      title = "Error Encountered";
    } else if (widget.isWarning) {
      startColor = const Color(0xFFD97706); // Amber
      endColor = const Color(0xFFF59E0B); // Gold
      icon = Icons.warning_amber_rounded;
      title = "Warning";
    } else {
      startColor = const Color(0xFF0D9488); // Teal
      endColor = const Color(0xFF10B981); // Emerald
      icon = Icons.check_circle_outline_rounded;
      title = "Success";
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _yAnimation.value),
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: _dismiss,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [startColor, endColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: startColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 28.w),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      widget.message,
                      style: GoogleFonts.outfit(
                        color: Colors.white.withOpacity(0.95),
                        fontWeight: FontWeight.w400,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Icon(Icons.close_rounded, color: Colors.white70, size: 18.w),
            ],
          ),
        ),
      ),
    );
  }
}
