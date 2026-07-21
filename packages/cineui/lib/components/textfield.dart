import 'package:custom_tv_text_field/custom_tv_text_field.dart';
import 'package:device/device.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cineui/constants/radius.dart';
import 'package:cineui/cineui.dart';

class CineTextField extends StatefulWidget {
  final TextEditingController? controller;
  final TextInputAction? textInputAction;
  final bool enableBorder;
  final String? hintText;
  final IconSource? icon;
  final bool secret;
  final Iterable<String>? autoFill;
  final String? Function(String?)? validator;
  final EdgeInsets? padding;
  final Function(dynamic)? onChange;
  final TextFieldType? textFieldType;

  const CineTextField({
    super.key,
    this.controller,
    this.textInputAction,
    this.enableBorder = true,
    this.hintText,
    this.icon,
    this.secret = false,
    this.autoFill,
    this.validator,
    this.padding,
    this.onChange,
    this.textFieldType,
  });

  @override
  State<CineTextField> createState() => _HqTextFieldState();
}

class _HqTextFieldState extends State<CineTextField> {
  late bool hidden;
  late FocusNode _fieldFocusNode;
  late FocusNode _boxFocusNode;
  bool _focused = false;
  late TextEditingController _controller;
  final GlobalKey<CustomTVTextFieldState> _tvFieldKey = GlobalKey<CustomTVTextFieldState>();

  @override
  void initState() {
    _fieldFocusNode = FocusNode();
    _boxFocusNode = FocusNode();
    hidden = widget.secret;
    _controller = widget.controller ?? TextEditingController();
    if (widget.onChange != null) {
      _controller.addListener(_onChanged);
    }
    super.initState();
  }

  void _onChanged() {
    widget.onChange!(_controller.text);
  }

  @override
  void dispose() {
    _fieldFocusNode.dispose();
    _boxFocusNode.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onChanged);
    }
    super.dispose();
  }

  void setObscureTextState() {
    setState(() {
      hidden = !hidden;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _boxFocusNode,
      onFocusChange: (val) {
        setState(() {
          _focused = val;
        });
      },
      onKeyEvent: (node, event) {
        if (Device.isTv) {
          if (event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.select) {
            if (event is KeyDownEvent) {
              _tvFieldKey.currentState?.openKeyboard();
              return KeyEventResult.handled;
            }
          }
        } else {
          if (event.logicalKey == LogicalKeyboardKey.enter && event is KeyDownEvent) {
            _boxFocusNode.unfocus();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      descendantsAreTraversable: false,
      child: Container(
        decoration: BoxDecoration(
          border: (_focused && Device.isTv) ? Border.all(color: CineColorScheme.outline, width: 2) : null,
          borderRadius: CineBorderRadius.br2.asRadius,
          color: Device.isTv ? null : CineColorScheme.surfaceBright,
        ),
        padding: widget.padding,
        child: Device.isTv
            ? CustomTVTextField(
                key: _tvFieldKey,
                controller: _controller,
                isFocused: _focused,
                hint: widget.hintText ?? '',
                validator: widget.validator,
                textFieldType:
                    widget.textFieldType ?? (widget.secret ? TextFieldType.password : TextFieldType.username),
                prefixIcon: widget.icon != null ? CineIcon(icon: widget.icon!, color: Colors.white) : null,
                suffixIcon: widget.secret
                    ? IconButton(
                        icon: Icon(hidden == true ? Icons.visibility : Icons.visibility_off),
                        color: CineColorScheme.onSurfaceContainer,
                        onPressed: () => setObscureTextState(),
                        iconSize: 20,
                      )
                    : null,
                backgroundColor: CineColorScheme.surfaceBright,
                fillColor: CineColorScheme.surfaceBright,
                borderRadius: CineBorderRadius.br2,
                borderColor: Colors.transparent,
                focusedBorderColor: Colors.transparent,
                textStyle: CineTextStyles.b1,
                hintStyle: CineTextStyles.b1.copyWith(color: Colors.white54),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                onVisibilityChanged: (isVisible) {
                  if (!isVisible) {
                    _boxFocusNode.requestFocus();
                  }
                },
                onFieldSubmitted: (_) {
                  _boxFocusNode.requestFocus();
                },
              )
            : TextFormField(
                focusNode: _fieldFocusNode,
                controller: _controller,
                onTapOutside: (_) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                style: CineTextStyles.b1,
                textInputAction: widget.textInputAction,
                enableInteractiveSelection: !Device.isTv,
                validator: widget.validator,
                obscureText: hidden,
                autofillHints: widget.autoFill,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.transparent),
                    borderRadius: CineBorderRadius.br2.asRadius,
                    gapPadding: 0,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.transparent),
                    borderRadius: CineBorderRadius.br2.asRadius,
                    gapPadding: 0,
                  ),
                  prefixIcon: widget.icon != null
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CineIcon(icon: widget.icon!, color: Colors.white),
                        )
                      : null,
                  suffixIcon: widget.secret
                      ? IconButton(
                          icon: Icon(hidden == true ? Icons.visibility : Icons.visibility_off),
                          color: CineColorScheme.onSurfaceContainer,
                          onPressed: () => setObscureTextState(),
                        )
                      : null,
                  fillColor: CineColorScheme.surfaceBright,
                  filled: true,
                  hintText: widget.hintText,
                ),
              ),
      ),
    );
  }
}
