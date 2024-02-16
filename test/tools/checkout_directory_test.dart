// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:io';

import 'package:gg_cli_cp/src/tools/checkout_directory.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

void main() {
  group('getCheckOutDir', () {
    // #########################################################################

    test('should return the parent of the gg_cli_cp directory', () {
      final checkOutDir = checkoutDirectory();
      expect(Directory(checkOutDir).existsSync(), isTrue);

      final ggDir = join(checkOutDir, 'gg_cli_cp');
      expect(Directory(ggDir).existsSync(), isTrue);
    });
  });
}
