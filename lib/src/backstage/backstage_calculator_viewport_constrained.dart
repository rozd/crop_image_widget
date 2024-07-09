import 'dart:math';

import 'package:flutter/widgets.dart';

import '../data/constraints_settings.dart';
import '../utils/painting+extensions.dart';
import 'backstage_calculator.dart';

class BackstageCalculatorViewportConstrained extends BackstageCalculator {
  const BackstageCalculatorViewportConstrained(super.backstage, {
    required this.settings,
  });

  final ViewportConstrainedSettings settings;

  @override
  Rect get bounds => backstage.viewport;

  @override
  Rect get imageRectBounds => backstage.viewport;

  @override
  Rect moveImageRect(ScaleUpdateDetails details) {
    final imageRect = backstage.imageRect;
    final bounds = imageRectBounds;

    var dx = details.focalPointDelta.dx;
    var dy = details.focalPointDelta.dy;

    double newLeft = imageRect.left + dx;
    double newTop = imageRect.top + dy;
    double newRight = imageRect.right + dx;
    double newBottom = imageRect.bottom + dy;

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