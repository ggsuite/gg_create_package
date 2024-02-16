// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:gg_cli_cp/src/snippets/lib_snippet.dart';
import 'package:test/test.dart';

void main() {
  group('LibSnippet', () {
    test('should work fine', () {
      expect(libSnippet(packageName: 'a_b_c'), isNotNull);
    });
  });
}
