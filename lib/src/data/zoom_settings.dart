double _defaultZoomSensitivityForScale(double scale) {
  return 0.05 * scale;
}

bool _defaultShouldUpdateScale(double scale) => true;

final class ZoomSettings {

  const ZoomSettings({
    required this.zoomSensitivityForScale,
    required this.shouldUpdateScale,
  });

  const ZoomSettings.defaults() : this(
    zoomSensitivityForScale: _defaultZoomSensitivityForScale,
    shouldUpdateScale: _defaultShouldUpdateScale,
  );

  final double Function(double scale) zoomSensitivityForScale;

  final bool Function(double scale) shouldUpdateScale;
}

