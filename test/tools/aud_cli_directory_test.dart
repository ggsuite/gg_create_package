// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:io';

import 'package:aud_cli_create_dart_package/src/tools.dart';
import 'package:test/test.dart';

void main() {
  group('getProjectDir', () {
    final oldCurrentDir = Directory.current;

    tearDown(() {
      Directory.current = oldCurrentDir;
    });

    // #########################################################################

    group('should return the current project directory', () {
      test('when the current working directory is the aud_cli directory', () {
        // Expect the current working directory to end with 'aud_cli'
        expect(audCliDirectory(), endsWith('aud_cli'));
      });

      test('when the current working directory is the parent dir of aud_cli',
          () {
        // Change the current working directory to the parent dir of aud_cli
        Directory.current = Directory.current.parent;
        expect(audCliDirectory(), endsWith('aud_cli'));
      });
    });

    test(
        'should throw when the current working dir '
        'is not checkout dir or aud_cli dir', () {
      // Change the current working dir to the grandparent dir of aud_cli
      Directory.current = Directory.systemTemp;
      expect(
        () => audCliDirectory(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            'Exception: The current directory needs to be '
                'either a subdirectory or the direct parent directory '
                'of aud_cli.',
          ),
        ),
      );
    });
  });
}
