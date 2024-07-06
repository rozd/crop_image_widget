sealed class ConstraintsSettings {
  const ConstraintsSettings();

  const factory ConstraintsSettings.cropAreaConstrained({
    required bool restrictImageToViewport,
  }) = CropAreaConstrainedSettings;

  const factory ConstraintsSettings.viewportConstrained(
  ) = ViewportConstrainedSettings;
}

class CropAreaConstrainedSettings extends ConstraintsSettings {
  final bool restrictImageToViewport;
  const CropAreaConstrainedSettings({
    required this.restrictImageToViewport,
  });
}

class ViewportConstrainedSettings extends ConstraintsSettings {
  const ViewportConstrainedSettings();
}
