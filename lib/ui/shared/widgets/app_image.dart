import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:sales_online_app/core/constants/app_styles.dart';

class AppImage extends StatelessWidget {
  final String imageData;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color? backgroundColor;

  const AppImage({
    super.key,
    required this.imageData,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = backgroundColor ?? _placeholderColor(context);
    final fallback = errorWidget ?? _DefaultImagePlaceholder(color: color);
    final source = imageData.trim();

    if (source.isEmpty || source == 'string') {
      return SizedBox(width: width, height: height, child: fallback);
    }

    if (_isDataImage(source)) {
      final bytes = _tryDecodeDataImage(source);
      if (bytes == null) {
        return SizedBox(width: width, height: height, child: fallback);
      }

      return Image.memory(
        bytes,
        width: width,
        height: height,
        fit: fit,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => fallback,
      );
    }

    if (_isNetworkUrl(source)) {
      return Image.network(
        source,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder ??
              ColoredBox(
                color: color,
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
        },
        errorBuilder: (_, _, _) => fallback,
      );
    }

    return SizedBox(width: width, height: height, child: fallback);
  }

  bool _isDataImage(String value) {
    return value.toLowerCase().startsWith('data:image') &&
        value.contains('base64,');
  }

  bool _isNetworkUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  Uint8List? _tryDecodeDataImage(String value) {
    final commaIndex = value.indexOf(',');
    if (commaIndex < 0 || commaIndex == value.length - 1) return null;

    try {
      return base64Decode(value.substring(commaIndex + 1));
    } on FormatException {
      return null;
    }
  }

  Color _placeholderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppColors.borderDark
        : AppColors.borderLight;
  }
}

class _DefaultImagePlaceholder extends StatelessWidget {
  final Color color;

  const _DefaultImagePlaceholder({required this.color});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color,
      child: const Center(
        child: Icon(Icons.image_not_supported_outlined, color: Colors.grey),
      ),
    );
  }
}
