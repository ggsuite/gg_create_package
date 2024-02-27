// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

/// This snippet is used to create check.yaml for the generaeted package.
String get checkYamlSnippet => '''
needsInternet: false
analyze:
  execute: true
format:
  execute: true
tests:
  execute: true
pana:
  execute: false
''';
