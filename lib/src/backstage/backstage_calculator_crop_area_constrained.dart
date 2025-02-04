import 'dart:math';

import 'package:flutter/widgets.dart';

import '../data/constraints_settings.dart';
import '../utils/painting+extensions.dart';
import 'backstage_calculator.dart';

/// A concrete implementation of [BackstageCalculator] that calculates image and
/// crop rectangle bounds while ensuring the image is constrained within the
/// crop area. This class adjusts the image and crop area according to specific
/// constraints defined in the [settings] object.
class BackstageCalculatorCropAreaConstrained extends BackstageCalculator {

  /// Constructs an instance of [BackstageCalculatorCropAreaConstrained] with the provided
  /// [backstage] context and [settings] that define the constraints for the crop area.
  const BackstageCalculatorCropAreaConstrained(super.backstage, {
    required this.settings,
  });

  final CropAreaConstrainedSettings settings;

  @override
  Rect get cropRectBounds {
    final imageBounds = calcImageBounds(backstage.imageRect);

    final viewport = backstage.viewport;

    // Limit centeredImageRect to the viewport
    double limitedLeft = max(imageBounds.left, viewport.left);
    double limitedTop = max(imageBounds.top, viewport.top);
    double limitedRight = min(imageBounds.right, viewport.right);
    double limitedBottom = min(imageBounds.bottom, viewport.bottom);

    // Ensure the limited rectangle has valid dimensions
    if (limitedRight < limitedLeft) {
      limitedRight = limitedLeft;
    }
    if (limitedBottom < limitedTop) {
      limitedBottom = limitedTop;
    }

    return Rect.fromLTRB(limitedLeft, limitedTop, limitedRight, limitedBottom);
  }

  @override
  Rect get imageRectBounds {
    final imageRect = backstage.imageRect;
    final cropRect = backstage.cropRect;
    final viewport = backstage.viewport;
    return settings.restrictImageToViewport
      ? imageRect.size > viewport.size
        ? viewport
        : imageRect.size.aspectRatio < viewport.size.aspectRatio
          ? Rect.fromLTWH(cropRect.left, viewport.top, cropRect.width, viewport.height)
          : Rect.fromLTWH(viewport.left, cropRect.top, viewport.width, cropRect.height)
      : backstage.cropRect;
  }

  Rect calcImageBounds(Rect imageRect) {
    // TODO: check imageInfo is null
    final imageInfo = backstage.imageInfo;
    final imageInfoAspectRatio = imageInfo.ratio;
    final imageRectAspectRatio = imageRect.size.aspectRatio;
    double scaledWidth, scaledHeight;
    if (imageInfoAspectRatio > imageRectAspectRatio) {
      // Image is wider than the rect, scale by width
      scaledWidth = imageRect.width;
      scaledHeight = scaledWidth / imageInfoAspectRatio;
    } else {
      // Image is taller than the rect, scale by height
      scaledHeight = imageRect.height;
      scaledWidth = scaledHeight * imageInfoAspectRatio;
    }
    final double left = imageRect.left + (imageRect.width - scaledWidth) / 2;
    final double top = imageRect.top + (imageRect.height - scaledHeight) / 2;
    // Adjusted _imageRect to fit the scaled image exactly at the center
    return Rect.fromLTWH(left, top, scaledWidth, scaledHeight);
  }

  @override
  Rect moveImageRect(double deltaX, double deltaY) {
    final imageRect = backstage.imageRect;

    final bounds = imageRectBounds;

    double newLeft = imageRect.left + deltaX;
    double newTop = imageRect.top + deltaY;
    double newRight = imageRect.right + deltaX;
    double newBottom = imageRect.bottom + deltaY;

    final newImageRect = Rect.fromLTRB(newLeft, newTop, newRight, newBottom);
    final newImageBounds = calcImageBounds(newImageRect);

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

  @override
  ({Rect imageRect, double scale})? scaleImageRect(double nextScale, {
    required Rect cropRect,
    required Rect imageRect,
    Offset? focalPoint,
    bool isReset = false,
  }) {
    final _cropRect = cropRect;
    final _imageRect = imageRect;
    final _scale = backstage.scale;
    final imageInfo = backstage.imageInfo;
    final viewport = backstage.viewport;
    final bounds = _cropRect;

    late double baseHeight;
    late double baseWidth;

    if (imageInfo.ratio < viewport.size.aspectRatio) {
      baseHeight = viewport.height;
      baseWidth = baseHeight * imageInfo.ratio;
    } else {
      baseWidth = viewport.width;
      baseHeight = baseWidth / imageInfo.ratio;
    }

    if (settings.restrictImageToViewport) {
      nextScale = max(
        nextScale,
        max(
          max(_cropRect.width / baseWidth, _cropRect.height / baseHeight),
          min(viewport.width / baseWidth, viewport.height / baseHeight),
        ),
      );
    } else {
      nextScale = max(
        nextScale,
        max(_cropRect.width / baseWidth, _cropRect.height / baseHeight),
      );
    }

    if (_scale == nextScale && !isReset) {
      return null;
    }

    final newWidth = baseWidth * nextScale;
    final horizontalFocalPointBias = focalPoint == null
      ? 0.5
      : (focalPoint.dx - _imageRect.left) / _imageRect.width;
    final leftPositionDelta =
      (newWidth - _imageRect.width) * horizontalFocalPointBias;

    final newHeight = baseHeight * nextScale;
    final verticalFocalPointBias = focalPoint == null
      ? 0.5
      : (focalPoint.dy - _imageRect.top) / _imageRect.height;
    final topPositionDelta =
      (newHeight - _imageRect.height) * verticalFocalPointBias;

    final newLeft = max(
      min(bounds.left, _imageRect.left - leftPositionDelta),
      bounds.right - newWidth
    );

    final newTop = max(
      min(bounds.top, _imageRect.top - topPositionDelta),
      bounds.bottom - newHeight
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