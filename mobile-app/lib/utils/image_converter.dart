import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;

/// Converts any image to JPG and returns the new file path.
Future<String> convertToJpg(String imagePath) async {
  final file = File(imagePath);

  final bytes = await file.readAsBytes();

  final image = img.decodeImage(bytes);

  if (image == null) {
    throw Exception("Cannot decode image");
  }

  final jpgBytes = img.encodeJpg(image, quality: 90);

  final newPath = path.join(
    file.parent.path,
    "${path.basenameWithoutExtension(imagePath)}_converted.jpg",
  );

  final newFile = File(newPath);

  await newFile.writeAsBytes(jpgBytes);

  return newFile.path;
}