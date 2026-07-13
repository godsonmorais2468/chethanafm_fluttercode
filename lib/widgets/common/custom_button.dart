import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chethanafm/utils/theme/app_colors.dart';

class PrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color? color;
  final Gradient? gradient;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.color,
    this.gradient,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}


class _PrimaryButtonState extends State<PrimaryButton> with SingleTickerProviderStateMixin {
  late double _scale;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.05,
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _controller.value;
    final shadowColor = widget.gradient != null
        ? const Color(0xFF0C466D).withOpacity(0.25)
        : (widget.color ?? AppColors.primaryColor).withOpacity(0.3);

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.isLoading ? null : widget.onPressed,
      child: Transform.scale(
        scale: _scale,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: widget.gradient != null ? null : (widget.color ?? AppColors.primaryColor),
            gradient: widget.gradient,
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    widget.text,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}


class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? borderColor;
  final Color? textColor;

  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.borderColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: textColor ?? AppColors.primaryColor,
        side: BorderSide(color: borderColor ?? AppColors.primaryColor, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// --- Inputs ---


