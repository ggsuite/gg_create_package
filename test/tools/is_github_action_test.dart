// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'dart:io';

import 'package:gg_create_package/src/tools/is_github_action.dart';
import 'package:test/test.dart';

void main() {
  group('IsGithubAction', () {
    test('should work fine', () {
      expect(isGitHubAction, Platform.environment['GITHUB_WORKSPACE'] != null);
    });
  });
}
