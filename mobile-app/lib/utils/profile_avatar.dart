import 'dart:io';

import 'package:dermamind_app/services/api_service.dart';
import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String? networkUrl;
  final String? localPath;
  final double size;
  final Color? borderColor;
  final double borderWidth;

  const ProfileAvatar({
    super.key,
    this.networkUrl,
    this.localPath,
    this.size = 80,
    this.borderColor,
    this.borderWidth = 3,
  });

  static String? resolveUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http')) return url;
    return '${ApiService.baseUrl}$url';
  }

  @override
  Widget build(BuildContext context) {
    final resolved = resolveUrl(networkUrl);
    ImageProvider? imageProvider;
    if (localPath != null && localPath!.isNotEmpty) {
      imageProvider = FileImage(File(localPath!));
    } else if (resolved != null) {
      imageProvider = NetworkImage(resolved);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.2),
        border: Border.all(
          color: borderColor ?? Colors.white,
          width: borderWidth,
        ),
        image: imageProvider != null
            ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
            : null,
      ),
      child: imageProvider == null
          ? Icon(Icons.person, color: Colors.white, size: size * 0.55)
          : null,
    );
  }
}
