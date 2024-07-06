import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../crop_image_widget.dart';
import 'backstage/backstage.dart';
import 'painting/listenable_image_provider.dart';
import 'rendering/crop_clipper.dart';
import 'theme/crop_image_theme.dart';

class CropImage extends StatefulWidget {
  const CropImage({
    required this.image,
    required this.cropArea,
    required this.controller,
    this.settings = const CropSettings.defaults(),
    super.key,
  });

  final ImageProvider image;

  final CropArea cropArea;

  final CropController controller;

  final CropSettings settings;

  @override
  State<CropImage> createState() => _CropImageState();
}

class _CropImageState extends State<CropImage> {
  StreamSubscription? _imagesSubscription;

  late ListenableImageProvider _image;

  late Backstage _backstage;

  late Rect _imageRect = _backstage.imageRect;
  late Rect _cropRect  = _backstage.cropRect;
  late double _scale   = _backstage.scale;

  @override
  void initState() {
    super.initState();
    _backstage = Backstage(
      settings: widget.settings,
      cropArea: widget.cropArea,
    );
    _backstage.addListener(listener);
    _image = ListenableImageProvider(widget.image);
    _imagesSubscription = _image.images.listen((event) {
      _backstage.imageInfo = event.image;
    });
    widget.controller.delegate = _backstage;
  }

  @override
  void dispose() {
    widget.controller.delegate = null;
    _backstage.removeListener(listener);
    _backstage.dispose();
    _image.dispose();
    _imagesSubscription?.cancel();
    _imagesSubscription = null;
    super.dispose();
  }

