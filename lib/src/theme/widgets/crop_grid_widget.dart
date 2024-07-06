import 'package:flutter/widgets.dart';

class CropGridPainter extends CustomPainter {
  const CropGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x99FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final double width = size.width;
    final double height = size.height;

    final hStep = width / 3;

    for (double i = hStep; i < width; i += hStep) {
      canvas.drawLine(Offset(i, 0), Offset(i, height), paint);
    }

    final vStep = height / 3;

    for (double i = vStep; i < height; i += vStep) {
      canvas.drawLine(Offset(0, i), Offset(width, i), paint);
    }
  }

  @override
  bool shouldRepaint(CropGridPainter oldDelegate) {
    return false;
  }

}

class CropGridWidget extends CustomPaint {
  const CropGridWidget({
    super.key
  }) : super(
    painter: const CropGridPainter(),
  );
}