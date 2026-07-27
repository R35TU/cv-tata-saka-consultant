import 'package:flutter/material.dart';

class BottomWaveWidget extends StatelessWidget {
  final Widget? child;
  final double height;

  const BottomWaveWidget({
    super.key,
    this.child,
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: BottomWavePainter(),
            ),
          ),
          if (child != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 20,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: child!,
              ),
            ),
        ],
      ),
    );
  }
}

class BottomWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Paints
    final redPaint = Paint()
      ..color = const Color(0xFFE50012)
      ..style = PaintingStyle.fill;

    final bluePaint = Paint()
      ..color = const Color(0xFF0033CC)
      ..style = PaintingStyle.fill;

    final blackPaint = Paint()
      ..color = const Color(0xFF000000)
      ..style = PaintingStyle.fill;

    // 1. Red Wave Path (Left side, curves down to right)
    final Path redPath = Path();
    redPath.moveTo(0, h * 0.25);
    // Control point is around 35% width, 30% height, ending at 100% width, 80% height
    redPath.quadraticBezierTo(w * 0.35, h * 0.3, w, h * 0.75);
    redPath.lineTo(w, h);
    redPath.lineTo(0, h);
    redPath.close();
    canvas.drawPath(redPath, redPaint);

    // 2. Blue Wave Path (Right side, curves down to left)
    final Path bluePath = Path();
    bluePath.moveTo(w, h * 0.3);
    // Control point around 65% width, 35% height, ending at 0 width, 85% height
    bluePath.quadraticBezierTo(w * 0.65, h * 0.35, 0, h * 0.8);
    bluePath.lineTo(0, h);
    bluePath.lineTo(w, h);
    bluePath.close();
    canvas.drawPath(bluePath, bluePaint);

    // 3. Black Wave Path (Solid bottom, covers the lower parts of red & blue)
    final Path blackPath = Path();
    blackPath.moveTo(0, h * 0.45);
    // Smooth curve from left to right with a slight dip in the middle
    blackPath.cubicTo(
      w * 0.3, h * 0.55,
      w * 0.7, h * 0.48,
      w, h * 0.65
    );
    blackPath.lineTo(w, h);
    blackPath.lineTo(0, h);
    blackPath.close();
    canvas.drawPath(blackPath, blackPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
