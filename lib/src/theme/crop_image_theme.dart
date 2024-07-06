import 'package:crop_image_widget/src/theme/widgets/crop_corner_widget.dart';
import 'package:crop_image_widget/src/theme/widgets/crop_frame_widget.dart';
import 'package:crop_image_widget/src/theme/widgets/crop_grid_widget.dart';
import 'package:flutter/widgets.dart';

typedef CornerIndicatorBuilder = PreferredSizeWidget Function(BuildContext context);

Widget _defaultCropGridBuilder(BuildContext context) {
  return const CropGridWidget();
}

Widget _defaultCropFrameBuilder(BuildContext context) {
  return const CropFrameWidget();
}

PreferredSizeWidget _defaultTopLeftCornerIndicatorBuilder(BuildContext context) {
  return const TopLeftCornerIndicator();
}

PreferredSizeWidget _defaultTopRightCornerIndicatorBuilder(BuildContext context) {
  return const TopRightCornerIndicator();
}

PreferredSizeWidget _defaultBottomLeftCornerIndicatorBuilder(BuildContext context) {
  return const BottomLeftCornerIndicator();
}

PreferredSizeWidget _defaultBottomRightCornerIndicatorBuilder(BuildContext context) {
  return const BottomRightCornerIndicator();
}

class CropImageThemeData {
  const CropImageThemeData({
    this.cropGridBuilder = _defaultCropGridBuilder,
    this.cropFrameBuilder = _defaultCropFrameBuilder,
    this.topLeftCornerIndicatorBuilder = _defaultTopLeftCornerIndicatorBuilder,
    this.topRightCornerIndicatorBuilder = _defaultTopRightCornerIndicatorBuilder,
    this.bottomLeftCornerIndicatorBuilder = _defaultBottomLeftCornerIndicatorBuilder,
    this.bottomRightCornerIndicatorBuilder = _defaultBottomRightCornerIndicatorBuilder,
  });

  final WidgetBuilder cropGridBuilder;
  final WidgetBuilder cropFrameBuilder;

  final CornerIndicatorBuilder topLeftCornerIndicatorBuilder;
  final CornerIndicatorBuilder topRightCornerIndicatorBuilder;
  final CornerIndicatorBuilder bottomLeftCornerIndicatorBuilder;
  final CornerIndicatorBuilder bottomRightCornerIndicatorBuilder;
}

class CropImageTheme extends InheritedWidget {

  static CropImageThemeData of(BuildContext context) {
    final theme = context.dependOnInheritedWidgetOfExactType<CropImageTheme>();
    return theme?.data ?? const CropImageThemeData();
  }

  final CropImageThemeData data;

  const CropImageTheme({
    required this.data,
    required super.child,
    super.key,
  });

  @override
  bool updateShouldNotify(CropImageTheme oldWidget) => data != oldWidget.data;
}