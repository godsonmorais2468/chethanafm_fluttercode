import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chethanafm/utils/theme/app_colors.dart';

class RadioProgramCard extends StatelessWidget {
  final String title;
  final String rj;
  final String start;
  final String end;
  final String image;
  final String details;
  final bool isStarred;
  final VoidCallback onStarPressed;

  const RadioProgramCard({
    super.key,
    required this.title,
    required this.rj,
    required this.start,
    required this.end,
    required this.image,
    required this.details,
    required this.isStarred,
    required this.onStarPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 15,
            offset: Offset(0, 6),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      image: DecorationImage(
                        image: NetworkImage(image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.mic, size: 14, color: AppColors.secondaryColor),
                            const SizedBox(width: 4),
                            Text(
                              rj,
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 14, color: AppColors.accentColor),
                            const SizedBox(width: 4),
                            Text(
                              "$start - $end",
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onStarPressed,
                    icon: Icon(
                      isStarred ? Icons.star_rounded : Icons.star_border_rounded,
                      color: isStarred ? Colors.amber : AppColors.textSecondary.withOpacity(0.6),
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
            if (details.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                color: AppColors.backgroundColor,
                child: Text(
                  details,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }
}


