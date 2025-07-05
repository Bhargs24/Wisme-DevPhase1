#!/usr/bin/env dart

/// Comprehensive integration test for Wisme app
/// This script checks all critical components and screens for proper integration

import 'dart:io';

void main() async {
  print('🚀 Starting Wisme App Integration Test\n');

  final results = <String, bool>{};

  // Test 1: Check core file structure
  print('📁 Testing file structure...');
  results['File Structure'] = await testFileStructure();

  // Test 2: Check import statements
  print('📦 Testing imports...');
  results['Import Validation'] = await testImports();

  // Test 3: Check provider structure
  print('🔧 Testing providers...');
  results['Provider Structure'] = await testProviders();

  // Test 4: Check navigation structure
  print('🧭 Testing navigation...');
  results['Navigation Structure'] = await testNavigation();

  // Test 5: Check UI components
  print('🎨 Testing UI components...');
  results['UI Components'] = await testUIComponents();

  // Test 6: Check constants and styles
  print('🎭 Testing constants and styles...');
  results['Constants & Styles'] = await testConstants();

  // Print results
  print('\n📊 TEST RESULTS:');
  print('=' * 50);
  
  int passed = 0;
  int total = results.length;
  
  results.forEach((test, testPassed) {
    final status = testPassed ? '✅' : '❌';
    print('$status $test');
    if (testPassed) passed++;
  });
  
  print('=' * 50);
  print('Total: $passed/$total tests passed');
  
  if (passed == total) {
    print('🎉 All tests passed! The app structure is ready for deployment.');
  } else {
    print('⚠️  Some tests failed. Please review the issues above.');
  }
  
  exit(passed == total ? 0 : 1);
}

Future<bool> testFileStructure() async {
  final requiredFiles = [
    'lib/main.dart',
    'lib/app.dart',
    'lib/routes.dart',
    'lib/models/user_model.dart',
    'lib/models/lesson_model.dart',
    'lib/models/coach_model.dart',
    'lib/providers/user_provider.dart',
    'lib/providers/lesson_provider.dart',
    'lib/providers/coach_provider.dart',
    'lib/providers/settings_provider.dart',
    'lib/UI/widgets/main_navigation.dart',
    'lib/UI/widgets/auth_wrapper.dart',
    'lib/UI/widgets/modern_components.dart',
    'lib/UI/widgets/error_boundary.dart',
    'lib/UI/widgets/loading_states.dart',
    'lib/UI/widgets/micro_interactions.dart',
    'lib/UI/screens/splash_screen.dart',
    'lib/UI/screens/home_screen.dart',
    'lib/UI/screens/dashboard_screen.dart',
    'lib/UI/screens/profile_screen.dart',
    'lib/constants/app_colors.dart',
    'lib/constants/app_text_styles.dart',
    'lib/services/auth_services.dart',
    'lib/utils/accessibility_helper.dart',
  ];

  int found = 0;
  for (final file in requiredFiles) {
    if (await File(file).exists()) {
      found++;
    } else {
      print('  ❌ Missing: $file');
    }
  }

  print('  Found $found/${requiredFiles.length} required files');
  return found == requiredFiles.length;
}

Future<bool> testImports() async {
  final filesToCheck = [
    'lib/main.dart',
    'lib/app.dart',
    'lib/routes.dart',
    'lib/UI/widgets/main_navigation.dart',
    'lib/UI/widgets/auth_wrapper.dart',
  ];

  int validFiles = 0;
  for (final file in filesToCheck) {
    if (await File(file).exists()) {
      final content = await File(file).readAsString();
      // Check for common import issues
      if (!content.contains('import \'package:flutter/material.dart\';')) {
        print('  ❌ $file: Missing Flutter material import');
        continue;
      }
      validFiles++;
    }
  }

  print('  Validated $validFiles/${filesToCheck.length} files');
  return validFiles == filesToCheck.length;
}

Future<bool> testProviders() async {
  final providers = [
    'lib/providers/user_provider.dart',
    'lib/providers/lesson_provider.dart',
    'lib/providers/coach_provider.dart',
    'lib/providers/settings_provider.dart',
  ];

  int validProviders = 0;
  for (final provider in providers) {
    if (await File(provider).exists()) {
      final content = await File(provider).readAsString();
      if (content.contains('ChangeNotifier') && content.contains('notifyListeners')) {
        validProviders++;
      } else {
        print('  ❌ $provider: Invalid provider structure');
      }
    }
  }

  print('  Validated $validProviders/${providers.length} providers');
  return validProviders == providers.length;
}

Future<bool> testNavigation() async {
  final routesFile = 'lib/routes.dart';
  final mainNavFile = 'lib/UI/widgets/main_navigation.dart';

  if (!await File(routesFile).exists() || !await File(mainNavFile).exists()) {
    print('  ❌ Navigation files missing');
    return false;
  }

  final routesContent = await File(routesFile).readAsString();
  final navContent = await File(mainNavFile).readAsString();

  final hasRoutes = routesContent.contains('static const String') && 
                   routesContent.contains('static Route<dynamic>');
  final hasNavigation = navContent.contains('BottomNavigationBar') || 
                       navContent.contains('NavigationBar');

  if (!hasRoutes) print('  ❌ Routes structure invalid');
  if (!hasNavigation) print('  ❌ Navigation structure invalid');

  return hasRoutes && hasNavigation;
}

Future<bool> testUIComponents() async {
  final components = [
    'lib/UI/widgets/modern_components.dart',
    'lib/UI/widgets/error_boundary.dart',
    'lib/UI/widgets/loading_states.dart',
    'lib/UI/widgets/micro_interactions.dart',
  ];

  int validComponents = 0;
  for (final component in components) {
    if (await File(component).exists()) {
      final content = await File(component).readAsString();
      if (content.contains('StatelessWidget') || content.contains('StatefulWidget')) {
        validComponents++;
      } else {
        print('  ❌ $component: Invalid widget structure');
      }
    }
  }

  print('  Validated $validComponents/${components.length} UI components');
  return validComponents == components.length;
}

Future<bool> testConstants() async {
  final constants = [
    'lib/constants/app_colors.dart',
    'lib/constants/app_text_styles.dart',
  ];

  int validConstants = 0;
  for (final constant in constants) {
    if (await File(constant).exists()) {
      final content = await File(constant).readAsString();
      if (content.contains('class') && content.contains('static')) {
        validConstants++;
      } else {
        print('  ❌ $constant: Invalid constants structure');
      }
    }
  }

  print('  Validated $validConstants/${constants.length} constant files');
  return validConstants == constants.length;
}
