import 'dart:typed_data';

import 'dart:ui';

import '../crop_controller.dart';

/// A default implementation of [ImageCropper] that provides basic cropping
/// functionality.
///
/// The [DefaultCropper] supports cropping images in both rectangular and oval
/// shapes. It uses a [Canvas] to draw the cropped portion of the image and then
/// converts the resulting image into a byte list in the specified format.
class DefaultCropper implements ImageCropper {

  /// Creates a new instance of [DefaultCropper].
  const DefaultCropper();

  /// Crops the given image in a rectangular shape.
  ///
  /// This method takes an image and a rectangle specifying the area to crop.
  /// It draws the cropped portion onto a new canvas and then returns the result
  /// as a [Uint8List] in the specified format.
  ///
  /// [image] The image to be cropped.
  /// [cropRect] The rectangle specifying the crop area.
  /// [format] The format to return the cropped image in.
  ///
  /// Returns a [Future<Uint8List>] containing the cropped image in the
  /// specified format.
  @override
  Future<Uint8List> cropRect(Image image, Rect cropRect, {
    required ImageByteFormat format,
  }) async {
    final recorder = PictureRecorder();
    Canvas(recorder).drawImageRect(
      image,
      cropRect,
      Rect.fromLTRB(0, 0, cropRect.width, cropRect.height),
      Paint(),
    );

    final croppedImage = await recorder.endRecording().toImage(
      cropRect.width.toInt(),
      cropRect.height.toInt(),
    );
    return _convertToByteList(croppedImage, format);
  }

  /// Crops the given image in an oval shape.
  ///
  /// This method takes an image and a rectangle specifying the area to crop.
  /// It draws the cropped portion of the image within an oval shape, clips the
  /// canvas, and then returns the result as a [Uint8List] in the specified
  /// format.
  ///
  /// [image] The image to be cropped.
  /// [cropRect] The rectangle specifying the bounding box of the oval crop area.
  /// [format] The format to return the cropped image in.
  ///
  /// Returns a [Future<Uint8List>] containing the cropped image in the
  /// specified format.
  @override
  Future<Uint8List> cropOval(Image image, Rect cropRect, {
    required ImageByteFormat format,
  }) {
    final recorder = PictureRecorder();
    final circlePath = Path()
      ..addOval(
        Rect.fromLTRB(
          0,
          0,
          cropRect.width,
          cropRect.height,
        ),
      );
    Canvas(recorder)
      ..clipPath(circlePath)
      ..drawImageRect(
        image,
        cropRect,
        Rect.fromLTRB(0, 0, cropRect.width, cropRect.height),
        Paint(),
      );

    final croppedImage = recorder.endRecording().toImageSync(
      cropRect.width.toInt(),
      cropRect.height.toInt(),
    );
    return _convertToByteList(croppedImage, format);
  }

  /// Converts the cropped image to a byte list in the specified format.
  ///
  /// This private method takes an [Image] and converts it to a [Uint8List] in
  /// the desired format (such as PNG or JPEG). It returns the byte data of the
  /// image.
  ///
  /// [image] The image to be converted.
  /// [format] The format to convert the image to (e.g., PNG or JPEG).
  ///
  /// Returns a [Future<Uint8List>] containing the image byte data in the
  /// specified format.
  Future<Uint8List> _convertToByteList(Image image, ImageByteFormat format) async {
    final byteData = await image.toByteData(format: format);

    if (byteData == null) {
      throw Exception('Failed to convert image to $format format.');
    }

    return byteData.buffer.asUint8List();
  }

}