import 'package:flutter/material.dart';

class ResponsiveAppShell extends StatelessWidget {
  const ResponsiveAppShell({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(child: child);
  }
}
