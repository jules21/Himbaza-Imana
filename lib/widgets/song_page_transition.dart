import 'package:flutter/material.dart';

class SongPageTransition extends StatelessWidget {
  const SongPageTransition({
    super.key,
    required this.forward,
    required this.child,
  });

  final bool forward;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        child: child,
        builder: (context, value, child) => Opacity(
          opacity: 0.4 + (value * 0.6),
          child: FractionalTranslation(
            translation: Offset((forward ? 0.12 : -0.12) * (1 - value), 0),
            child: child,
          ),
        ),
      ),
    );
  }
}
