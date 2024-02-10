// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:io';

import 'package:aud_cli_create_dart_package/src/tools.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

void main() {
  group('getCheckOutDir', () {
    // #########################################################################

    test(
        'should return the parent of the aud_cli_create_dart_package directory',
        () {
      final checkOutDir = checkoutDirectory();
      expect(Directory(checkOutDir).existsSync(), isTrue);

      final audCliDir = join(checkOutDir, 'aud_cli_create_dart_package');
      expect(Directory(audCliDir).existsSync(), isTrue);
    });
  });
}
