import 'package:flutter/painting.dart';

/// An abstract class representing different types of crop areas for image
/// manipulation. This class includes properties like [isEditable], [isCircle],
/// and [keepAspectRatio], and provides factory constructors for creating
/// different crop area types.
abstract class CropArea {
  /// Creates an instance of [CropArea].
  ///
  /// [isEditable]: A boolean flag indicating whether the crop area is editable.
  /// [isCircle]: A boolean flag indicating whether the crop area is circular.
  /// [keepAspectRatio]: A boolean flag indicating whether the aspect ratio should be maintained.
  const CropArea({
    required this.isEditable,
    required this.isCircle,
    required this.keepAspectRatio,
  });

  /// Factory constructor that creates an [AspectRatioCropArea] with a specific
  /// aspect ratio.
  ///
  /// [aspectRatio]: The aspect ratio to be maintained by the crop area.
  /// [isEditable]: A boolean flag indicating whether the crop area is editable.
  /// [margin]: The margin around the crop area.
  factory CropArea.aspectRatio(double aspectRatio, {
    required bool isEditable,
    required double margin,
  }) => AspectRatioCropArea(
    isEditable: isEditable,
    aspectRatio: aspectRatio,
    margin: margin,
  );

  /// Factory constructor that creates a [FreeCropArea] with a specified size.
  ///
  /// [size]: The size of the crop area.
  /// [isEditable]: A boolean flag indicating whether the crop area is editable.
  /// [origin]: The origin point of the crop area (optional).
  factory CropArea.free(Size size, {
    required bool isEditable,
    Offset? origin,
  }) => FreeCropArea(
    isEditable: isEditable,
    origin: origin,
    size: size,
  );

  /// Factory constructor that creates a [CircleCropArea] with a specified size.
  ///
  /// [size]: The size of the crop area.
  /// [isEditable]: A boolean flag indicating whether the crop area is editable.
  /// [origin]: The origin point of the crop area (optional).
  factory CropArea.circle(Size size, {
    required bool keepAspectRatio,
    required bool isEditable,
    Offset? origin,
  }) => CircleCropArea(
    isEditable: isEditable,
    keepAspectRatio: keepAspectRatio,
    origin: origin,
    size: size,
  );

  /// A boolean flag indicating whether the crop area is editable.
  final bool isEditable;

  /// A boolean flag indicating whether the crop area is circular.
  final bool isCircle;

  /// A boolean flag indicating whether the aspect ratio should be maintained.
  final bool keepAspectRatio;

  /// Abstract method to calculate and return the crop area as a [Rect].
  /// The method uses the provided [size] to calculate the area.
  Rect getArea(Size size);
}

/// A class representing a crop area with a specific aspect ratio.
/// This class extends [CropArea] and maintains the aspect ratio of the crop area.
class AspectRatioCropArea extends CropArea {
  /// Creates an instance of [AspectRatioCropArea].
  ///
  /// [isEditable]: A boolean flag indicating whether the crop area is editable.
  /// [aspectRatio]: The aspect ratio to be maintained.
  /// [margin]: The margin around the crop area.
  AspectRatioCropArea({
    required super.isEditable,
    required this.aspectRatio,
    required this.margin,
  }) : super(
    isCircle: false,
    keepAspectRatio: true,
  );

  /// The aspect ratio to be maintained by the crop area.
  final double aspectRatio;

  /// The margin around the crop area.
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

/// A class representing a free-form crop area with a specified size.
/// This class extends [CropArea] and does not maintain an aspect ratio by default.
class FreeCropArea extends CropArea {
  /// Creates an instance of [FreeCropArea].
  ///
  /// [isEditable]: A boolean flag indicating whether the crop area is editable.
  /// [size]: The size of the crop area.
  /// [origin]: The origin point of the crop area (optional).
  FreeCropArea({
    required super.isEditable,
    required this.size,
    this.origin,
    super.isCircle = false,
    super.keepAspectRatio = false,
  });

  /// The origin point of the crop area (optional).
  final Offset? origin;

  /// The size of the crop area.
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

/// A class representing a circular crop area.
/// This class extends [FreeCropArea] and forces the crop area to be circular.
class CircleCropArea extends FreeCropArea {
  /// Creates an instance of [CircleCropArea].
  ///
  /// [isEditable]: A boolean flag indicating whether the crop area is editable.
  /// [size]: The size of the crop area.
  /// [origin]: The origin point of the crop area (optional).
  CircleCropArea({
    required super.size,
    required super.isEditable,
    required super.keepAspectRatio,
    super.origin,
    super.isCircle = true,
  });
}
