import 'package:crop_image_widget/src/data/constraints_settings.dart';
import 'package:crop_image_widget/src/data/zoom_settings.dart';

final class CropSettings {
  const CropSettings({
    required this.zoom,
    required this.constraints,
  });

  const CropSettings.defaults() : this(
    zoom: const ZoomSettings.defaults(),
    constraints: const ConstraintsSettings.cropAreaConstrained(
      restrictImageToViewport: true,
    ),
  );

  final ZoomSettings zoom;
  final ConstraintsSettings constraints;
}