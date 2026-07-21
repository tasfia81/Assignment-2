import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import 'splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Premium Dark Theme Swipe Background
          const _ColorSwipeBackground(),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  // Burger Assembly Custom Painter
                  const SizedBox(
                    height: 250,
                    width: 250,
                    child: _BurgerAssemblyAnimator(),
                  ),
                  const SizedBox(height: 40.0),
                  // Loading phrases
                  Obx(() => Text(
                        controller.loadingText.value.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: AppTypography.goldLabel(
                          fontSize: 16.0,
                        ).copyWith(color: AppColors.white),
                      )),
                  const SizedBox(height: 24.0),
                  // Progress Loading bar
                  Container(
                    height: 6,
                    width: 200,
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    alignment: Alignment.centerLeft,
                    child: Obx(() => Container(
                          width: 200 * controller.progress.value,
                          decoration: BoxDecoration(
                            color: AppColors.gold,
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.gold.withOpacity(0.5),
                                blurRadius: 6,
                              )
                            ],
                          ),
                        )),
                  ),
                  const Spacer(),
                  // Branding details
                  Text(
                    'MUSTAV',
                    style: AppTypography.displayBold(
                      fontSize: 28.0,
                      color: AppColors.gold,
                    ),
                  ),
                  Text(
                    'ARTISAN SMASHED EXPERIENCE • EST. 2024',
                    style: AppTypography.caption(
                      fontSize: 10.0,
                      color: AppColors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorSwipeBackground extends StatefulWidget {
  const _ColorSwipeBackground();

  @override
  State<_ColorSwipeBackground> createState() => _ColorSwipeBackgroundState();
}

class _ColorSwipeBackgroundState extends State<_ColorSwipeBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _controller.forward();
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
        return Stack(
          children: [
            Container(color: AppColors.black),
            // Grey Swipe
            Transform.translate(
              offset: Offset(0, (1.0 - _controller.value) * MediaQuery.of(context).size.height),
              child: Container(color: AppColors.lightGrey),
            ),
            // Gold Swipe
            Transform.translate(
              offset: Offset(0, (1.0 - math.pow(_controller.value, 1.5)) * MediaQuery.of(context).size.height),
              child: Container(color: AppColors.gold.withOpacity(0.85)),
            ),
            // Dark Velvet Black Swipe
            Transform.translate(
              offset: Offset(0, (1.0 - math.pow(_controller.value, 2)) * MediaQuery.of(context).size.height),
              child: Container(color: AppColors.black),
            ),
          ],
        );
      },
    );
  }
}

class _BurgerAssemblyAnimator extends StatefulWidget {
  const _BurgerAssemblyAnimator();

  @override
  State<_BurgerAssemblyAnimator> createState() => _BurgerAssemblyAnimatorState();
}

class _BurgerAssemblyAnimatorState extends State<_BurgerAssemblyAnimator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _offsets;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    _offsets = List.generate(5, (index) {
      final double start = index * 0.15;
      final double end = start + 0.3;
      return Tween<double>(begin: -150.0, end: 0.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.bounceOut),
        ),
      );
    });
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
        return CustomPaint(
          painter: _BurgerPainter(
            topBunY: _offsets[0].value,
            lettuceY: _offsets[1].value,
            cheeseY: _offsets[2].value,
            pattyY: _offsets[3].value,
            bottomBunY: _offsets[4].value,
          ),
        );
      },
    );
  }
}

class _BurgerPainter extends CustomPainter {
  final double topBunY;
  final double lettuceY;
  final double cheeseY;
  final double pattyY;
  final double bottomBunY;

  _BurgerPainter({
    required this.topBunY,
    required this.lettuceY,
    required this.cheeseY,
    required this.pattyY,
    required this.bottomBunY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.width / 2;
    
    // Premium gold outlines
    final borderPaint = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Fillings - Sleek premium dark fills
    final darkBunPaint = Paint()..color = AppColors.surface;
    final darkPattyPaint = Paint()..color = AppColors.lightGrey;
    final goldCheesePaint = Paint()..color = AppColors.gold;
    final whiteLettucePaint = Paint()..color = AppColors.white.withOpacity(0.9);

    // 1. Bottom Bun
    final bottomBunPath = Path()
      ..moveTo(center - 55, 170 + bottomBunY)
      ..lineTo(center + 55, 170 + bottomBunY)
      ..arcToPoint(
        Offset(center - 55, 170 + bottomBunY),
        radius: const Radius.circular(55),
        clockwise: false,
      );
    canvas.drawPath(bottomBunPath, darkBunPaint);
    canvas.drawPath(bottomBunPath, borderPaint);

    // 2. Patty
    final pattyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(center - 60, 140 + pattyY, 120, 24),
      const Radius.circular(8),
    );
    canvas.drawRRect(pattyRect, darkPattyPaint);
    canvas.drawRRect(pattyRect, borderPaint);

    // 3. Cheese
    final cheesePath = Path()
      ..moveTo(center - 55, 130 + cheeseY)
      ..lineTo(center + 55, 130 + cheeseY)
      ..lineTo(center + 45, 145 + cheeseY)
      ..lineTo(center + 15, 138 + cheeseY)
      ..lineTo(center - 10, 152 + cheeseY)
      ..lineTo(center - 35, 135 + cheeseY)
      ..close();
    canvas.drawPath(cheesePath, goldCheesePaint);
    canvas.drawPath(cheesePath, borderPaint);

    // 4. Lettuce
    final lettucePath = Path()
      ..moveTo(center - 58, 115 + lettuceY)
      ..quadraticBezierTo(center - 40, 105 + lettuceY, center - 30, 115 + lettuceY)
      ..quadraticBezierTo(center - 15, 125 + lettuceY, center, 115 + lettuceY)
      ..quadraticBezierTo(center + 15, 105 + lettuceY, center + 30, 115 + lettuceY)
      ..quadraticBezierTo(center + 45, 125 + lettuceY, center + 58, 115 + lettuceY)
      ..lineTo(center + 58, 122 + lettuceY)
      ..lineTo(center - 58, 122 + lettuceY)
      ..close();
    canvas.drawPath(lettucePath, whiteLettucePaint);
    canvas.drawPath(lettucePath, borderPaint);

    // 5. Top Bun
    final topBunRect = Rect.fromLTWH(center - 55, 60 + topBunY, 110, 45);
    final topBunPath = Path()
      ..moveTo(center - 55, 105 + topBunY)
      ..lineTo(center + 55, 105 + topBunY)
      ..arcTo(topBunRect, 0, -math.pi, false)
      ..close();
    canvas.drawPath(topBunPath, darkBunPaint);
    canvas.drawPath(topBunPath, borderPaint);

    // Sesame Seeds on Top Bun
    final seedPaint = Paint()..color = AppColors.gold;
    canvas.drawOval(Rect.fromLTWH(center - 25, 75 + topBunY, 6, 3), seedPaint);
    canvas.drawOval(Rect.fromLTWH(center + 15, 80 + topBunY, 6, 3), seedPaint);
    canvas.drawOval(Rect.fromLTWH(center, 70 + topBunY, 6, 3), seedPaint);
    canvas.drawOval(Rect.fromLTWH(center - 10, 85 + topBunY, 6, 3), seedPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
