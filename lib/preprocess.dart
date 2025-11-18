import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Prepare a resized RGB Uint8List from BGRA camera bytes.
/// 
/// Compatible with 'image' package version 4.x
Uint8List prepareInputForQuant(Map<String, dynamic> args) {
  final Uint8List bytes = args['bytes'] as Uint8List;
  final int width = args['width'] as int;
  final int height = args['height'] as int;
  final int rowStride = args['rowStride'] as int;
  final int targetW = args['targetW'] as int;
  final int targetH = args['targetH'] as int;

  // 1. Create an empty image container (v4 uses named arguments)
  final image = img.Image(width: width, height: height);

  // 2. Fill pixels from BGRA buffer.
  // BGRA layout: bytes are [B, G, R, A] per pixel. 
  // rowStride is often > width * 4 due to padding.
  for (int y = 0; y < height; y++) {
    final int rowStart = y * rowStride;
    for (int x = 0; x < width; x++) {
      final int byteIndex = rowStart + (x * 4);

      // Safety check for buffer overflow
      if (byteIndex + 3 >= bytes.length) {
        image.setPixelRgba(x, y, 0, 0, 0, 255);
        continue;
      }

      final int b = bytes[byteIndex];
      final int g = bytes[byteIndex + 1];
      final int r = bytes[byteIndex + 2];
      final int a = bytes[byteIndex + 3];

      // Set the pixel. Note: In 'image' v4, the arguments are (x, y, r, g, b, a)
      image.setPixelRgba(x, y, r, g, b, a);
    }
  }

  // 3. Resize to model input size
  final resized = img.copyResize(
    image,
    width: targetW,
    height: targetH,
    interpolation: img.Interpolation.linear,
  );

  // 4. Build RGB output (no alpha) for the model
  final out = Uint8List(targetW * targetH * 3);
  int outIdx = 0;

  // In 'image' v4, we can iterate over the pixels directly.
  // This is much cleaner than bit-shifting 32-bit integers.
  for (final pixel in resized) {
    // pixel.r, pixel.g, pixel.b return num/int values directly.
    out[outIdx++] = pixel.r.toInt();
    out[outIdx++] = pixel.g.toInt();
    out[outIdx++] = pixel.b.toInt();
  }

  return out;
}