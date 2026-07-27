import 'dart:io';
import 'dart:math';
import 'package:animated_visibility/animated_visibility.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:device/device.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class HqColorScheme {
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color transparent = Colors.transparent;

  static const Color primary = Color.fromARGB(255, 226, 171, 255);
  static const Color secondary = Color.fromARGB(255, 201, 177, 209);
  static const Color tertiary = Color(0xfff4b7b9);
  static const Color primaryContainer = Color.fromARGB(255, 189, 87, 233);
  static const Color secondaryContainer = Color.fromARGB(255, 178, 129, 199);
  static const Color tertiaryContainer = Color(0xff663b3d);

  static const Color onPrimary = Color(0xff422356);
  static const Color onSecondary = Color(0xff382c3e);
  static const Color onTertiary = Color(0xff4c2527);
  static const Color onPrimaryContainer = Color.fromARGB(255, 240, 211, 252);
  static const Color onSecondaryContainer = Color.fromARGB(255, 237, 212, 245);
  static const Color onTertiaryContainer = Color(0xffffdada);

  static const Color surface = Color(0xff161217);
  static const Color surfaceBright = Color(0xff3c383d);
  static const Color onSurfaceBright = Color.fromARGB(255, 229, 205, 235);
  static const Color onSurface = Color.fromARGB(255, 240, 224, 236);
  static const Color surfaceContainer = Color.fromARGB(255, 32, 31, 49);
  static const Color onSurfaceContainer = Color(0xffe0b8f6);
  static const Color surfaceContainerHigh = Color.fromARGB(255, 32, 29, 34);
  static const Color surfaceTint = Color(0xffe0b8f6);

  static const Color inverseSurface = Color(0xffe9e0e7);
  static const Color onInverseSurface = Color(0xff332f35);
  static const Color outline = Color(0xff978e98);
  static const Color outlineVariant = Color(0xff4b454d);
  static const Color inversePrimary = Color(0xff735187);
}

extension ColorUtils on Color {
  Color putOpacity(double val) {
    return withAlpha((255 * val).toInt());
  }
}

class HqScaler {
  static double get textScale => Device.isMobile ? 1 : 1.1;
  static double get spacingScale => Device.isMobile ? 1 : 1.1;
}

class HqSpacing {
  static double get s1 => 4 * HqScaler.spacingScale;
  static double get s2 => 8 * HqScaler.spacingScale;
  static double get s3 => 12 * HqScaler.spacingScale;
  static double get s4 => 16 * HqScaler.spacingScale;
  static double get s5 => 20 * HqScaler.spacingScale;
  static double get s6 => 28 * HqScaler.spacingScale;
  static double get s7 => 40 * HqScaler.spacingScale;
  static double get s8 => 60 * HqScaler.spacingScale;
  static double get s9 => 100 * HqScaler.spacingScale;
  static double get s10 => 160 * HqScaler.spacingScale;
  static double get s11 => 240 * HqScaler.spacingScale;
}

class HqBorderRadius {
  static const double br1 = 5;
  static const double br2 = 8;
  static const double br3 = 10;
}

extension BorderUtils on double {
  BorderRadius get asRadius {
    return BorderRadius.circular(this);
  }
}

class HqTextStyles {
  static TextStyle get h1 => const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 0.5, height: 1.1);
  static TextStyle get h2 => const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: 0.5, height: 1.1);
  static TextStyle get h3 => const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, letterSpacing: 0, height: 1.15);
  static TextStyle get h4 => const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0, height: 1.15);
  static TextStyle get h5 => const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0, height: 1.15);
  static TextStyle get h6 => const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0, height: 1.15);

  static TextStyle get b1 => const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.5, height: 1.4);
  static TextStyle get b2 => const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.2, height: 1.4);
  static TextStyle get b3 => const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0, height: 1.4);

  static TextStyle get btnText => const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.75, height: 1.2);
}

class HqText extends StatelessWidget {
  final String? text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final Color? color;
  final int? maxLines;

  const HqText(this.text, {super.key, this.style, this.textAlign, this.color, this.maxLines});

  @override
  Widget build(BuildContext context) {
    if (text == null) return const SizedBox.shrink();
    return Text(
      text ?? "",
      softWrap: false,
      maxLines: maxLines,
      textAlign: textAlign,
      overflow: TextOverflow.ellipsis,
      textScaler: TextScaler.linear(HqScaler.textScale),
      style: (style ?? HqTextStyles.b1).copyWith(color: color),
    );
  }
}

class HqListTile extends StatefulWidget {
  final String? title;
  final Widget? titleWidget;
  final String? subtitle;
  final Widget? subtitleWidget;
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsets? padding;
  final bool filled;
  final VoidCallback? onPress;
  final FocusNode? focusNode;

  const HqListTile({
    super.key,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.subtitleWidget,
    this.leading,
    this.trailing,
    this.padding,
    this.filled = false,
    this.onPress,
    this.focusNode,
  });

  @override
  State<HqListTile> createState() => _HqListTileState();
}

