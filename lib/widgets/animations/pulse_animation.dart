import 'package:flutter/material.dart';
import 'package:chethanafm/utils/theme/app_colors.dart';

class PulsatingPlayButton extends StatefulWidget {
  final bool isPlaying;
  final VoidCallback onTap;

  const PulsatingPlayButton({
    super.key,
    required this.isPlaying,
    required this.onTap,
  });

  @override
  State<PulsatingPlayButton> createState() => _PulsatingPlayButtonState();
}


class _PulsatingPlayButtonState extends State<PulsatingPlayButton> with SingleTickerProviderStateMixin {
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
  void didUpdateWidget(covariant PulsatingPlayButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.value = 0.0;
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
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.secondaryColor,
              boxShadow: [
                if (widget.isPlaying)
                  BoxShadow(
                    color: AppColors.secondaryColor.withOpacity(0.5 + (_controller.value * 0.3)),
                    blurRadius: 20 + (_controller.value * 10),
                    spreadRadius: 5 + (_controller.value * 5),
                  )
                else
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
              ],
              border: Border.all(
                color: widget.isPlaying ? AppColors.secondaryColor.withOpacity(0.8) : Colors.transparent,
                width: 2,
              ),
            ),
            child: Icon(
              widget.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 40,
            ),
          );
        },
      ),
    );
  }
}


