import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      // Use provided background color or default to surface
      color: backgroundColor ?? scheme.surface,
      surfaceTintColor: Colors.transparent,
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}

