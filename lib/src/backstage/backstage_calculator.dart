import 'package:flutter/widgets.dart';

import 'backstage.dart';

/// Abstract class that defines the contract for calculating image and crop area
/// boundaries, as well as handling movement and scaling logic for the cropping
/// interface. It is a helper class that aims to make the `Backstage` class more
/// lightweight.
abstract class BackstageCalculator {

  /// Constructor that initializes the associated Backstage object.
  const BackstageCalculator(this.backstage);

  /// The Backstage object this calculator is associated with.
  final Backstage backstage;

  /// Gets the bounds of the crop rectangle.
  Rect get cropRectBounds;

  /// Gets the bounds of the image rectangle.
  Rect get imageRectBounds;

  /// Moves the image by a given delta, updating the image rectangle.
  ///
  /// [deltaX] is the horizontal movement, and [deltaY] is the vertical movement.
  ///
  /// Returns the new image rect after the movement.
  Rect moveImageRect(double deltaX, double deltaY);

  /// Scales the image based on a new scale factor and adjusts the image
  /// rectangle accordingly. Optionally includes a focal point to apply the
  /// scale from a specific location.
  /// Returns the new image rectangle and scale, or null if the scaling
  /// operation couldn't be applied.
  ///
  /// [nextScale] is the desired scale factor.
  /// [cropRect] is the rectangle used for cropping the image.
  /// [imageRect] is the current image rectangle.
  /// [focalPoint] is the optional point from which to scale the image.
  /// [isReset] indicates whether the scaling is a reset to the original size.
  ///
  /// Returns the new image rect and scale, or null if the scaling operation
  /// couldn't be applied.
  ({Rect imageRect, double scale})? scaleImageRect(double nextScale, {
    required Rect cropRect,
    required Rect imageRect,
    Offset? focalPoint,
    bool isReset = false,
  });

}