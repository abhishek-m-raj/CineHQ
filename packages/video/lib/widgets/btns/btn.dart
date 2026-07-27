import 'package:flutter/material.dart';
import 'package:video/ui/ui.dart';
import 'package:video/style/style.dart';
import '../../other/responsive.dart';

class VidBtn extends StatefulWidget {
  final IconSource icon;
  final VidStyle style;
  final VoidCallback? onTap;
  final double? size;
  final FocusNode? focusNode;

  const VidBtn({super.key, required this.icon, required this.style, this.onTap, this.size, this.focusNode});

  @override
  State<VidBtn> createState() => VidBtnState();
}

class VidBtnState extends State<VidBtn> {
  late FocusNode _focusNode;
  late bool _focused;
  late bool _hovering;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focused = _focusNode.hasFocus;
    _hovering = false;
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {
        _focused = _focusNode.hasFocus;
      });
    }
  }

  @override
  void didUpdateWidget(VidBtn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode?.removeListener(_onFocusChange);
      _focusNode = widget.focusNode ?? FocusNode();
      _focused = _focusNode.hasFocus;
      _focusNode.addListener(_onFocusChange);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      alignment: Alignment.center,
      transformAlignment: Alignment.center,
      height: (widget.size ?? buttonSize()) * 1.1 + HqSpacing.s1,
      width: (widget.size ?? buttonSize()) * 1.1 + HqSpacing.s1,
      decoration: BoxDecoration(
        color: (_hovering || _focused) ? widget.style.videoUiBtnsFocusColor.putOpacity(0.2) : HqColorScheme.transparent,
        borderRadius: HqBorderRadius.br3.asRadius,
      ),
      transform: Matrix4.identity()
        ..scaleByDouble(_hovering || _focused ? 1.05 : 1.0, _hovering || _focused ? 1.05 : 1.0, 1.0, 1.0),
      child: IconButton(
        focusNode: _focusNode,
        onHover: (hover) => setState(() => _hovering = hover),
        onPressed: widget.onTap,
        icon: HqIcon(icon: widget.icon, color: widget.style.videoUiBtnsColor, size: widget.size ?? buttonSize()),
        color: widget.style.videoUiBtnsColor,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        iconSize: widget.size ?? buttonSize(),
        splashRadius: (widget.size ?? buttonSize()) - 5,
        padding: EdgeInsets.all(HqSpacing.s1),
        constraints: const BoxConstraints(),
      ),
    );
  }
}
