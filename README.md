# Crop Image Widget

A Flutter widget for cropping sections of an image provided by an `ImageProvider`.

---

## Key Features

- **Zero Dependencies**: Cropping is implemented using Flutter's standard painting API, ensuring compatibility across all Flutter platforms.
- **Aesthetic Blur Background**: Provides a visually pleasing blurred background effect (subjective preference).
- **Minimalistic Interface**: Designed for simplicity and ease of use (subjective preference).
- **Highly Customizable**: Focused on balancing flexibility and simplicity without overwhelming the API.
- **Rich Feature Set**: Offers most of the essential functionalities expected from an image cropper:
    - Resize the crop area by dragging the edges of the grid overlay.
    - Restrict the crop area to a specific aspect ratio.
    - Move and scale the image using gestures.
    - Support for circular crop areas.
    - **Note**: Currently, image rotation is not supported.

---

## Demo

[Include screenshots, videos, or links showcasing the widget in action.]

---

## Usage Examples

### Examples of Crop Area Settings

#### Aspect Ratio Crop Area
```dart
CropImage(
  image: _image,
  controller: _aspectRatioController,
  cropArea: CropArea.aspectRatio(16 / 9,
    isEditable: true,
    margin: 0,
  ),
),
```
<img width="320" alt="Aspect Ratio Crop" src="docs/screenshots/example-aspect-ratio.png">

#### Free-Form Crop Area
```dart
CropImage(
  image: _image,
  controller: _freeFormController,
  cropArea: CropArea.free(const Size.square(256),
    isEditable: true,
  ),
),
```
<img width="320" alt="Aspect Ratio Crop" src="docs/screenshots/example-free-form.png">

#### Circle Crop Area
```dart
CropImage(
  image: _image,
  controller: _circleController,
  cropArea: CropArea.circle(const Size.square(256),
    isEditable: true,
  ),
),
```
<img width="320" alt="Aspect Ratio Crop" src="docs/screenshots/example-circle.png">

## Limitations
The html web renderer is not supported.

## Credits
Image used in the demo is by David Foodphototasty on Unsplash.