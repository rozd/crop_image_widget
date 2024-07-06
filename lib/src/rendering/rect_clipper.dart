import 'package:flutter/rendering.dart';

class RectClipper extends CustomClipper<Rect> {
  RectClipper(this.rect);

  final Rect rect;

  @override
  Rect getClip(Size size) {
    return rect;
  }

  @override
  bool shouldReclip(RectClipper oldClipper) {
    return oldClipper.rect != rect;
  }
}