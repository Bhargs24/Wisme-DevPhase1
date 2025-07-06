#!/usr/bin/env dart

// ==============================================================================
// WISME APP - IMPORT MIGRATION SCRIPT
// ==============================================================================
// This script helps migrate all your existing Dart files to use the new 
// centralized exports.dart file instead of individual imports.
// 
// Usage: dart run migration_script.dart
// ==============================================================================

import 'dart:io';

void main() {
  print('🚀 Starting Wisme App Import Migration...\n');
  
  // Define directories to process
  final directories = [
    'lib/UI/screens',
    'lib/UI/widgets', 
    'lib/providers',
    'lib/services',
    'lib/models',
    'lib/managers',
  ];
  
  int filesProcessed = 0;
  int filesModified = 0;
  
  for (final dirPath in directories) {
    final directory = Directory(dirPath);
    if (!directory.existsSync()) {
      print('⚠️  Directory not found: $dirPath');
      continue;
    }
    
    print('📁 Processing directory: $dirPath');
    
    final dartFiles = directory
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .toList();
    
    for (final file in dartFiles) {
      filesProcessed++;
      if (processFile(file)) {
        filesModified++;
        print('   ✅ Modified: ${file.path}');
      } else {
        print('   ⏭️  Skipped: ${file.path}');
      }
    }
  }
  
  print('\n🎉 Migration Complete!');
  print('📊 Files processed: $filesProcessed');
  print('✏️  Files modified: $filesModified');
  print('\n💡 All files now use the centralized import system!');
}

bool processFile(File file) {
  try {
    final content = file.readAsStringSync();
    final lines = content.split('\n');
    
    // Skip files that already use exports.dart
    if (content.contains("import '../../core/exports.dart'") || 
        content.contains("import '../core/exports.dart'") ||
        content.contains("import 'core/exports.dart'")) {
      return false;
    }
    
    // Find imports to replace
    final importsToReplace = <String>[];
    final newImports = <String>[];
    bool hasRelevantImports = false;
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      
      // Stop processing imports when we hit the first non-import/non-comment line
      if (!line.startsWith('import ') && 
          !line.startsWith('export ') && 
          !line.startsWith('//') && 
          !line.startsWith('/*') && 
          !line.startsWith('*') && 
          !line.startsWith('*/') && 
          line.isNotEmpty) {
        break;
      }
      
      if (line.startsWith('import ') && shouldReplaceImport(line)) {
        importsToReplace.add(line);
        hasRelevantImports = true;
      } else if (line.startsWith('import ') && !shouldReplaceImport(line)) {
        newImports.add(line);
      } else if (!line.startsWith('import ') && !line.startsWith('export ')) {
        newImports.add(line);
      }
    }
    
    if (!hasRelevantImports) {
      return false;
    }
    
    // Calculate the correct relative path to exports.dart
    final filePath = file.path.replaceAll('\\', '/');
    final relativePath = calculateRelativePath(filePath);
    
    // Build new content
    final newContent = StringBuffer();
    
    // Add the exports import
    newContent.writeln("import '$relativePath/core/exports.dart';");
    
    // Add any remaining imports (external packages, etc.)
    for (final import in newImports) {
      if (import.trim().isNotEmpty && import.startsWith('import ') && !shouldReplaceImport(import)) {
        newContent.writeln(import);
      }
    }
    
    // Add the rest of the file (non-import content)
    bool foundFirstNonImport = false;
    for (final line in lines) {
      if (!line.trim().startsWith('import ') && 
          !line.trim().startsWith('export ') && 
          (foundFirstNonImport || (!line.trim().startsWith('//') && line.trim().isNotEmpty))) {
        foundFirstNonImport = true;
        newContent.writeln(line);
      }
    }
    
    // Write the modified content back to file
    file.writeAsStringSync(newContent.toString());
    return true;
    
  } catch (e) {
    print('❌ Error processing ${file.path}: $e');
    return false;
  }
}

String calculateRelativePath(String filePath) {
  // Count directory depth from lib/
  final libIndex = filePath.indexOf('lib/');
  if (libIndex == -1) return '../..';
  
  final pathFromLib = filePath.substring(libIndex + 4);
  final depth = pathFromLib.split('/').length - 1;
  
  return List.filled(depth, '..').join('/');
}

bool shouldReplaceImport(String importLine) {
  // List of import patterns that should be replaced by exports.dart
  final patternsToReplace = [
    'package:flutter/material.dart',
    'package:flutter/services.dart', 
    'package:flutter/foundation.dart',
    'package:provider/provider.dart',
    '/constants/',
    '/models/',
    '/services/',
    '/providers/',
    '/managers/',
    '/UI/widgets/',
    '/UI/screens/',
    '/utils/',
    'routes.dart',
  ];
  
  return patternsToReplace.any((pattern) => importLine.contains(pattern));
}
