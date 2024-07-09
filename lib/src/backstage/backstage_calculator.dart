import 'package:flutter/widgets.dart';

import 'backstage.dart';

abstract class BackstageCalculator {
  const BackstageCalculator(this.backstage);

  final Backstage backstage;

  Rect get bounds;

  Rect get imageRectBounds;

  Rect moveImageRect(ScaleUpdateDetails details);

  ({Rect imageRect, double scale})? scaleImageRect(double nextScale, {
    required Rect cropRect,
    required Rect imageRect,
    Offset? focalPoint,
    bool isReset = false,
  });

}