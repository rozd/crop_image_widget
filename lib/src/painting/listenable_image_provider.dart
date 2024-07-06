import 'dart:async';

import 'package:flutter/widgets.dart';

class ListenableImageProvider<T extends Object> implements ImageProvider<T> {

  ListenableImageProvider(this.provider);

  final ImageProvider<T> provider;

  @mustCallSuper
  void dispose() {
    __imageStream?.removeListener(_listener);
    __imageStream = null;
  }

  ImageStream? __imageStream;
  set _imageStream(ImageStream value) {
    if (value == __imageStream) {
      return;
    }
    final oldImageStream = __imageStream;
    __imageStream = value;
    if (__imageStream?.key != oldImageStream?.key) {
      oldImageStream?.removeListener(_listener);
      __imageStream?.addListener(_listener);
    }
  }

  late final ImageStreamListener _listener = ImageStreamListener((ImageInfo image, bool synchronousCall) {
    _images?.add((image: image, synchronousCall: synchronousCall));
  });

  StreamController<({ImageInfo image, bool synchronousCall})>? _images;
  Stream<({ImageInfo image, bool synchronousCall})> get images {
    _images ??= StreamController.broadcast(
      onCancel: () {
        _images = null;
        __imageStream?.removeListener(_listener);
        __imageStream = null;
      },
    );
    return _images!.stream.distinct((previous, next) {
      return previous.image == next.image && previous.synchronousCall == next.synchronousCall;
    },);
  }

  @override
  ImageStream createStream(ImageConfiguration configuration) {
    return _imageStream = provider.createStream(configuration);
  }

  @override
  Future<bool> evict({
    ImageCache? cache,
    ImageConfiguration configuration = ImageConfiguration.empty,
  }) {
    return provider.evict(cache: cache, configuration: configuration);
  }

  @override
  @Deprecated(
    'Implement loadImage for image loading. '
    'This feature was deprecated after v3.7.0-1.4.pre.',
  )
  ImageStreamCompleter loadBuffer(T key, DecoderBufferCallback decode) {
    return provider.loadBuffer(key, decode);
  }

  @override
  ImageStreamCompleter loadImage(T key, ImageDecoderCallback decode) {
    return provider.loadImage(key, decode);
  }

  @override
  Future<ImageCacheStatus?> obtainCacheStatus({
    required ImageConfiguration configuration,
    ImageErrorListener? handleError,
  }) {
    return provider.obtainCacheStatus(
      configuration: configuration,
      handleError: handleError,
    );
  }

  @override
  Future<T> obtainKey(ImageConfiguration configuration) {
    return provider.obtainKey(configuration);
  }

  @override
  ImageStream resolve(ImageConfiguration configuration) {
    return _imageStream = provider.resolve(configuration);
  }

  @override
  void resolveStreamForKey(
    ImageConfiguration configuration,
    ImageStream stream, T key,
    ImageErrorListener handleError,
  ) {
    provider.resolveStreamForKey(configuration, stream, key, handleError);
    _imageStream = stream;
  }

}