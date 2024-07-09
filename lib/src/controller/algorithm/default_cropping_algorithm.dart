import 'dart:typed_data';

import 'dart:ui';

import 'package:crop_image_widget/crop_image_widget.dart';

class DefaultCroppingAlgorithm implements CroppingAlgorithm {

  const DefaultCroppingAlgorithm();

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

  Future<Uint8List> _convertToByteList(Image image, ImageByteFormat format) async {
    final byteData = await image.toByteData(format: format);

    if (byteData == null) {
      throw Exception('Failed to convert image to $format format.');
    }

    return byteData.buffer.asUint8List();
  }

}