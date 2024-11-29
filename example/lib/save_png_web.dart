import 'dart:convert';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

Future<void> savePNG(Uint8List bytes) async {
  final web.HTMLAnchorElement anchor =
  web.document.createElement('a') as web.HTMLAnchorElement
    ..href = "data:image/png;base64,${base64Encode(bytes)}"
    ..style.display = 'none'
    ..download = 'cropped.png';
  web.document.body!.appendChild(anchor);
  anchor.click();
  web.document.body!.removeChild(anchor);
}
