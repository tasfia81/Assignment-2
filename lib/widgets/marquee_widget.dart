import 'package:flutter/material.dart';

/// A continuous horizontal scrolling ticker/marquee widget.
class MarqueeWidget extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Color backgroundColor;
  final double height;
  final double speedMultiplier; // Default 1.0

  const MarqueeWidget({
    super.key,
    required this.text,
    required this.style,
    this.backgroundColor = Colors.transparent,
    this.height = 40.0,
    this.speedMultiplier = 1.0,
  });

  @override
  State<MarqueeWidget> createState() => _MarqueeWidgetState();
}

class _MarqueeWidgetState extends State<MarqueeWidget> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    
    // Slow down the scrolling speed (65 seconds per loop cycle by default)
    final int baseSeconds = (65 / widget.speedMultiplier).round();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: baseSeconds),
    )..addListener(() {
        if (_scrollController.hasClients) {
          final maxScrollExtent = _scrollController.position.maxScrollExtent;
          if (maxScrollExtent > 0) {
            final scrollPosition = _animationController.value * maxScrollExtent;
            _scrollController.jumpTo(scrollPosition);
          }
        }
      })..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Duplicate text to ensure continuous scrolling
    final String repeatedText = List.generate(15, (_) => widget.text).join('   ');

    return Container(
      color: widget.backgroundColor,
      height: widget.height,
      alignment: Alignment.center,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 1,
        itemBuilder: (context, index) {
          return Center(
            child: Text(
              repeatedText,
              style: widget.style,
            ),
          );
        },
      ),
    );
  }
}

