import 'dart:math';

import 'package:flutter/widgets.dart';

import '../data/constraints_settings.dart';
import '../utils/painting+extensions.dart';
import 'backstage_calculator.dart';

/// A concrete implementation of [BackstageCalculator] that calculates image and
/// crop rectangle bounds with respect to a constrained viewport. It provides
/// methods for moving and scaling the image within the given viewport bounds.
class BackstageCalculatorViewportConstrained extends BackstageCalculator {
  const BackstageCalculatorViewportConstrained(super.backstage, {
    required this.settings,
  });

  // Settings that control how the viewport constrains the image and crop area.
  final ViewportConstrainedSettings settings;

  /// Returns the bounds of the crop rectangle, constrained to the viewport's bounds.
  @override
  Rect get cropRectBounds => backstage.viewport;

  /// Returns the bounds of the image rectangle, constrained to the viewport's bounds.
  @override
  Rect get imageRectBounds => backstage.viewport;

  /// Moves the image rectangle by the specified delta values for horizontal
  /// and vertical movement, ensuring the image stays within the boundaries of
  /// the viewport.
  @override
  Rect moveImageRect(double deltaX, double deltaY) {
    final imageRect = backstage.imageRect;
    final bounds = imageRectBounds;

    double newLeft = imageRect.left + deltaX;
    double newTop = imageRect.top + deltaY;
    double newRight = imageRect.right + deltaX;
    double newBottom = imageRect.bottom + deltaY;

    final newImageBounds = Rect.fromLTRB(newLeft, newTop, newRight, newBottom);

    if (newImageBounds.left > bounds.left) {
      newLeft -= newImageBounds.left - bounds.left;
      newRight = newLeft + imageRect.width;
    } else if (newImageBounds.right < bounds.right) {
      newRight += bounds.right - newImageBounds.right;
      newLeft = newRight - imageRect.width;
    }

    if (newImageBounds.top > bounds.top) {
      newTop -= newImageBounds.top - bounds.top;
      newBottom = newTop + imageRect.height;
    } else if (newImageBounds.bottom < bounds.bottom) {
      newBottom += bounds.bottom - newImageBounds.bottom;
      newTop = newBottom - imageRect.height;
    }

    return Rect.fromLTRB(newLeft, newTop, newRight, newBottom);
  }

  /// Scales the image to a new scale factor, adjusting the image rectangle
  /// accordingly. If a focal point is provided, scaling will be applied
  /// relative to that point. Returns the new image rectangle and scale after
  /// applying the transformation.
  @override
  ({Rect imageRect, double scale})? scaleImageRect(double nextScale, {
    required Rect cropRect,
    required Rect imageRect,
    Offset? focalPoint,
    bool isReset = false,
  }) {
    final _imageRect = imageRect;
    final _scale = backstage.scale;
    final imageInfo = backstage.imageInfo;
    final viewport = backstage.viewport;
    final bounds = backstage.cropRectBounds;

    late double baseHeight;
    late double baseWidth;

    if (imageInfo.ratio < viewport.size.aspectRatio) {
      baseHeight = viewport.height;
      baseWidth = baseHeight * imageInfo.ratio;
    } else {
      baseWidth = viewport.width;
      baseHeight = baseWidth / imageInfo.ratio;
    }

    nextScale = max(
      nextScale,
      max(viewport.width / baseWidth, viewport.height / baseHeight),
    );

    if (_scale == nextScale && !isReset) {
      return null;
    }

    final newWidth = baseWidth * nextScale;
    final horizontalFocalPointBias = focalPoint == null || bounds.width < viewport.width
        ? 0.5
        : (focalPoint.dx - _imageRect.left) / _imageRect.width;
    final leftPositionDelta =
        (newWidth - _imageRect.width) * horizontalFocalPointBias;

    final newHeight = baseHeight * nextScale;
    final verticalFocalPointBias = focalPoint == null || bounds.height < viewport.height
        ? 0.5
        : (focalPoint.dy - _imageRect.top) / _imageRect.height;
    final topPositionDelta =
        (newHeight - _imageRect.height) * verticalFocalPointBias;

    // position
    final newLeft = max(
        min(viewport.left, _imageRect.left - leftPositionDelta),
        viewport.right - newWidth
    );

    final newTop = max(
        min(viewport.top, _imageRect.top - topPositionDelta),
        viewport.bottom - newHeight
    );

    return (
      imageRect: Rect.fromLTRB(
        newLeft,
        newTop,
        newLeft + newWidth,
        newTop + newHeight,
      ),
      scale: nextScale,
    );
  }

}