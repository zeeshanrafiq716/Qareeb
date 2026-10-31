import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

/// Native (Android / iOS / Desktop) image picker implementation
Future<({Uint8List bytes, String name})?> pickImageCustom({
  required ImageSource source,
}) async {
  final picker = ImagePicker();
  final picked = await picker.pickImage(
    source: source,
    maxWidth: 1920,
    maxHeight: 1920,
    imageQuality: 88,
  );

  if (picked == null) return null;
  final bytes = await picked.readAsBytes();
  return (bytes: bytes, name: picked.name);
}
