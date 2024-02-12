#!/usr/bin/env dart

import 'dart:io';
import 'dart:async';

// .............................................................................
bool isFlutterPackage() {
  final File pubspec = File('pubspec.yaml');
  if (!pubspec.existsSync()) {
    throw Exception('pubspec.yaml not found');
  }

  final String content = pubspec.readAsStringSync();
  return (content.contains('flutter'));
}

// .............................................................................
Future<void> main(List<String> arguments) async {
  // Remove the coverage directory
  var coverageDir = Directory('coverage');
  if (await coverageDir.exists()) {
    await coverageDir.delete(recursive: true);
  }

  // Run the Dart coverage command

  var testResult = isFlutterPackage()
      ? await Process.run('flutter', ['test', '--coverage'])
      : await Process.run('dart', ['run', 'coverage:test_with_coverage']);
  if (testResult.exitCode != 0) {
    final lines = testResult.stdout
        .toString()
        .split(RegExp(r'\d\d:\d\d'))
        .where((x) => x.contains('[E]'));
    final errorLines = lines.where((x) => x.contains('[E]'));

    print(errorLines.join('\n'));
    exit(testResult.exitCode);
  }
}
