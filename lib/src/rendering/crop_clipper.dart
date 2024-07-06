import 'package:flutter/rendering.dart';

class CropClipper extends CustomClipper<Path> {

  CropClipper(this.rect, {
    this.borderRadius = BorderRadius.zero,
  }) : isCircle = false;

  CropClipper.circle(this.rect)
    : isCircle = true,
      borderRadius = BorderRadius.zero;

  final Rect rect;
  final BorderRadius borderRadius;
  final bool isCircle;

  @override
  Path getClip(Size size) {
    final path = Path();
    if (isCircle) {
      path.addOval(rect);
    } else if (borderRadius == BorderRadius.zero) {
      path.addRect(rect);
    } else {
      path.addRRect(borderRadius.resolve(TextDirection.ltr).toRRect(rect));
    }
    return path
      ..addRect(Rect.fromLTWH(0.0, 0.0, size.width, size.height))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(CropClipper oldClipper) {
    return oldClipper.rect != rect ||
        oldClipper.borderRadius != borderRadius ||
        oldClipper.isCircle != isCircle;
  }

}