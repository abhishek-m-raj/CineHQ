import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MediaTypeSwitcher extends StatefulWidget {
  final bool isMoviesActive;
  final ValueChanged<bool> onChanged;
  final FocusNode? focusNode;

  const MediaTypeSwitcher({
    super.key,
    required this.isMoviesActive,
    required this.onChanged,
    this.focusNode,
  });

  @override
  State<MediaTypeSwitcher> createState() => _MediaTypeSwitcherState();
}

class _MediaTypeSwitcherState extends State<MediaTypeSwitcher> {
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
      _focusNode = FocusNode(debugLabel: 'MediaTypeSwitcherSingle');
      _isInternalFocusNode = true;
    }
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(MediaTypeSwitcher oldWidget) {
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
        _focusNode = FocusNode(debugLabel: 'MediaTypeSwitcherSingle');
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

  void _toggle() {
    widget.onChanged(!widget.isMoviesActive);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMovies = widget.isMoviesActive;
    final label = isMovies ? 'MOVIES' : 'SERIES';
    final icon = isMovies ? Icons.movie_outlined : Icons.tv_outlined;

    return Focus(
      focusNode: _focusNode,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.select ||
              event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.space ||
              event.logicalKey == LogicalKeyboardKey.gameButtonA) {
            _toggle();
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
          onTap: () {
            _focusNode.requestFocus();
            _toggle();
          },
          behavior: HitTestBehavior.opaque,
          child: AnimatedScale(
            scale: _isFocused ? 1.06 : (_isHovered ? 1.03 : 1.0),
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: _isFocused
                    ? theme.colorScheme.primary
                    : (_isHovered
                        ? theme.colorScheme.primary.withValues(alpha: 0.85)
                        : theme.colorScheme.primary.withValues(alpha: 0.15)),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _isFocused || _isHovered
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline.withValues(alpha: 0.5),
                  width: _isFocused ? 2.0 : 1.0,
                ),
                boxShadow: _isFocused
                    ? [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.4),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ]
                    : (_isHovered
                        ? [
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(alpha: 0.2),
                              blurRadius: 6,
                            ),
                          ]
                        : []),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  );
                },
                child: Row(
                  key: ValueKey<bool>(isMovies),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 16,
                      color: (_isFocused || _isHovered)
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        color: (_isFocused || _isHovered)
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.swap_horiz_rounded,
                      size: 14,
                      color: (_isFocused || _isHovered)
                          ? theme.colorScheme.onPrimary.withValues(alpha: 0.8)
                          : theme.colorScheme.primary.withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
