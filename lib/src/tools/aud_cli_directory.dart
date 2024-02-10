// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:io';

import 'package:path/path.dart';

/// Get the project directory
String audCliDirectory() {
  // Get the current working directory
  final current = Directory.current.path;

  // Is the current working directory in the checkout dir?
  final isCheckOutDir = Directory(join(current, 'aud_cli')).existsSync();

  // Does the current working directory contain an "aud_cli" directory?
  final isAudCliDir = !isCheckOutDir && current.contains('aud_cli');

  // We need to be either within the aud_cli directory or in the checkout dir
  if (!isAudCliDir && !isCheckOutDir) {
    throw Exception('The current directory needs to be either a '
        'subdirectory or the direct parent directory of aud_cli.');
  }

  // Estimate the project root
  final projectRoot = isAudCliDir
      ? current.substring(0, current.lastIndexOf('aud_cli') + 7)
      : join(current, 'aud_cli');

  return projectRoot;
}
