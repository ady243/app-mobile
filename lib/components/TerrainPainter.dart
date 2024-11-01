import 'package:flutter/material.dart';

class TerrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final fieldRect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(fieldRect, paint);
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.1,
      paint,
    );

    // Surface de réparation (zones de but)
    double penaltyBoxWidth = size.width * 0.3;
    double penaltyBoxHeight = size.height * 0.2;

    // Surface de réparation côté haut
    canvas.drawRect(
      Rect.fromLTWH((size.width - penaltyBoxWidth) / 2, 0, penaltyBoxWidth, penaltyBoxHeight),
      paint,
    );

    // Surface de réparation côté bas
    canvas.drawRect(
      Rect.fromLTWH((size.width - penaltyBoxWidth) / 2, size.height - penaltyBoxHeight, penaltyBoxWidth, penaltyBoxHeight),
      paint,
    );

    // Dessiner les buts
    double goalWidth = size.width * 0.15;
    canvas.drawLine(
      Offset((size.width - goalWidth) / 2, 0),
      Offset((size.width + goalWidth) / 2, 0),
      paint,
    );
    canvas.drawLine(
      Offset((size.width - goalWidth) / 2, size.height),
      Offset((size.width + goalWidth) / 2, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}