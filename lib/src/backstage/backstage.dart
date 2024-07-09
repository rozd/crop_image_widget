import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../../crop_image_widget.dart';
import '../data/constraints_settings.dart';
import '../data/crop_settings.dart';
import 'backstage_calculator.dart';
import 'backstage_calculator_crop_area_constrained.dart';
import 'backstage_calculator_viewport_constrained.dart';

class Backstage extends ChangeNotifier implements CropControllerDelegate {

  Backstage({
    required CropArea cropArea,
    required CropSettings settings,
  }) : _cropArea = cropArea, _settings = settings;

  late var calculator = settings.constraints.createCalculator(this);

  CropArea _cropArea;
  CropArea get cropArea => _cropArea;
  set cropArea(CropArea value) {
    _cropArea = value;
  }

  CropSettings _settings;
  CropSettings get settings => _settings;
  set settings(CropSettings value) {
    _settings = value;
    calculator = settings.constraints.createCalculator(this);
  }

  ImageInfo? _imageInfo;
  ImageInfo get imageInfo => _imageInfo!;
  set imageInfo(ImageInfo value) {
    _imageInfo = value;
    needsInitialization = true;
    initializeIfNeeded();
    notifyListeners();
  }

  Rect? _viewport;
  Rect get viewport => _viewport!;
  set viewport(Rect value) {
    if (value == _viewport) {
      return;
    }
    _viewport = value;
    initializeIfNeeded();
  }

  bool get isReady => _imageInfo != null && _viewport != null;

  late Rect _imageRect = Rect.fromLTWH(0, 0, viewport.width, viewport.height);
  Rect get imageRect => _imageRect;
  void _setImageRect(Rect value) {
    _imageRect = value;
    notifyListeners();
  }

  Rect? _cropRect;
  Rect get cropRect => _cropRect!;
  void _setCropRect(Rect value) {
    _cropRect = value;
    notifyListeners();
  }

  double _scale = 1.0;
  double get scale => _scale;
  void _setScale(double value) {
    _scale = value;
    notifyListeners();
  }

  var needsInitialization = true;
  void initializeIfNeeded() {
    if (!needsInitialization && _imageInfo != null && _cropRect != null) {
      return;
    }
    if (_viewport == null) {
      return;
    }
    _imageRect = Rect.fromLTWH(0, 0, viewport.width, viewport.height);
    _cropRect = cropArea.getArea(viewport.size);
    resetScale();
    needsInitialization = false;
  }

  // MARK: - <CropControllerDelegate>

  @override
  ui.Image getImage() {
    return imageInfo.image.clone();
  }

  @override
  Rect getImageCropRect() {
    final ratioX = imageInfo.image.width / viewport.width;
    final ratioY = imageInfo.image.height / viewport.height;
    final ratio = max(ratioX, ratioY);

    return Rect.fromLTWH(
      (cropRect.left - _imageRect.left) * ratio / _scale,
      (cropRect.top - _imageRect.top) * ratio / _scale,
      cropRect.width * ratio / _scale,
      cropRect.height * ratio / _scale,
    );
  }

  @override
  bool isCircleCropArea() {
    return cropArea.isCircle;
  }

  // MARK: - Calculations

  Rect get cropRectBounds {
    return calculator.bounds;
  }

  // MARK: Move Image

  var _isMoving = false;

  void startMove(ScaleStartDetails details) {
    _isMoving = false;
  }

  void updateMove(ScaleUpdateDetails details) {
    if (!isReady) {
      return;
    }
    _setImageRect(calculator.moveImageRect(details));
    _isMoving = true;
  }

  void endMove() {
    _isMoving = false;
  }

  // MARK: Scale Image

  late var _baseScale = _scale;

  void startScale(ScaleStartDetails details) {
    if (!isReady) {
      return;
    }
    _baseScale = _scale;
  }

  void updateScale(ScaleUpdateDetails details) {
    if (!isReady) {
      return;
    }
    applyScale(_baseScale * details.scale,
      cropRect: cropRect,
      imageRect: imageRect,
      focalPoint: details.localFocalPoint,
    );
  }

  void endScale(ScaleEndDetails details) {
  }

