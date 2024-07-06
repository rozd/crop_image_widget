import 'package:flutter/widgets.dart';

class CropFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xEEFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(CropFramePainter oldDelegate) => false;
}

class CropFrameWidget extends StatelessWidget {
  const CropFrameWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CropFramePainter(),
    );
  }
}