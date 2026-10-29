import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Renders a base64 encoded image, caching decoded bytes between rebuilds
class Base64Image extends StatelessWidget {
  final String data;
  final BoxFit fit;
  final double? width;
  final double? height;

  const Base64Image(
    this.data, {
    super.key,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  static final Map<int, Uint8List> _cache = {};

  static Uint8List? _decode(String data) {
    final key = data.hashCode;
    final cached = _cache[key];
    if (cached != null) return cached;
    try {
      final bytes = base64Decode(data);
      if (_cache.length > 50) _cache.clear();
      return _cache[key] = bytes;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bytes = _decode(data);
    if (bytes == null) return const Icon(Icons.broken_image_outlined);
    return Image.memory(
      bytes,
      fit: fit,
      width: width,
      height: height,
      gaplessPlayback: true,
      errorBuilder: (_, _, _) => const Icon(Icons.broken_image_outlined),
    );
  }
}
