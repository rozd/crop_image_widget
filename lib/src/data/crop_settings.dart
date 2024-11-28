import 'package:crop_image_widget/src/data/constraints_settings.dart';
import 'package:crop_image_widget/src/data/zoom_settings.dart';

/// A class that encapsulates the settings related to image cropping.
/// It includes [zoom] settings for controlling zoom behavior and
/// [constraints] settings
/// for defining the constraints of the crop area.
final class CropSettings {
  /// Creates an instance of [CropSettings].
  ///
  /// [zoom]: The [ZoomSettings] that define the zoom behavior.
  /// [constraints]: The [ConstraintsSettings] that define the constraints of the crop area.
  const CropSettings({
    required this.zoom,
    required this.constraints,
  });

  /// A default constructor for [CropSettings], setting default values for zoom
  /// and constraints.
  ///
  /// The default [ZoomSettings] is created via [ZoomSettings.defaults()], and the default
  /// [ConstraintsSettings] uses [ConstraintsSettings.cropAreaConstrained], with
  /// [restrictImageToViewport] set to `true`.
  const CropSettings.defaults() : this(
    zoom: const ZoomSettings.defaults(),
    constraints: const ConstraintsSettings.cropAreaConstrained(
      restrictImageToViewport: true,
    ),
  );

  /// The zoom settings for the crop area.
  final ZoomSettings zoom;

  /// The constraints settings for the crop area.
  final ConstraintsSettings constraints;
}
