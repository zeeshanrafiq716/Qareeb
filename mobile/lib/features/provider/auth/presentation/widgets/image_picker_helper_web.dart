// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

/// Web image picker implementation with automatic fallback to HTML file upload
Future<({Uint8List bytes, String name})?> pickImageCustom({
  required ImageSource source,
}) async {
  // 1. Attempt standard ImagePicker first
  try {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 88,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      return (bytes: bytes, name: picked.name);
    }
    return null;
  } catch (_) {
    // Falls back to direct browser HTML file input if plugin is not registered
    // in the currently running web dev session
  }

  // 2. Direct browser HTML5 file input fallback
  final completer = Completer<({Uint8List bytes, String name})?>();
  final uploadInput = html.FileUploadInputElement();
  uploadInput.accept = 'image/*';
  if (source == ImageSource.camera) {
    uploadInput.setAttribute('capture', 'environment');
  }

  uploadInput.onChange.listen((event) {
    final files = uploadInput.files;
    if (files != null && files.isNotEmpty) {
      final file = files[0];
      final reader = html.FileReader();
      reader.onLoadEnd.listen((event) {
        final result = reader.result;
        if (result is Uint8List) {
          completer.complete((bytes: result, name: file.name));
        } else if (result is ByteBuffer) {
          completer.complete((bytes: result.asUint8List(), name: file.name));
        } else if (result is List<int>) {
          completer.complete((bytes: Uint8List.fromList(result), name: file.name));
        } else {
          completer.complete(null);
        }
      });
      reader.onError.listen((event) => completer.complete(null));
      reader.readAsArrayBuffer(file);
    } else {
      completer.complete(null);
    }
  });

  uploadInput.click();
  return completer.future;
}
