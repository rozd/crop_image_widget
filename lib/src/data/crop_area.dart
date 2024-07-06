import 'package:flutter/painting.dart';

abstract class CropArea {
  const CropArea({
    required this.isEditable,
    required this.isCircle,
    required this.keepAspectRatio,
  });

  factory CropArea.aspectRatio(double aspectRatio, {
    required bool isEditable,
    required double margin,
  }) => AspectRatioCropArea(
    isEditable: isEditable,
    aspectRatio: aspectRatio,
    margin: margin,
  );

  factory CropArea.free(Size size, {
    required bool isEditable,
    Offset? origin,
  }) => FreeCropArea(
    isEditable: isEditable,
    origin: origin,
    size: size,
  );

  factory CropArea.circle(Size size, {
    required bool isEditable,
    Offset? origin,
  }) => CircleCropArea(
    isEditable: isEditable,
    origin: origin,
    size: size,
  );

  final bool isEditable;
  final bool isCircle;
  final bool keepAspectRatio;

  Rect getArea(Size size);
}

class AspectRatioCropArea extends CropArea {
  AspectRatioCropArea({
    required super.isEditable,
    required this.aspectRatio,
    required this.margin,
  }) : super(
    isCircle: false,
    keepAspectRatio: true,
  );

  final double aspectRatio;
  final double margin;

  @override
  Rect getArea(Size size) {
    final width = size.width - margin * 2;
    final height = size.height - margin * 2;
    final areaAspectRatio = width / height;
    final areaWidth = areaAspectRatio > aspectRatio ? height * aspectRatio : width;
    final areaHeight = areaAspectRatio > aspectRatio ? height : width / aspectRatio;
    final left = (size.width - areaWidth) / 2;
    final top = (size.height - areaHeight) / 2;
    return Rect.fromLTWH(left, top, areaWidth, areaHeight);
  }
}

class FreeCropArea extends CropArea {
  FreeCropArea({
    required super.isEditable,
    required this.size,
    this.origin,
    super.isCircle = false,
    super.keepAspectRatio = false,
  });

  final Offset? origin;
  final Size size;

  @override
  Rect getArea(Size size) {
    final topLeft = origin;
    if (topLeft != null) {
      return Rect.fromPoints(topLeft, this.size.bottomRight(topLeft));
    }
    return Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: this.size.width,
      height: this.size.height,
    );
  }
}

class CircleCropArea extends FreeCropArea {
  CircleCropArea({
    required super.isEditable,
    required super.size,
    super.origin,
    super.isCircle = true,
  });
}