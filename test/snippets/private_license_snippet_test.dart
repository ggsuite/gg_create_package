// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:gg_create_package/src/snippets/private_license_snippet.dart';
import 'package:test/test.dart';

void main() {
  group('PrivateLicenseSnippet', () {
    test('should work fine', () {
      final year = DateTime.now().year.toString();
      expect(privateLicenceSnippet, contains(year));
    });
  });
}
