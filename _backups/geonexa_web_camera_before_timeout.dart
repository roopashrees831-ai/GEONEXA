import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

@JS('geonexaCapturePhoto')
external JSPromise<JSString> _capturePhoto();

@JS('geonexaClassifyPhoto')
external JSPromise<JSString> _classifyPhoto(JSString imageData);

Future<Uint8List?> captureGeonexaWebPhoto() async {
  try {
    final result = await _capturePhoto().toDart;

    final dataUrl = result.toDart;

    if (dataUrl.isEmpty) {
      return null;
    }

    final comma = dataUrl.indexOf(',');

    if (comma < 0) {
      return null;
    }

    return Uint8List.fromList(base64Decode(dataUrl.substring(comma + 1)));
  } catch (_) {
    return null;
  }
}

Future<Map<String, dynamic>?> classifyGeonexaWebPhoto(Uint8List bytes) async {
  try {
    final dataUrl =
        'data:image/jpeg;base64,'
        '${base64Encode(bytes)}';

    final raw = await _classifyPhoto(dataUrl.toJS).toDart;

    final text = raw.toDart;

    if (text.isEmpty) {
      return null;
    }

    final decoded = jsonDecode(text);

    if (decoded is! Map) {
      return null;
    }

    return Map<String, dynamic>.from(decoded);
  } catch (_) {
    return null;
  }
}
