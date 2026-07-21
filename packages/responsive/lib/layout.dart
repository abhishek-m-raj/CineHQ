import 'package:device/device.dart';
import 'package:flutter/material.dart';
import 'dimensions.dart';

class ResponsiveLayout extends StatefulWidget {
  final Widget? mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? tv;

  const ResponsiveLayout({super.key, this.mobile, this.tablet, this.desktop, this.tv});

  @override
  State<ResponsiveLayout> createState() => _ResponsiveLayoutState();
}

class _ResponsiveLayoutState extends State<ResponsiveLayout> with WidgetsBindingObserver {
  late Size _windowSize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    _windowSize = View.of(context).physicalSize / View.of(context).devicePixelRatio;
    super.didChangeDependencies();
  }

  @override
  void didChangeMetrics() {
    final newSize = View.of(context).physicalSize / View.of(context).devicePixelRatio;
    setState(() {
      _windowSize = newSize;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mobile == null && widget.tablet == null && widget.desktop == null) {
      return const Center(
        child: Text("No children provided", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        if (Device.isTv) {
          return widget.tv ?? widget.desktop ?? widget.tablet ?? widget.mobile!;
        }

        final double screenWidth = (_windowSize.width != 0) ? _windowSize.width : constraints.maxWidth;
        if (screenWidth <= tabletWidth && screenWidth > mobileWidth) {
          return (widget.tablet ?? widget.mobile ?? widget.desktop)!;
        } else if (screenWidth <= mobileWidth) {
          return (widget.mobile ?? widget.tablet ?? widget.desktop)!;
        } else {
          return (widget.desktop ?? widget.tablet ?? widget.mobile)!;
        }
      },
    );
  }
}
