import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  final double size;

  const LogoWidget({
    super.key,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 1.5,
      height: size * 1.3,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Top curved text
          Positioned(
            top: 0,
            child: Text(
              'CV. TATA SAKA',
              style: TextStyle(
                fontSize: size * 0.08,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E1E1E),
                letterSpacing: 1.2,
                fontFamily: 'Inter',
              ),
            ),
          ),
          // Custom Painted Logo Symbol
          Positioned(
            top: size * 0.12,
            child: SizedBox(
              width: size,
              height: size * 0.8,
              child: CustomPaint(
                painter: LogoPainter(),
              ),
            ),
          ),
          // Bottom text
          Positioned(
            bottom: 0,
            child: Text(
              'CONSULTANT',
              style: TextStyle(
                fontSize: size * 0.065,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E1E1E),
                letterSpacing: 1.8,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;

    // Paints
    final redPaint = Paint()
      ..color = const Color(0xFFFF0000) // Vibrant Red from screenshot
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.075
      ..strokeCap = StrokeCap.square;

    final bluePaint = Paint()
      ..color = const Color(0xFF0033CC) // Royal Blue from screenshot
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.075
      ..strokeCap = StrokeCap.square;

    final blackPaint = Paint()
      ..color = const Color(0xFF111111) // Sleek Black
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.095
      ..strokeCap = StrokeCap.square;

    // 1. Draw the Black "S" character structure in the center
    final Path sPath = Path();
    // Start top-right loop
    sPath.moveTo(cx + w * 0.22, cy - h * 0.26);
    sPath.cubicTo(
      cx - w * 0.15, cy - h * 0.38,
      cx - w * 0.18, cy - h * 0.05,
      cx, cy
    );
    // Continue to bottom-left loop
    sPath.cubicTo(
      cx + w * 0.18, cy + h * 0.05,
      cx + w * 0.15, cy + h * 0.38,
      cx - w * 0.22, cy + h * 0.26
    );
    canvas.drawPath(sPath, blackPaint);

    // 2. Draw the Red horizontal line intersecting the center left to represent the E bar
    // It goes from the left outer edge and overlaps into the middle of the 'S'
    final Path redBar = Path();
    redBar.moveTo(cx - w * 0.44, cy);
    redBar.lineTo(cx + w * 0.05, cy);
    canvas.drawPath(redBar, redPaint);

    // 3. Draw the Top Blue Curve (crescent style top half of the circle)
    final Path topBlueCurve = Path();
    topBlueCurve.moveTo(cx - w * 0.36, cy - h * 0.24);
    topBlueCurve.cubicTo(
      cx - w * 0.22, cy - h * 0.46,
      cx + w * 0.30, cy - h * 0.42,
      cx + w * 0.38, cy - h * 0.18
    );
    canvas.drawPath(topBlueCurve, bluePaint);

    // 4. Draw the Bottom Red Curve (crescent style bottom half of the circle)
    final Path bottomRedCurve = Path();
    bottomRedCurve.moveTo(cx - w * 0.38, cy + h * 0.18);
    bottomRedCurve.cubicTo(
      cx - w * 0.30, cy + h * 0.42,
      cx + w * 0.22, cy + h * 0.46,
      cx + w * 0.36, cy + h * 0.24
    );
    canvas.drawPath(bottomRedCurve, redPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
