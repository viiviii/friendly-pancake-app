import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

extension MyTestGesture on WidgetController {
  Future<TestGesture> createMouse() {
    return createGesture(kind: ui.PointerDeviceKind.mouse);
  }
}

/// 👀 https://github.com/flutter/flutter/blob/3.7.12/packages/flutter/test/painting/image_test_utils.dart
class TestImageProvider extends ImageProvider<TestImageProvider> {
  const TestImageProvider(this.image);

  final ui.Image image;

  @override
  Future<TestImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<TestImageProvider>(this);
  }

  @override
  ImageStreamCompleter loadBuffer(
      TestImageProvider key, DecoderBufferCallback decode) {
    return OneFrameImageStreamCompleter(
      SynchronousFuture<ImageInfo>(ImageInfo(image: image)),
    );
  }
}
