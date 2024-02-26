// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:io';

import 'package:path/path.dart';

/// Get the project directory
String ggDirectory() {
  const packageName = 'gg_create_package';

  // Get the current working directory
  final current = Directory.current.path;

  // The checkout directory contains all of our repositories
  // If the currenct directory contains a gg/ directory, we are in the checkout
  // directory
  final isCheckOutDir = Directory(join(current, packageName)).existsSync();

  // Does the current working directory contain an "gg" directory?
  final isGgCliCpDir = !isCheckOutDir && (current.contains(packageName));

  // We need to be either within the gg directory or in the checkout dir
  if (!isGgCliCpDir && !isCheckOutDir) {
    throw Exception(
      'The current directory needs to be either a '
      'subdirectory or the direct parent directory of '
      'gg_create_package.',
    );
  }

  // Estimate the project root
  final projectRoot = isGgCliCpDir
      ? current.substring(
          0,
          current.lastIndexOf(packageName) + packageName.length,
        )
      : join(current, packageName);

  return projectRoot;
}
