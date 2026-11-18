import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Ultra-fast category image cache with disk persistence and SVG raster extraction.
/// Eliminates delay by serving from in-memory cache instantly (0ms) on frame 1,
/// reading from local disk cache, and extracting embedded PNGs from SVGs uploaded by Admin.
class CategoryImageCache {
  CategoryImageCache._();

  static final Map<String, Uint8List> _memCache = {};
  static final Map<String, Future<Uint8List?>> _pending = {};
  static SharedPreferences? _prefsInstance;

  static Future<SharedPreferences> _getPrefs() async {
    return _prefsInstance ??= await SharedPreferences.getInstance();
  }

  static String _diskKey(String url) {
    return 'qareeb_cat_img_cache_${url.hashCode}_${url.length}';
  }

  /// Synchronously retrieve decoded image bytes from memory (0ms)
  static Uint8List? getFromMemory(String url) => _memCache[url];

  /// Preload image in background so it's ready before card appears
  static void preload(String url) {
    if (_memCache.containsKey(url)) return;
    unawaited(load(url));
  }

  /// Retrieve from disk cache
  static Future<Uint8List?> _getFromDisk(String url) async {
    try {
      final prefs = await _getPrefs();
      final b64 = prefs.getString(_diskKey(url));
      if (b64 != null && b64.isNotEmpty) {
        final bytes = base64Decode(b64);
        _memCache[url] = bytes;
        return bytes;
      }
    } catch (_) {}
    return null;
  }

  /// Save bytes to persistent disk cache
  static Future<void> _saveToDisk(String url, Uint8List bytes) async {
    try {
      final prefs = await _getPrefs();
      await prefs.setString(_diskKey(url), base64Encode(bytes));
    } catch (_) {}
  }

  /// Load image with memory -> disk -> network hierarchy
  static Future<Uint8List?> load(String url) async {
    final cached = _memCache[url];
    if (cached != null) return cached;

    final disk = await _getFromDisk(url);
    if (disk != null) return disk;

    if (_pending.containsKey(url)) {
      return await _pending[url];
    }

    final future = _fetchAndDecode(url);
    _pending[url] = future;
    try {
      final bytes = await future;
      if (bytes != null && bytes.isNotEmpty) {
        _memCache[url] = bytes;
        unawaited(_saveToDisk(url, bytes));
      }
      return bytes;
    } finally {
      _pending.remove(url);
    }
  }

  static Future<Uint8List?> _fetchAndDecode(String url) async {
    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
          responseType: ResponseType.bytes,
        ),
      );

      final response = await dio.get<List<int>>(url);
      if (response.statusCode != 200 || response.data == null) return null;

      final bytes = Uint8List.fromList(response.data!);
      if (bytes.isEmpty) return null;

      // Detect SVG by URL extension or XML/SVG declaration headers
      final isSvg = url.toLowerCase().contains('.svg') ||
          (bytes.length > 4 &&
              ((bytes[0] == 0x3C && bytes[1] == 0x73 && bytes[2] == 0x76 && bytes[3] == 0x67) || // <svg
               (bytes[0] == 0x3C && bytes[1] == 0x3F && bytes[2] == 0x78 && bytes[3] == 0x6D))); // <?xm

      if (isSvg) {
        final svgText = utf8.decode(bytes, allowMalformed: true);
        // Extract embedded raster image (PNG, JPEG, WebP) uploaded from Figma/Admin
        final match = RegExp(
          r'data:image/(?:png|jpeg|jpg|webp);base64,([A-Za-z0-9+/=\s]+)',
          caseSensitive: false,
        ).firstMatch(svgText);

        if (match != null && match.group(1) != null) {
          final cleanB64 = match.group(1)!.replaceAll(RegExp(r'\s+'), '');
          return base64Decode(cleanB64);
        }
      }

      return bytes;
    } catch (e) {
      debugPrint('[CategoryImageCache] Network load failed for $url: $e');
      return null;
    }
  }
}

/// Widget that displays the category image seamlessly:
/// - If cached: renders immediately in 0ms
/// - If loading: renders the crisp local vehicle placeholder immediately (no blank cards)
/// - When downloaded: smoothly cross-fades to the admin's exact uploaded image
class CategoryImageWidget extends StatefulWidget {
  final String url;
  final Widget fallback;
  final double width;
  final double height;

  const CategoryImageWidget({
    super.key,
    required this.url,
    required this.fallback,
    this.width = 98.0,
    this.height = 60.0,
  });

  @override
  State<CategoryImageWidget> createState() => _CategoryImageWidgetState();
}

class _CategoryImageWidgetState extends State<CategoryImageWidget> {
  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    _bytes = CategoryImageCache.getFromMemory(widget.url);
    if (_bytes == null) {
      _load();
    }
  }

  @override
  void didUpdateWidget(covariant CategoryImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _bytes = CategoryImageCache.getFromMemory(widget.url);
      if (_bytes == null) {
        _load();
      }
    }
  }

  Future<void> _load() async {
    final bytes = await CategoryImageCache.load(widget.url);
    if (mounted && bytes != null) {
      setState(() {
        _bytes = bytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_bytes != null) {
      return Image.memory(
        _bytes!,
        width: widget.width,
        height: widget.height,
        fit: BoxFit.contain,
        alignment: AlignmentDirectional.centerStart,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, _, _) => widget.fallback,
      );
    }

    return widget.fallback;
  }
}
