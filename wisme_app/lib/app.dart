import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'routes.dart';
import 'design_system/themes/app_theme.dart';
import 'providers/user_provider.dart';
import 'UI/screens/home_screen.dart';
import 'UI/screens/login_screen.dart';

class WismeApp extends StatelessWidget {
  const WismeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wisme - Microlearning App',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          return userProvider.isLoggedIn 
              ? const HomeScreen() 
              : const LoginScreen();
        },
      ),
      routes: AppRoutes.routes,
    );
  }
}
