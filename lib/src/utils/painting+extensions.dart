import 'package:flutter/painting.dart';

extension ImageInfoWithRatio on ImageInfo {

  double get ratio => image.width / image.height;

  bool get isLandscape => image.width >= image.height;
  bool get isPortrait => image.width < image.height;

}
