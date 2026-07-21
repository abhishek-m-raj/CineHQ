import 'package:flutter/material.dart';
import 'package:cineui/components/skeleton.dart';
import 'package:cineui/constants/spacing.dart';
import 'package:cineui/utils/colors.dart';
import 'package:cineui/utils/radius.dart';
import '../constants/radius.dart';
import '../constants/theme/color_scheme.dart';

class CineCard extends StatefulWidget {
  final double aspectRatio;
  final double? height;
  final double? width;
  final DecorationImage? image;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BoxShape? shape;
  final Color color;
  final bool loading;
  final bool inShadow;
  final bool outerShadow;
  final bool scaleEffect;
  final bool defaultBorder;
  final VoidCallback? onAction;
  final VoidCallback? onTap;
  final Widget? child;

  const CineCard({
    super.key,
    this.height,
    this.width,
    this.image,
    this.aspectRatio = 1,
    this.color = CineColorScheme.surfaceBright,
    this.inShadow = true,
    this.outerShadow = true,
    this.scaleEffect = true,
    this.loading = false,
    this.defaultBorder = false,
    this.onAction,
    this.onTap,
    this.padding,
    this.margin,
    this.shape,
    this.child,
  });

  @override
  State<CineCard> createState() => _HqCardState();
}

class _HqCardState extends State<CineCard> {
  bool _isHovered = false;
  bool _isFocused = false;
  bool _isPressed = false;

  bool get _isActive => _isHovered || _isFocused;

  Widget inShadow() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            if (_isActive) CineColorScheme.surface.putOpacity(0.9),
            if (!_isActive && widget.inShadow) CineColorScheme.surface.putOpacity(0.8),
            if (!widget.inShadow) Colors.transparent,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      canRequestFocus: false,
      onFocusChange: (focus) {
        setState(() => _isFocused = focus);
        if (focus) {
          Scrollable.ensureVisible(
            context,
            alignment: 0.5,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          child: SizedBox(
            height: widget.height,
            width: widget.width,
            child: AspectRatio(
              aspectRatio: widget.aspectRatio,
              child: widget.loading
                  ? CineSkelton()
                  : AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      alignment: Alignment.center,
                      transformAlignment: Alignment.center,
                      clipBehavior: Clip.antiAlias,
                      margin: widget.margin,
                      transform: Matrix4.identity()
                        ..scaleByDouble(
                          (_isActive && widget.scaleEffect) ? 1.05 : 1.0,
                          (_isActive && widget.scaleEffect) ? 1.05 : 1.0,
                          1.0,
                          1.0,
                        )
                        ..translateByDouble(0.0, _isPressed ? 1.5 : 0.0, 0.0, 1.0),
                      decoration: BoxDecoration(
                        color: _isActive ? widget.color.putOpacity(0.9) : widget.color,
                        border: (_isActive || _isPressed || widget.defaultBorder)
                            ? Border.all(color: CineColorScheme.onSurface, width: 1)
                            : null,
                        shape: widget.shape ?? BoxShape.rectangle,
                        image: widget.image,
                        borderRadius: widget.shape == null ? CineBorderRadius.br2.asRadius : null,
                        boxShadow: _isActive
                            ? [
                                if (widget.outerShadow)
                                  BoxShadow(
                                    color: const Color.fromRGBO(240, 224, 236, 1).withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 4),
                                  ),
                              ]
                            : [
                                if (widget.outerShadow)
                                  BoxShadow(
                                    color: widget.color.withValues(alpha: 0.3),
                                    blurRadius: 15,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 4),
                                  ),
                              ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: widget.color.putOpacity(0.2),
                          highlightColor: widget.color.putOpacity(0.1),
                          onTap: widget.onTap,
                          onLongPress: widget.onAction,
                          onSecondaryTap: widget.onAction,
                          onFocusChange: (val) => setState(() => _isFocused = val),
                          borderRadius: CineBorderRadius.br2.asRadius,
                          child: ClipRRect(
                            borderRadius: CineBorderRadius.br2.asRadius,
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              clipBehavior: Clip.hardEdge,
                              children: [
                                if (widget.inShadow) Builder(builder: (_) => inShadow()),
                                Padding(padding: widget.padding ?? EdgeInsets.all(CineSpacing.s1), child: widget.child),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
