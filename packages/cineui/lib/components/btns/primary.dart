import 'package:flutter/material.dart';
import 'package:cineui/constants/radius.dart';
import 'package:cineui/cineui.dart';

class CinePrimaryBtn extends StatefulWidget {
  final String? text;
  final IconSource? icon;
  final double? height;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final bool scrollTillTop;

  const CinePrimaryBtn({
    super.key,
    this.icon,
    this.text,
    this.height,
    this.onTap,
    this.focusNode,
    this.scrollTillTop = false,
  });

  @override
  State<CinePrimaryBtn> createState() => _HqPrimaryBtnState();
}

class _HqPrimaryBtnState extends State<CinePrimaryBtn> with SingleTickerProviderStateMixin {
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
          height: widget.height,
          transform: Matrix4.diagonal3Values(_isActive ? 1.05 : 1.0, _isActive ? 1.05 : 1.0, 1.0),
          decoration: BoxDecoration(
            color: _isActive ? CineColorScheme.primary.withValues(alpha: 0.9) : CineColorScheme.primary,
            border: Border.all(color: _isFocused ? CineColorScheme.white : Colors.transparent, width: 3.0),
            borderRadius: BorderRadius.circular(_isPressed ? CineBorderRadius.br3 : CineBorderRadius.br3),
            boxShadow: _isActive
                ? [BoxShadow(color: CineColorScheme.primary.withValues(alpha: 0.3), blurRadius: 8, spreadRadius: 1)]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              focusNode: widget.focusNode,
              focusColor: Colors.transparent,
              splashColor: CineColorScheme.onPrimary.withValues(alpha: 0.2),
              highlightColor: CineColorScheme.onPrimary.withValues(alpha: 0.1),
              onTap: widget.onTap,
              onFocusChange: (val) {
                setState(() => _isFocused = val);
                if (val) {
                  smartScrollToButton(context);
                }
              },
              borderRadius: BorderRadius.circular(_isPressed ? CineBorderRadius.br3 : CineBorderRadius.br3),
              child: Container(
                padding: widget.height == null
                    ? const EdgeInsets.symmetric(vertical: 8, horizontal: 12)
                    : EdgeInsets.only(top: 8, bottom: 8, left: widget.icon != null ? 5 : 10, right: 10),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (widget.icon != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CineIcon(icon: widget.icon!, color: CineColorScheme.onPrimary),
                            SizedBox(width: CineSpacing.s1),
                          ],
                        ),
                      CineText(widget.text, style: CineTextStyles.btnText, color: CineColorScheme.onPrimary),
                    ],
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
