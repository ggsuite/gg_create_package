// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:gg_cli_cp/src/snippets/bin_snippet.dart';
import 'package:test/test.dart';

void main() {
  group('BinSnippet', () {
    test('should work fine', () {
      final snippet = binSnippet(
        packageName: 'my_package',
        description: 'My description.',
      );

      void exp(String txt) => expect(snippet, contains(txt));
      exp('import \'package:my_package/my_package.dart\';');
      exp('Future<void> runMyPackage({');
    });
  });
}
