import 'package:flutter/material.dart';
import '../theme.dart';

/// Bondly logo — clean "B" with green accent.
class BondlyLogo extends StatelessWidget {
  final double size;
  final bool showText;
  const BondlyLogo({super.key, this.size = 40, this.showText = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CustomPaint(
          size: Size(size, size),
          painter: _LogoPainter(),
        ),
        if (showText) ...[
          const SizedBox(width: 10),
          Text(
            'bondly',
            style: TextStyle(
              fontSize: size * 0.55,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.5,
              color: BColor.text,
            ),
          ),
        ],
      ],
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Background — solid black with green border
    final bgPaint = Paint()..color = BColor.bg1;
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(size.width * 0.28));
    canvas.drawRRect(rr, bgPaint);

    // Green border
    final borderPaint = Paint()
      ..color = BColor.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.055;
    canvas.drawRRect(rr, borderPaint);

    // Diamond accent at top-right
    final diamondPaint = Paint()
      ..color = BColor.green.withAlpha(70)
      ..style = PaintingStyle.fill;
    final diamondPath = Path();
    final cx = size.width * 0.72;
    final cy = size.height * 0.28;
    final r = size.width * 0.10;
    diamondPath.moveTo(cx, cy - r);
    diamondPath.lineTo(cx + r * 0.7, cy);
    diamondPath.lineTo(cx, cy + r);
    diamondPath.lineTo(cx - r * 0.7, cy);
    diamondPath.close();
    canvas.drawPath(diamondPath, diamondPaint);

    // "b" stem
    final bPaint = Paint()
      ..color = BColor.text
      ..style = PaintingStyle.fill;
    final stemLeft   = size.width * 0.22;
    final stemTop    = size.height * 0.18;
    final stemBottom = size.height * 0.82;
    final stemWidth  = size.width * 0.13;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(stemLeft, stemTop, stemWidth, stemBottom - stemTop),
        Radius.circular(stemWidth / 2),
      ),
      bPaint,
    );

    // Curves
    final curvePaint = Paint()
      ..color = BColor.text
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromLTWH(stemLeft + stemWidth * 0.5, size.height * 0.20, size.width * 0.32, size.height * 0.28),
      -1.57, 3.14, false, curvePaint,
    );
    canvas.drawArc(
      Rect.fromLTWH(stemLeft + stemWidth * 0.5, size.height * 0.47, size.width * 0.40, size.height * 0.32),
      -1.57, 3.14, false, curvePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
