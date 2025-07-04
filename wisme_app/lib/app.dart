import 'package:flutter/material.dart';

import 'routes.dart';
import 'design_system/themes/app_theme.dart';

class WismeApp extends StatelessWidget {
  const WismeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wisme - Microlearning App',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.launcher,
      routes: AppRoutes.routes,
    );
  }
}
