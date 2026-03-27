import 'package:flutter/material.dart';

import '../../../core/ui/widgets/app_scaffold.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  static const routeLocation = '/app/more';

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'More',
      body: Center(child: Text('More (placeholder)')),
    );
  }
}

