import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chethanafm/utils/theme/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: actions,
      backgroundColor: AppColors.primaryColor,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);
}


class CustomSliverAppBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool pinned;
  final bool floating;
  final bool snap;

  const CustomSliverAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.pinned = true,
    this.floating = true,
    this.snap = false,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      leading: leading,
      pinned: pinned,
      floating: floating,
      snap: snap,
      expandedHeight: 180.0,
      backgroundColor: AppColors.primaryColor,
      shape: const ContinuousRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          title,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              const Shadow(
                color: Colors.black54,
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?q=80&w=1000&auto=format&fit=crop",
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    AppColors.primaryColor.withOpacity(0.85),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: actions,
    );
  }
}


