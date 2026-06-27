import 'package:dermamind_app/services/api_service.dart';
import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color fallbackColor;
  final IconData fallbackIcon;
  final Color fallbackIconColor;
  final double fallbackIconSize;
  final BorderRadius? borderRadius;

  const ProductImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fallbackColor = const Color(0xFFEFF6FF),
    this.fallbackIcon = Icons.science_outlined,
    this.fallbackIconColor = const Color(0xFF0C81E4),
    this.fallbackIconSize = 42,
    this.borderRadius,
  });

  static String? resolveUrl(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    final trimmed = url.trim();
    if (trimmed.startsWith('http')) return trimmed;
    if (trimmed.startsWith('//')) return 'https:$trimmed';
    final path = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    return '${ApiService.baseUrl}$path';
  }

  @override
  Widget build(BuildContext context) {
    final resolved = resolveUrl(imageUrl);
    Widget child;

    if (resolved != null) {
      child = Image.network(
        resolved,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            width: width,
            height: height,
            color: fallbackColor,
            alignment: Alignment.center,
            child: const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (_, __, ___) => _fallback(),
      );
    } else {
      child = _fallback();
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: child);
    }
    return child;
  }

  Widget _fallback() {
    return Container(
      width: width,
      height: height,
      color: fallbackColor,
      alignment: Alignment.center,
      child: Icon(fallbackIcon, color: fallbackIconColor, size: fallbackIconSize),
    );
  }
}
