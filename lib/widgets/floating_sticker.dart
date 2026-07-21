import 'dart:math' as math;
import 'package:flutter/material.dart';

class FloatingSticker extends StatefulWidget {
  final Widget child;
  final double baseRotation; // In degrees
  final double floatDistance;
  final Duration duration;

  const FloatingSticker({
    super.key,
    required this.child,
    this.baseRotation = 0.0,
    this.floatDistance = 8.0,
    this.duration = const Duration(seconds: 7),
  });

  @override
  State<FloatingSticker> createState() => _FloatingStickerState();
}

class _FloatingStickerState extends State<FloatingSticker> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(
      begin: 0.0,
      end: widget.floatDistance,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _rotateAnimation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double baseRad = widget.baseRotation * math.pi / 180;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double currentRotation = baseRad + (_rotateAnimation.value * math.pi / 180);
        return Transform.translate(
          offset: Offset(0, -_floatAnimation.value),
          child: Transform.rotate(
            angle: currentRotation,
            child: widget.child,
          ),
        );
      },
    );
  }
}
