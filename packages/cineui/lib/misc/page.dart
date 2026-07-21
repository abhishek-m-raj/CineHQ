import 'package:device/device.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum TransitionType { slideIn, fadeScaleIn, fadeIn }

class CineTransitionPage {
  final LocalKey? key;
  final String? name;
  final TransitionType? transitionType;
  final Widget child;

  const CineTransitionPage({this.key, this.name, this.transitionType, required this.child});

  CustomTransitionPage<void> call() {
    if (Device.isTv) {
      return NoTransitionPage<void>(key: key, name: name, child: child);
    }
    if (transitionType == TransitionType.fadeScaleIn) {
      return _fadeScaleInPage();
    } else if (transitionType == TransitionType.fadeIn) {
      return _fadeInPage();
    } else if (transitionType == TransitionType.slideIn) {
      return _slideInPage();
    } else {
      if (Device.isMobile) {
        return _fadeScaleInPage();
      } else {
        return _fadeInPage();
      }
    }
  }

  CustomTransitionPage<void> _fadeInPage() {
    return CustomTransitionPage<void>(
      key: key,
      name: name,
      child: child,
      transitionDuration: const Duration(milliseconds: 500),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  CustomTransitionPage<void> _slideInPage() {
    return CustomTransitionPage<void>(
      key: key,
      name: name,
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }

  CustomTransitionPage<void> _fadeScaleInPage() {
    return CustomTransitionPage(
      key: key,
      name: name,
      transitionDuration: const Duration(milliseconds: 500),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeInOutQuart).animate(animation),
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.6,
              end: 1.0,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutQuart)),
            child: child,
          ),
        );
      },
    );
  }
}
