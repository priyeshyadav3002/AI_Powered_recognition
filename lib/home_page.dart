// lib/home_page.dart
import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'detector_service.dart';
import 'preprocess.dart';
import 'recognition.dart';
import 'box_painter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  CameraController? _controller;
  late List<CameraDescription> _cameras;
  final DetectorService _detector = DetectorService();

  List<Recognition> _recognitions = [];
  bool _isDetecting = false;
  Size? _previewSize;
  bool _mirror = false;

  // process every Nth frame to reduce load
  int _frameSkip = 0;
  final int _processEveryNFrames = 3; // tune this if needed

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setup();
  }

  Future<void> _setup() async {
    await _detector.loadModel(modelPath: 'assets/detect.tflite', labelsPath: 'assets/labelmap.txt');

    _cameras = await availableCameras();
    if (_cameras.isEmpty) {
      // ignore: avoid_print
      print('No cameras found');
      return;
    }

    final cam = _cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.back, orElse: () => _cameras.first);
    _mirror = cam.lensDirection == CameraLensDirection.front;

    _controller = CameraController(
      cam,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.bgra8888,
    );

    await _controller!.initialize();
    _previewSize = _controller!.value.previewSize;
    setState(() {});

    _controller!.startImageStream(_processCameraImage);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    try {
      _controller?.stopImageStream();
    } catch (_) {}
    _controller?.dispose();
    _detector.close();
    super.dispose();
  }

  void _processCameraImage(CameraImage image) async {
    _frameSkip = (_frameSkip + 1) % _processEveryNFrames;
    if (_frameSkip != 0) return;

    if (_isDetecting) return;
    _isDetecting = true;

    try {
      final args = {
        'bytes': image.planes[0].bytes,
        'width': image.width,
        'height': image.height,
        'rowStride': image.planes[0].bytesPerRow,
        'targetW': 300,
        'targetH': 300,
      };

      final Uint8List input = await compute(prepareInputForQuant, args);

      final List<Recognition> results = _detector.runOnFrame(input, inputWidth: 300, inputHeight: 300, threshold: 0.45);

      if (mounted) {
        setState(() {
          _recognitions = results;
        });
      }
    } catch (e, st) {
      // ignore: avoid_print
      print('Frame processing error: $e\n$st');
    } finally {
      _isDetecting = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;

    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('AI Object Detector')),
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_controller!),
          if (_previewSize != null)
            Positioned.fill(
              child: CustomPaint(
                painter: DetectionBoxPainter(
                  detections: _recognitions,
                  previewSize: _previewSize!,
                  screenSize: screen,
                  mirror: _mirror,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
