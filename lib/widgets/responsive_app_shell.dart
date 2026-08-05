import 'package:flutter/material.dart';

class ResponsiveAppShell extends StatelessWidget {
  const ResponsiveAppShell({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final maxContentWidth = width >= 1200 ? 1100.0 : width >= 700 ? 840.0 : width;

        return ColoredBox(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: maxContentWidth,
              height: constraints.maxHeight,
              child: child,
            ),
          ),
        );
      },
    );
  }
}
