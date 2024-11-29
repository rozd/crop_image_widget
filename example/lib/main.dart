import 'dart:typed_data';
import 'dart:ui';

import 'package:crop_image_widget/crop_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scrollBehavior: CustomScrollBehavior(),
      title: 'Crop Image Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Crop Image Widget'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  late final _picker = ImagePicker();

  late final _controller = CropController();

  late ImageProvider _image = const AssetImage('assets/bowl.jpg');

  // MARK: - Settings

  var _margin = 10.0;

  var _cropAreaType = DemoCropAreaType.freeForm;

  var _constraintsType = DemoConstraintsType.viewPort;

  var _constraintsRestrictImageToViewport = true;

  var _isCropAreaEditable = true;

  var _keepAspectRatio = true;

  var _zoomSensitivityCoefficient = 0.05;

  // MARK: - Lifecycle

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        title: Text(widget.title),
        actions: [
          PopupMenuButton<ImageByteFormat>(
            icon: const Icon(Icons.crop),
            onSelected: (ImageByteFormat format) {
              _controller.crop(format: format).then((bytes) {
                if (bytes == null) {
                  return;
                }
                if (!context.mounted) {
                  return;
                }
                _showCroppedImageDialog(bytes);
              });
            },
            itemBuilder: (context) => ImageByteFormat.values.map((format) => PopupMenuItem(
              value: format,
              child: Text(format.nameForDisplay),
            )).toList(),
          ),
        ],
      ),
      backgroundColor: theme.colorScheme.surfaceContainerHigh,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Expanded(
              child: CropImage(
                image: _image,
                controller: _controller,
                cropArea: _cropArea,
                settings: _settings,
              ),
            ),
            const Text('The CropImage widget only provides the UI above this text.'),
            const SizedBox(height: 16,),
            Text('Settings', style: theme.textTheme.titleMedium,),
            Divider(color: theme.colorScheme.outline,),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Crop Area:'),
                    IconButton(
                      isSelected: _cropAreaType == DemoCropAreaType.aspectRatio16x9,
                      onPressed: () {
                        setState(() {
                          _cropAreaType = DemoCropAreaType.aspectRatio16x9;
                        });
                      },
                      icon: const Icon(Icons.crop_16_9),
                    ),
                    IconButton(
                      isSelected: _cropAreaType == DemoCropAreaType.aspectRatio3x2,
                      onPressed: () {
                        setState(() {
                          _cropAreaType = DemoCropAreaType.aspectRatio3x2;
                        });
                      },
                      icon: const Icon(Icons.crop_3_2),
                    ),
                    IconButton(
                      isSelected: _cropAreaType == DemoCropAreaType.aspectRatio5x4,
                      onPressed: () {
                        setState(() {
                          _cropAreaType = DemoCropAreaType.aspectRatio5x4;
                        });
                      },
                      icon: const Icon(Icons.crop_5_4),
                    ),
                    IconButton(
                      isSelected: _cropAreaType == DemoCropAreaType.freeForm,
                      onPressed: () {
                        setState(() {
                          _cropAreaType = DemoCropAreaType.freeForm;
                        });
                      },
                      icon: const Icon(Icons.crop_free),
                    ),
                    IconButton(
                      isSelected: _cropAreaType == DemoCropAreaType.circle,
                      onPressed: () {
                        setState(() {
                          _cropAreaType = DemoCropAreaType.circle;
                        });
                      },
                      icon: const Icon(Icons.circle_outlined),
                    ),
                  ]
                ),
                const SizedBox(width: 24,),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: !_isCropAreaEditable,
                      onChanged: (value) {
                        setState(() {
                          _isCropAreaEditable = !(value ?? false);
                        });
                      },
                    ),
                    const Text('Locked'),
                    const SizedBox(width: 8,),
                    Checkbox(
                      value: _keepAspectRatio,
                      onChanged: _cropAreaType == DemoCropAreaType.circle
                        ? (value) {
                            setState(() {
                              _keepAspectRatio = value ?? false;
                            });
                          }
                        : null,
                    ),
                    const Text('Keep Aspect Ratio'),
                  ]
                )
              ],
            ),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text('Crop Area Margin:'),
                SizedBox(
                  width: 300,
                  child: Slider(
                    value: _margin,
                    max: 100,
                    min: 0,
                    label: _margin.round().toString(),
                    onChanged: _cropAreaType.isAspectRatio
                      ? (double value) {
                          setState(() {
                            _margin = value;
                          });
                        }
                      : null,
                  ),
                ),
              ],
            ),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text('Constraints:'),
                const SizedBox(width: 8,),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Radio(
                      value: DemoConstraintsType.viewPort,
                      groupValue: _constraintsType,
                      onChanged: (value) {
                        setState(() {
                          _constraintsType = DemoConstraintsType.viewPort;
                        });
                      },
                    ),
                    const Text('View Port'),
                  ],
                ),
                const SizedBox(width: 8,),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Radio(
                      value: DemoConstraintsType.cropArea,
                      groupValue: _constraintsType,
                      onChanged: (value) {
                        setState(() {
                          _constraintsType = DemoConstraintsType.cropArea;
                        });
                      },
                    ),
                    const Text('Crop Area'),
                  ],
                ),
                const SizedBox(width: 8,),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: _constraintsRestrictImageToViewport,
                      onChanged: _constraintsType == DemoConstraintsType.cropArea
                        ? (value) {
                            setState(() {
                              _constraintsRestrictImageToViewport = value ?? true;
                            });
                          }
                        : null,
                    ),
                    const Text('Restrict image to viewport'),
                  ],
                ),
              ],
            ),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text('Zoom Sensitivity:'),
                SizedBox(
                  width: 300,
                  child: Slider(
                    value: _zoomSensitivityCoefficient,
                    max: 0.1,
                    min: 0.0,
                    divisions: 10,
                    label: _zoomSensitivityCoefficient.toString(),
                    onChanged: (double value) {
                      setState(() {
                        _zoomSensitivityCoefficient = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ]
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        tooltip: 'Upload',
        child: const Icon(Icons.upload),
      ),
    );
  }

  // MARK: - Handlers

  Future _pickImage() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    setState(() {
      _image = NetworkImage(file.path);
    });
  }

  Future _showCroppedImageDialog(Uint8List bytes) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Image.memory(bytes),
        );
      }
    );
  }
}

class CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}

// MARK: - Demo support types

enum DemoCropAreaType {
  aspectRatio3x2,
  aspectRatio5x4,
  aspectRatio16x9,
  freeForm,
  circle,
}

extension on DemoCropAreaType {

  bool get isAspectRatio {
    return aspectRatio != null;
  }

  double? get aspectRatio {
    switch (this) {
      case DemoCropAreaType.aspectRatio3x2:
        return 3 / 2;
      case DemoCropAreaType.aspectRatio5x4:
        return 5 / 4;
      case DemoCropAreaType.aspectRatio16x9:
        return 16 / 9;
      default:
        return null;
    }
  }
}

enum DemoConstraintsType {
  viewPort,
  cropArea,
}

extension ImageByteFormatForDisplay on ImageByteFormat {

  String get nameForDisplay {
    switch (this) {
      case ImageByteFormat.rawRgba:
        return 'RGBA';
      case ImageByteFormat.rawUnmodified:
        return 'Unmodified';
      case ImageByteFormat.rawStraightRgba:
        return 'RGBA with straight alpha';
      case ImageByteFormat.png:
        return 'PNG';
      default:
        return 'Unknown';
    }
  }

}

// MARK: - Settings routines

extension on _MyHomePageState {

  CropArea get _cropArea {
    final aspectRatio = _cropAreaType.aspectRatio;
    if (aspectRatio != null) {
      return CropArea.aspectRatio(aspectRatio,
        isEditable: _isCropAreaEditable,
        margin: _margin,
      );
    } else if (_cropAreaType == DemoCropAreaType.circle) {
      return CropArea.circle(const Size.square(96),
        isEditable: _isCropAreaEditable,
        keepAspectRatio: _keepAspectRatio,
      );
    } else {
      return CropArea.free(const Size.square(96),
        isEditable: _isCropAreaEditable,
      );
    }
  }

  CropSettings get _settings {
    return CropSettings(
      constraints: _constraintsSettings,
      zoom: _zoomSettings,
    );
  }

  ZoomSettings get _zoomSettings {
    return ZoomSettings(
      zoomSensitivityForScale: (double scale) {
        return _zoomSensitivityCoefficient * scale;
      },
      shouldUpdateScale: (scale) => true,
    );
  }

  ConstraintsSettings get _constraintsSettings {
    switch (_constraintsType) {
      case DemoConstraintsType.viewPort:
        return const ConstraintsSettings.viewportConstrained();
      case DemoConstraintsType.cropArea:
        return ConstraintsSettings.cropAreaConstrained(
          restrictImageToViewport: _constraintsRestrictImageToViewport,
        );
    }
  }

}