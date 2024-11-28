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
      scrollBehavior: CustomScrollBehavior(),
      title: 'Crop Image Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Crop Image'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Stack(
          children: [
            CropImage(
              image: _image,
              controller: _controller,
              cropArea: CropArea.aspectRatio(16 / 9,
                isEditable: true,
                margin: 32,
              ),
            ),
            Positioned(
              left: 8,
              bottom: 8,
              child: ElevatedButton(
                onPressed: () {
                  _controller.crop(format: ImageByteFormat.rawUnmodified).then((bytes) {
                    if (bytes == null) {
                      return;
                    }
                    if (!context.mounted) {
                      return;
                    }
                    _showCroppedImageDialog(bytes);
                  });
                },
                child: const Text('Crop'),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        tooltip: 'Upload',
        child: const Icon(Icons.upload),
      ),
    );
  }

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
