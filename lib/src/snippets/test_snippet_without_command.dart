// @license
// Copyright (c) 2019 - 2024 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:recase/recase.dart';

/// The snippet for the test file
String testSnippetWithoutCommand({required String packageName}) {
  final packageNamePascalCase = packageName.pascalCase;
  final packageNameCamelCase = packageName.camelCase;
  final packageNameSnakeCase = packageName.snakeCase;

  return '''
import 'dart:io';

import 'package:$packageNameSnakeCase/$packageNameSnakeCase.dart';
import 'package:test/test.dart';

void main() {
  group('$packageNamePascalCase()', () {

    group('foo()', () {
      test('should return foo', () async {
        final $packageNameCamelCase = $packageNamePascalCase();
        expect($packageNameCamelCase.foo(), 'foo');
      });
    });
  });
}

'''
      .trim();
}
