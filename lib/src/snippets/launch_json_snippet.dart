// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:recase/recase.dart';

/// Creates a launchJson snippet
String launchJsonSnippet({required String packageName}) {
  final packageNamePascalCase = packageName.pascalCase;
  final packageNameCamelCase = packageName.camelCase;
  final packageNameSnakeCase = packageName.snakeCase;

  return '''
{
  // Use IntelliSense to learn about possible attributes.
  // Hover to view descriptions of existing attributes.
  // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
  "version": "0.2.0",

  "configurations": [
    {
      "name": "Run $packageNamePascalCase",
      "type": "dart",
      "request": "launch",
      "program": "\${workspaceFolder}/bin/$packageNameSnakeCase.dart",
      "args": ["$packageNameCamelCase", "--param", "value"],
      "console": "debugConsole"
    },
    {
      "name": "Test Current File",
      "type": "dart",
      "request": "launch",
      "program": "\${file}"
    }
  ]
}
'''
      .trim();
}
