// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:io';

import 'package:path/path.dart';

/// Get the project directory
String audCliDirectory() {
  const packageName = 'aud_cli_create_dart_package';

  // Get the current working directory
  final current = Directory.current.path;

  // Is the current working directory in the checkout dir?
  final isCheckOutDir = Directory(join(current, packageName)).existsSync();

  // Does the current working directory contain an "aud_cli_create_dart_package"
  // directory?
  final isAudCliDir = !isCheckOutDir && current.contains(packageName);

  // We need to be either within the aud_cli directory or in the checkout dir
  if (!isAudCliDir && !isCheckOutDir) {
    throw Exception('The current directory needs to be either a '
        'subdirectory or the direct parent directory of '
        'aud_cli_create_dart_package.');
  }

  // Estimate the project root
  final projectRoot = isAudCliDir
      ? current.substring(
          0,
          current.lastIndexOf(packageName) + packageName.length,
        )
      : join(current, packageName);

  return projectRoot;
}
