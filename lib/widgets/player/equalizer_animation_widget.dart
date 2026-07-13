import 'package:flutter/material.dart';
import 'package:chethanafm/utils/theme/app_colors.dart';

class AnimatedWaveform extends StatefulWidget {
  final bool isPlaying;

  const AnimatedWaveform({super.key, required this.isPlaying});

  @override
  State<AnimatedWaveform> createState() => _AnimatedWaveformState();
}


class _AnimatedWaveformState extends State<AnimatedWaveform> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  final int barCount = 12;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      barCount,
      (index) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 400 + (index * 150)),
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 8.0, end: 40.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    _updateState();
  }

  void _updateState() {
    if (widget.isPlaying) {
      for (var controller in _controllers) {
        controller.repeat(reverse: true);
      }
    } else {
      for (var controller in _controllers) {
        controller.stop();
      }
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedWaveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPlaying != widget.isPlaying) {
      _updateState();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45, // Fixed height prevents shifting of layout below
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(barCount, (index) {
          return AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 5,
                height: _animations[index].value,
                decoration: BoxDecoration(
                  color: AppColors.secondaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

// --- Glassmorphism ---


