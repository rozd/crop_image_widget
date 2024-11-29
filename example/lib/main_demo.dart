import 'dart:typed_data';
import 'dart:ui';

import 'package:crop_image_widget/crop_image_widget.dart';
import 'package:example/main.dart';
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
      home: const MyHomePage(title: 'Crop Image Widget Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {

  late final _picker = ImagePicker();

  late final _aspectRatioController = CropController();
  late final _freeFormController = CropController();
  late final _circledController = CropController();
  late final _controllers = [
    _aspectRatioController,
    _freeFormController,
    _circledController,
  ];

  late ImageProvider _image = const AssetImage('assets/bowl.jpg');

  // MARK: - Lifecycle

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            Builder(
              builder: (context) {
                return PopupMenuButton<ImageByteFormat>(
                  icon: const Icon(Icons.crop),
                  onSelected: (ImageByteFormat format) {
                    final tabController = DefaultTabController.of(context);
                    final controller = _controllers[tabController.index];
                    controller.crop(format: format).then((bytes) {
                      if (bytes == null) {
                        return;
                      }
                      if (!context.mounted) {
                        return;
                      }
                      _showCroppedImageDialog(bytes);
                    }).onError((error, stackTrace) {
                      print(error.toString());
                    });
                  },
                  itemBuilder: (context) => ImageByteFormat.values.map((format) => PopupMenuItem(
                    value: format,
                    child: Text(format.nameForDisplay),
                  )).toList(),
                );
              }
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Aspect ratio'),
              Tab(text: 'Free Form',),
              Tab(text: 'Oval',)
            ]
          ),
        ),
        backgroundColor: theme.colorScheme.surfaceContainerHigh,
        body: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Expanded(
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    CropImage(
                      image: _image,
                      controller: _aspectRatioController,
                      cropArea: CropArea.aspectRatio(16 / 9,
                        isEditable: true,
                        margin: 0
                      ),
                    ),
                    CropImage(
                      image: _image,
                      controller: _freeFormController,
                      cropArea: CropArea.free(const Size.square(128),
                        isEditable: true,
                      ),
                    ),
                    CropImage(
                      image: _image,
                      controller: _circledController,
                      cropArea: CropArea.circle(const Size.square(128),
                        keepAspectRatio: true,
                        isEditable: true,
                      ),
                    ),
                ]),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _pickImage,
          tooltip: 'Upload',
          child: const Icon(Icons.upload),
        ),
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