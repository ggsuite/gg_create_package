// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:gg_create_package/src/snippets/make_executable_snippet.dart';
import 'package:test/test.dart';

void main() {
  group('MakeExecutableSnippet', () {
    test('should work fine', () {
      createCoverageForMakeExecutableCreate();
      expect(makeExecutableSnippet, '#!/usr/bin/env dart\n');
    });
  });
}
