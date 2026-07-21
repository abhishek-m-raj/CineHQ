import 'dimensions.dart';

class ResponsiveValue<T> {
  final double screenWidth;
  final T? mobile;
  final T? tablet;
  final T? desktop;

  const ResponsiveValue({required this.screenWidth, this.mobile, this.tablet, this.desktop});

  T value() {
    if (screenWidth <= tabletWidth && screenWidth > mobileWidth) {
      return (tablet ?? desktop ?? mobile)!;
    } else if (screenWidth <= mobileWidth) {
      return (mobile ?? tablet ?? desktop)!;
    } else {
      return (desktop ?? tablet ?? mobile)!;
    }
  }
}
