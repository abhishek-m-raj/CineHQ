import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cineui/components/icon.dart';
import 'package:cineui/components/skeleton.dart';
import 'package:cineui/constants/icons.dart';
export 'package:cached_network_image/cached_network_image.dart';

enum ImageType { asset, network, file }

class CineImage extends StatelessWidget {
  final bool cache;
  final bool showLoading;
  final String? src;
  final ImageType type;
  final Alignment? alignment;
  final BoxFit? fit;
  final double? width;
  final double? height;

  const CineImage({
    super.key,
    this.cache = false,
    this.showLoading = true,
    required this.src,
    required this.type,
    this.alignment,
    this.fit,
    this.width,
    this.height,
  });

  const CineImage.cachedNetwork({
    super.key,
    this.cache = true,
    this.showLoading = true,
    this.type = ImageType.network,
    required this.src,
    this.alignment,
    this.fit,
    this.width,
    this.height,
  });

  const CineImage.network({
    super.key,
    this.cache = false,
    this.showLoading = true,
    this.type = ImageType.network,
    required this.src,
    this.alignment,
    this.fit,
    this.width,
    this.height,
  });

  const CineImage.file({
    super.key,
    this.cache = false,
    this.showLoading = true,
    this.type = ImageType.file,
    required this.src,
    this.alignment,
    this.fit,
    this.width,
    this.height,
  });

  const CineImage.asset({
    super.key,
    this.cache = true,
    this.showLoading = true,
    this.type = ImageType.asset,
    required this.src,
    this.alignment,
    this.fit,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (src == null) {
      return SizedBox(
        width: width,
        height: height,
        child: Center(child: CineIcon(icon: CineIcons.noImage)),
      );
    }
    if (cache && type == ImageType.network) {
      return CachedNetworkImage(
        imageUrl: src!,
        alignment: alignment ?? Alignment.center,
        fit: fit,
        width: width,
        height: height,
        fadeInDuration: const Duration(milliseconds: 500),
        fadeInCurve: Curves.easeInCubic,
        placeholder: (_, _) => showLoading ? CineSkelton() : SizedBox(width: width, height: height),
        errorWidget: (_, _, _) => SizedBox(
          width: width,
          height: height,
          child: Center(child: CineIcon(icon: CineIcons.noImage)),
        ),
      );
    }
    switch (type) {
      case ImageType.asset:
        return Image.asset(
          src!,
          alignment: alignment ?? Alignment.center,
          fit: fit,
          width: width,
          height: height,
          frameBuilder: (_, child, _, _) {
            return child.animate().fadeIn(duration: 500.ms, curve: Curves.easeInCubic);
          },
          errorBuilder: (_, _, _) => SizedBox(
            width: width,
            height: height,
            child: Center(child: CineIcon(icon: CineIcons.noImage)),
          ),
        );
      case ImageType.network:
        return Image.network(
          src!,
          alignment: alignment ?? Alignment.center,
          fit: fit,
          width: width,
          height: height,
          frameBuilder: (_, child, _, _) {
            return child.animate().fadeIn(duration: 500.ms, curve: Curves.easeInCubic);
          },
          loadingBuilder: (_, _, _) => CineSkelton(),
          errorBuilder: (_, _, _) => SizedBox(
            width: width,
            height: height,
            child: Center(child: CineIcon(icon: CineIcons.noImage)),
          ),
        );
      case ImageType.file:
        return Image.file(
          File(src!),
          alignment: alignment ?? Alignment.center,
          fit: fit,
          width: width,
          height: height,
          frameBuilder: (_, child, _, _) {
            return child.animate().fadeIn(duration: 500.ms, curve: Curves.easeInCubic);
          },
          errorBuilder: (_, _, _) => SizedBox(
            width: width,
            height: height,
            child: Center(child: CineIcon(icon: CineIcons.noImage)),
          ),
        );
    }
  }
}

class CineDecorationImage {
  static DecorationImage cachedNetwork(String? src, [BoxFit fit = BoxFit.cover]) {
    return DecorationImage(
      image: CachedNetworkImageProvider(src ?? "no"),
      onError: (exception, stackTrace) {},
      fit: fit,
    );
  }

  static DecorationImage network(String? src, [BoxFit fit = BoxFit.cover]) {
    return DecorationImage(image: NetworkImage(src ?? "no"), onError: (exception, stackTrace) {}, fit: fit);
  }

  static DecorationImage file(String src, [BoxFit fit = BoxFit.cover]) {
    return DecorationImage(image: FileImage(File(src)), fit: fit);
  }

  static DecorationImage asset(String src, [BoxFit fit = BoxFit.cover]) {
    return DecorationImage(image: AssetImage(src), fit: fit);
  }
}
