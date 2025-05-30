// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

/// This snippet is used to create ./check script
String get installSnippet => '''
#!/usr/bin/env bash

dart pub global activate --source path .
''';
