import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MediaTypeSwitcher extends StatelessWidget {
  final bool isMoviesActive;
  final ValueChanged<bool> onChanged;

  const MediaTypeSwitcher({
    super.key,
    required this.isMoviesActive,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _MediaTypeTabTile(
          label: 'MOVIES',
          isSelected: isMoviesActive,
          onTap: () {
            if (!isMoviesActive) {
              onChanged(true);
            }
          },
        ),
        const SizedBox(width: 6),
        _MediaTypeTabTile(
          label: 'SERIES',
          isSelected: !isMoviesActive,
          onTap: () {
            if (isMoviesActive) {
              onChanged(false);
            }
          },
        ),
      ],
    );
  }
}

class _MediaTypeTabTile extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _MediaTypeTabTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_MediaTypeTabTile> createState() => _MediaTypeTabTileState();
}

class _MediaTypeTabTileState extends State<_MediaTypeTabTile> {
  late final FocusNode _focusNode;
  bool _isFocused = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(debugLabel: 'MediaTypeTab_${widget.label}');
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = _isFocused || _isHovered;

    return Focus(
      focusNode: _focusNode,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.select ||
              event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.gameButtonA ||
              event.logicalKey == LogicalKeyboardKey.space) {
            widget.onTap();
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
            widget.onTap();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? theme.colorScheme.primary
                  : (isActive
                      ? theme.colorScheme.surfaceBright
                      : theme.colorScheme.surfaceBright.withValues(alpha: 0.6)),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isActive
                    ? theme.colorScheme.primary
                    : (widget.isSelected
                        ? Colors.transparent
                        : theme.colorScheme.outline.withValues(alpha: 0.5)),
                width: isActive ? 2 : 1,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.35),
                        blurRadius: 8,
                      ),
                    ]
                  : [],
            ),
            child: Text(
              widget.label,
              style: TextStyle(
                color: widget.isSelected
                    ? theme.colorScheme.onPrimary
                    : (isActive
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface),
                fontWeight: widget.isSelected || isActive
                    ? FontWeight.bold
                    : FontWeight.w600,
                fontSize: 11,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
