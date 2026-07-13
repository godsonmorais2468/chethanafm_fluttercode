import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../cards/glass_card.dart';
import 'equalizer_animation_widget.dart';

class FloatingMiniPlayer extends StatelessWidget {
  final String showName;
  final String rjName;
  final String imageUrl;
  final VoidCallback onPause;
  final bool isPlaying;

  const FloatingMiniPlayer({
    super.key,
    required this.showName,
    required this.rjName,
    required this.imageUrl,
    required this.onPause,
    required this.isPlaying,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: BorderRadius.circular(30),
      opacity: 0.25,
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(imageUrl),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      showName,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "LIVE",
                        style: GoogleFonts.outfit(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  rjName,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (isPlaying) const AnimatedWaveform(isPlaying: true),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.pause_rounded, color: Colors.white),
            onPressed: onPause,
          ),
        ],
      ),
    );
  }
}


