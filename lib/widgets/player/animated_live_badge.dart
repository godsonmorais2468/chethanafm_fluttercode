import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LiveBadge extends StatefulWidget {
  final bool isPlaying;
  const LiveBadge({super.key, required this.isPlaying});

  @override
  State<LiveBadge> createState() => _LiveBadgeState();
}


class _LiveBadgeState extends State<LiveBadge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    if (widget.isPlaying) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant LiveBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPlaying != widget.isPlaying) {
      if (widget.isPlaying) {
        _controller.repeat(reverse: true);
      } else {
        _controller.animateTo(0.0, duration: const Duration(milliseconds: 300));
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1 + (_controller.value * 0.2)),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.red.withOpacity(0.5 + (_controller.value * 0.5)), width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                "LIVE",
                style: GoogleFonts.outfit(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


