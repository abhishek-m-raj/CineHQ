import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// A single thumbnail cue parsed from a VTT file.
class ThumbnailCue {
  final Duration start;
  final Duration end;
  final String imageUrl;
  final int? x;
  final int? y;
  final int? w;
  final int? h;

  const ThumbnailCue({required this.start, required this.end, required this.imageUrl, this.x, this.y, this.w, this.h});

  bool get isSprite => x != null && y != null && w != null && h != null;

  bool containsTime(Duration time) => time >= start && time < end;
}

/// Parses a WebVTT thumbnail file into a list of [ThumbnailCue]s.
class VttParser {
  static List<ThumbnailCue> parse(Uint8List vttBytes, String baseUrl) {
    final content = utf8.decode(vttBytes, allowMalformed: true);
    final lines = content.split(RegExp(r'\r?\n'));
    final cues = <ThumbnailCue>[];

    int i = 0;
    // Skip header
    while (i < lines.length) {
      final line = lines[i].trim();
      if (line.startsWith('WEBVTT') || line.isEmpty || line.startsWith('NOTE')) {
        i++;
        continue;
      }
      break;
    }

    while (i < lines.length) {
      final line = lines[i].trim();

      // Skip empty lines and cue identifiers (numeric or text without -->)
      if (line.isEmpty) {
        i++;
        continue;
      }

      // Check if this line is a timestamp line
      if (!line.contains('-->')) {
        // Could be a cue identifier, skip it
        i++;
        continue;
      }

      // Parse timestamp line
      final timestamps = _parseTimestampLine(line);
      if (timestamps == null) {
        i++;
        continue;
      }

      i++;

      // Next non-empty line should be the image reference
      while (i < lines.length && lines[i].trim().isEmpty) {
        i++;
      }

      if (i >= lines.length) break;

      final payload = lines[i].trim();
      i++;

      if (payload.isEmpty) continue;

      // Parse image URL and optional sprite coordinates
      final cue = _parseCue(timestamps.$1, timestamps.$2, payload, baseUrl);
      if (cue != null) {
        cues.add(cue);
      }
    }

    return cues;
  }

  static (Duration, Duration)? _parseTimestampLine(String line) {
    final parts = line.split('-->');
    if (parts.length != 2) return null;

    final start = _parseDuration(parts[0].trim());
    // Remove any position/alignment metadata after the end time
    final endPart = parts[1].trim().split(RegExp(r'\s+')).first;
    final end = _parseDuration(endPart);

    if (start == null || end == null) return null;
    return (start, end);
  }

  static Duration? _parseDuration(String time) {
    // Supports HH:MM:SS.mmm and MM:SS.mmm
    final match = RegExp(r'(\d+:)?(\d+):(\d+)\.(\d+)').firstMatch(time);
    if (match == null) return null;

    final hours = match.group(1) != null ? int.parse(match.group(1)!.replaceAll(':', '')) : 0;
    final minutes = int.parse(match.group(2)!);
    final seconds = int.parse(match.group(3)!);
    final millisStr = match.group(4)!.padRight(3, '0').substring(0, 3);
    final millis = int.parse(millisStr);

    return Duration(hours: hours, minutes: minutes, seconds: seconds, milliseconds: millis);
  }

  static ThumbnailCue? _parseCue(Duration start, Duration end, String payload, String baseUrl) {
    // Split by # to separate URL from sprite fragment
    String imageRef;
    int? x, y, w, h;

    final hashIndex = payload.indexOf('#xywh=');
    if (hashIndex != -1) {
      imageRef = payload.substring(0, hashIndex);
      final coords = payload.substring(hashIndex + 6).split(',');
      if (coords.length == 4) {
        x = int.tryParse(coords[0]);
        y = int.tryParse(coords[1]);
        w = int.tryParse(coords[2]);
        h = int.tryParse(coords[3]);
      }
    } else {
      imageRef = payload;
    }

    // Resolve relative URLs
    String imageUrl;
    if (imageRef.startsWith('http://') || imageRef.startsWith('https://')) {
      imageUrl = imageRef;
    } else if (baseUrl.isNotEmpty) {
      final base = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
      imageUrl = '$base$imageRef';
    } else {
      // Can't resolve relative URL without base
      return null;
    }

    return ThumbnailCue(start: start, end: end, imageUrl: imageUrl, x: x, y: y, w: w, h: h);
  }
}

/// Cache for downloaded sprite/thumbnail images.
class _ThumbnailImageCache {
  static final Map<String, ui.Image?> _cache = {};
  static final Map<String, Future<ui.Image?>> _pending = {};

  static Future<ui.Image?> getImage(String url) {
    if (_cache.containsKey(url)) {
      return Future.value(_cache[url]);
    }
    if (_pending.containsKey(url)) {
      return _pending[url]!;
    }

    final future = _downloadImage(url);
    _pending[url] = future;
    future
        .then((img) {
          _cache[url] = img;
          _pending.remove(url);
        })
        .catchError((_) {
          _pending.remove(url);
        });
    return future;
  }

  static Future<ui.Image?> _downloadImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return null;
      final codec = await ui.instantiateImageCodec(response.bodyBytes);
      final frame = await codec.getNextFrame();
      return frame.image;
    } catch (_) {
      return null;
    }
  }

  // ignore: unused_element
  static void clear() {
    _cache.clear();
    _pending.clear();
  }
}

