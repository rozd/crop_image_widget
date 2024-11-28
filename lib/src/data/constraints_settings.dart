/// A sealed class representing different types of constraints settings for
/// image manipulation.
sealed class ConstraintsSettings {
  /// Creates an instance of [ConstraintsSettings].
  const ConstraintsSettings();

  /// A factory constructor that creates a [ConstraintsSettings] instance
  /// with a [CropAreaConstrainedSettings].
  ///
  /// [restrictImageToViewport]: A boolean flag that indicates whether the
  /// image should be restricted to the viewport.
  const factory ConstraintsSettings.cropAreaConstrained({
    required bool restrictImageToViewport,
  }) = CropAreaConstrainedSettings;

  /// A factory constructor that creates a [ConstraintsSettings] instance
  /// with a [ViewportConstrainedSettings].
  const factory ConstraintsSettings.viewportConstrained(
  ) = ViewportConstrainedSettings;
}

/// A class that defines the settings for a crop area constrained image
/// manipulation.
class CropAreaConstrainedSettings extends ConstraintsSettings {
  /// A boolean flag that indicates whether the image should be restricted to
  /// the viewport.
  final bool restrictImageToViewport;

  /// Creates an instance of [CropAreaConstrainedSettings].
  ///
  /// [restrictImageToViewport]: A boolean value to define if the image should be
  /// restricted to the viewport.
  const CropAreaConstrainedSettings({
    required this.restrictImageToViewport,
  });
}

/// A class that defines the settings for a viewport-constrained image
/// manipulation.
class ViewportConstrainedSettings extends ConstraintsSettings {
  /// Creates an instance of [ViewportConstrainedSettings].
  const ViewportConstrainedSettings();
}
