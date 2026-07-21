import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:device/device.dart';
import 'icon.dart';
import '../constants/theme/color_scheme.dart';
import '../utils/colors.dart';

final bottomNavbarSpace = const SizedBox(height: 75);

class CineNavigationBar<T> extends StatelessWidget {
  const CineNavigationBar({
    super.key,
    this.direction = Axis.horizontal,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final Axis direction;
  final List<CineNavbarItem> items;
  final T currentIndex;
  final Function(T) onTap;

  final Color indicatorColor = CineColorScheme.primary;
  final Color selectedItemColor = CineColorScheme.secondary;
  Color get unselectedItemColor => CineColorScheme.primary.putOpacity(0.4);
  Color get backgroundColor => isSideNavbar ? Colors.black.putOpacity(0.3) : Colors.black.putOpacity(0.5);
  final Color outlineBorderColor = Colors.white24;

  final Duration duration = const Duration(milliseconds: 500);
  final Curve curve = Curves.easeOutQuint;

  final List<BoxShadow> boxShadow = const [
    BoxShadow(color: Colors.transparent, spreadRadius: 0, blurRadius: 0, offset: Offset(0, 0)),
  ];
  EdgeInsets get marginR {
    if (isSideNavbar) {
      return const EdgeInsets.all(5).copyWith(right: 0);
    } else {
      return const EdgeInsets.only(left: 30, right: 30, bottom: 10, top: 25);
    }
  }

  EdgeInsets get paddingR {
    if (isSideNavbar) {
      return const EdgeInsets.all(10);
    } else {
      return const EdgeInsets.only(bottom: 10, top: 10, right: 8, left: 8);
    }
  }

  final EdgeInsets itemPadding = const EdgeInsets.symmetric(vertical: 10, horizontal: 10);

  final double borderRadius = 15;
  double get height => isSideNavbar ? 70 : 105;

  bool get isSideNavbar {
    return direction == Axis.vertical;
  }

  @override
  Widget build(BuildContext context) {
    if (isSideNavbar) {
      return Builder(
        builder: (context) {
          return _builder();
        },
      );
    } else {
      return BottomAppBar(
        color: Colors.transparent,
        padding: EdgeInsets.zero,
        elevation: 0,
        height: height,
        child: Builder(
          builder: (context) {
            return _builder();
          },
        ),
      );
    }
  }

  Container _builder() {
    final Widget content = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: outlineBorderColor),
        color: backgroundColor,
      ),
      padding: paddingR,
      child: Body(
        items: items,
        currentIndex: currentIndex,
        curve: curve,
        duration: duration,
        selectedItemColor: selectedItemColor,
        unselectedItemColor: unselectedItemColor,
        onTap: (val) => onTap(val),
        itemPadding: itemPadding,
        indicatorColor: indicatorColor,
        isSideNavbar: isSideNavbar,
      ),
    );

    return Container(
      width: height,
      margin: marginR,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(boxShadow: boxShadow, borderRadius: BorderRadius.circular(borderRadius)),
      child: (Device.isTv) ? content : BackdropFilter(filter: ImageFilter.blur(sigmaY: 10, sigmaX: 10), child: content),
    );
  }
}

class Body<T> extends StatefulWidget {
  const Body({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.curve,
    required this.duration,
    required this.selectedItemColor,
    required this.unselectedItemColor,
    required this.onTap,
    required this.itemPadding,
    required this.indicatorColor,
    this.isSideNavbar = false,
    this.splashBorderRadius,
    this.splashColor,
    this.iconSize = 24,
  });

  final List<CineNavbarItem> items;
  final T currentIndex;
  final Curve curve;
  final Duration duration;
  final Color selectedItemColor;
  final Color unselectedItemColor;
  final Function(T) onTap;
  final EdgeInsets itemPadding;
  final Color indicatorColor;
  final Color? splashColor;
  final double iconSize;
  final double? splashBorderRadius;
  final bool isSideNavbar;

  @override
  State<Body<T>> createState() => _BodyState<T>();
}

class _BodyState<T> extends State<Body<T>> {
  final Map<T, FocusNode> _focusNodes = {};

  @override
  void initState() {
    super.initState();
    _updateFocusNodes();
    if (Device.isTv) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNodes[widget.currentIndex]?.requestFocus();
      });
    }
  }

  @override
  void didUpdateWidget(covariant Body<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _updateFocusNodes();
    }
  }

  void _updateFocusNodes() {
    for (var item in widget.items) {
      _focusNodes.putIfAbsent(item.id, () => FocusNode());
    }
  }

  @override
  void dispose() {
    for (var node in _focusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isSideNavbar) {
      return Column(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: _children);
    }
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, mainAxisSize: MainAxisSize.max, children: _children);
  }

  List<Widget> get _children {
    return [
      SizedBox(height: widget.itemPadding.top),
      for (final item in widget.items)
        TweenAnimationBuilder<double>(
          tween: Tween(end: item.id == widget.currentIndex ? 1.0 : 0.0),
          curve: widget.curve,
          duration: widget.duration,
          builder: (context, t, _) {
            final bool selected = item.id == widget.currentIndex;
            final selectedColor = item.selectedColor ?? widget.selectedItemColor;
            final unselectedColor = item.unselectedColor ?? widget.unselectedItemColor;
            return Material(
              color: Color.lerp(Colors.transparent, Colors.transparent, t),
              borderRadius: BorderRadius.circular(widget.splashBorderRadius ?? 8),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                focusNode: _focusNodes[item.id],
                onTap: () => widget.onTap.call(item.id),
                focusColor: widget.splashColor ?? selectedColor.putOpacity(0.1),
                highlightColor: widget.splashColor ?? selectedColor.putOpacity(0.1),
                splashColor: widget.splashColor ?? selectedColor.putOpacity(0.1),
                hoverColor: widget.splashColor ?? selectedColor.putOpacity(0.1),
                child: Stack(
                  children: <Widget>[
                    Padding(
                      padding: widget.itemPadding + const EdgeInsets.symmetric(horizontal: 2),
                      child: CineIcon(
                        icon: selected ? item.icon : (item.unselectedIcon ?? item.icon),
                        size: widget.iconSize,
                        color: Color.lerp(unselectedColor, selectedColor, t),
                      ),
                    ),
                    if (selected)
                      Positioned(
                        top: widget.isSideNavbar ? widget.iconSize / 1.7 : null,
                        left: widget.isSideNavbar ? 5 : widget.iconSize / 1.5,
                        bottom: widget.isSideNavbar ? null : 0,
                        child: Container(
                          height: widget.isSideNavbar ? 16 : 3,
                          width: widget.isSideNavbar ? 3 : 16,
                          decoration: BoxDecoration(color: selectedColor, borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      SizedBox(height: widget.itemPadding.top),
    ];
  }
}

class CineNavbarItem<T> {
  final IconSource icon;
  final T id;
  final IconSource? unselectedIcon;
  final Color? selectedColor;
  final Color? unselectedColor;

  CineNavbarItem({required this.icon, required this.id, this.unselectedIcon, this.selectedColor, this.unselectedColor});
}