/// Widget that displays a thumbnail from a VTT file at the given time.
class VttThumbnail extends StatefulWidget {
  /// Raw VTT file bytes.
  final Uint8List vtt;

  /// Base URL for resolving relative image paths in the VTT.
  final String baseUrl;

  /// The current time to display the thumbnail for.
  final Duration currentTime;

  /// Dimensions for the thumbnail display.
  final double? width;
  final double? height;

  /// Widget to show while loading.
  final Widget? loading;

  /// Widget to show on error.
  final Widget? error;

  const VttThumbnail({
    super.key,
    required this.vtt,
    required this.baseUrl,
    required this.currentTime,
    this.width,
    this.height,
    this.loading,
    this.error,
  });

  @override
  State<VttThumbnail> createState() => _VttThumbnailState();
}

class _VttThumbnailState extends State<VttThumbnail> {
  List<ThumbnailCue>? _cues;
  ui.Image? _currentImage;
  ThumbnailCue? _currentCue;
  String? _loadedImageUrl;
  bool _loading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _parseCues();
    _loadThumbnail();
  }

  @override
  void didUpdateWidget(VttThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.vtt != widget.vtt || oldWidget.baseUrl != widget.baseUrl) {
      _parseCues();
    }
    if (oldWidget.currentTime != widget.currentTime || oldWidget.vtt != widget.vtt) {
      _loadThumbnail();
    }
  }

  void _parseCues() {
    _cues = VttParser.parse(widget.vtt, widget.baseUrl);
  }

  void _loadThumbnail() {
    if (_cues == null || _cues!.isEmpty) return;

    // Find the cue for the current time
    ThumbnailCue? cue;
    for (final c in _cues!) {
      if (c.containsTime(widget.currentTime)) {
        cue = c;
        break;
      }
    }

    // Fallback: find the closest cue
    cue ??= _findClosestCue(widget.currentTime);
    if (cue == null) return;

    _currentCue = cue;

    // Only reload image if the URL changed
    if (cue.imageUrl == _loadedImageUrl && _currentImage != null) {
      setState(() {});
      return;
    }

    setState(() {
      _loading = true;
      _hasError = false;
    });

    _ThumbnailImageCache.getImage(cue.imageUrl).then((image) {
      if (!mounted) return;
      setState(() {
        _currentImage = image;
        _loadedImageUrl = cue!.imageUrl;
        _loading = false;
        _hasError = image == null;
      });
    });
  }

  ThumbnailCue? _findClosestCue(Duration time) {
    if (_cues == null || _cues!.isEmpty) return null;

    ThumbnailCue? closest;
    // Keep within JS safe integer range so web compilation succeeds.
    int minDiff = 9007199254740991;

    for (final cue in _cues!) {
      final diff = (cue.start.inMilliseconds - time.inMilliseconds).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closest = cue;
      }
    }
    return closest;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return SizedBox(width: widget.width, height: widget.height, child: widget.loading ?? const SizedBox.shrink());
    }

    if (_hasError || _currentImage == null || _currentCue == null) {
      return SizedBox(width: widget.width, height: widget.height, child: widget.error ?? const SizedBox.shrink());
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: CustomPaint(
        size: Size(widget.width ?? 160, widget.height ?? 90),
        painter: _ThumbnailPainter(image: _currentImage!, cue: _currentCue!),
      ),
    );
  }
}

/// Paints a thumbnail, cropping from a sprite sheet if needed.
class _ThumbnailPainter extends CustomPainter {
  final ui.Image image;
  final ThumbnailCue cue;

  _ThumbnailPainter({required this.image, required this.cue});

  @override
  void paint(Canvas canvas, Size size) {
    final Rect src;
    if (cue.isSprite) {
      src = Rect.fromLTWH(cue.x!.toDouble(), cue.y!.toDouble(), cue.w!.toDouble(), cue.h!.toDouble());
    } else {
      src = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
    }

    final dst = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawImageRect(image, src, dst, Paint());
  }

  @override
  bool shouldRepaint(_ThumbnailPainter oldDelegate) => oldDelegate.image != image || oldDelegate.cue != cue;
}

/// Widget that displays a single, pre-parsed thumbnail cue.
class SingleCueThumbnail extends StatefulWidget {
  final ThumbnailCue cue;
  final double? width;
  final double? height;
  final Widget? loading;
  final Widget? error;

  const SingleCueThumbnail({super.key, required this.cue, this.width, this.height, this.loading, this.error});

  @override
  State<SingleCueThumbnail> createState() => _SingleCueThumbnailState();
}

class _SingleCueThumbnailState extends State<SingleCueThumbnail> {
  ui.Image? _image;
  bool _loading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(SingleCueThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cue.imageUrl != widget.cue.imageUrl) {
      _loadImage();
    }
  }

  void _loadImage() {
    setState(() {
      _loading = true;
      _hasError = false;
    });
    _ThumbnailImageCache.getImage(widget.cue.imageUrl).then((image) {
      if (!mounted) return;
      setState(() {
        _image = image;
        _loading = false;
        _hasError = image == null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return SizedBox(width: widget.width, height: widget.height, child: widget.loading ?? const SizedBox.shrink());
    }
    if (_hasError || _image == null) {
      return SizedBox(width: widget.width, height: widget.height, child: widget.error ?? const SizedBox.shrink());
    }
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: CustomPaint(
        size: Size(widget.width ?? 160, widget.height ?? 90),
        painter: _ThumbnailPainter(image: _image!, cue: widget.cue),
      ),
    );
  }
}
