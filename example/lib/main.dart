import 'dart:typed_data';
import 'dart:ui';

import 'package:crop_image_widget/crop_image_widget.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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

  late final _controller = CropController();

  // MARK: - Lifecycle

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: 'Crop as PNG',
            onPressed: () {
              _controller.crop(format: ImageByteFormat.png).then((bytes) {
                if (bytes == null) {
                  return;
                }
                if (!context.mounted) {
                  return;
                }
                _showCroppedImageDialog(bytes, ImageByteFormat.png);
              });
            },
            icon: const Icon(Icons.crop),
          )
        ],
      ),
      backgroundColor: theme.colorScheme.surfaceContainerHigh,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Expanded(
              child: CropImage(
                image: const AssetImage('assets/bowl.jpg'),
                controller: _controller,
                cropArea: CropArea.aspectRatio(16 / 9,
                  isEditable: true,
                  margin: 32,
                ),
                settings: const CropSettings(
                  constraints: ConstraintsSettings.viewportConstrained(),
                  zoom: ZoomSettings.defaults(),
                ),
              ),
            ),
          ]
        ),
      ),
    );
  }

  // MARK: - Handlers

  Future _showCroppedImageDialog(
    Uint8List bytes,
    ImageByteFormat format,
  ) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Complete'),
          content: Text('Bytes length of cropped image : ${bytes.length}'),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK')
            )
          ],
        );
      }
    );
  }

}