  void applyScale(double nextScale, {
    required Rect cropRect,
    required Rect imageRect,
    Offset? focalPoint,
  }) {
    if (!settings.zoom.shouldUpdateScale(nextScale)) {
      return;
    }

    if (!isReady) {
      return;
    }

    if (_isMoving) {
      return;
    }

    final result = calculator.scaleImageRect(nextScale,
      cropRect: cropRect,
      imageRect: imageRect,
      focalPoint: focalPoint,
    );
    if (result == null) {
      return;
    }

    _setImageRect(result.imageRect);

    _setScale(result.scale);
  }

  void resetScale() {
    if (!settings.zoom.shouldUpdateScale(1.0)) {
      return;
    }

    if (!isReady) {
      return;
    }

    final result = calculator.scaleImageRect(1.0,
      cropRect: cropRect,
      imageRect: imageRect,
      isReset: true,
    );
    if (result == null) {
      return;
    }

    _setImageRect(result.imageRect);

    _setScale(result.scale);
  }

  // MARK: Move Crop Area

  void moveCropArea(double deltaX, double deltaY, {
    required Rect cropRect,
  }) {
    final bounds = cropRectBounds;

    // Calculate the new position
    double newLeft = cropRect.left + deltaX;
    double newTop = cropRect.top + deltaY;
    double newRight = cropRect.right + deltaX;
    double newBottom = cropRect.bottom + deltaY;

    // Ensure the new position does not exceed the left or top bounds
    if (newLeft < bounds.left) {
      newLeft = bounds.left;
      newRight = newLeft + cropRect.width;
    }
    if (newTop < bounds.top) {
      newTop = bounds.top;
      newBottom = newTop + cropRect.height;
    }

    // Ensure the new position does not exceed the right or bottom bounds
    if (newRight > bounds.right) {
      newRight = bounds.right;
      newLeft = newRight - cropRect.width;
    }
    if (newBottom > bounds.bottom) {
      newBottom = bounds.bottom;
      newTop = newBottom - cropRect.height;
    }

    // Update the crop rectangle's position
    _setCropRect(Rect.fromLTRB(newLeft, newTop, newRight, newBottom));
  }

  void moveTopLeft(double deltaX, double deltaY, {
    required Rect cropRect,
    bool keepAspectRatio = false,
  }) {

    final bounds = this.cropRectBounds;
    final newLeft = max(
      bounds.left,
      min(cropRect.left + deltaX, cropRect.right - 40),
    );
    final newTop = min(
      max(cropRect.top + deltaY, bounds.top),
      cropRect.bottom - 40,
    );
    if (!keepAspectRatio) {
      _setCropRect(
        Rect.fromLTRB(
          newLeft,
          newTop,
          cropRect.right,
          cropRect.bottom,
        )
      );
    }
    final aspectRatio = cropRect.size.aspectRatio;
    if (deltaX.abs() > deltaY.abs()) {
      var newWidth = cropRect.right - newLeft;
      var newHeight = newWidth / aspectRatio;
      if (cropRect.bottom - newHeight < bounds.top) {
        newHeight = cropRect.bottom - bounds.top;
        newWidth = newHeight * aspectRatio;
      }
      _setCropRect(
        Rect.fromLTRB(
          cropRect.right - newWidth,
          cropRect.bottom - newHeight,
          cropRect.right,
          cropRect.bottom,
        )
      );
    } else {
      var newHeight = cropRect.bottom - newTop;
      var newWidth = newHeight * aspectRatio;
      if (cropRect.right - newWidth < bounds.left) {
        newWidth = cropRect.right - bounds.left;
        newHeight = newWidth / aspectRatio;
      }
      _setCropRect(
        Rect.fromLTRB(
          cropRect.right - newWidth,
          cropRect.bottom - newHeight,
          cropRect.right,
          cropRect.bottom,
        )
      );
    }
  }

  void moveTopRight(double deltaX, double deltaY, {
    required Rect cropRect,
    bool keepAspectRatio = false,
  }) {
    final bounds = this.cropRectBounds;
    final newTop = min(
      max(cropRect.top + deltaY, bounds.top),
      cropRect.bottom - 40,
    );
    final newRight = max(
      min(cropRect.right + deltaX, bounds.right),
      cropRect.left + 40,
    );
    if (!keepAspectRatio) {
      _setCropRect(
        Rect.fromLTRB(
          cropRect.left,
          newTop,
          newRight,
          cropRect.bottom,
        )
      );
    }
    final aspectRatio = cropRect.size.aspectRatio;
    if (deltaX.abs() > deltaY.abs()) {
      var newWidth = newRight - cropRect.left;
      var newHeight = newWidth / aspectRatio;
      if (cropRect.bottom - newHeight < bounds.top) {
        newHeight = cropRect.bottom - bounds.top;
        newWidth = newHeight * aspectRatio;
      }
      _setCropRect(
        Rect.fromLTWH(
          cropRect.left,
          cropRect.bottom - newHeight,
          newWidth,
          newHeight,
        )
      );
    } else {
      var newHeight = cropRect.bottom - newTop;
      var newWidth = newHeight * aspectRatio;
      if (cropRect.left + newWidth > bounds.right) {
        newWidth = bounds.right - cropRect.left;
        newHeight = newWidth / aspectRatio;
      }
      _setCropRect(
        Rect.fromLTRB(
          cropRect.left,
          cropRect.bottom - newHeight,
          cropRect.left + newWidth,
          cropRect.bottom,
        )
      );
    }
  }

