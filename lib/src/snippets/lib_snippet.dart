// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:recase/recase.dart';

/// The snippet for the lib/dart file
String libSnippet({required String packageName}) {
  final packageNameSnakeCase = packageName.snakeCase;

  return '''
library;

export 'src/$packageNameSnakeCase.dart';
'''
      .trim();
}
