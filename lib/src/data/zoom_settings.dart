double _defaultZoomSensitivityForScale(double scale) {
  return 0.05 * scale;
}

bool _defaultShouldUpdateScale(double scale) => true;

/// A class that encapsulates settings related to zoom behavior for cropping.
/// It provides configuration for zoom sensitivity and whether the scale should be updated.
final class ZoomSettings {
  /// Creates an instance of [ZoomSettings].
  ///
  /// [zoomSensitivityForScale]: A function that calculates the zoom sensitivity for a given scale.
  /// [shouldUpdateScale]: A function that determines whether the scale should be updated for a given scale.
  const ZoomSettings({
    required this.zoomSensitivityForScale,
    required this.shouldUpdateScale,
  });

  /// A default constructor for [ZoomSettings], using default functions for zoom sensitivity and scale update behavior.
  ///
  /// The default `zoomSensitivityForScale` function calculates the sensitivity as `0.05 * scale`.
  /// The default `shouldUpdateScale` function always returns `true`, meaning the scale will always be updated.
  const ZoomSettings.defaults() : this(
    zoomSensitivityForScale: _defaultZoomSensitivityForScale,
    shouldUpdateScale: _defaultShouldUpdateScale,
  );

  /// A function that calculates the zoom sensitivity based on the given scale.
  ///
  /// This function returns `0.05 * scale` by default, which means the sensitivity is proportional to the scale.
  final double Function(double scale) zoomSensitivityForScale;

  /// A function that determines whether the scale should be updated.
  ///
  /// This function returns `true` by default, meaning that the scale should always be updated.
  final bool Function(double scale) shouldUpdateScale;
}