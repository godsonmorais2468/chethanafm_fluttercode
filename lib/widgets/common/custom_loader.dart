import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chethanafm/utils/theme/app_colors.dart';
import 'package:shimmer/shimmer.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 100,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}


class EmptyStateWidget extends StatelessWidget {
  final String text;

  const EmptyStateWidget({super.key, this.text = "No content available"});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.radio_button_off, size: 64, color: AppColors.textSecondary.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            text,
            style: GoogleFonts.outfit(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          )
        ],
      ),
    );
  }
}

// --- Dynamic Animations ---


