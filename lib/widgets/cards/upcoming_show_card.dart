import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chethanafm/utils/theme/app_colors.dart';

import 'glass_card.dart';

class UpcomingShowCard extends StatelessWidget {
  final String showName;
  final String rjName;
  final String startsIn;

  const UpcomingShowCard({
    super.key,
    required this.showName,
    required this.rjName,
    required this.startsIn,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Upcoming Show",
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                showName,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                rjName,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: AppColors.secondaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              startsIn,
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Floating Widgets ---


