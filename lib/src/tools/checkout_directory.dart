// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:io';

import 'package:gg_cli_cp/src/tools/gg_directory.dart';

/// Returns the directory the checkouts need to be done
String checkoutDirectory() {
  // Get the current working directory
  return Directory(ggDirectory()).parent.absolute.path;
}