class _HqListTileState extends State<HqListTile> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: HqBorderRadius.br2.asRadius,
          border: (_focused && Device.isTv) ? Border.all(color: HqColorScheme.outline, width: 2) : null,
        ),
        child: ListTile(
          focusNode: widget.focusNode,
          onFocusChange: (val) {
            setState(() {
              _focused = val;
            });
          },
          leading: widget.leading,
          title: widget.titleWidget ??
              (widget.title != null
                  ? HqText(widget.title, style: HqTextStyles.b2, color: HqColorScheme.onSurface)
                  : null),
          subtitle: widget.subtitleWidget ??
              (widget.subtitle != null
                  ? HqText(widget.subtitle!, style: HqTextStyles.b3, color: HqColorScheme.secondary.putOpacity(0.8))
                  : null),
          tileColor: (widget.filled == true) ? HqColorScheme.surfaceBright.putOpacity(0.3) : null,
          enabled: !(widget.onPress == null),
          contentPadding: widget.padding,
          onTap: widget.onPress,
          shape: RoundedRectangleBorder(borderRadius: HqBorderRadius.br2.asRadius),
          trailing: widget.trailing,
        ),
      ),
    );
  }
}

class HqLoadingIndicator extends StatelessWidget {
  final bool loading;

  const HqLoadingIndicator({super.key, this.loading = true});

  @override
  Widget build(BuildContext context) {
    return AnimatedVisibility(
      visible: loading,
      enterDuration: const Duration(milliseconds: 200),
      exitDuration: const Duration(milliseconds: 200),
      enter: fadeIn(curve: Curves.easeIn),
      exit: fadeOut(curve: Curves.easeOut),
      child: const Center(child: Loader()),
    );
  }
}

class Loader extends StatefulWidget {
  const Loader({super.key});

  @override
  LoaderState createState() => LoaderState();
}

class LoaderState extends State<Loader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..addListener(() {
        if (mounted) {
          setState(() {});
        }
      })
      ..repeat();

    _animation = CurveTween(curve: Curves.easeOutSine).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value * 2 * pi,
          child: CustomPaint(size: const Size(70, 70), painter: _LoaderPainter()),
        );
      },
    );
  }
}

class _LoaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final angle = -pi / 2;

    final trailPaint = Paint()
      ..shader = SweepGradient(
        startAngle: 0.0,
        endAngle: 2 * pi,
        colors: [
          Colors.transparent,
          HqColorScheme.secondaryContainer.putOpacity(0.3),
          HqColorScheme.secondaryContainer,
          HqColorScheme.primary,
          Colors.white,
        ],
        stops: const [0.0, 0.35, 0.5, 0.8, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius - 4), angle, 2 * pi, false, trailPaint);

    final dotPaint = Paint()
      ..color = Colors.white
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 15);
    const dotRadius = 4.0;
    final dotOffset = Offset(center.dx - (radius - 4) * sin(angle), center.dy - (radius - 4) * cos(angle));
    canvas.drawCircle(dotOffset, dotRadius, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HqDecorationImage {
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

// ---------------------------------------------------------------------------
// Icon system (extracted from hqui)
// ---------------------------------------------------------------------------

sealed class IconSource {}

class NormalIcon extends IconSource {
  final IconData icon;
  NormalIcon(this.icon);
}

class ExternalIcon extends IconSource {
  final List<List<dynamic>> icon;
  ExternalIcon(this.icon);
}

class HqIcon extends StatelessWidget {
  final IconSource icon;
  final Color? color;
  final double? size;
  final double? strokeWidth;

  const HqIcon({super.key, required this.icon, this.color, this.size, this.strokeWidth});

  @override
  Widget build(BuildContext context) {
    if (icon is ExternalIcon) {
      final externalIcon = icon as ExternalIcon;
      return HugeIcon(
        icon: externalIcon.icon,
        color: color ?? Theme.of(context).iconTheme.color ?? Colors.white,
        size: size ?? 24,
        strokeWidth: strokeWidth ?? 2,
      );
    } else {
      return Icon((icon as NormalIcon).icon, color: color, size: size);
    }
  }
}

class HqIcons {
  static final vidPlay = ExternalIcon(HugeIcons.strokeRoundedPlay);
  static final vidPause = ExternalIcon(HugeIcons.strokeRoundedPause);
  static final vidFastForward = ExternalIcon(HugeIcons.strokeRoundedForward01);
  static final vidFastRewind = ExternalIcon(HugeIcons.strokeRoundedBackward01);
  static final vidFullscreen = ExternalIcon(HugeIcons.strokeRoundedArrowExpand);
  static final vidCloseFullscreen = ExternalIcon(HugeIcons.strokeRoundedArrowShrink);
  static final vidMuted = ExternalIcon(HugeIcons.strokeRoundedVolumeMute01);
  static final vidVolume = ExternalIcon(HugeIcons.strokeRoundedVolumeHigh);
  static final vidSettings = ExternalIcon(HugeIcons.strokeRoundedSettings02);
  static final vidEpList = ExternalIcon(HugeIcons.strokeRoundedListVideo);
  static final vidMusicList = ExternalIcon(HugeIcons.strokeRoundedPlaylist01);
  static final vidBoxContain = ExternalIcon(HugeIcons.strokeRoundedSquare);
  static final vidBoxCover = ExternalIcon(HugeIcons.strokeRoundedArrowExpand01);
  static final vidBoxFill = ExternalIcon(HugeIcons.strokeRoundedGrid);
}
