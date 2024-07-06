import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:crop_image_widget/src/controller/algorithm/default_cropping_algorithm.dart';
import 'package:flutter/painting.dart';

class CropController {

  CropController({
    this.algorithm = const DefaultCroppingAlgorithm(),
  });

  final CroppingAlgorithm algorithm;

  CropControllerDelegate? delegate;

  Future<Uint8List?> crop({
    required ui.ImageByteFormat format,
  }) async {
    final image = delegate?.getImage();
    if (image == null) {
      return null;
    }
    final cropRect = delegate?.getImageCropRect();
    if (cropRect == null) {
      return null;
    }
    final isCircle = delegate?.isCircleCropArea() ?? false;
    return isCircle
      ? await algorithm.cropOval(image, cropRect, format: format)
      : await algorithm.cropRect(image, cropRect, format: format);
  }

}

abstract class CropControllerDelegate {

  ui.Image? getImage();

  Rect getImageCropRect();

  bool isCircleCropArea();

}

abstract class CroppingAlgorithm {

  Future<Uint8List> cropRect(ui.Image image, Rect cropRect, {
    required ui.ImageByteFormat format,
  });

  Future<Uint8List> cropOval(ui.Image image, Rect cropRect, {
    required ui.ImageByteFormat format,
  });

}