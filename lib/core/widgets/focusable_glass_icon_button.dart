import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FocusableGlassIconButton extends StatefulWidget {
  final ThemeData theme;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? iconColor;
  final FocusNode? focusNode;
  final double size;

  const FocusableGlassIconButton({
    super.key,
    required this.theme,
    required this.icon,
    required this.onPressed,
    this.iconColor,
    this.focusNode,
    this.size = 36,
  });

  @override
  State<FocusableGlassIconButton> createState() => _FocusableGlassIconButtonState();
}

class _FocusableGlassIconButtonState extends State<FocusableGlassIconButton> {
  late FocusNode _focusNode;
  bool _isInternalFocusNode = false;
  bool _isFocused = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
      _isInternalFocusNode = false;
    } else {
      _focusNode = FocusNode(debugLabel: 'GlassIconButton_${widget.icon.codePoint}');
      _isInternalFocusNode = true;
    }
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(FocusableGlassIconButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      _focusNode.removeListener(_handleFocusChange);
      if (_isInternalFocusNode) {
        _focusNode.dispose();
      }
      if (widget.focusNode != null) {
        _focusNode = widget.focusNode!;
        _isInternalFocusNode = false;
      } else {
        _focusNode = FocusNode(debugLabel: 'GlassIconButton_${widget.icon.codePoint}');
        _isInternalFocusNode = true;
      }
      _focusNode.addListener(_handleFocusChange);
    }
  }

  void _handleFocusChange() {
    if (_isFocused != _focusNode.hasFocus) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (_isInternalFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final isDark = theme.brightness == Brightness.dark;
    final isActive = _isFocused || _isHovered;

    final defaultBg = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.05);
    final defaultIconColor = widget.iconColor ?? (isDark ? Colors.white70 : Colors.black54);

    final activeBg = Colors.white;
    final activeIconColor = Colors.black;

    return Focus(
      focusNode: _focusNode,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.select ||
              event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.space ||
              event.logicalKey == LogicalKeyboardKey.gameButtonA) {
            widget.onPressed();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onPressed,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: isActive ? activeBg : defaultBg,
              border: isActive
                  ? Border.all(color: Colors.white, width: 2.0)
                  : null,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.3),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
            ),
            child: Center(
              child: Icon(
                widget.icon,
                color: isActive ? activeIconColor : defaultIconColor,
                size: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
