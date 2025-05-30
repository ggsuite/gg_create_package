// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:io';

import 'package:gg_create_package/src/tools/gg_directory.dart';
import 'package:test/test.dart';

void main() {
  group('getProjectDir', () {
    final oldCurrentDir = Directory.current;

    tearDown(() {
      Directory.current = oldCurrentDir;
    });

    // #########################################################################

    group('should return the current project directory', () {
      test(
          'when the current working directory is the '
          'gg_create_package directory', () {
        // Expect the current working directory to end with
        // 'gg_create_package'
        expect(ggDirectory(), endsWith('gg_create_package'));
      });

      test(
          'when the current working directory is the parent dir of '
          'gg_create_package', () {
        // Change the current working directory to the parent dir of
        // gg_create_package
        Directory.current = Directory.current.parent;
        expect(ggDirectory(), endsWith('gg_create_package'));
      });
    });

    test(
        'should throw when the current working dir '
        'is not checkout dir or gg_create_package dir', () {
      // Change the current working dir to the grandparent dir of
      // gg_create_package
      Directory.current = Directory.systemTemp;
      expect(
        () => ggDirectory(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            'Exception: The current directory needs to be '
                'either a subdirectory or the direct parent directory '
                'of gg_create_package.',
          ),
        ),
      );
    });
  });
}
