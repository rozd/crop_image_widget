import 'package:flutter/rendering.dart';

/// A custom [Clipper] used to create a clipping path for cropping.
///
/// This class allows creating different crop areas, either rectangular or
/// circular, with the option to specify border radii for rounded corners.
class CropClipper extends CustomClipper<Path> {
  /// Creates a [CropClipper] with a rectangular crop area and an optional border radius.
  ///
  /// [rect]: The rectangular area to clip.
  /// [borderRadius]: The border radius for the crop area. Defaults to [BorderRadius.zero].
  CropClipper(this.rect, {
    this.borderRadius = BorderRadius.zero,
  }) : isCircle = false;

  /// Creates a [CropClipper] with a circular crop area.
  ///
  /// [rect]: The rectangular area that will define the circle's bounds.
  CropClipper.circle(this.rect)
    : isCircle = true,
      borderRadius = BorderRadius.zero;

  /// The rectangular bounds of the crop area.
  final Rect rect;

  /// The border radius for the crop area. If no border radius is provided,
  /// the crop area will have sharp corners.
  final BorderRadius borderRadius;

  /// A flag indicating if the crop area should be circular. If `true`, the crop area
  /// will be clipped as a circle; otherwise, it will be rectangular or rounded based
  /// on the [borderRadius].
  final bool isCircle;

  /// Returns the clipping path for the crop area.
  ///
  /// The method creates a clipping path for the given crop area, which could be:
  /// - A circle if [isCircle] is `true`.
  /// - A rectangle if [borderRadius] is [BorderRadius.zero].
  /// - A rounded rectangle if [borderRadius] is not [BorderRadius.zero].
  ///
  /// This path is used for clipping the content in a [ClipPath] widget.
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

  /// Determines if the clipper needs to be re-applied.
  ///
  /// The clipper should be re-applied if any of the properties (`rect`, `borderRadius`, or `isCircle`)
  /// have changed from the previous clipper.
  @override
  bool shouldReclip(CropClipper oldClipper) {
    return oldClipper.rect != rect ||
        oldClipper.borderRadius != borderRadius ||
        oldClipper.isCircle != isCircle;
  }
}