  void moveBottomLeft(double deltaX, double deltaY, {
    required Rect cropRect,
    bool keepAspectRatio = false,
  }) {
    final bounds = this.cropRectBounds;
    final newLeft = max(
      bounds.left,
      min(cropRect.left + deltaX, cropRect.right - 40),
    );
    final newBottom = max(
      min(cropRect.bottom + deltaY, bounds.bottom),
      cropRect.top + 40,
    );
    if (!keepAspectRatio) {
      _setCropRect(
        Rect.fromLTRB(
          newLeft,
          cropRect.top,
          cropRect.right,
          newBottom,
        )
      );
    }
    final aspectRatio = cropRect.size.aspectRatio;
    if (deltaX.abs() > deltaY.abs()) {
      var newWidth = cropRect.right - newLeft;
      var newHeight = newWidth / aspectRatio;
      if (cropRect.top + newHeight > bounds.bottom) {
        newHeight = bounds.bottom - cropRect.top;
        newWidth = newHeight * aspectRatio;
      }
      _setCropRect(
        Rect.fromLTRB(
          cropRect.right - newWidth,
          cropRect.top,
          cropRect.right,
          cropRect.top + newHeight,
        )
      );
    } else {
      var newHeight = newBottom - cropRect.top;
      var newWidth = newHeight * aspectRatio;
      if (cropRect.right - newWidth < bounds.left) {
        newWidth = cropRect.right - bounds.left;
        newHeight = newWidth / aspectRatio;
      }
      _setCropRect(
        Rect.fromLTRB(
          cropRect.right - newWidth,
          cropRect.top,
          cropRect.right,
          cropRect.top + newHeight,
        )
      );
    }
  }

  void moveBottomRight(double deltaX, double deltaY, {
    required Rect cropRect,
    bool keepAspectRatio = false,
  }) {
    final bounds = this.cropRectBounds;
    final newRight = min(
      bounds.right,
      max(cropRect.right + deltaX, cropRect.left + 40),
    );
    final newBottom = max(
      min(cropRect.bottom + deltaY, bounds.bottom),
      cropRect.top + 40,
    );
    if (!keepAspectRatio) {
      _setCropRect(
        Rect.fromLTRB(
          cropRect.left,
          cropRect.top,
          newRight,
          newBottom,
        )
      );
    }
    final aspectRatio = cropRect.size.aspectRatio;
    if (deltaX.abs() > deltaY.abs()) {
      var newWidth = newRight - cropRect.left;
      var newHeight = newWidth / aspectRatio;
      if (cropRect.top + newHeight > bounds.bottom) {
        newHeight = bounds.bottom - cropRect.top;
        newWidth = newHeight * aspectRatio;
      }
      _setCropRect(
        Rect.fromLTWH(
          cropRect.left,
          cropRect.top,
          newWidth,
          newHeight,
        )
      );
    } else {
      var newHeight = newBottom - cropRect.top;
      var newWidth = newHeight * aspectRatio;
      if (cropRect.left + newWidth > bounds.right) {
        newWidth = bounds.right - cropRect.left;
        newHeight = newWidth / aspectRatio;
      }
      _setCropRect(
        Rect.fromLTWH(
          cropRect.left,
          cropRect.top,
          newWidth,
          newHeight,
        )
      );
    }
  }

}

extension on ConstraintsSettings {

  BackstageCalculator createCalculator(Backstage backstage) {
    return switch (this) {
      CropAreaConstrainedSettings settings => BackstageCalculatorCropAreaConstrained(backstage, settings: settings),
      ViewportConstrainedSettings settings => BackstageCalculatorViewportConstrained(backstage, settings: settings),
    };
  }

}