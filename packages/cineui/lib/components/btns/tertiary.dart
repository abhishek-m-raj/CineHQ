import 'package:flutter/material.dart';
import 'package:cineui/constants/radius.dart';
import 'package:cineui/cineui.dart';

class CineTertiaryBtn extends StatefulWidget {
  final IconSource? icon;
  final Widget? iconWidget;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final bool filled;
  final EdgeInsets? margin;
  final bool scrollTillTop;

  const CineTertiaryBtn({
    super.key,
    this.icon,
    this.iconWidget,
    this.padding,
    this.filled = true,
    this.margin,
    this.onTap,
    this.scrollTillTop = false,
  }) : assert(icon != null || iconWidget != null, 'Either icon or iconWidget must be provided');

  @override
  State<CineTertiaryBtn> createState() => _HqTertiaryBtnState();
}

class _HqTertiaryBtnState extends State<CineTertiaryBtn> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isFocused = false;
  bool _isPressed = false;

  bool get _isActive => _isHovered || _isFocused;

  void smartScrollToButton(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;

      // 1. Search up the tree to find ONLY the Vertical Scrollable
      ScrollableState? verticalScroll;
      context.visitAncestorElements((element) {
        if (element.widget is Scrollable) {
          final axis = (element.widget as Scrollable).axisDirection;
          if (axis == AxisDirection.down || axis == AxisDirection.up) {
            verticalScroll = (element as StatefulElement).state as ScrollableState;
            return false; // Found vertical, stop searching!
          }
        }
        return true; // Keep looking up
      });

      if (verticalScroll == null) return;

      final position = verticalScroll!.position;
      final targetBox = context.findRenderObject() as RenderBox;
      final viewportBox = verticalScroll!.context.findRenderObject() as RenderBox;

      // 2. Find the button's position relative to the viewport
      final targetY = targetBox.localToGlobal(Offset.zero, ancestor: viewportBox).dy;
      final targetHeight = targetBox.size.height;
      final viewportHeight = position.viewportDimension;

      double targetOffset;

      // 3. Apply your custom logic:
      if (widget.scrollTillTop) {
        // Logic for "scrollTillTop" (Button at bottom, showing max content before)
        targetOffset = position.pixels + (targetY + targetHeight - viewportHeight);
      } else if (position.pixels == 0.0) {
        // Logic for "keepVisibleAtStart"
        if (targetY < 0) {
          // Button is hidden above the screen
          targetOffset = position.pixels + targetY;
        } else if (targetY + targetHeight > viewportHeight) {
          // Button is hidden below the screen
          targetOffset = position.pixels + (targetY + targetHeight - viewportHeight);
        } else {
          // Button is fully visible, don't move at all!
          return;
        }
      } else {
        // Logic for "explicit 0.5" (Centering)
        // Calculate how far we need to move to put it in the dead center
        final distanceToCenter = targetY - (viewportHeight / 2) + (targetHeight / 2);
        targetOffset = position.pixels + distanceToCenter;
      }

      // 4. Clamp so we don't try to overscroll past the top or bottom of the list
      targetOffset = targetOffset.clamp(position.minScrollExtent, position.maxScrollExtent);

      // 5. Fire the animation on ONLY the vertical axis
      position.animateTo(targetOffset, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: Alignment.center,
          transformAlignment: Alignment.center,
          margin: widget.margin,
          transform: Matrix4.translationValues(0.0, _isPressed ? 1.2 : 0.0, 0.0)
            ..multiply(Matrix4.diagonal3Values(_isActive ? 1.05 : 1.0, _isActive ? 1.05 : 1.0, 1.0)),
          decoration: BoxDecoration(
            color: _isActive
                ? widget.filled
                      ? CineColorScheme.surfaceContainer
                      : CineColorScheme.surfaceContainer.putOpacity(0.3)
                : widget.filled
                ? CineColorScheme.surfaceContainer.putOpacity(0.9)
                : CineColorScheme.surfaceContainer.putOpacity(0),
            border: Border.all(color: _isFocused ? CineColorScheme.white : Colors.transparent, width: 3.0),
            borderRadius: CineBorderRadius.br2.asRadius,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              focusColor: Colors.transparent,
              splashColor: CineColorScheme.surfaceContainer.putOpacity(0.2),
              highlightColor: CineColorScheme.surfaceContainer.putOpacity(0.1),
              onTap: widget.onTap,
              onFocusChange: (val) {
                setState(() => _isFocused = val);
                if (val) {
                  smartScrollToButton(context);
                }
              },
              borderRadius: CineBorderRadius.br2.asRadius,
              child: Container(
                padding: widget.padding ?? const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                child: Center(
                  child: widget.iconWidget ?? CineIcon(icon: widget.icon!, color: CineColorScheme.onSurfaceContainer),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
