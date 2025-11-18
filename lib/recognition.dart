// lib/recognition.dart
import 'dart:ui';

class Recognition {
  final int id;
  final String label;
  final double score;
  final Rect location; // normalized (left, top, right, bottom) in 0..1

  Recognition(this.id, this.label, this.score, this.location);

  @override
  String toString() => 'Recognition($label ${score.toStringAsFixed(2)} @ $location)';
}
