import 'package:flutter/material.dart';

class TerrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grassPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), grassPaint);

    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;

    canvas.drawLine(Offset(0, size.height * 0.05), Offset(size.width, size.height * 0.05), linePaint);
    canvas.drawLine(Offset(0, size.height * 0.95), Offset(size.width, size.height * 0.95), linePaint);


    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), linePaint);

    final centerCircleRadius = size.width * 0.1;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: centerCircleRadius * 2,
        height: centerCircleRadius * 1.5,
      ),
      linePaint,
    );

    // Point central
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width * 0.02, linePaint);


    final penaltyAreaWidth = size.width * 0.35;
    final penaltyAreaHeight = size.height * 0.15;


    canvas.drawRect(
      Rect.fromLTWH((size.width - penaltyAreaWidth) / 2, size.height * 0.05, penaltyAreaWidth, penaltyAreaHeight),
      linePaint,
    );

    canvas.drawRect(
      Rect.fromLTWH((size.width - penaltyAreaWidth) / 2, size.height - penaltyAreaHeight - size.height * 0.05, penaltyAreaWidth, penaltyAreaHeight),
      linePaint,
    );

    // Surface de but en perspective
    final goalAreaWidth = size.width * 0.15;
    final goalAreaHeight = size.height * 0.075;

    canvas.drawRect(
      Rect.fromLTWH((size.width - goalAreaWidth) / 2, size.height * 0.05, goalAreaWidth, goalAreaHeight),
      linePaint,
    );

    canvas.drawRect(
      Rect.fromLTWH((size.width - goalAreaWidth) / 2, size.height - goalAreaHeight - size.height * 0.05, goalAreaWidth, goalAreaHeight),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
