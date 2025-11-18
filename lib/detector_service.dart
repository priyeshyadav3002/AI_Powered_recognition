// lib/detector_service.dart
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'recognition.dart';
import 'package:flutter/material.dart';

class DetectorService {
  late Interpreter _interpreter;
  late List<String> labels;
  bool isReady = false;

  /// Call once at startup
  Future<void> loadModel({
    String modelPath = 'assets/detect.tflite',
    String labelsPath = 'assets/labelmap.txt',
  }) async {
    _interpreter = await Interpreter.fromAsset(modelPath);
    final raw = await rootBundle.loadString(labelsPath);
    labels = raw
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    isReady = true;
    // debug
    // ignore: avoid_print
    print('DetectorService: model loaded, labels=${labels.length}');
  }

  /// Run inference on a quantized model using an RGB Uint8List shaped as [1, H, W, 3]
  /// `input` should be a Uint8List of length H*W*3 (we pass the interpreter a 1D buffer).
  /// Returns detections with normalized coordinates (0..1).
  List<Recognition> runOnFrame(Uint8List input,
      {int inputWidth = 300, int inputHeight = 300, double threshold = 0.45}) {
    if (!isReady) return [];

    // Prepare outputs for typical SSD MobileNet quantized (COCO):
    const int maxResults = 10;
    // outputs must match TFLite model signature order. For common ssd_mobilenet:
    // 0: boxes -> [1, maxResults, 4]
    // 1: classes -> [1, maxResults]
    // 2: scores -> [1, maxResults]
    // 3: num_detections -> [1]
    var outputBoxes = List.generate(1, (_) => List.generate(maxResults, (_) => List.filled(4, 0.0)));
    var outputClasses = List.generate(1, (_) => List.filled(maxResults, 0.0));
    var outputScores = List.generate(1, (_) => List.filled(maxResults, 0.0));
    var numDetections = List.filled(1, 0.0);

    final outputs = <int, Object>{
      0: outputBoxes,
      1: outputClasses,
      2: outputScores,
      3: numDetections,
    };

    // The interpreter will accept the raw bytes as input (quantized). We wrap input in a list:
    try {
      _interpreter.runForMultipleInputs([input], outputs);
    } catch (e) {
      // ignore: avoid_print
      print('Interpreter run error: $e');
      return [];
    }

    final int N = (numDetections[0]).toInt();
    final List<Recognition> results = [];

    for (int i = 0; i < N && i < maxResults; i++) {
      final double score = (outputScores[0][i] as double);
      if (score < threshold) continue;

      int classId = (outputClasses[0][i] as double).toInt();
      String label = (classId >= 0 && classId < labels.length) ? labels[classId] : 'class_$classId';

      final box = outputBoxes[0][i];
      // box order in many SSD models is [top, left, bottom, right]
      final double top = box[0];
      final double left = box[1];
      final double bottom = box[2];
      final double right = box[3];

      results.add(Recognition(i, label, score, Rect.fromLTRB(left, top, right, bottom)));
    }

    return results;
  }

  void close() {
    try {
      _interpreter.close();
    } catch (_) {}
    isReady = false;
  }
}