  @override
  void didUpdateWidget(CropImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.image != widget.image) {
      _imagesSubscription?.cancel();
      _image.dispose();
      _image = ListenableImageProvider(widget.image);
      _imagesSubscription = _image.images.listen((event) {
        _backstage.imageInfo = event.image;
      });
    }
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.delegate = null;
      widget.controller.delegate = _backstage;
    }
    if (oldWidget.settings != widget.settings) {
      _backstage.settings = widget.settings;
    }
    if (oldWidget.cropArea != widget.cropArea) {
      _backstage.cropArea = widget.cropArea;
    }
  }

  void listener() {
    setState(() {
      if (_imageRect != _backstage.imageRect) {
        _imageRect = _backstage.imageRect;
      }
      if (_cropRect != _backstage.cropRect) {
        _cropRect = _backstage.cropRect;
      }
      if (_scale != _backstage.scale) {
        _scale = _backstage.scale;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = CropImageTheme.of(context);

    return Container(
      color: const Color(0xFF000000),
      child: LayoutBuilder(
        builder: (context, constraints) {
          _backstage.viewport = Rect.fromLTRB(0, 0, constraints.maxWidth, constraints.maxHeight);
          return Listener(
            onPointerSignal: (event) {
              if (event is! PointerScrollEvent) {
                return;
              }
              if (event.scrollDelta.dy > 0) {
                _backstage.applyScale(
                  _scale - widget.settings.zoom.zoomSensitivityForScale(_scale),
                  cropRect: _cropRect,
                  imageRect: _imageRect,
                  focalPoint: event.localPosition,
                );
              } else if (event.scrollDelta.dy < 0) {
                _backstage.applyScale(
                  _scale + widget.settings.zoom.zoomSensitivityForScale(_scale),
                  cropRect: _cropRect,
                  imageRect: _imageRect,
                  focalPoint: event.localPosition,
                );
              }
            },
            child: GestureDetector(
              onScaleStart: (details) {
                if (details.pointerCount < 2) {
                  _backstage.startMove(details);
                  return;
                }
                _backstage.startScale(details);
              },
              onScaleUpdate: (ScaleUpdateDetails details) {
                if (details.pointerCount < 2) {
                  _backstage.updateMove(details);
                  return;
                }
                _backstage.updateScale(details);
              },
              onScaleEnd: (details) {
                if (details.pointerCount < 2) {
                  _backstage.endMove();
                  return;
                }
                _backstage.endScale(details);
              },
              child: Stack(
                children: [
                  Positioned(
                    left: _imageRect.left,
                    top: _imageRect.top,
                    child: Image(
                      image: _image,
                      width: _imageRect.width,
                      height: _imageRect.height,
                      fit: BoxFit.contain,
                    ),
                  ),
                  IgnorePointer(
                    child: ClipPath(
                      clipper: widget.cropArea.isCircle
                        ? CropClipper.circle(_cropRect)
                        : CropClipper(_cropRect),
                      child: Stack(
                        children: [
                          Positioned(
                            left: _imageRect.left,
                            top: _imageRect.top,
                            child: ClipRect(
                              child: ImageFiltered(
                                imageFilter: ui.ImageFilter.blur(
                                  sigmaX: 8 * _scale,
                                  sigmaY: 8 * _scale,
                                ),
                                child: Image(
                                  image: _image,
                                  width: _imageRect.width,
                                  height: _imageRect.height,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                          const Positioned.fill(
                            child: ColoredBox(
                              color: Color(0x80000000),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    left: _cropRect.left,
                    top: _cropRect.top,
                    width: _cropRect.width,
                    height: _cropRect.height,
                    child: theme.cropGridBuilder(context),
                  ),
                  Positioned(
                    left: _cropRect.left,
                    top: _cropRect.top,
                    width: _cropRect.width,
                    height: _cropRect.height,
                    child: theme.cropFrameBuilder(context),
                  ),
                  Positioned(
                    left: _cropRect.left,
                    top: _cropRect.top,
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        _backstage.moveCropArea(
                          details.delta.dx,
                          details.delta.dy,
                          cropRect: _cropRect,
                        );
                      },
                      child: SizedBox(
                        width: _cropRect.width,
                        height: _cropRect.height,
                        child: const ColoredBox(
                          color: Color(0x00000000),
                        ),
                      ),
                    )
                  ),
                  Builder(builder: (context) {
                    final indicator = theme.topLeftCornerIndicatorBuilder(context);
                    return Positioned(
                      top: _cropRect.top,
                      left: _cropRect.left,
                      child: GestureDetector(
                        onPanUpdate: widget.cropArea.isEditable
                          ? (details) {
                              _backstage.moveTopLeft(
                                details.delta.dx,
                                details.delta.dy,
                                cropRect: _cropRect,
                                keepAspectRatio: widget.cropArea.keepAspectRatio,
                              );
                            }
                          : null,
                        child: indicator,
                      ),
                    );
                  }),
                  Builder(builder: (context) {
                    final indicator = theme.topRightCornerIndicatorBuilder(context);
                    return Positioned(
                      top: _cropRect.top,
                      left: _cropRect.right - indicator.preferredSize.width,
                      child: GestureDetector(
                        onPanUpdate: widget.cropArea.isEditable
                          ? (details) {
                              _backstage.moveTopRight(
                                details.delta.dx,
                                details.delta.dy,
                                cropRect: _cropRect,
                                keepAspectRatio: widget.cropArea.keepAspectRatio,
                              );
                            }
                          : null,
                        child: indicator,
                      ),
                    );
                  }),
                  Builder(builder: (context) {
                    final indicator = theme.bottomLeftCornerIndicatorBuilder(context);
                    return Positioned(
                      top: _cropRect.bottom - indicator.preferredSize.height,
                      left: _cropRect.left,
                      child: GestureDetector(
                        onPanUpdate: widget.cropArea.isEditable
                          ? (details) {
                              _backstage.moveBottomLeft(
                                details.delta.dx,
                                details.delta.dy,
                                cropRect: _cropRect,
                                keepAspectRatio: widget.cropArea.keepAspectRatio,
                              );
                            }
                          : null,
                        child: indicator,
                      ),
                    );
                  }),
                  Builder(builder: (context) {
                    final indicator = theme.bottomRightCornerIndicatorBuilder(context);
                    return Positioned(
                      top: _cropRect.bottom - indicator.preferredSize.height,
                      left: _cropRect.right - indicator.preferredSize.width,
                      child: GestureDetector(
                        onPanUpdate: widget.cropArea.isEditable
                          ? (details) {
                              _backstage.moveBottomRight(
                                details.delta.dx,
                                details.delta.dy,
                                cropRect: _cropRect,
                                keepAspectRatio: widget.cropArea.keepAspectRatio,
                              );
                            }
                          : null,
                        child: indicator
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        }
      ),
    );
  }

}
