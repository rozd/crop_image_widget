import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import 'cropper/default_cropper.dart';

/// A controller class that manages image cropping operations.
///
/// The [CropController] interacts with a [cropper] and a delegate to
/// perform cropping based on user-selected crop areas and the provided format.
///
/// You can configure the [CropController] with a custom cropper and delegate.
class CropController {

  /// Creates a [CropController] with an optional custom cropper.
  ///
  /// If no custom cropper is provided, the default [DefaultCropper] is used.
  CropController({
    this.cropper = const DefaultCropper(),
  });

  /// The cropper used for cropping the image.
  final ImageCropper cropper;

  /// The delegate provides the image to be cropped, the crop rectangle, and
  /// whether the crop area should be circular.
  CropControllerDelegate? delegate;

  /// Crops the image based on the crop area and format provided by the delegate.
  ///
  /// This method checks if a valid image and crop rectangle are provided by
  /// the delegate, then performs the cropping operation. The cropping will
  /// either be rectangular or oval based on the crop area shape.
  ///
  /// [format] The format in which the cropped image will be returned.
  ///
  /// Returns a [Uint8List] representing the cropped image in the specified
  /// format, or null if either the image or the crop rectangle is not provided.
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
      ? await cropper.cropOval(image, cropRect, format: format)
      : await cropper.cropRect(image, cropRect, format: format);
  }

}

/// An abstract delegate class that provides information required for cropping
/// an image.
///
/// This class serves as the contract that the [CropController] relies on to get
/// the image, the crop rectangle, and information about the crop area shape
/// (rectangular or oval).
/// This level of abstraction is useful as it allows to separate concerns and
/// make cropping functionality that is implemented by the [ImageCropper] and
/// configuration of the crop area independent of each other.
/// This contract is unlikely to need a custom implementation.
abstract class CropControllerDelegate {

  /// Returns the image to be cropped.
  ui.Image? getImage();

  /// Returns the crop rectangle.
  Rect getImageCropRect();

  /// Determines whether the crop area is circular.
  bool isCircleCropArea();
}

/// An abstract class that defines methods for cropping an image.
///
/// This class provides methods for cropping an image in either a rectangular or oval shape.
/// Implementing this class allows for custom cropping behavior.
abstract class ImageCropper {

  /// Crops the image in a rectangular shape.
  ///
  /// [image] The image to be cropped.
  /// [cropRect] The rectangle specifying the crop area.
  /// [format] The format in which the cropped image should be returned.
  ///
  /// Returns a [Uint8List] containing the cropped image in the specified format.
  Future<Uint8List> cropRect(ui.Image image, Rect cropRect, {
    required ui.ImageByteFormat format,
  });

  /// Crops the image in an oval shape.
  ///
  /// [image] The image to be cropped.
  /// [cropRect] The rectangle specifying the crop area (used to determine the oval's bounding box).
  /// [format] The format in which the cropped image should be returned.
  ///
  /// Returns a [Uint8List] containing the cropped image in the specified format.
  Future<Uint8List> cropOval(ui.Image image, Rect cropRect, {
    required ui.ImageByteFormat format,
  });

}